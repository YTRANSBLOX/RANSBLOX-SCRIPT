-- =====================================================================
-- RobotFighter_Logic.lua  (LOGIC ONLY, zero GUI / zero WindUI)
--
-- Usage:
--   local Core, err = loadstring(game:HttpGet("URL_LOGIC"))()
--   if not Core then ... show err ... return end
--
-- GUI -> Core:   Core.SetFeature(id, bool), Core.SetRarity(slot, list), dst.
-- Core -> GUI:   Core.OnStatus, Core.OnNotify, Core.OnFeatureChanged (callback).
-- =====================================================================

local HUB_NAME = "Robot Fighter"

local Core = {
    Name = HUB_NAME,
    Version = "2.1-quest-idle", -- GUI shows this so you can tell which logic is really running
    Features = {},   -- id -> feature table { id, title, on, busy }

    -- hooks (GUI overrides these after loading the module)
    OnStatus         = function(text) end,
    OnNotify         = function(content, duration) end,
    OnFeatureChanged = function(id, on) end, -- only for Fight<->Train exclusion (GUI mirrors the switch)
}

local function setStatus(text) Core.OnStatus(text) end

-- CONNECTION MANAGER
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- GAME (Robot Fighter)
-- =====================================================================
local Players     = game:GetService("Players")
local RS          = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LP          = Players.LocalPlayer
local alive       = true

local Remotes = RS:WaitForChild("Remotes", 10)
if not (Remotes and Remotes:FindFirstChild("RobotCommandEvent")) then
    return nil, "Robot Fighter not found. This script only works in Robot Fighter."
end

local Shared = RS:FindFirstChild("Shared")

-- remote shortcuts
local E = {}
for _, n in ipairs({
    "RobotCommandEvent", "FightSpeedEvent", "CarryEvent", "WiringEvent",
    "RobotInventoryEvent", "SignButtonEvent", "QuestEvent", "CrateEvent", "RebirthEvent",
    "PvpTournamentEvent",
}) do
    E[n] = Remotes:FindFirstChild(n)
end

local function fire(name, ...)
    local r = E[name]
    if r then pcall(r.FireServer, r, ...) end
end

local function requireShared(name)
    local okR, mod = pcall(function() return require(Shared:WaitForChild(name, 5)) end)
    return okR and mod or nil
end
local DealerConfig     = requireShared("DealerConfig")
local LuckConfig       = requireShared("LuckConfig")
local FightStartConfig = requireShared("FightStartConfig")

-- ---------- helpers ----------
local function hrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function myPlot()
    local plots = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Plots")
    if not plots then return nil end
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == LP.UserId then return p end
    end
end

local function posOf(inst)
    if inst:IsA("Attachment") then return inst.WorldPosition end
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") then return inst:GetPivot().Position end
end

-- prompts that look like paid / Robux actions are never pressed
local PAID_WORDS = { "robux", "skip", "pass", "premium", "vip", "rbx", "r$" }
local function isPaid(pr)
    local s = (pr.Name .. " " .. pr.ActionText .. " " .. pr.ObjectText):lower()
    for _, w in ipairs(PAID_WORDS) do
        if s:find(w, 1, true) then return true end
    end
    return false
end

local function findPrompt(root, name, needEnabled)
    if not root then return nil end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ProximityPrompt") and (not name or d.Name == name) and (not needEnabled or d.Enabled) and not isPaid(d) then
            return d
        end
    end
end

local function resetCamera()
    pcall(function()
        local cam = workspace.CurrentCamera
        cam.CameraType = Enum.CameraType.Custom
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
    end)
end

-- teleport next to a position, run fn, then go back to where you were
local allowTP = true
local tpLock = false
local function withVisit(pos, fn)
    local root = hrp()
    if not root then return false end
    if not allowTP or (root.Position - pos).Magnitude <= 10 then
        return pcall(fn)
    end
    while tpLock and alive do task.wait(0.1) end
    tpLock = true
    local okV, result = pcall(function()
        local home = root.CFrame
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.25)
        local ok2 = pcall(fn)
        task.wait(0.1)
        local r2 = hrp()
        if r2 then r2.CFrame = home end
        return ok2
    end)
    tpLock = false
    return okV and result
end

local function press(pr)
    if not (pr and pr.Parent and pr.Enabled) or isPaid(pr) then return false end
    local pos = posOf(pr.Parent)
    if not pos then return false end
    return withVisit(pos, function() fireproximityprompt(pr) end)
end

-- run fn while holding the teleport lock (always released, even on error)
local function withLock(fn)
    while tpLock and alive do task.wait(0.1) end
    tpLock = true
    local okL, res = pcall(fn)
    tpLock = false
    return okL and res
end

local function readRobots()
    local raw = LP:GetAttribute("RobotInventory")
    if type(raw) ~= "string" then return {} end
    local okJ, data = pcall(HttpService.JSONDecode, HttpService, raw)
    return (okJ and type(data) == "table") and data or {}
end

-- ---------- feature runner ----------
-- Every feature has TWO layers:
--   f.on = what the user picked in the GUI (the toggle). ONLY the GUI changes this.
--   f.ov = temporary overrides from Quest Mode / Tournament (true / false / nil).
-- The loop runs while isActive(f). Overrides never touch f.on, so the GUI switches
-- stay exactly where the user left them, and the user's choice comes back by itself
-- as soon as the override is cleared.
local Features = Core.Features
local Hooks = {} -- id -> function(active), called when a feature really starts / stops

local function isActive(f)
    local o = f.ov
    if o.tourney ~= nil then return o.tourney end
    if o.quest ~= nil then return o.quest end
    return f.on
end

local function refresh(f)
    local a = isActive(f)
    if a == f.active then return end
    f.active = a
    local h = Hooks[f.id]
    if h then h(a) end
end

local function setOverride(source, id, val)
    local f = Features[id]
    if not f or f.ov[source] == val then return end
    f.ov[source] = val
    refresh(f)
end

local function clearOverrides(source)
    for _, f in pairs(Features) do
        if f.ov[source] ~= nil then
            f.ov[source] = nil
            refresh(f)
        end
    end
end

local function newFeature(id, title)
    local f = { id = id, title = title, on = false, active = false, ov = {}, busy = false }
    Features[id] = f
    return f
end

-- id    : key used by the GUI (Core.SetFeature("Pull", true))
-- title : human label used in status text (nil = no status message)
local function feature(id, title, every, step)
    local f = newFeature(id, title)
    task.spawn(function()
        while alive do
            task.wait(every)
            if isActive(f) and not f.busy then
                f.busy = true
                local okS, err = pcall(step)
                if not okS then warn("[" .. HUB_NAME .. "] " .. id .. ": " .. tostring(err)) end
                f.busy = false
            end
        end
    end)
    return f
end

-- ---------- rarity + parts (shared by Pull / Buy / Build) ----------
-- Same order the game uses (RarityConfig.Order)
local RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Event", "Legendary", "Mythic", "Exotic", "Apex" }
Core.RARITIES = RARITIES

-- the 3 slots on the Charging Bed: Head, Upper (body), Lower (legs)
local SLOTS = { "Head", "Upper", "Lower" }
Core.SLOTS = SLOTS

-- rarities the user wants to buy, per bed slot (all selected by default)
local selRarity = {}
for _, slot in ipairs(SLOTS) do
    selRarity[slot] = {}
    for _, r in ipairs(RARITIES) do selRarity[slot][r] = true end
end

-- rarities the user wants stored on the Parts Shelf instead of built (none by default)
local selStoreRarity = {}
local storeF = newFeature("Store", "Auto Store Part") -- flag only, no loop

-- the game stores the part rarity as an attribute "Rarity" on the plate
local function plateRarity(p)
    local r = p:GetAttribute("Rarity")
    if r then return tostring(r) end
    for _, d in ipairs(p:GetDescendants()) do
        local dr = d:GetAttribute("Rarity")
        if dr then return tostring(dr) end
    end
    return nil
end

-- which slot a plate belongs to (attribute "PartType": Head / Upper / Lower)
local function plateSlot(p)
    local t = p:GetAttribute("PartType")
    return t and tostring(t) or nil
end

-- the part model currently on the bed for a slot (nil = slot is empty)
local function placedPart(slot)
    local plot = myPlot()
    local bed = plot and plot:FindFirstChild("ChargingBed")
    local placed = bed and bed:FindFirstChild("PlacedParts")
    return placed and placed:FindFirstChild(slot)
end

-- a plate is wanted when its rarity is selected, AND (its bed slot is still empty
-- OR it's going to be stored on the shelf instead of built, so the bed doesn't matter)
local function plateWanted(p)
    local rarity = plateRarity(p)
    local slot = plateSlot(p)
    if not (rarity and slot and selRarity[slot] and selRarity[slot][rarity]) then return false end
    local goingToStore = isActive(storeF) and selStoreRarity[rarity]
    if not goingToStore and placedPart(slot) then return false end
    return true
end

-- ---------- Parts Shelf storage (PartShelf.Stored / PartShelf.StoreAnchors) ----------
local function storeFolder()
    local plot = myPlot()
    local shelf = plot and plot:FindFirstChild("PartShelf")
    return shelf and shelf:FindFirstChild("Stored")
end

local function storeAnchorsRoot()
    local plot = myPlot()
    local shelf = plot and plot:FindFirstChild("PartShelf")
    return shelf and shelf:FindFirstChild("StoreAnchors")
end

local function storeCapacity()
    return tonumber(LP:GetAttribute("StorageSlots")) or 0
end

local function storeUsed()
    local f = storeFolder()
    return f and #f:GetChildren() or 0
end

local function storeIsFull()
    return storeUsed() >= storeCapacity()
end

-- true while you hold a part in your hands
local function carryingPart()
    local v = LP:GetAttribute("CarryingPart")
    return v ~= nil and v ~= false and v ~= ""
end

-- true while one of YOUR plates that we want is still lying there
local function wantedPlateWaiting()
    local junk = workspace.Map:FindFirstChild("Junkyard")
    local plates = junk and junk:FindFirstChild("ActivePlates")
    if not plates then return false end
    for _, p in ipairs(plates:GetChildren()) do
        if p:GetAttribute("FoundBy") == LP.UserId then
            if plateWanted(p) then return true end
        end
    end
    return false
end

-- ---------- STEP 1: gacha pull ----------
-- Parks you next to the lever when it starts (and stays there, no teleport back).
-- Pauses while a wanted part still has to be bought and placed on the bed.
local buyF -- assigned in STEP 2
local pullPaused = false
local pullF = feature("Pull", "Auto Pull", 1.5, function()
    local plot = myPlot()
    if not plot then return end

    -- pause: a wanted part is waiting / in your hands
    if buyF and isActive(buyF) and (carryingPart() or wantedPlateWaiting()) then
        if not pullPaused then
            pullPaused = true
            setStatus("Got a wanted part. Pull paused until it's bought and placed")
        end
        return
    end
    pullPaused = false

    local pr = findPrompt(plot:FindFirstChild("GachaPillar"), "PullPrompt", true)
    if not pr then return end

    local pos = posOf(pr.Parent)
    local root = hrp()
    if not (pos and root) then return end

    -- walk up to the lever once and stay there
    if allowTP and (root.Position - pos).Magnitude > 5 then
        withLock(function()
            local r2 = hrp()
            if r2 then r2.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
            task.wait(0.3)
        end)
    end

    if pr.Enabled and (hrp() and (hrp().Position - pos).Magnitude <= 6.5) then
        fireproximityprompt(pr)
        setStatus("Pulled the gacha lever")
    end
end)

-- ---------- STEP 2: buy wanted parts, insert them on the bed ----------
-- enabled "insert" prompt on the Charging Bed (swap prompts are never pressed)
local function bedPrompt()
    local plot = myPlot()
    local bed = plot and plot:FindFirstChild("ChargingBed")
    if not bed then return nil end
    for _, d in ipairs(bed:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and not isPaid(d) then
            local a = d.ActionText:lower()
            if not a:find("swap", 1, true) and (d.Name == "PlacePartPrompt" or a:find("insert", 1, true)) then
                return d
            end
        end
    end
end

local skipped = setmetatable({}, { __mode = "k" }) -- plates already reported as skipped
local noSlotShown, placeKey, placeTries = false, nil, 0
local storageFullWarned = false

buyF = feature("Buy", "Auto Buy Parts", 1.5, function()
    -- 1) holding a part -> store it (if wanted) or insert it on the bed
    if carryingPart() then
        local carryRarity = tostring(LP:GetAttribute("CarryingRarity"))
        local key = tostring(LP:GetAttribute("CarryingPart")) .. "|" .. carryRarity
        if key ~= placeKey then
            placeKey = key
            placeTries = 0
            storageFullWarned = false
        end

        -- try the Parts Shelf first if this rarity is selected for storage
        if isActive(storeF) and selStoreRarity[carryRarity] then
            if storeIsFull() then
                if not storageFullWarned then
                    storageFullWarned = true
                    setStatus("Storage full (" .. storeUsed() .. "/" .. storeCapacity() .. "). Placing " .. carryRarity .. " on bed instead")
                end
                -- fall through to the normal bed logic below
            else
                local sp = findPrompt(storeAnchorsRoot(), "StorePrompt", true)
                if sp then
                    noSlotShown = false
                    if placeTries >= 5 then
                        setStatus("Couldn't store the part after 5 tries")
                        return
                    end
                    placeTries += 1
                    if press(sp) then
                        setStatus("Stored " .. carryRarity .. " part (" .. storeUsed() .. "/" .. storeCapacity() .. ")")
                        task.wait(0.6)
                    end
                    return
                end
                -- no store anchor free right now (e.g. mid-animation) - try again next tick
                return
            end
        end

        local pr = bedPrompt()
        if pr then
            noSlotShown = false
            if placeTries >= 5 then
                setStatus("Couldn't place the part after 5 tries")
                return
            end
            placeTries += 1
            if press(pr) then
                setStatus("Inserted the part on the Charging Bed")
                task.wait(0.6)
            end
        elseif not noSlotShown then
            noSlotShown = true
            setStatus("Holding a part. Place or throw it yourself")
        end
        return
    end
    noSlotShown, placeKey, placeTries, storageFullWarned = false, nil, 0, false

    -- 2) buy parts whose rarity you selected
    local junk = workspace.Map:FindFirstChild("Junkyard")
    local plates = junk and junk:FindFirstChild("ActivePlates")
    if not plates then return end
    local money = tonumber(LP:GetAttribute("Money")) or math.huge
    for _, p in ipairs(plates:GetChildren()) do
        if p:GetAttribute("FoundBy") == LP.UserId then
            local rarity = plateRarity(p)
            local slot = plateSlot(p)
            if not plateWanted(p) then
                if not skipped[p] then
                    skipped[p] = true
                    local reason
                    if not (slot and selRarity[slot] and rarity and selRarity[slot][rarity]) then
                        reason = "rarity not selected for this slot"
                    else
                        reason = "bed slot already has a " .. tostring(slot or "part")
                    end
                    setStatus("Skipped " .. tostring(rarity or "?") .. " " .. tostring(slot or "part") .. " (" .. reason .. ")")
                end
            else
                local price = tonumber(p:GetAttribute("Price")) or 0
                if price <= money then
                    local pr = findPrompt(p, "BuyPartPrompt", true)
                    if pr and press(pr) then
                        money -= price
                        setStatus("Bought " .. tostring(p:GetAttribute("DisplayName") or p.Name) .. " (" .. tostring(rarity or "?") .. " " .. tostring(plateSlot(p) or "part") .. ")")
                        break -- one part at a time: place it first
                    end
                end
            end
        end
    end
end)

-- ---------- STEP 3: robot build: power station -> wiring -> boot -> name ----------
-- how many of the 3 slots have a part on the Charging Bed.
-- The Power lever prompt is always enabled, so we have to check this ourselves.
local function bedCount()
    local n = 0
    for _, s in ipairs(SLOTS) do
        if placedPart(s) then n += 1 end
    end
    return n
end

local lastBedCount = -1
local wiringSince, bootSince, lastPower, renameAt = nil, nil, 0, 0
local robotFullNotified = false
local buildF = feature("Build", "Auto Build Robot", 1, function()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end

    -- wiring minigame: wait 3s, then finish it
    local wg = pg:FindFirstChild("WiringGui")
    if wg and wg.Enabled then
        wiringSince = wiringSince or os.clock()
        if os.clock() - wiringSince >= 3 then
            fire("WiringEvent", "Done")
            wg.Enabled = false
            resetCamera()
            wiringSince = nil
            setStatus("Wiring finished")
        end
        return
    end
    wiringSince = nil

    -- boot minigame: wait 2.5s, then finish it
    local bg = pg:FindFirstChild("BootGui")
    if bg and bg.Enabled then
        bootSince = bootSince or os.clock()
        if os.clock() - bootSince >= 2.5 then
            fire("WiringEvent", "BootDone")
            bg.Enabled = false
            LP:SetAttribute("BootActive", nil)
            resetCamera()
            bootSince = nil
            setStatus("Boot finished")
        end
        return
    end
    bootSince = nil

    -- name the new robot
    local ng = pg:FindFirstChild("RobotNameGui")
    local nroot = ng and ng:FindFirstChild("Root")
    if ng and ng.Enabled and nroot and nroot.Visible then
        if os.clock() - renameAt > 5 then
            renameAt = os.clock()
            local best
            for _, r in ipairs(readRobots()) do
                if type(r.Id) == "number" and (not best or r.Id > best) then best = r.Id end
            end
            if best then
                fire("RobotInventoryEvent", "Rename", best, "Bot" .. best)
                setStatus("Named the new robot")
            end
        end
        return
    end

    -- pull the Power Station lever to start a new robot
    if os.clock() - lastPower >= 4 then
        local limit = tonumber(LP:GetAttribute("RobotLimit")) or 5
        if #readRobots() >= limit then
            setStatus("Robot storage is full")
            if not robotFullNotified then
                robotFullNotified = true
                Core.OnNotify("Robot storage is full. Make room before it can build another robot.", 4)
            end
            return
        end
        robotFullNotified = false
        local plot = myPlot()

        -- wait until all 3 slots are filled. No teleport while waiting.
        local have = bedCount()
        if have ~= lastBedCount then
            lastBedCount = have
            setStatus("Waiting for parts (" .. have .. "/3)")
        end
        if have < 3 then return end

        local pr = plot and findPrompt(plot:FindFirstChild("PowerStation"), nil, true)
        if pr and press(pr) then
            lastPower = os.clock()
            lastBedCount = -1
            setStatus("Pulled the Power Station lever")
        end
    end
end)

-- ---------- fighting ----------
local roundMode, speedWanted = "Highest", nil
local function fighting() return LP:GetAttribute("Fighting") == true end

local function pickRound()
    if not FightStartConfig then return nil end
    local okU, list = pcall(FightStartConfig.Unlocked, LP)
    if not (okU and type(list) == "table" and #list > 0) then return nil end
    if roundMode == "Round 1" then return 1 end
    local best
    for _, v in pairs(list) do
        if type(v) == "number" and (not best or v > best) then best = v end
    end
    return best
end

local fightF = feature("Fight", "Auto Fight", 2, function()
    if speedWanted and LP:GetAttribute("FightSpeed") ~= speedWanted then
        fire("FightSpeedEvent", "Set", speedWanted)
    end
    if LP:GetAttribute("AutoFight") ~= true then
        fire("RobotCommandEvent", "AutoFight", true)
    end
    if not fighting() and LP:GetAttribute("RobotCommand") ~= "ToArena" then
        local rd = pickRound()
        if rd then fire("RobotCommandEvent", "Fight", rd) else fire("RobotCommandEvent", "Fight") end
        setStatus("Starting a fight")
    end
end)

local trainF = feature("Train", "Auto Train", 3, function()
    if fighting() or isActive(fightF) then return end
    local cmd = LP:GetAttribute("RobotCommand")
    if cmd ~= "Train" and cmd ~= "ToArena" then
        fire("RobotCommandEvent", "Train")
        setStatus("Robot is training")
    end
end)

-- ---------- money-safe buying (never press a buy button unless the price is confirmed affordable) ----------
local function parseMoneyText(s)
    if type(s) ~= "string" then return nil end
    s = s:gsub("[%$,]", ""):gsub("%s+", "")
    local suffix = s:match("[%a]+$")
    local mult = 1
    if suffix then
        local m = { K = 1e3, M = 1e6, B = 1e9, T = 1e12 }
        local up = suffix:upper()
        if not m[up] then return nil end
        mult = m[up]
        s = s:sub(1, #s - #suffix)
    end
    local n = tonumber(s)
    return n and math.floor(n * mult) or nil
end

local COST_ATTRS = { "Price", "Cost", "NextCost", "UpgradeCost", "BuyCost", "TotalCost", "Amount" }
local function readCost(inst)
    if not inst then return nil end
    for _, a in ipairs(COST_ATTRS) do
        local n = tonumber(inst:GetAttribute(a))
        if n then return n end
    end
    for _, d in ipairs(inst:GetDescendants()) do
        for _, a in ipairs(COST_ATTRS) do
            local n = tonumber(d:GetAttribute(a))
            if n then return n end
        end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local n = parseMoneyText(d.Text)
            if n then return n end
        end
    end
    return nil
end

-- true only when we can CONFIRM the price and you can afford it.
-- if the price can't be read at all, it refuses to press, no guessing, no forcing a buy.
local costUnknownWarned = {}
local function canAffordSign(label, board, btn)
    local money = tonumber(LP:GetAttribute("Money"))
    local cost = readCost(btn) or readCost(board)
    if not money or not cost then
        if not costUnknownWarned[label] then
            costUnknownWarned[label] = true
            setStatus(label .. ": can't read the price yet, skipping to be safe")
        end
        return false
    end
    return cost <= money
end

-- ---------- upgrades (signs on the plot) ----------
local SIGNS = { ["Luck"] = "LuckSign", ["Punching Bag"] = "BagSign", ["Storage"] = "StorageSign", ["Shredder"] = "ShredderSign" }
local upgradeSel, buyMax = { ["Luck"] = true }, true
local upgradeF = feature("Upgrade", "Auto Upgrade", 8, function()
    local plot = myPlot()
    if not plot then return end
    for label, signName in pairs(SIGNS) do
        if upgradeSel[label] then
            local sign = plot:FindFirstChild(signName, true)
            local board = sign and sign:FindFirstChild("Board")
            local btn = sign and (buyMax and sign:FindFirstChild("MaxButton") or nil) or nil
            btn = btn or (sign and sign:FindFirstChild("BuyButton"))
            if btn and board then
                if canAffordSign(label, board, btn) then
                    local pressed = false
                    withVisit(board.Position, function()
                        -- re-check right at the moment of pressing: money/price can
                        -- shift during the walk-over, so the first check alone isn't enough
                        if canAffordSign(label, board, btn) then
                            pressed = true
                            fire("SignButtonEvent", "Press", btn)
                        end
                    end)
                    if pressed then
                        setStatus("Upgrade: " .. label)
                        task.wait(0.6) -- give Money time to sync before checking the next sign
                    else
                        setStatus(label .. ": price changed, skipping this pass")
                    end
                else
                    setStatus(label .. ": not enough money yet")
                end
            end
        end
    end
end)

-- ---------- quests ----------
local claimedQ = {}
local questF = feature("ClaimQuests", nil, 5, function()
    local raw = LP:GetAttribute("Quests")
    if type(raw) ~= "string" then return end
    local okJ, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not (okJ and type(data) == "table" and type(data.q) == "table") then return end
    for _, q in ipairs(data.q) do
        local key = tostring(data.d) .. ":" .. tostring(q.s)
        if not claimedQ[key] and (tonumber(q.p) or 0) >= (tonumber(q.t) or math.huge) then
            claimedQ[key] = true
            fire("QuestEvent", "Claim", q.s)
            setStatus("Claimed a quest reward")
        end
    end
end)

-- ---------- crates ----------
local function crateTool()
    for _, holder in ipairs({ LP:FindFirstChildOfClass("Backpack"), LP.Character }) do
        if holder then
            for _, t in ipairs(holder:GetChildren()) do
                if t:IsA("Tool") and t:GetAttribute("CrateType") then return t end
            end
        end
    end
end
local crateF = feature("Crate", "Auto Open Crates", 3, function()
    if LP:GetAttribute("CrateOpening") then return end
    local t = crateTool()
    if not t then return end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and t.Parent ~= LP.Character then
        hum:EquipTool(t)
        task.wait(0.4)
    end
    fire("CrateEvent", "Open", t:GetAttribute("CrateType"))
    setStatus("Opening a crate")
end)

-- ---------- rebirth ----------
-- Only the free "Rebirth" trigger is ever fired here (no Robux "Skip"). A guard
-- blocks a second FireServer until the server confirms "Done", so a slow or
-- flickering BotRound/Rebirths attribute update can't cause a double-fire.
local rebirthPending = false
if E.RebirthEvent then
    bind(E.RebirthEvent.OnClientEvent, function(msg)
        if msg == "Done" then
            rebirthPending = false
            setStatus("Rebirth done")
        end
    end)
end
local rebirthF = feature("Rebirth", "Auto Rebirth", 5, function()
    if not LuckConfig or rebirthPending then return end
    local okR, need = pcall(LuckConfig.RoundsFor, LP:GetAttribute("Rebirths") or 0)
    if not (okR and need) then return end
    local done = math.max(0, (LP:GetAttribute("BotRound") or 1) - 1)
    if done >= need then
        rebirthPending = true
        fire("RebirthEvent", "Rebirth")
        setStatus("Rebirth sent")
        task.delay(10, function() rebirthPending = false end) -- fallback kalau "Done" nggak pernah kekirim
    end
end)

-- ---------- scrap ----------
-- How the game does it (from its own client scripts): scrap models live in Map.GrassScrap.
-- ScrapClient disables the model's ProximityPrompts as soon as the attribute FlyTo is set, and the
-- tutorial checks FlyTo == your UserId, so that is the pickup signal. Scrap with ReservedFor of another
-- player is not yours. Carry limit is 10 (50 with the Big Scrap Bag pass), then you shred it at the
-- Shredder on your plot.
local scrapCount, scrapFails = 0, 0
local scrapInit, lastFailTarget = false, nil

local function scrapCap()
    return LP:GetAttribute("HasBigScrapBag") and 50 or 10
end

-- how much scrap you carry. The game keeps it in the player attribute "Scrap" (a JSON string,
-- "[]" when the bag is empty). Handles {"Metal":3,"Gold":1} style and list style. nil = not exposed.
local function readBag()
    local raw = LP:GetAttribute("Scrap")
    if type(raw) ~= "string" then return nil end
    local okJ, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not (okJ and type(data) == "table") then return nil end
    local isDict = false
    for k in pairs(data) do
        if type(k) ~= "number" then isDict = true break end
    end
    local total = 0
    if isDict then
        for _, v in pairs(data) do total += tonumber(v) or 0 end
    else
        for _, v in ipairs(data) do
            if type(v) == "table" then
                total += tonumber(v.n or v.c or v.count or v.amount) or 1
            elseif type(v) == "number" then
                total += v
            else
                total += 1
            end
        end
    end
    return total
end

-- fire the prompt, and hold it too when it has a hold time
local function usePrompt(pr)
    pcall(fireproximityprompt, pr)
    if (pr.HoldDuration or 0) > 0 then
        pcall(function()
            pr:InputHoldBegin()
            task.wait(pr.HoldDuration + 0.1)
            pr:InputHoldEnd()
        end)
    end
end

-- same pick as the game's own nearestScrap: scrap reserved for you first, then the closest
local function nearestScrap()
    local folder = workspace.Map:FindFirstChild("GrassScrap")
    local root = hrp()
    if not (folder and root) then return nil end
    local best, bestMine, bestD
    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") and m.PrimaryPart and not m:GetAttribute("FlyTo") then
            local rf = m:GetAttribute("ReservedFor")
            if rf == nil or rf == LP.UserId then
                local mine = rf == LP.UserId
                local d = (m:GetPivot().Position - root.Position).Magnitude
                if not best or (mine and not bestMine) or (mine == bestMine and d < bestD) then
                    best, bestMine, bestD = m, mine, d
                end
            end
        end
    end
    return best, bestD
end

-- scrap items in your hotbar / hands (used only to check that the shred worked)
local function scrapToolCount()
    local n = 0
    for _, holder in ipairs({ LP:FindFirstChildOfClass("Backpack"), LP.Character }) do
        if holder then
            for _, t in ipairs(holder:GetChildren()) do
                if t:IsA("Tool") and not t:GetAttribute("CrateType") then
                    local nm = t.Name:lower()
                    if nm:find("scrap", 1, true) or nm:find("metal", 1, true)
                        or nm:find("gold", 1, true) or nm:find("diamond", 1, true) then
                        n += 1
                    end
                end
            end
        end
    end
    return n
end

-- the "Shred Scrap" prompt on your Shredder (matched by its text), never a Robux one
local function shredPrompt()
    local plot = myPlot()
    local sh = plot and plot:FindFirstChild("Shredder")
    if not sh then return nil end
    local shred, any
    for _, d in ipairs(sh:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled and not isPaid(d) then
            local txt = (d.Name .. " " .. d.ActionText .. " " .. d.ObjectText):lower()
            if txt:find("shred", 1, true) and txt:find("scrap", 1, true) then return d end
            if txt:find("shred", 1, true) then shred = shred or d end
            any = any or d
        end
    end
    return shred or any
end

-- go to the Shredder on your plot and sell your scrap (no teleport back)
local function shredScrap()
    if carryingPart() then
        setStatus("Holding a part. Put it away first, then shred")
        return false
    end
    local pr = shredPrompt()
    local pos = pr and posOf(pr.Parent)
    if not pos then return false end
    local root = hrp()
    if not allowTP and (not root or (root.Position - pos).Magnitude > 10) then return false end
    return withLock(function()
        local r = hrp()
        if r and allowTP then r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
        task.wait(0.4)
        for _ = 1, 3 do
            usePrompt(pr)
            task.wait(0.5)
        end
        return true
    end)
end

-- Farm loop: read the bag when you turn it on (full -> sell first), then collect until the bag is
-- full, sell everything at the Shredder, and keep farming. It never sells per scrap.
local function sellScrap()
    if shredScrap() then
        setStatus("Shredded scrap")
        scrapCount, scrapFails, lastFailTarget = 0, 0, nil
        return true
    end
    return false
end

local scrapF = feature("Scrap", "Auto Farm Scrap", 0.5, function()
    -- 1) just turned on: look at the bag first
    if not scrapInit then
        scrapInit = true
        local have = readBag()
        if have and have >= scrapCap() then
            setStatus("Bag is full (" .. have .. "), selling first")
            sellScrap()
            return
        end
    end

    -- 2) bag full -> sell
    local carried = readBag() or scrapCount
    if carried >= scrapCap() then
        setStatus("Bag is full (" .. carried .. "/" .. scrapCap() .. "), selling")
        sellScrap()
        return
    end

    -- 3) collect. Grass empty -> just wait, it respawns.
    local best, dist = nearestScrap()
    if not best then return end
    if not allowTP and dist > 10 then return end
    local bagBefore = readBag()

    -- stand on the scrap and press its prompt until it is yours (FlyTo = your UserId)
    local got = false
    withLock(function()
        local r = hrp()
        if r and allowTP then r.CFrame = CFrame.new(best:GetPivot().Position) end
        task.wait(0.2)
        local t0 = os.clock()
        while alive and best.Parent and os.clock() - t0 < 2 do
            local fly = best:GetAttribute("FlyTo")
            if fly then
                got = (fly == LP.UserId)
                break
            end
            for _, d in ipairs(best:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled and not isPaid(d) then usePrompt(d) end
            end
            task.wait(0.2)
        end
    end)

    if got then
        scrapCount += 1
        scrapFails, lastFailTarget = 0, nil
        -- let the game add it to your bag before we look again
        if bagBefore then
            local t1 = os.clock()
            while alive and os.clock() - t1 < 1.2 and (readBag() or 0) <= bagBefore do task.wait(0.1) end
        end
        setStatus("Picked up scrap (" .. tostring(readBag() or scrapCount) .. "/" .. scrapCap() .. ")")
    else
        -- two different scrap in a row that can't be picked up while carrying scrap = bag is full
        if best ~= lastFailTarget then
            scrapFails += 1
            lastFailTarget = best
        end
        setStatus("Scrap not picked up")
        if scrapFails >= 2 then
            local c = readBag()
            local carrying
            if c then carrying = c > 0 else carrying = scrapCount > 0 or scrapToolCount() > 0 end
            if carrying then
                setStatus("Can't pick up more, selling")
                sellScrap()
            end
        end
    end
end)

-- ---------- auto quest mode ----------
-- which automation makes progress on each quest kind (from QuestConfig.KINDS)
local QUEST_KIND_TASK = {
    WinRounds  = "fight",
    EarnMoney  = "fight",
    TrainHits  = "train",
    Spin       = "pull",
    PickScrap  = "scrap",
    ShredScrap = "scrap",
    -- Playtime needs no action, it ticks on its own
}

-- which tasks today's unfinished quests still need
local function activeQuestTasks()
    local raw = LP:GetAttribute("Quests")
    if type(raw) ~= "string" then return {} end
    local okJ, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not (okJ and type(data) == "table" and type(data.q) == "table") then return {} end
    local need = {}
    for _, q in ipairs(data.q) do
        local done = q.c == true or (tonumber(q.p) or 0) >= (tonumber(q.t) or math.huge)
        local taskName = (not done) and q.k and QUEST_KIND_TASK[q.k]
        if taskName then need[taskName] = true end
    end
    return need
end

-- Quest Mode only PAUSES / FORCES features through overrides. The GUI toggles are never touched,
-- and when Quest Mode is turned off every feature goes back to what the user had picked.
local QUEST_PAUSED = { "Buy", "Store", "Build", "Upgrade", "Crate", "Rebirth" }

local questIdleShown = false
local function runQuestMode()
    local need = activeQuestTasks()

    -- No quest needs anything (none today, all done, or data not readable yet):
    -- do NOT pause anything. Everything runs exactly like the user's toggles say,
    -- Tournament included. Only keep claiming rewards.
    if not (need.train or need.fight or need.pull or need.scrap) then
        clearOverrides("quest")
        setOverride("quest", "ClaimQuests", true)
        if not questIdleShown then
            questIdleShown = true
            setStatus("No quest to do, running your normal toggles")
        end
        return
    end
    questIdleShown = false

    -- there IS quest work: everything that isn't needed to finish quests is paused
    for _, id in ipairs(QUEST_PAUSED) do setOverride("quest", id, false) end

    -- Fight and Train are mutually exclusive; finish TrainHits first, then Fight/EarnMoney.
    -- But never yank AutoFight off while a match is already running (that cancels the fight
    -- in-game) - let the current fight finish naturally, then switch over to Train.
    -- Pull/Scrap are independent of Fight/Train, so they're always evaluated below,
    -- including mid-fight, instead of being frozen until the fight ends.
    if fighting() then
        setOverride("quest", "Fight", true)
        setOverride("quest", "Train", false)
    else
        setOverride("quest", "Train", need.train == true)
        setOverride("quest", "Fight", (not need.train) and need.fight == true)
    end
    setOverride("quest", "Pull", need.pull == true)
    setOverride("quest", "Scrap", need.scrap == true)
    setOverride("quest", "ClaimQuests", true) -- always keep claiming finished quests
end

-- Polled every 1s (fast) as a baseline, PLUS re-run instantly the moment a fight
-- actually ends. fightF itself polls every 2s and will happily queue a brand new
-- match the instant "Fighting" flips to false if AutoFight is still true - if Quest
-- Mode only reacted on its own slow timer, there was a window for a stray extra
-- fight to start (and the character to sit there fighting) before the switch to
-- Train/Scrap landed. Reacting on the attribute change itself closes that gap.
local questModeF = feature("QuestMode", "Auto Quest Mode", 1, runQuestMode)
bind(LP:GetAttributeChangedSignal("Fighting"), function()
    if isActive(questModeF) then runQuestMode() end
end)

-- ---------- auto tournament (Underground Tournament / PvP) ----------
-- ReplicatedStorage.PvpTournament:GetAttribute("Phase") drives the whole event:
-- "Join" = join window is open, anything else = closed / running / results.
local function tournamentPhase()
    local t = RS:FindFirstChild("PvpTournament")
    return t and t:GetAttribute("Phase")
end

-- true while we're signed up for or actively fighting in the tournament
local function inTournament()
    return LP:GetAttribute("PvpJoined") == true or LP:GetAttribute("PvP") == true
end

-- true only while this feature is holding Auto Fight paused (override, toggle stays untouched)
local pausedFightForTournament = false

local tourneyF = feature("Tournament", "Auto Tournament", 3, function()
    local phase = tournamentPhase()
    local joining = phase == "Join" or inTournament()

    if joining then
        -- the bot can't join while it's off fighting a normal PvE match, so pause that first
        pausedFightForTournament = true
        setOverride("tourney", "Fight", false)

        -- AutoFight=false only stops NEW fights from starting. A fight already in progress
        -- (or the robot walking to the Arena) keeps going unless we actually cancel it, the
        -- same way pressing the Retreat button in-game does.
        if not inTournament() and (fighting() or LP:GetAttribute("RobotCommand") == "ToArena") then
            fire("RobotCommandEvent", "Retreat")
            setStatus("Retreated from the current fight to join the tournament")
            return
        end

        if phase == "Join" and not inTournament() and not fighting() then
            fire("PvpTournamentEvent", "Join")
            setStatus("Joined the Underground Tournament")
        end
        return
    end

    -- tournament window closed and we're no longer in it -> release the pause,
    -- Auto Fight runs again only if the user's toggle (or Quest Mode) wants it
    if pausedFightForTournament then
        pausedFightForTournament = false
        setOverride("tourney", "Fight", nil)
        setStatus("Tournament's over, Auto Fight released")
    end
end)

-- =====================================================================
-- PUBLIC API (this is the only thing the GUI should touch)
-- =====================================================================

-- what has to happen when a feature REALLY starts / stops (whoever caused it)
Hooks.Scrap = function(active)
    if active then scrapInit = false end
end
Hooks.Fight = function(active)
    if not active then fire("RobotCommandEvent", "AutoFight", false) end
end
Hooks.Train = function(active)
    if active then fire("RobotCommandEvent", "AutoFight", false) end
end
Hooks.QuestMode = function(active)
    if not active then clearOverrides("quest") end
end
Hooks.Tournament = function(active)
    if not active then
        clearOverrides("tourney")
        pausedFightForTournament = false
    end
end

-- GUI toggle -> logic. This is the ONLY place that changes f.on.
function Core.SetFeature(id, on)
    local f = Features[id]
    if not f then return end
    on = on and true or false
    if f.on == on then return end
    f.on = on
    refresh(f)

    -- Fight and Train can't both be picked: switching one on drops the other one's toggle
    local other = on and ((id == "Fight" and "Train") or (id == "Train" and "Fight")) or nil
    local o = other and Features[other]
    if o and o.on then
        o.on = false
        refresh(o)
        Core.OnFeatureChanged(other, false) -- GUI mirrors the switch
    end

    if f.title then
        setStatus(on and (f.title .. " is on") or (f.title .. " is off"))
    end
end

-- what the user picked (the toggle)
function Core.IsOn(id)
    local f = Features[id]
    return f and f.on or false
end

-- what is really running right now (toggle + Quest/Tournament overrides)
function Core.IsActive(id)
    local f = Features[id]
    return f and isActive(f) or false
end

-- ---------- settings (GUI passes plain strings / arrays / numbers) ----------
local function toSet(list)
    local s = {}
    if type(list) == "table" then
        for _, v in ipairs(list) do s[tostring(v)] = true end
    end
    return s
end

-- slot: "Head" | "Upper" | "Lower"
function Core.SetRarity(slot, list)
    if selRarity[slot] then selRarity[slot] = toSet(list) end
end

function Core.SetStoreRarity(list) selStoreRarity = toSet(list) end
function Core.SetUpgrades(list)    upgradeSel = toSet(list) end
function Core.SetBuyMax(v)         buyMax = v and true or false end
function Core.SetAllowTP(v)        allowTP = v and true or false end
function Core.SetRound(mode)       roundMode = mode end -- "Highest" | "Round 1"

function Core.SetSpeed(n)
    speedWanted = tonumber(n)
    if speedWanted then fire("FightSpeedEvent", "Set", speedWanted) end
end

-- ---------- lifecycle ----------
function Core.IsAlive() return alive end

function Core.Unload()
    if not alive then return end
    alive = false
    for _, f in pairs(Features) do f.on = false end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
end

return Core
