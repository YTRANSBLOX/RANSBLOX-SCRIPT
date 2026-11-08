-- =====================================================================
-- Net a Fish — LOGIC MODULE
-- All remotes, state, and feature loops live here. Returns a single
-- module table `L` that gui.lua requires and drives entirely through
-- getters/setters + a few manual "do it now" functions, so every
-- reassignment from the GUI keeps the background loops in sync.
-- =====================================================================

local L = {}

-- Re-execute safety: unload the previous logic instance first (separate
-- from the GUI's own unload flag, since logic.lua can be re-required on
-- its own if gui.lua is reloaded while logic.lua's loadstring is cached)
if _G.NETAFISH_LOGIC_Unload then pcall(_G.NETAFISH_LOGIC_Unload) end

-- CONNECTION MANAGER
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end
L.Connections = Connections

-- =====================================================================
-- GAME (Net a Fish)
-- =====================================================================
local alive = true

-- Shared guard: true whenever we're actually confirmed inside Megalodon
-- Turret Mode (character anchored, camera scriptable). Declared up here,
-- ahead of every feature, so character-moving features (Collect, Place)
-- defined earlier in the file can check it without forward-reference
-- issues. Set by the Auto Turret feature further down.
local turretActive = false

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Remotes       = RS:WaitForChild("Remotes")
local ThrowNet      = Remotes:WaitForChild("ThrowNet")
local ReelIn        = Remotes:WaitForChild("ReelIn")
local CoolerAction  = Remotes:WaitForChild("CoolerAction")
local GetData       = Remotes:WaitForChild("GetData")
local DataUpdate    = Remotes:WaitForChild("DataUpdate")
local CollectPadReq = Remotes:WaitForChild("CollectPadReq")
local BuyItem       = Remotes:WaitForChild("BuyItem")
local RebirthRequest = Remotes:WaitForChild("RebirthRequest")
local RebirthDone    = Remotes:WaitForChild("RebirthDone")
local HelperAction   = Remotes:WaitForChild("HelperAction")
local SpearAction    = Remotes:WaitForChild("SpearAction")
local BoatAction     = Remotes:WaitForChild("BoatAction")
local Tackle         = Remotes:WaitForChild("Tackle")
local PotionsRemote  = Remotes:WaitForChild("Potions")
local BlackMarket    = Remotes:WaitForChild("BlackMarket")
local Contracts      = Remotes:WaitForChild("Contracts")
local ContractPing   = Remotes:WaitForChild("ContractPing")
local Challenge      = Remotes:WaitForChild("Challenge")
local ChallengePing  = Remotes:WaitForChild("ChallengePing")
local CurrentRemote  = Remotes:WaitForChild("Current")
local CurrentPing    = Remotes:WaitForChild("CurrentPing")

local FishingShared = require(RS:WaitForChild("FishingShared"))
L.FishingShared = FishingShared

local RARITY_NAMES = {}
for i, r in ipairs(FishingShared.Rarities) do
    RARITY_NAMES[i] = r.Name
end
L.RARITY_NAMES = RARITY_NAMES

local function money(n)
    n = math.floor(tonumber(n) or 0)
    local neg = n < 0
    if neg then n = -n end

    local suffix, divisor
    if n >= 1e15 then
        suffix, divisor = "Q", 1e15
    elseif n >= 1e12 then
        suffix, divisor = "T", 1e12
    elseif n >= 1e9 then
        suffix, divisor = "B", 1e9
    elseif n >= 1e6 then
        suffix, divisor = "M", 1e6
    elseif n >= 1e3 then
        suffix, divisor = "K", 1e3
    end

    local out
    if divisor then
        local scaled = n / divisor
        -- trims to at most 2 decimals, dropping trailing zeros (1.50K -> 1.5K, 2.00M -> 2M)
        out = (("%.2f"):format(scaled)):gsub("0+$", ""):gsub("%.$", "") .. suffix
    else
        out = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end

    return (neg and "-$" or "$") .. out
end
L.money = money

-- =====================================================================
-- DATA LAYER
-- =====================================================================
local function getPlayerData()
    local ok2, data = pcall(function()
        return GetData:InvokeServer()
    end)
    if ok2 and type(data) == "table" then
        return data
    end
    return nil
end
L.getPlayerData = getPlayerData

-- returns list of { kind = "Net"|"Upgrade"|"Helper"|"Spear", id = <tier number or upgrade id string>, cost = n }
-- for things currently in "buy" state for the given category name
-- ("Nets" | "Fishing" | "Market" -> FishingShared.Upgrades by Tab;
--  "Fisherman" -> FishingShared.Helper.Upgrades; "Spear Gun" -> FishingShared.Spear.Upgrades)
local function getBuyableUpgrades(tabName, data)
    local list = {}
    if not data then return list end

    if tabName == "Nets" then
        local nextTier = (data.NetTier or 1) + 1
        local netDef = FishingShared.Nets and FishingShared.Nets[nextTier]
        if netDef then
            local ok2, canBuy = pcall(FishingShared.NetRebirthOk, data, nextTier)
            if ok2 and canBuy then
                table.insert(list, { kind = "Net", id = nextTier, cost = netDef.Cost })
            end
        end
    elseif tabName == "Fisherman" then
        local upgrades = FishingShared.Helper and FishingShared.Helper.Upgrades
        for _, upgrade in ipairs(upgrades or {}) do
            local level = (data.Helper and data.Helper[upgrade.Id]) or 0
            if level < upgrade.Max then
                local ok2, canBuy = pcall(FishingShared.HelperLevelOk, data, upgrade, level + 1)
                if ok2 and canBuy then
                    local ok3, cost = pcall(FishingShared.HelperCost, upgrade.Id, level)
                    if ok3 then
                        table.insert(list, { kind = "Helper", id = upgrade.Id, cost = cost })
                    end
                end
            end
        end
    elseif tabName == "Boat" then
        local boatData = (type(data.Boat) == "table") and data.Boat or {}
        local hullLevel = boatData.Hull or 0
        local hullDef = FishingShared.Boat and FishingShared.Boat.Hulls and FishingShared.Boat.Hulls[hullLevel + 1]

        -- Hull is bought first and gates everything else: no boat yet, or a
        -- further hull tier is available and affordable/eligible
        if hullDef and (data.Rebirths or 0) >= hullDef.Rebirth and (data.Cash or 0) >= hullDef.Cost then
            table.insert(list, { kind = "BoatHull", id = "Hull", cost = hullDef.Cost })
        end

        -- Trawl/Engine/Sonar etc. only unlock once you actually own a hull,
        -- and each one's level is capped by BoatMaxLevel(hullLevel) on top
        -- of its own Max and the shared Boat.MaxLevel ceiling
        if hullLevel > 0 then
            for _, upgrade in ipairs(FishingShared.Boat.Upgrades or {}) do
                local level = boatData[upgrade.Id] or 0
                local eligible
                if upgrade.Extra then
                    if level < (upgrade.Max or 0) then
                        local ok2, extraOk = pcall(FishingShared.ExtraOk, data, upgrade, level + 1)
                        eligible = ok2 and extraOk
                    else
                        eligible = false
                    end
                elseif level < FishingShared.Boat.MaxLevel then
                    local ok2, maxLvl = pcall(FishingShared.BoatMaxLevel, hullLevel)
                    eligible = ok2 and level < maxLvl
                else
                    eligible = false
                end

                if eligible then
                    local ok3, cost = pcall(FishingShared.BoatCost, upgrade.Id, level)
                    if ok3 and cost and cost <= (data.Cash or 0) then
                        table.insert(list, { kind = "BoatUpgrade", id = upgrade.Id, cost = cost })
                    end
                end
            end
        end
    elseif tabName == "Spear Gun" then
        local upgrades = FishingShared.Spear and FishingShared.Spear.Upgrades
        for _, upgrade in ipairs(upgrades or {}) do
            local level = (data.Spear and data.Spear[upgrade.Id]) or 0
            if level < upgrade.Max then
                local ok2, canBuy = pcall(FishingShared.HelperLevelOk, data, upgrade, level + 1)
                if ok2 and canBuy then
                    local ok3, cost = pcall(FishingShared.SpearCost, upgrade.Id, level)
                    if ok3 then
                        table.insert(list, { kind = "Spear", id = upgrade.Id, cost = cost })
                    end
                end
            end
        end
    else
        for _, upgrade in ipairs(FishingShared.Upgrades) do
            if upgrade.Tab == tabName and not upgrade.Hidden then
                local level = (data.Upgrades and data.Upgrades[upgrade.Id]) or 0
                if level < upgrade.Max then
                    local ok2, canBuy = pcall(FishingShared.UpgradeLevelOk, data, upgrade, level + 1)
                    if ok2 and canBuy then
                        local ok3, cost = pcall(FishingShared.UpgradeCost, upgrade.Id, level)
                        if ok3 then
                            table.insert(list, { kind = "Upgrade", id = upgrade.Id, cost = cost })
                        end
                    end
                end
            end
        end
    end

    return list
end

local function getCoolerStacks()
    local data = getPlayerData()
    if not data or not data.Cooler then return {} end

    local stacks = {}
    for key, state in pairs(data.Cooler) do
        local species = FishingShared.SpeciesById[state.s]
        if species and (state.n or 0) > 0 then
            table.insert(stacks, {
                key = key,
                state = state,
                species = species,
                rarity = species.Rarity,
            })
        end
    end
    return stacks
end

local function getMyBase()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local bases = map:FindFirstChild("Bases")
    if not bases then return nil end
    for _, base in ipairs(bases:GetChildren()) do
        if base:GetAttribute("OwnerUserId") == LP.UserId then
            return base
        end
    end
    return nil
end

-- list of pedestal slot numbers that are currently empty on our own base, sorted by slot number
local function getOpenPedestalSlots()
    local base = getMyBase()
    if not base then return {} end

    local pedestalsFolder = base:FindFirstChild("Pedestals")
    if not pedestalsFolder then return {} end

    local openSlots = {}
    for _, pedestal in ipairs(pedestalsFolder:GetChildren()) do
        local isOpen = pedestal:GetAttribute("Open")
        local slotNum = pedestal:GetAttribute("Slot")
        local passHidden = pedestal:GetAttribute("PassHidden")

        if isOpen == true and slotNum and not passHidden then
            table.insert(openSlots, slotNum)
        end
    end

    table.sort(openSlots)
    return openSlots
end

-- list of fish currently displayed on our own pedestals: { {slot=n, label="Name", prompt=Instance, rarity=n}, ... }
local function getShowcasedFish()
    local data = getPlayerData()
    local base = getMyBase()
    if not data or not data.Showcase or not base then return {} end

    local pedestalsFolder = base:FindFirstChild("Pedestals")
    if not pedestalsFolder then return {} end

    -- index pedestal instances by their Slot attribute
    local bySlot = {}
    for _, pedestal in ipairs(pedestalsFolder:GetChildren()) do
        local slotNum = pedestal:GetAttribute("Slot")
        if slotNum then
            bySlot[slotNum] = pedestal
        end
    end

    local list = {}
    for slotKey, entry in pairs(data.Showcase) do
        local slotNum = tonumber(slotKey)
        if slotNum and type(entry) == "table" and entry.s then
            local species = FishingShared.SpeciesById[entry.s]
            local pedestal = bySlot[slotNum]
            if species and pedestal then
                local base2 = pedestal:FindFirstChild("Base")
                local prompt = base2 and base2:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    table.insert(list, {
                        slot = slotNum,
                        label = species.Name .. " (Slot " .. slotNum .. ")",
                        prompt = prompt,
                        part = base2,
                        rarity = species.Rarity,
                        key = slotKey,
                    })
                end
            end
        end
    end

    table.sort(list, function(a, b) return a.slot < b.slot end)
    return list
end

-- =====================================================================
-- FEATURE: AUTO THROW NET
-- =====================================================================
local throwRunning = false
local throwStatus = "Stopped"
local setThrowStatus = function() end

-- reel-in threshold: fraction of NetCap (0..1) at which the net is pulled in early.
-- 1 = only reel in when full (let the game's own full-net auto reel-in handle it).
local reelInThreshold = 1

task.spawn(function()
    while alive do
        if throwRunning then
            local base = getMyBase()
            if base then
                local state = base:GetAttribute("NetState")
                if state == "Idle" or state == nil then
                    pcall(function() ThrowNet:FireServer() end)
                elseif state == "Out" or state == "Fishing" then
                    if reelInThreshold < 1 then
                        local count = base:GetAttribute("NetCount") or 0
                        local cap = base:GetAttribute("NetCap") or 1
                        local fill = count / math.max(1, cap)
                        if fill >= reelInThreshold then
                            pcall(function() ReelIn:FireServer() end)
                        end
                    end
                end
            else
                pcall(function() ThrowNet:FireServer() end)
            end
        end
        task.wait(1)
    end
end)

-- =====================================================================
-- FEATURE: TAKE FISH BY RARITY
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local TAKE_INTERVAL = 5 -- seconds, built-in, not user-configurable

local takeRunning = false
local takeBusy = false
local takeSelected = {} -- set of rarity index -> true
local takeStatus = "Stopped"
local setTakeStatus = function() end

local function takeStep()
    if takeBusy then return end
    takeBusy = true

    local didSomething = false
    local stacks = getCoolerStacks()
    for _, stack in ipairs(stacks) do
        if takeSelected[stack.rarity] then
            local ok2, result = pcall(function()
                return CoolerAction:InvokeServer("place", stack.key)
            end)
            if ok2 and result and result.ok then
                didSomething = true
            end
            task.wait(0.3)
        end
    end

    setTakeStatus(didSomething and "Collected fish just now" or "No matching fish found")
    takeBusy = false
end

task.spawn(function()
    while alive do
        task.wait(TAKE_INTERVAL)
        if takeRunning then pcall(takeStep) end
    end
end)

-- =====================================================================
-- FEATURE: SELL FISH BY RARITY
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local SELL_INTERVAL = 5 -- seconds, built-in, not user-configurable

local sellRunning = false
local sellBusy = false
local sellSelected = {} -- set of rarity index -> true
local sellStatus = "Stopped"
local setSellStatus = function() end

local function sellStep()
    if sellBusy then return end
    sellBusy = true

    local didSomething = false
    local stacks = getCoolerStacks()
    for _, stack in ipairs(stacks) do
        if sellSelected[stack.rarity] then
            local amount = stack.state.n or 0
            if amount > 0 then
                local ok2, result = pcall(function()
                    return CoolerAction:InvokeServer("release", stack.key, amount)
                end)
                if ok2 and result and result.ok then
                    didSomething = true
                end
                task.wait(0.3)
            end
        end
    end

    setSellStatus(didSomething and "Sold fish just now" or "No matching fish found")
    sellBusy = false
end

task.spawn(function()
    while alive do
        task.wait(SELL_INTERVAL)
        if sellRunning then pcall(sellStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO PLACE FISH BY RARITY
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local PLACE_INTERVAL = 5 -- seconds, built-in, not user-configurable

local placeRunning = false
local placeBusy = false
local placeSelected = {} -- set of rarity index -> true
local placeStatus = "Stopped"
local setPlaceStatus = function() end

local function placeStep()
    if placeBusy then return end
    if turretActive then
        setPlaceStatus("Paused (Turret Mode active)")
        return
    end
    placeBusy = true

    local openSlots = getOpenPedestalSlots()
    if #openSlots == 0 then
        setPlaceStatus("No open pedestal slots")
        placeBusy = false
        return
    end

    local stacks = getCoolerStacks()
    local candidates = {}
    for _, stack in ipairs(stacks) do
        if placeSelected[stack.rarity] then
            table.insert(candidates, stack)
        end
    end
    table.sort(candidates, function(a, b) return a.rarity > b.rarity end)

    local placed = 0
    local slotIndex = 1
    for _, stack in ipairs(candidates) do
        if slotIndex > #openSlots then break end

        local targetSlot = openSlots[slotIndex]
        local ok2, result = pcall(function()
            return CoolerAction:InvokeServer("place", stack.key, targetSlot)
        end)
        if ok2 and result and result.ok then
            placed = placed + 1
            slotIndex = slotIndex + 1
        end
        task.wait(0.3)
    end

    setPlaceStatus(placed > 0 and ("Placed " .. placed .. " fish just now") or "No matching fish found")
    placeBusy = false
end

task.spawn(function()
    while alive do
        task.wait(PLACE_INTERVAL)
        if placeRunning then pcall(placeStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO COLLECT
-- The server only accepts CollectPadReq when you're actually near the
-- pedestal, so this teleports your HumanoidRootPart next to each open
-- pedestal, fires the collect, then moves to the next one — returning you
-- to your original position once every pedestal's been visited.
-- Interval is user-configurable via the dropdown below (not a fixed 5s
-- loop like the other Auto features) since teleporting every few seconds
-- would be disruptive while you're fishing manually.
-- =====================================================================
local collectRunning = false
local collectBusy = false
local collectInterval = 30 -- seconds; changed via the GUI dropdown
local collectStatus = "Stopped"
local setCollectStatus = function() end

-- finds a part on a pedestal to teleport next to; prefers "Base" (same part
-- used elsewhere in this script for the ProximityPrompt), falls back to
-- PrimaryPart or any BasePart child
local function pedestalTargetPart(pedestal)
    local targetPart = pedestal:FindFirstChild("Base")
    if targetPart then return targetPart end
    if pedestal:IsA("Model") and pedestal.PrimaryPart then
        return pedestal.PrimaryPart
    end
    for _, child in ipairs(pedestal:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function collectStep()
    if collectBusy then return end
    if turretActive then
        setCollectStatus("Paused (Turret Mode active)")
        return
    end
    collectBusy = true

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        setCollectStatus("Character not loaded")
        collectBusy = false
        return
    end

    local base = getMyBase()
    if not base then
        setCollectStatus("Couldn't find your base")
        collectBusy = false
        return
    end

    local pedestalsFolder = base:FindFirstChild("Pedestals")
    if not pedestalsFolder then
        setCollectStatus("No pedestals found")
        collectBusy = false
        return
    end

    local originalCFrame = hrp.CFrame
    local collected = 0

    for _, pedestal in ipairs(pedestalsFolder:GetChildren()) do
        local slot = pedestal:GetAttribute("Slot")
        local isOpen = pedestal:GetAttribute("Open")

        -- only visit pedestals that are actually unlocked and yours — a
        -- placeholder/locked slot that still carries a Slot attribute
        -- doesn't get teleported to or counted
        if slot and isOpen == true then
            local targetPart = pedestalTargetPart(pedestal)
            if targetPart then
                hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
                task.wait(0.5) -- let the server register the new position

                local ok2 = pcall(function()
                    CollectPadReq:FireServer(slot)
                end)
                if ok2 then
                    collected = collected + 1
                end
                task.wait(0.3)
            end
        end
    end

    -- return to where you were before the collect run started
    pcall(function() hrp.CFrame = originalCFrame end)

    setCollectStatus(collected > 0 and ("Collected from " .. collected .. " pedestal(s) just now") or "Nothing to collect")
    collectBusy = false
end

task.spawn(function()
    while alive do
        task.wait(collectInterval)
        if collectRunning then pcall(collectStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO BUY UPGRADES (priority list: Nets / Fishing / Market / Fisherman / Spear Gun)
-- One combined loop: buys the cheapest affordable candidate across every
-- category the user has checked in the priority dropdown, then re-evaluates.
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local BUY_INTERVAL = 1 -- seconds, built-in, not user-configurable
local BUY_CATEGORIES = { "Nets", "Fishing", "Market", "Fisherman", "Spear Gun", "Boat" }
L.BUY_CATEGORIES = BUY_CATEGORIES

local buyRunning = false
local buyBusy = false
local buyPriority = {} -- set of category name -> true (from the priority dropdown)
local buyStatus = "Stopped"
local setBuyStatus = function() end

-- current level/tier of a given candidate, read straight from a data snapshot
-- (used to verify a buy actually landed, since every buy remote here is
-- fire-and-forget or best read back from the next data snapshot)
local function currentLevelOf(item, data)
    if not data then return 0 end
    if item.kind == "Net" then
        return data.NetTier or 0
    elseif item.kind == "Helper" then
        return (data.Helper and data.Helper[item.id]) or 0
    elseif item.kind == "Spear" then
        return (data.Spear and data.Spear[item.id]) or 0
    elseif item.kind == "BoatHull" then
        return (type(data.Boat) == "table" and data.Boat.Hull) or 0
    elseif item.kind == "BoatUpgrade" then
        return (type(data.Boat) == "table" and data.Boat[item.id]) or 0
    else
        return (data.Upgrades and data.Upgrades[item.id]) or 0
    end
end

-- fires the right remote for the candidate's category; Nets/Upgrade tabs use
-- the fire-and-forget BuyItem, Fisherman/Spear Gun/Boat use their own
-- InvokeServer "buy" action (same pattern as the live game's own buy buttons)
local function fireBuy(item)
    if item.kind == "Helper" then
        pcall(function() HelperAction:InvokeServer("buy", item.id) end)
    elseif item.kind == "Spear" then
        pcall(function() SpearAction:InvokeServer("buy", item.id) end)
    elseif item.kind == "BoatHull" or item.kind == "BoatUpgrade" then
        pcall(function() BoatAction:InvokeServer("buy", item.id) end)
    else
        pcall(function() BuyItem:FireServer(item.kind, item.id) end)
    end
end

local function buyStep()
    if buyBusy then return end
    buyBusy = true

    local data = getPlayerData()
    if not data then
        setBuyStatus("Couldn't read player data")
        buyBusy = false
        return
    end

    local cash = data.Cash or 0
    local bought = 0

    -- re-fetch candidates once per loop pass across every checked category,
    -- merge into one list, then sort globally so the cheapest buy always
    -- goes first regardless of which category it's from
    local candidates = {}
    for _, tabName in ipairs(BUY_CATEGORIES) do
        if buyPriority[tabName] then
            for _, item in ipairs(getBuyableUpgrades(tabName, data)) do
                table.insert(candidates, item)
            end
        end
    end
    table.sort(candidates, function(a, b) return (a.cost or math.huge) < (b.cost or math.huge) end)

    -- fires every affordable candidate back-to-back, no delay between them;
    -- cash is deducted locally (optimistic) so the cheapest-first ordering
    -- still makes sense within this same pass, since we're not waiting on
    -- the server to confirm each one before moving to the next
    for _, item in ipairs(candidates) do
        if item.cost and item.cost <= cash then
            fireBuy(item)
            bought = bought + 1
            cash = cash - item.cost
        end
    end

    setBuyStatus(bought > 0 and ("Bought " .. bought .. " just now") or "Nothing affordable right now")
    buyBusy = false
end

task.spawn(function()
    while alive do
        task.wait(BUY_INTERVAL)
        if buyRunning then pcall(buyStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO REBIRTH
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local REBIRTH_INTERVAL = 5 -- seconds, built-in, not user-configurable

local rebirthRunning = false
local rebirthBusy = false
local rebirthStatus = "Stopped"
local setRebirthStatus = function() end
-- forward-declared here (defined once the Shop tab's bait dropdown exists,
-- further down) so the RebirthDone handler below can call it safely
local refreshBaitDropdown = function() end

-- tries the game's own rebirth-eligibility function first (same trust model
-- as NetRebirthOk/UpgradeLevelOk elsewhere in this script); falls back to a
-- manual check (net tier maxed = no next net, or can't afford it) if that
-- function isn't reachable from this module
local function canRebirth(data)
    local ok, result = pcall(function()
        return FishingShared.CanRebirth(data)
    end)
    if ok then return result end

    local nextTier = (data.NetTier or 1) + 1
    local netDef = FishingShared.Nets and FishingShared.Nets[nextTier]
    local netMaxed = (not netDef) or ((data.Cash or 0) < netDef.Cost)
    return netMaxed
end

local function rebirthStep()
    if rebirthBusy then return end
    rebirthBusy = true

    local data = getPlayerData()
    if not data then
        setRebirthStatus("Couldn't read player data")
        rebirthBusy = false
        return
    end

    local rebirths = data.Rebirths or 0
    local maxRebirth = FishingShared.MaxRebirth or math.huge

    if rebirths >= maxRebirth then
        setRebirthStatus("Max rebirth reached")
    elseif canRebirth(data) then
        pcall(function() RebirthRequest:FireServer() end)
        setRebirthStatus("Requested rebirth...")
    else
        setRebirthStatus("Not ready yet")
    end

    rebirthBusy = false
end

task.spawn(function()
    while alive do
        task.wait(REBIRTH_INTERVAL)
        if rebirthRunning then pcall(rebirthStep) end
    end
end)

-- server confirms the new rebirth count via this event (fire-and-forget request,
-- event-based response — same pattern as the live game's own RebirthDone handler).
-- Also re-renders the Shop tab's bait dropdown so a bait that just unlocked
-- shows its price instead of 🔒 (refreshBaitDropdown is assigned once the GUI
-- builds that dropdown further down; this is a no-op if fired before that).
bind(RebirthDone.OnClientEvent, function(newCount)
    setRebirthStatus("Rebirth " .. tostring(newCount) .. "!")
    refreshBaitDropdown()
end)

-- =====================================================================
-- FEATURE: AUTO BUY BAIT
-- Tops up selected baits to a chosen level (20 / 40 / 60 / Max) and
-- re-buys automatically once a bait runs out (owned count hits 0).
-- Uses Tackle:InvokeServer("buyBait", id, amount) — amount can be a
-- number or the string "max", matching the in-game Buy buttons.
-- Built-in interval, not exposed in the GUI
-- =====================================================================
local BAIT_BUY_INTERVAL = 5 -- seconds, built-in, not user-configurable

local baitBuyRunning = false
local baitBuyBusy = false
local baitSelected = {} -- set of bait Id -> true
local baitBuyLevel = 20 -- 20 | 40 | 60 | "max"
local baitBuyStatus = "Stopped"
local setBaitBuyStatus = function() end

-- "Nightcrawlers — $170" style label so price shows right in the dropdown item;
-- rebirth-locked baits get a 🔒 + requirement instead of a price, so it's
-- obvious from the dropdown alone which ones aren't buyable yet.
-- Rebuilt whenever rebirth count changes (see RebirthDone handler below the
-- GUI section) so a bait that just unlocked shows its price, not 🔒, without
-- needing a manual refresh button.
local BAIT_LABELS = {}
local BAIT_LABEL_TO_ID = {}
L.BAIT_LABELS = BAIT_LABELS
L.BAIT_LABEL_TO_ID = BAIT_LABEL_TO_ID

local function rebuildBaitLabels()
    local myRebirths = 0
    local snapshot = getPlayerData()
    if snapshot then myRebirths = snapshot.Rebirths or 0 end

    table.clear(BAIT_LABELS)
    table.clear(BAIT_LABEL_TO_ID)

    for _, bait in ipairs(FishingShared.Baits) do
        local requiredRebirth = bait.Rebirth or 0
        local label
        if requiredRebirth > myRebirths then
            label = bait.Name .. "  —  🔒 Rebirth " .. requiredRebirth
        else
            label = bait.Name .. "  —  " .. money(bait.Price or 0)
        end
        table.insert(BAIT_LABELS, label)
        BAIT_LABEL_TO_ID[label] = bait.Id
    end
end
rebuildBaitLabels()

local function ownedBaitCount(baitId, data)
    return (data.Tackle and data.Tackle.Baits and data.Tackle.Baits[baitId]) or 0
end

local function baitBuyStep()
    if baitBuyBusy then return end
    baitBuyBusy = true

    local data = getPlayerData()
    if not data then
        setBaitBuyStatus("Couldn't read player data")
        baitBuyBusy = false
        return
    end

    local bought = 0
    local skippedLocked = 0

    for _, bait in ipairs(FishingShared.Baits) do
        if baitSelected[bait.Id] then
            -- rebirth-locked baits (e.g. Glitter Lure, Golden Grub) are left
            -- alone rather than erroring the whole pass
            local rebirthOk = (bait.Rebirth or 0) <= (data.Rebirths or 0)
            if not rebirthOk then
                skippedLocked = skippedLocked + 1
            else
                local owned = ownedBaitCount(bait.Id, data)
                -- only re-buys once the bait is actually out, per the requested pipeline
                if owned <= 0 then
                    local ok2, result = pcall(function()
                        return Tackle:InvokeServer("buyBait", bait.Id, baitBuyLevel)
                    end)
                    if ok2 and result and not result.err then
                        bought = bought + 1
                    end
                    task.wait(0.3)
                end
            end
        end
    end

    if bought > 0 then
        setBaitBuyStatus("Bought " .. bought .. " bait type(s) just now")
    elseif skippedLocked > 0 then
        setBaitBuyStatus(skippedLocked .. " selected bait(s) still rebirth-locked")
    else
        setBaitBuyStatus("All selected baits still in stock")
    end

    baitBuyBusy = false
end

task.spawn(function()
    while alive do
        task.wait(BAIT_BUY_INTERVAL)
        if baitBuyRunning then pcall(baitBuyStep) end
    end
end)

-- =====================================================================
-- FEATURE: EQUIP BAIT
-- Only one bait can be equipped for fishing at a time (mirrors the
-- in-game Bait Shop's Use/Unequip button per bait). This is a manual,
-- single-select dropdown: picking a bait immediately fires
-- Tackle:InvokeServer("equipBait", id) — no auto-switch/auto-equip logic.
-- =====================================================================
local equipBaitStatus = "Not set"
local setEquipBaitStatus = function() end

local function equipBaitStep(id, label)
    local ok2, result = pcall(function()
        return Tackle:InvokeServer("equipBait", id)
    end)
    if ok2 and result and not result.err then
        setEquipBaitStatus("Equipped: " .. label)
    else
        local errMsg = (ok2 and result and result.err) and tostring(result.err) or "request failed"
        setEquipBaitStatus("Couldn't equip (" .. errMsg .. ")")
    end
end

-- =====================================================================
-- FEATURE: AUTO BUY POTION (Hub > Potion Shop)
-- Game-native auto-buy exists ("auto" action on the Potions remote) but
-- this is a standalone version. The dropdown is a static list of all 20
-- kind+tier combos (Net Space I-X, Cash Boost I-X) since tiers themselves
-- never change — only which 5 of them are in stock right now changes on
-- each 10-min restock. User picks whichever combo(s) they want; every
-- pass we pull current stock via Potions:InvokeServer("state") and buy
-- any stock slot whose kind+tier matches a selected combo, isn't already
-- bought, and is affordable. If a picked combo isn't in the current 5
-- slots, it just waits for a future restock to roll it.
-- =====================================================================
local POTION_BUY_INTERVAL = 5 -- seconds, built-in, not user-configurable

local potionBuyRunning = false
local potionBuyBusy = false
local potionComboSelected = {} -- set of "Net_3" | "Cash_7" etc -> true
local potionBuyStatus = "Stopped"
local setPotionBuyStatus = function() end

-- static 20-option list: tier labels are fixed (I-X) regardless of what's
-- currently in stock, matching the real Potion Shop's own tier range
local POTION_COMBO_LABELS = {}
local POTION_LABEL_TO_COMBO = {}
for _, kindId in ipairs({ "Net", "Cash" }) do
    local kindDef = FishingShared.PotionKinds[kindId]
    for tier = 1, 10 do
        local roman = FishingShared.PotionRoman[tier]
        local label = kindDef.Name .. " " .. roman
        table.insert(POTION_COMBO_LABELS, label)
        POTION_LABEL_TO_COMBO[label] = kindId .. "_" .. tier
    end
end
L.POTION_COMBO_LABELS = POTION_COMBO_LABELS
L.POTION_LABEL_TO_COMBO = POTION_LABEL_TO_COMBO

local function getPotionState()
    local ok2, state = pcall(function()
        return PotionsRemote:InvokeServer("state")
    end)
    if ok2 and type(state) == "table" then
        return state
    end
    return nil
end

local function potionBuyStep()
    if potionBuyBusy then return end
    potionBuyBusy = true

    local state = getPotionState()
    if not state or type(state.stock) ~= "table" then
        setPotionBuyStatus("Couldn't read potion shop state")
        potionBuyBusy = false
        return
    end

    local cash = state.cash or 0
    local bought = 0
    local skippedFunds = 0

    for slotIndex, slot in ipairs(state.stock) do
        local combo = (slot.kind or "") .. "_" .. tostring(slot.tier)
        if potionComboSelected[combo] and not slot.bought then
            if (slot.price or 0) <= cash then
                local ok2, result = pcall(function()
                    return PotionsRemote:InvokeServer("buy", slotIndex)
                end)
                if ok2 and result and result.ok then
                    bought = bought + 1
                    if result.state then
                        cash = result.state.cash or cash
                    end
                end
                task.wait(0.3)
            else
                skippedFunds = skippedFunds + 1
            end
        end
    end

    if bought > 0 then
        setPotionBuyStatus("Bought " .. bought .. " potion(s) just now")
    elseif skippedFunds > 0 then
        setPotionBuyStatus(skippedFunds .. " selected potion(s) too expensive right now")
    else
        setPotionBuyStatus("No matching potions in stock")
    end

    potionBuyBusy = false
end

task.spawn(function()
    while alive do
        task.wait(POTION_BUY_INTERVAL)
        if potionBuyRunning then pcall(potionBuyStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO DRINK POTION (Main > Auto Drink)
-- Different from Auto Buy Potion: this drinks potions already sitting in
-- the Cooler (data.PotionInv, a map of "Net_5"/"Cash_3"-style id -> count),
-- via Potions:InvokeServer("use", id) (same remote as buy, different
-- action -- confirmed from the live "Drink" button's own code).
--
-- Selection is by KIND (Cash / Net), not a fixed tier: whichever tier is
-- best/worst per the Drink Priority setting is picked fresh from the
-- Cooler on every pass. This is what fixes the old static-dropdown issue
-- where checking a tier that had 0 stock could end up firing "use" for an
-- id the Cooler didn't actually have -- there is no way to select an
-- empty tier anymore, since tiers are never user-picked directly.
-- =====================================================================
local POTION_DRINK_INTERVAL = 5 -- seconds, built-in, not user-configurable

local potionDrinkRunning = false
local potionDrinkBusy = false
local potionDrinkKindSelected = {} -- set of "Cash"|"Net" -> true; picks a KIND, not a fixed tier
local potionDrinkSortMode = "Best" -- "Best" = always drink the highest tier currently in stock, "Worst" = always the lowest
local potionDrinkStatus = "Stopped"
local setPotionDrinkStatus = function() end

local DRINK_KIND_LABELS, DRINK_LABEL_TO_KIND = {}, {}
for _, kindId in ipairs({ "Cash", "Net" }) do
    local kindDef = FishingShared.PotionKinds[kindId]
    local label = kindDef.Name
    table.insert(DRINK_KIND_LABELS, label)
    DRINK_LABEL_TO_KIND[label] = kindId
end
L.DRINK_KIND_LABELS = DRINK_KIND_LABELS
L.DRINK_LABEL_TO_KIND = DRINK_LABEL_TO_KIND

-- Returns, for each owned kind, every tier currently sitting in the Cooler
-- (count > 0), sorted by the chosen priority (Best = highest tier first,
-- Worst = lowest tier first). Picking a kind in the dropdown means "always
-- drink whichever tier of this kind is best/worst right now" -- so once the
-- selected tier runs out, the next pass automatically picks the next one
-- in this order instead of silently stopping.
local function getDrinkCandidates(data)
    local inv = (data and data.PotionInv) or {}
    local byKind = {}
    for id, count in pairs(inv) do
        if (tonumber(count) or 0) > 0 then
            local kindId, tier = id:match("^(%a+)_(%d+)$")
            tier = tonumber(tier)
            if kindId and tier then
                byKind[kindId] = byKind[kindId] or {}
                table.insert(byKind[kindId], { id = id, tier = tier })
            end
        end
    end
    for _, list in pairs(byKind) do
        table.sort(list, function(a, b)
            if potionDrinkSortMode == "Worst" then return a.tier < b.tier end
            return a.tier > b.tier -- Best First (default)
        end)
    end
    return byKind
end

-- data.Potions["Net"|"Cash"] = { e = <server-time expiry>, t = <tier> } when
-- that kind currently has an active effect running (same field PotionMenu's
-- own HUD timer reads). Returns true while that kind's effect still has
-- time left, so we don't drink a new one of the same kind on top of it.
local function kindEffectActive(data, kindId)
    local info = data.Potions and data.Potions[kindId]
    if not info then return false end
    local ok, now = pcall(function() return workspace:GetServerTimeNow() end)
    if not ok then now = os.time() end
    return (info.e or 0) > now
end

local function potionDrinkStep()
    if potionDrinkBusy then return end
    potionDrinkBusy = true

    local data = getPlayerData()
    if not data then
        setPotionDrinkStatus("Couldn't read player data")
        potionDrinkBusy = false
        return
    end

    local drank = 0
    local skippedActive = 0
    local skippedEmpty = 0
    local byKind = getDrinkCandidates(data) -- { [kindId] = { {id, tier}, ... } sorted best/worst-first }

    -- For each selected kind, try its top candidate first; if the server
    -- rejects it (e.g. the Cooler snapshot was stale), fall through to the
    -- next-best candidate of that kind instead of giving up or re-firing
    -- the same id -- this is what makes "best/worst tier" self-healing when
    -- the top pick runs out, without ever needing the user to re-pick it.
    for kindId in pairs(potionDrinkKindSelected) do
        if kindEffectActive(data, kindId) then
            skippedActive = skippedActive + 1
        else
            local candidates = byKind[kindId]
            if not candidates or #candidates == 0 then
                skippedEmpty = skippedEmpty + 1
            else
                local gotOne = false
                for _, cand in ipairs(candidates) do
                    local ok2, result = pcall(function()
                        return PotionsRemote:InvokeServer("use", cand.id)
                    end)
                    task.wait(0.3)
                    if ok2 and result and result.ok then
                        drank = drank + 1
                        gotOne = true
                        break -- this kind is now active again, move to the next kind
                    end
                    -- server said no (likely stale stock) -- try the next
                    -- best/worst candidate of this same kind instead
                end
                if not gotOne then skippedEmpty = skippedEmpty + 1 end
            end
        end
    end

    if drank > 0 then
        setPotionDrinkStatus("Drank " .. drank .. " potion(s) just now")
    elseif skippedActive > 0 and skippedEmpty > 0 then
        setPotionDrinkStatus(skippedActive .. " kind(s) waiting on an active effect, " .. skippedEmpty .. " kind(s) out of stock")
    elseif skippedActive > 0 then
        setPotionDrinkStatus(skippedActive .. " selected kind(s) waiting on an active effect to end")
    else
        setPotionDrinkStatus("None of the selected kinds are in stock right now")
    end

    potionDrinkBusy = false
end

task.spawn(function()
    while alive do
        task.wait(POTION_DRINK_INTERVAL)
        if potionDrinkRunning then pcall(potionDrinkStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO BUY BLACK MARKET (Hub > Black Market)
-- Silas the Smuggler: 3 random items restocked hourly, one of each per
-- customer. No dropdown needed per the requested design -- just buys
-- every item currently in stock that isn't already bought and that's
-- affordable right now. Uses BlackMarket:InvokeServer("state") to read
-- the 3 current items (each has id/price/bought) and
-- BlackMarket:InvokeServer("buy", itemId) to purchase by item id.
-- =====================================================================
local BLACKMARKET_BUY_INTERVAL = 5 -- seconds, built-in, not user-configurable

local blackMarketBuyRunning = false
local blackMarketBuyBusy = false
local blackMarketBuyStatus = "Stopped"
local setBlackMarketBuyStatus = function() end

local function blackMarketBuyStep()
    if blackMarketBuyBusy then return end
    blackMarketBuyBusy = true

    local ok1, state = pcall(function()
        return BlackMarket:InvokeServer("state")
    end)
    if not ok1 or type(state) ~= "table" or type(state.items) ~= "table" then
        setBlackMarketBuyStatus("Couldn't read Black Market state")
        blackMarketBuyBusy = false
        return
    end

    local cash = state.cash or 0
    local bought = 0
    local skippedFunds = 0

    for _, item in ipairs(state.items) do
        if not item.bought then
            if (item.price or 0) <= cash then
                local ok2, result = pcall(function()
                    return BlackMarket:InvokeServer("buy", item.id)
                end)
                if ok2 and result and result.ok then
                    bought = bought + 1
                    if result.state then
                        cash = result.state.cash or cash
                    end
                end
                task.wait(0.3)
            else
                skippedFunds = skippedFunds + 1
            end
        end
    end

    if bought > 0 then
        setBlackMarketBuyStatus("Bought " .. bought .. " item(s) just now")
    elseif skippedFunds > 0 then
        setBlackMarketBuyStatus(skippedFunds .. " item(s) in stock but too expensive right now")
    else
        setBlackMarketBuyStatus("Nothing new to buy (already bought this restock)")
    end

    blackMarketBuyBusy = false
end

task.spawn(function()
    while alive do
        task.wait(BLACKMARKET_BUY_INTERVAL)
        if blackMarketBuyRunning then pcall(blackMarketBuyStep) end
    end
end)

-- =====================================================================
-- FEATURE: AUTO TURRET (Megalodon boss event, Event tab)
-- Megalodon is a single-target boss (no rarity selection needed): while the
-- event is live this auto-enters Turret Mode, aims at the shark's live
-- position (same FishingShared.MegPos(elapsed) formula the game's own
-- MegalodonClient uses to render it), and fires once per cooldown window as
-- long as it's in range -- then auto-leaves once the event ends.
--
-- This fires the exact same MegEvent remote the real "Enter Turret Mode"
-- and Fire buttons fire (server-validated identically either way); it does
-- not touch LocalPlayer's TurretMode attribute or camera itself -- the
-- server's own response to "enter" is what flips that, same as if a human
-- clicked the button. If the live UI happens to also be open, running both
-- at once isn't supported.
-- Built-in interval, not exposed in the GUI.
-- =====================================================================
local MEG_ENTER_RETRY = 2 -- seconds between re-tries of FireServer("enter") while not yet confirmed in
local MEG_FIRE_POLL = 0.25 -- seconds between fire-loop checks once confirmed in turret mode

local turretRunning = false
local turretStatus = "Stopped"
local setTurretStatus = function() end
local turretConfirmed = false -- true once the server has actually put us in turret mode
local turretNextEnterAt = 0
local turretReadyAt = 0 -- local cooldown gate, mirrors Megalodon.Cooldown

-- single place that flips both turretConfirmed and the shared turretActive
-- guard together, so Collect/Place (defined earlier in this file) always
-- see an accurate, immediately up-to-date picture -- never set
-- turretConfirmed directly anywhere else below.
local function setTurretConfirmed(v)
    turretConfirmed = v
    turretActive = v
end

local MegEvent = Remotes:FindFirstChild("MegEvent") -- may not exist if this game build doesn't have the event yet

local function megDef()
    return FishingShared.Megalodon
end

-- current shark position, same formula the live MegalodonClient renders
-- the model with (elapsed seconds since MegStart -> world position)
local function megSharkPos()
    local ok2, pos = pcall(function()
        local elapsed = workspace:GetServerTimeNow() - (workspace:GetAttribute("MegStart") or workspace:GetServerTimeNow())
        return FishingShared.MegPos(math.max(0, elapsed))
    end)
    if ok2 then return pos end
    return nil
end

-- our own spear gun's world position, same lookup the live client uses
-- (GunPivot attribute as a CFrame, falling back to the model's pivot)
local function mySpearGunPos()
    local base = getMyBase()
    local gun = base and base:FindFirstChild("SpearGun")
    if not gun then return nil end
    local pivot = gun:GetAttribute("GunPivot")
    if typeof(pivot) == "CFrame" then
        return pivot.Position
    end
    local ok2, pos = pcall(function() return gun:GetPivot().Position end)
    if ok2 then return pos end
    return nil
end

local function turretEligible(data)
    local def = megDef()
    if not def or not data then return false end
    return (data.Rebirths or 0) >= (def.NeedRebirth or 0)
end

local function turretFireStep()
    if not MegEvent then return end
    local def = megDef()
    if not def then return end

    local sharkPos = megSharkPos()
    local gunPos = mySpearGunPos()
    if not sharkPos or not gunPos then
        setTurretStatus("Waiting for shark/gun position...")
        return
    end

    local dist = (sharkPos - gunPos).Magnitude
    local range = (def.Range or 0) + (def.HitR or 0)
    if dist > range then
        setTurretStatus(("Out of range (%.0f / %.0f studs)"):format(dist, range))
        return
    end

    if os.clock() < turretReadyAt then
        setTurretStatus(("Reloading (%.1fs)"):format(turretReadyAt - os.clock()))
        return
    end

    turretReadyAt = os.clock() + (def.Cooldown or 2)
    pcall(function() MegEvent:FireServer("fire", sharkPos) end)
    setTurretStatus("Firing at the Megalodon...")
end

-- main poll loop: handles eligibility checks, requesting entry, and
-- resetting state once the event ends
task.spawn(function()
    while alive do
        task.wait(1)
        if turretRunning and MegEvent then
            local ok2, err = pcall(function()
                local active = workspace:GetAttribute("MegActive") == true
                if not active then
                    setTurretConfirmed(false)
                    setTurretStatus("Waiting for Megalodon event...")
                    return
                end

                local data = getPlayerData()
                if not turretEligible(data) then
                    setTurretStatus("Needs Rebirth " .. tostring((megDef() or {}).NeedRebirth or "?") .. " to fight")
                    return
                end

                if not turretConfirmed then
                    if os.clock() - turretNextEnterAt >= MEG_ENTER_RETRY then
                        turretNextEnterAt = os.clock()
                        pcall(function() MegEvent:FireServer("enter") end)
                        setTurretStatus("Entering turret mode...")
                    end
                    return
                end

                turretFireStep()
            end)
            if not ok2 then
                setTurretStatus("Error: " .. tostring(err))
            end
        elseif turretRunning and not MegEvent then
            setTurretStatus("MegEvent remote not found (event may not exist in this game build)")
        end
    end
end)

-- faster-than-poll fire loop: once confirmed inside turret mode, fire as
-- soon as cooldown + range allow rather than waiting for the 1s poll above,
-- so damage output isn't needlessly throttled
task.spawn(function()
    while alive do
        task.wait(MEG_FIRE_POLL)
        if turretRunning and turretConfirmed and workspace:GetAttribute("MegActive") == true then
            pcall(turretFireStep)
        end
    end
end)

-- MegEvent.OnClientEvent: known string actions are handled explicitly;
-- anything else (the live client treats this as the "you're in turret mode
-- now" payload, distinct from every named action above) is our real
-- "we're in" signal, same as the live UI entering turret mode.
if MegEvent then
    bind(MegEvent.OnClientEvent, function(action, payload)
        if not turretRunning then return end
        if action == "end" then
            setTurretConfirmed(false)
            setTurretStatus("Event ended")
        elseif action == "capped" then
            setTurretStatus(payload == "max" and "Max damage reached, waiting for Last Stand" or "Waiting for other docks' turn")
        elseif action == "start" then
            setTurretStatus("Megalodon has arrived")
        elseif action == "warn" or action == "shot" or action == "loot" or action == "board" or action == "stats" or action == "turret" then
            -- not relevant to the auto-turret loop; ignored here
        else
            -- unrecognized action with a payload: treat as entry confirmation
            setTurretConfirmed(true)
            setTurretStatus("In turret mode, firing...")
        end
    end)
end

-- ---- Auto Turret (Megalodon) ----
function L.setTurretRunning(v)
    turretRunning = v
    if not v then
        setTurretConfirmed(false)
        setTurretStatus("Stopped")
    end
end
function L.getTurretRunning() return turretRunning end
function L.getTurretStatus() return turretStatus end
function L.onTurretStatus(cb) setTurretStatus = function(text) turretStatus = text; cb(text) end end

-- =====================================================================
-- FEATURE: AUTO CLAIM CONTRACT (Quest tab)
-- Uses Contracts:InvokeServer("state") to read the current contract list
-- (each entry has p/goal/k) and Contracts:InvokeServer("claim", index) to
-- claim one that's finished. index is the 1-based position in state.list,
-- not an id string -- matches the live Claim button's own code. Contracts
-- with k == "wait" are skipped (claiming those just triggers the "Skip
-- Contract Wait" gamepass prompt server-side, not an actual claim).
-- Built-in interval, not exposed in the GUI.
-- =====================================================================
local CONTRACT_CLAIM_INTERVAL = 5 -- seconds, built-in, not user-configurable

local contractClaimRunning = false
local contractClaimBusy = false
local contractClaimStatus = "Stopped"
local setContractClaimStatus = function() end

local function getContractState()
    local ok2, state = pcall(function()
        return Contracts:InvokeServer("state")
    end)
    if ok2 and type(state) == "table" then
        return state
    end
    return nil
end

local function contractClaimStep()
    if contractClaimBusy then return end
    contractClaimBusy = true

    local state = getContractState()
    if not state or type(state.list) ~= "table" then
        setContractClaimStatus("Couldn't read contract state")
        contractClaimBusy = false
        return
    end

    local claimed = 0
    for i, c in ipairs(state.list) do
        if type(c) == "table" and c.k ~= "wait" and (c.p or 0) >= (c.goal or math.huge) then
            local ok2, result = pcall(function()
                return Contracts:InvokeServer("claim", i)
            end)
            if ok2 and result and result.ok then
                claimed = claimed + 1
            end
            task.wait(0.3)
        end
    end

    setContractClaimStatus(claimed > 0 and ("Claimed " .. claimed .. " contract(s) just now") or "Nothing ready to claim")
    contractClaimBusy = false
end

task.spawn(function()
    while alive do
        task.wait(CONTRACT_CLAIM_INTERVAL)
        if contractClaimRunning then pcall(contractClaimStep) end
    end
end)

-- re-checks immediately whenever the server broadcasts a finished contract,
-- instead of waiting for the next 5s poll
bind(ContractPing.OnClientEvent, function(payload)
    if contractClaimRunning and payload == "done" then
        task.spawn(function() pcall(contractClaimStep) end)
    end
end)

-- =====================================================================
-- FEATURE: AUTO CLAIM TODAY CHALLENGE (Quest tab)
-- Uses Challenge:InvokeServer("state") to read the 3 daily tiers (each has
-- goal/done/claimed/reward) and Challenge:InvokeServer("claim", tier) where
-- tier is 1/2/3 -- matches the live "ClaimTier1/2/3" buttons' own code.
-- Built-in interval, not exposed in the GUI.
-- =====================================================================
local CHALLENGE_CLAIM_INTERVAL = 5 -- seconds, built-in, not user-configurable

local challengeClaimRunning = false
local challengeClaimBusy = false
local challengeClaimStatus = "Stopped"
local setChallengeClaimStatus = function() end

local function getChallengeState()
    local ok2, state = pcall(function()
        return Challenge:InvokeServer("state")
    end)
    if ok2 and type(state) == "table" then
        return state
    end
    return nil
end

local function challengeClaimStep()
    if challengeClaimBusy then return end
    challengeClaimBusy = true

    local state = getChallengeState()
    if not state or type(state.tiers) ~= "table" then
        setChallengeClaimStatus("Couldn't read challenge state")
        challengeClaimBusy = false
        return
    end

    local claimed = 0
    for tier, t in ipairs(state.tiers) do
        if type(t) == "table" and t.done and not t.claimed then
            local ok2, result = pcall(function()
                return Challenge:InvokeServer("claim", tier)
            end)
            if ok2 and result and result.ok then
                claimed = claimed + 1
            end
            task.wait(0.3)
        end
    end

    setChallengeClaimStatus(claimed > 0 and ("Claimed " .. claimed .. " tier(s) just now") or "Nothing ready to claim")
    challengeClaimBusy = false
end

task.spawn(function()
    while alive do
        task.wait(CHALLENGE_CLAIM_INTERVAL)
        if challengeClaimRunning then pcall(challengeClaimStep) end
    end
end)

-- re-checks immediately whenever the server pings a challenge update
-- (new day rolled over, progress changed, etc)
bind(ChallengePing.OnClientEvent, function()
    if challengeClaimRunning then
        task.spawn(function() pcall(challengeClaimStep) end)
    end
end)

-- =====================================================================
-- FEATURE: AUTO CALL CURRENT (Deep Current, Quest tab)
-- Different from the claim features above: Deep Current doesn't have a
-- "reward waiting" to collect -- you spend charge (pts, earned from
-- finishing contracts) to "call" a rare creature into your net via
-- Current:InvokeServer("call", rarityIndex). Only one call can be active
-- at a time (state.active), and a target is only callable if your net's
-- MaxRarity covers it and you have enough pts.
-- Strategy: every pass, if nothing is currently active, call the highest
-- -rarity target you can both afford and actually catch (so charge isn't
-- wasted on a low-rarity call when a bigger one is already affordable).
-- Built-in interval, not exposed in the GUI.
-- =====================================================================
local CURRENT_CALL_INTERVAL = 5 -- seconds, built-in, not user-configurable

local currentCallRunning = false
local currentCallBusy = false
local currentCallStatus = "Stopped"
local setCurrentCallStatus = function() end

local function getCurrentState()
    local ok2, state = pcall(function()
        return CurrentRemote:InvokeServer("state")
    end)
    if ok2 and type(state) == "table" then
        return state
    end
    return nil
end

-- picks the best (highest-rarity) target from FishingShared.Current.Targets
-- that's affordable (pts >= cost) and reachable by the player's current net
local function bestCurrentTarget(state)
    local sharedCurrent = FishingShared.Current
    if not sharedCurrent or type(sharedCurrent.Targets) ~= "table" then return nil end

    local netDef = FishingShared.Nets and FishingShared.Nets[state.net or 1]
    local maxRarity = netDef and netDef.MaxRarity
    local pts = state.pts or 0

    local best
    for _, target in ipairs(sharedCurrent.Targets) do
        local reachable = (not maxRarity) or (maxRarity >= target.r)
        local affordable = pts >= (target.cost or math.huge)
        if reachable and affordable and (not best or target.r > best.r) then
            best = target
        end
    end
    return best
end

local function currentCallStep()
    if currentCallBusy then return end
    currentCallBusy = true

    local state = getCurrentState()
    if not state then
        setCurrentCallStatus("Couldn't read Deep Current state")
        currentCallBusy = false
        return
    end

    if state.active then
        setCurrentCallStatus("Already calling a creature...")
        currentCallBusy = false
        return
    end

    local target = bestCurrentTarget(state)
    if not target then
        setCurrentCallStatus("Not enough charge / net too small yet")
        currentCallBusy = false
        return
    end

    local rarityName = (FishingShared.Rarities and FishingShared.Rarities[target.r] and FishingShared.Rarities[target.r].Name) or tostring(target.r)
    local ok2, result = pcall(function()
        return CurrentRemote:InvokeServer("call", target.r)
    end)
    if ok2 and result and result.ok then
        setCurrentCallStatus("Called " .. rarityName .. " just now")
    else
        setCurrentCallStatus("Call failed, will retry")
    end

    currentCallBusy = false
end

task.spawn(function()
    while alive do
        task.wait(CURRENT_CALL_INTERVAL)
        if currentCallRunning then pcall(currentCallStep) end
    end
end)

-- re-checks immediately when a called creature arrives/escapes, instead of
-- waiting for the next poll (so the next call fires right away)
bind(CurrentPing.OnClientEvent, function()
    if currentCallRunning then
        task.spawn(function() pcall(currentCallStep) end)
    end
end)

-- =====================================================================
-- FEATURE: AUTO MINI GAMES (Main tab, bottom)
-- A random mini-game can pop up during reel-in (Perfect Reel): a needle
-- moves across a bar and you must tap at the exact right moment to win a
-- bonus. This reads the same attributes/values the game's own mini-game
-- UI uses (NetT0, ReelSweet, FishingShared.ReelTime, PerfectReel.Window)
-- and fires the same PerfectTap remote at the computed ideal moment.
-- Built-in interval, not exposed as a separate dropdown -- just one toggle.
-- =====================================================================
local PerfectTap = Remotes:FindFirstChild("PerfectTap") -- may not exist on older game builds

local miniGamesRunning = false
local miniGamesStatus = "Stopped"
local setMiniGamesStatus = function() end
local lastHandledT0 = nil -- NetT0 we already scheduled a tap for, so we don't double-fire

local function perfectReelStep()
    if not PerfectTap then
        setMiniGamesStatus("Mini-game remote not found (may not exist in this game build)")
        return
    end

    local def = FishingShared.PerfectReel
    if not def or not FishingShared.PerfectReelEnabled then
        setMiniGamesStatus("Waiting for mini-game...")
        return
    end

    local base = getMyBase()
    if not base then
        setMiniGamesStatus("Couldn't find your base")
        return
    end

    local state = base:GetAttribute("NetState")
    local t0 = base:GetAttribute("NetT0")

    if state ~= "Reeling" or not t0 then
        setMiniGamesStatus("Waiting for mini-game...")
        return
    end

    if lastHandledT0 == t0 then
        return -- already scheduled/tapped for this reel
    end
    lastHandledT0 = t0

    local sweet = tonumber(base:GetAttribute("ReelSweet")) or 0.5
    sweet = math.clamp(sweet, 0.05, 0.95)

    local reelTime = FishingShared.ReelTime
    if type(reelTime) ~= "number" or reelTime <= 0 then
        setMiniGamesStatus("Couldn't read reel timing")
        return
    end

    local idealTime = t0 + sweet * reelTime

    task.spawn(function()
        local now = workspace:GetServerTimeNow()
        local waitFor = idealTime - now
        if waitFor > 0 then
            task.wait(waitFor)
        end
        pcall(function()
            PerfectTap:FireServer(workspace:GetServerTimeNow())
        end)
        setMiniGamesStatus("Tapped mini-game just now")
    end)
end

task.spawn(function()
    while alive do
        task.wait(0.1)
        if miniGamesRunning then pcall(perfectReelStep) end
    end
end)

-- =====================================================================
-- PUBLIC API (consumed by gui.lua)
-- Every toggle exposes get/set<Name>Running + a status get/set-callback
-- registration so gui.lua's Paragraph element can be kept live without
-- logic.lua reaching into GUI internals.
-- =====================================================================

-- ---- Auto Throw Net ----
function L.setThrowRunning(v) throwRunning = v end
function L.getThrowRunning() return throwRunning end
function L.getThrowStatus() return throwStatus end
function L.onThrowStatus(cb) setThrowStatus = function(text) throwStatus = text; cb(text) end end
function L.setReelInThreshold(v) reelInThreshold = v end
function L.getReelInThreshold() return reelInThreshold end

-- ---- Auto Take ----
function L.setTakeRunning(v) takeRunning = v end
function L.getTakeRunning() return takeRunning end
function L.getTakeStatus() return takeStatus end
function L.onTakeStatus(cb) setTakeStatus = function(text) takeStatus = text; cb(text) end end
function L.setTakeSelected(names) -- names: list of rarity-name strings
    takeSelected = {}
    if type(names) == "table" then
        for _, name in ipairs(names) do
            for i, rn in ipairs(RARITY_NAMES) do
                if rn == name then takeSelected[i] = true break end
            end
        end
    end
end

-- ---- Auto Sell ----
function L.setSellRunning(v) sellRunning = v end
function L.getSellRunning() return sellRunning end
function L.getSellStatus() return sellStatus end
function L.onSellStatus(cb) setSellStatus = function(text) sellStatus = text; cb(text) end end
function L.setSellSelected(names)
    sellSelected = {}
    if type(names) == "table" then
        for _, name in ipairs(names) do
            for i, rn in ipairs(RARITY_NAMES) do
                if rn == name then sellSelected[i] = true break end
            end
        end
    end
end

-- ---- Auto Place ----
function L.setPlaceRunning(v)
    placeRunning = v
    if v then task.spawn(function() pcall(placeStep) end) end
end
function L.getPlaceRunning() return placeRunning end
function L.getPlaceStatus() return placeStatus end
function L.onPlaceStatus(cb) setPlaceStatus = function(text) placeStatus = text; cb(text) end end
function L.setPlaceSelected(names)
    placeSelected = {}
    if type(names) == "table" then
        for _, name in ipairs(names) do
            for i, rn in ipairs(RARITY_NAMES) do
                if rn == name then placeSelected[i] = true break end
            end
        end
    end
end

-- ---- Auto Collect ----
function L.setCollectRunning(v) collectRunning = v end
function L.getCollectRunning() return collectRunning end
function L.getCollectStatus() return collectStatus end
function L.onCollectStatus(cb) setCollectStatus = function(text) collectStatus = text; cb(text) end end
function L.setCollectInterval(seconds) collectInterval = seconds end
function L.getCollectInterval() return collectInterval end
function L.collectNow() task.spawn(function() pcall(collectStep) end) end

-- ---- Auto Drink Potion ----
function L.setPotionDrinkRunning(v) potionDrinkRunning = v end
function L.getPotionDrinkRunning() return potionDrinkRunning end
function L.getPotionDrinkStatus() return potionDrinkStatus end
function L.onPotionDrinkStatus(cb) setPotionDrinkStatus = function(text) potionDrinkStatus = text; cb(text) end end
function L.setPotionDrinkSortMode(mode) potionDrinkSortMode = mode end -- "Best" | "Worst"
function L.setPotionDrinkKindSelected(labels)
    potionDrinkKindSelected = {}
    if type(labels) == "table" then
        for _, label in ipairs(labels) do
            local kindId = DRINK_LABEL_TO_KIND[label]
            if kindId then potionDrinkKindSelected[kindId] = true end
        end
    end
end

-- ---- Auto Buy Upgrades ----
function L.setBuyRunning(v) buyRunning = v end
function L.getBuyRunning() return buyRunning end
function L.getBuyStatus() return buyStatus end
function L.onBuyStatus(cb) setBuyStatus = function(text) buyStatus = text; cb(text) end end
function L.setBuyPriority(names)
    buyPriority = {}
    if type(names) == "table" then
        for _, name in ipairs(names) do buyPriority[name] = true end
    end
end

-- ---- Auto Rebirth ----
function L.setRebirthRunning(v) rebirthRunning = v end
function L.getRebirthRunning() return rebirthRunning end
function L.getRebirthStatus() return rebirthStatus end
function L.onRebirthStatus(cb) setRebirthStatus = function(text) rebirthStatus = text; cb(text) end end

-- ---- Auto Buy Bait ----
function L.setBaitBuyRunning(v) baitBuyRunning = v end
function L.getBaitBuyRunning() return baitBuyRunning end
function L.getBaitBuyStatus() return baitBuyStatus end
function L.onBaitBuyStatus(cb) setBaitBuyStatus = function(text) baitBuyStatus = text; cb(text) end end
function L.setBaitBuyLevel(v) baitBuyLevel = v end -- 20 | 40 | 60 | "max"
function L.setBaitSelected(labels)
    baitSelected = {}
    if type(labels) == "table" then
        for _, label in ipairs(labels) do
            local id = BAIT_LABEL_TO_ID[label]
            if id then baitSelected[id] = true end
        end
    end
end

-- refreshBaitDropdown is assigned by gui.lua (it owns the dropdown widgets);
-- logic.lua just rebuilds the label data and calls back into the GUI.
function L.setRefreshBaitDropdown(fn)
    refreshBaitDropdown = function()
        rebuildBaitLabels()
        fn(BAIT_LABELS)
    end
end

-- ---- Equip Bait ----
function L.getEquipBaitStatus() return equipBaitStatus end
function L.onEquipBaitStatus(cb) setEquipBaitStatus = function(text) equipBaitStatus = text; cb(text) end end
function L.equipBait(id, label) equipBaitStep(id, label) end

-- ---- Auto Buy Potion ----
function L.setPotionBuyRunning(v) potionBuyRunning = v end
function L.getPotionBuyRunning() return potionBuyRunning end
function L.getPotionBuyStatus() return potionBuyStatus end
function L.onPotionBuyStatus(cb) setPotionBuyStatus = function(text) potionBuyStatus = text; cb(text) end end
function L.setPotionComboSelected(labels)
    potionComboSelected = {}
    if type(labels) == "table" then
        for _, label in ipairs(labels) do
            local combo = POTION_LABEL_TO_COMBO[label]
            if combo then potionComboSelected[combo] = true end
        end
    end
end

-- ---- Auto Buy Black Market ----
function L.setBlackMarketBuyRunning(v) blackMarketBuyRunning = v end
function L.getBlackMarketBuyRunning() return blackMarketBuyRunning end
function L.getBlackMarketBuyStatus() return blackMarketBuyStatus end
function L.onBlackMarketBuyStatus(cb) setBlackMarketBuyStatus = function(text) blackMarketBuyStatus = text; cb(text) end end

-- ---- Auto Claim Contract ----
function L.setContractClaimRunning(v)
    contractClaimRunning = v
    if v then task.spawn(function() pcall(contractClaimStep) end) end
end
function L.getContractClaimRunning() return contractClaimRunning end
function L.getContractClaimStatus() return contractClaimStatus end
function L.onContractClaimStatus(cb) setContractClaimStatus = function(text) contractClaimStatus = text; cb(text) end end

-- ---- Auto Claim Today Challenge ----
function L.setChallengeClaimRunning(v)
    challengeClaimRunning = v
    if v then task.spawn(function() pcall(challengeClaimStep) end) end
end
function L.getChallengeClaimRunning() return challengeClaimRunning end
function L.getChallengeClaimStatus() return challengeClaimStatus end
function L.onChallengeClaimStatus(cb) setChallengeClaimStatus = function(text) challengeClaimStatus = text; cb(text) end end

-- ---- Auto Call Deep Current ----
function L.setCurrentCallRunning(v)
    currentCallRunning = v
    if v then task.spawn(function() pcall(currentCallStep) end) end
end
function L.getCurrentCallRunning() return currentCallRunning end
function L.getCurrentCallStatus() return currentCallStatus end
function L.onCurrentCallStatus(cb) setCurrentCallStatus = function(text) currentCallStatus = text; cb(text) end end

-- ---- Auto Mini Games ----
function L.setMiniGamesRunning(v)
    miniGamesRunning = v
    if not v then lastHandledT0 = nil end
end
function L.getMiniGamesRunning() return miniGamesRunning end
function L.getMiniGamesStatus() return miniGamesStatus end
function L.onMiniGamesStatus(cb) setMiniGamesStatus = function(text) miniGamesStatus = text; cb(text) end end

-- ---- Lifecycle ----
-- stops every loop and disconnects every signal; gui.lua calls this from
-- its own unload button alongside Window:Destroy()
local function unloadLogic()
    if _G.NETAFISH_LOGIC_Unloaded == L then return end
    _G.NETAFISH_LOGIC_Unloaded = L
    alive = false
    throwRunning = false
    takeRunning = false
    sellRunning = false
    placeRunning = false
    collectRunning = false
    rebirthRunning = false
    buyRunning = false
    baitBuyRunning = false
    potionBuyRunning = false
    potionDrinkRunning = false
    blackMarketBuyRunning = false
    turretRunning = false
    turretActive = false
    contractClaimRunning = false
    challengeClaimRunning = false
    currentCallRunning = false
    miniGamesRunning = false
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
end
L.unload = unloadLogic
_G.NETAFISH_LOGIC_Unload = unloadLogic

return L
