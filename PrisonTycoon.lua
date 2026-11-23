local HUB_NAME = "Prison Tycoon"
local VERSION  = "v1.0"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"

-- Re-execute safety
if _G.PRISONTYCOON_Unload then pcall(_G.PRISONTYCOON_Unload) end

pcall(function() setclipboard(YT_LINK) end)

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then return end

local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local MugshotRemote = RS.Remotes.Mugshot
local SearchRemote = RS.Remotes.Search

local alive = true

-- =====================================================================
-- TOGGLE STATE — ini satu-satunya tempat yang nentuin stage mana jalan
-- =====================================================================
local Toggles = {
    GrabBook   = false,
    Feed       = false,
    Protest    = false,
    Search     = false,
    Clinic     = false,
    Fight      = false,
    Tackle     = false,
    DoorSafety = false,
    MayorCall  = false,
}

local RISK_PRESETS = { Safe = 0.3, Balance = 0.45, Risk = 0.65 }
local MayorRiskMode = "Balance"

-- diisi beneran pas bikin GUI (Paragraph:SetDesc)
local setFarmStatus  = function() end
local setMayorStatus = function() end

-- =====================================================================
-- GLOBAL BUSY FLAG (dari v20, apa adanya)
-- =====================================================================
_G.PT_Busy = _G.PT_Busy or nil
_G.PT_NpcCellMap = _G.PT_NpcCellMap or {}

local function Core_acquire(name)
    if _G.PT_Busy ~= nil then return false end
    _G.PT_Busy = name
    return true
end

local function Core_release()
    _G.PT_Busy = nil
end

local function Core_runStage(name, fn)
    if not Core_acquire(name) then return false end
    local okRun, result = pcall(fn)
    Core_release()
    if not okRun then
        warn("[PT AutoFarm] error di stage " .. name .. ": " .. tostring(result))
        return false
    end
    return result
end

-- =====================================================================
-- CORE HELPERS (copy dari v20)
-- =====================================================================

local function Core_getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Core_teleportTo(targetPos)
    local hrp = Core_getHRP()
    if not hrp then return false end
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
    task.wait(0.2)
    local hrpNow = Core_getHRP()
    if not hrpNow then return false end
    return (hrpNow.Position - targetPos).Magnitude < 6
end

local function Core_teleportToSafe(targetPos)
    local hrp = Core_getHRP()
    if not hrp then return false end
    local prevCollide = hrp.CanCollide
    hrp.CanCollide = false
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
    task.wait(0.2)
    local hrpNow = Core_getHRP()
    if not hrpNow then
        if hrp then hrp.CanCollide = prevCollide end
        return false
    end
    hrpNow.CanCollide = prevCollide
    return (hrpNow.Position - targetPos).Magnitude < 6
end

local function Core_getLockStandPos(cellModel)
    local front = cellModel:FindFirstChild("Front")
    local barsWall = front and front:FindFirstChild("BarsWall")
    local lockPart = barsWall and barsWall:FindFirstChild("Lock")
    if not lockPart then return nil end
    return lockPart.Position
end

local function Core_tweenTo(targetPos, duration, noCollideOnArrive)
    local hrp = Core_getHRP()
    if not hrp then return false end

    local goal = CFrame.new(targetPos + Vector3.new(0, 2, 0))
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration or 1.2, Enum.EasingStyle.Linear),
        { CFrame = goal }
    )

    if noCollideOnArrive then
        hrp.CanCollide = false
    end

    tween:Play()
    tween.Completed:Wait()

    task.wait(0.2)
    local hrpNow = Core_getHRP()
    if not hrpNow then return false end

    if noCollideOnArrive then
        hrpNow.CFrame = goal
    end

    return (hrpNow.Position - targetPos).Magnitude < 6
end

local function Core_tryFirePrompt(prompt)
    local fireOk = pcall(function() fireproximityprompt(prompt) end)
    return fireOk
end

local function Core_getPos(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then
        return inst.Position
    elseif inst:IsA("Model") then
        local pOk, pos = pcall(function() return inst:GetPivot().Position end)
        if pOk then return pos end
    end
    return nil
end

local function Core_getZoneCenter(zoneModel)
    local sumX, sumY, sumZ, n = 0, 0, 0, 0
    for _, d in ipairs(zoneModel:GetChildren()) do
        if d:IsA("BasePart") then
            sumX = sumX + d.Position.X
            sumY = sumY + d.Position.Y
            sumZ = sumZ + d.Position.Z
            n = n + 1
        end
    end
    if n == 0 then return nil end
    return Vector3.new(sumX/n, sumY/n, sumZ/n)
end

local function Core_getBuildings()
    local plotName = LocalPlayer:GetAttribute("SpacePlot")
    if not plotName then return nil end
    local plotsFolder = workspace:FindFirstChild("Plots")
    local plot = plotsFolder and plotsFolder:FindFirstChild(plotName)
    return plot and plot:FindFirstChild("Buildings")
end

local function Core_getOwnNpcsFolder()
    local plotName = LocalPlayer:GetAttribute("SpacePlot")
    if not plotName then return nil end
    local plotsFolder = workspace:FindFirstChild("Plots")
    local plot = plotsFolder and plotsFolder:FindFirstChild(plotName)
    return plot and plot:FindFirstChild("Npcs")
end

local function hasTray()
    local t = LocalPlayer:GetAttribute("Trays")
    return type(t) == "number" and t > 0
end

-- forward declare (dipake Stage2/Main sebelum definisi asli di Stage8)
local Stage8_findEscapingNpc

-- =====================================================================
-- STAGE 1+2: GRAB NAPI + MUGSHOT + LOCK CELL  (-> toggle GrabBook)
-- =====================================================================

local function Stage1_findTakeTarget()
    local hrp = Core_getHRP()
    if not hrp then return nil, nil end
    local bestPrompt, bestNpc, bestDist = nil, nil, math.huge
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("Interact") == "take" and prompt.Enabled then
            local owner = prompt:GetAttribute("OwnerUserId")
            if owner == nil or owner == LocalPlayer.UserId then
                local part = prompt.Parent
                local pos = part and part:IsA("BasePart") and part.Position
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPrompt = prompt
                        bestNpc = part.Parent
                    end
                end
            end
        end
    end
    return bestPrompt, bestNpc
end

local function Stage1_findAvailableBookingZone(buildings)
    if not buildings then return nil end
    for _, child in ipairs(buildings:GetChildren()) do
        if child.Name:match("^mugshot_%d+$") then
            local occupied = child:GetAttribute("Occupied") == true
            if not occupied then
                local bookZone = child:FindFirstChild("BookZone")
                if bookZone then
                    local center = Core_getZoneCenter(bookZone)
                    if center then return center end
                end
            end
        end
    end
    return nil
end

local function Stage1_runMugshot()
    local phase = "waiting"
    local done = false
    local conn
    conn = MugshotRemote.OnClientEvent:Connect(function(action, data)
        if action == "start" then
            phase = "snap"
        elseif action == "file" then
            phase = "file"
            task.spawn(function()
                task.wait(1.6)
                if phase == "file" then
                    MugshotRemote:FireServer("done")
                end
            end)
        elseif action == "end" then
            phase = "done"
            done = true
        end
    end)
    local start = os.clock()
    while not done and os.clock() - start < 20 do
        if phase == "snap" then
            MugshotRemote:FireServer("snap")
        end
        task.wait(0.3)
    end
    if conn then conn:Disconnect() end
    return done
end

local function Stage2_findAvailableCell(buildings, excludeNames)
    if not buildings then return nil end
    for _, child in ipairs(buildings:GetChildren()) do
        if child.Name:match("^cell_%d+$") then
            if not (excludeNames and excludeNames[child.Name]) then
                local cap = child:GetAttribute("Capacity")
                local inmates = child:GetAttribute("Inmates")
                if cap and inmates and inmates < cap then
                    return child
                end
            end
        end
    end
    return nil
end

local function Stage2_lockNpcInCell(cellModel)
    local front = cellModel:FindFirstChild("Front")
    local barsWall = front and front:FindFirstChild("BarsWall")
    local lockPart = barsWall and barsWall:FindFirstChild("Lock")
    if not lockPart then return false, "nolock" end
    local prompt = lockPart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return false, "noprompt" end

    local frontPos = Core_getLockStandPos(cellModel)
    if not frontPos then
        if front:IsA("Model") then
            frontPos = front:GetPivot().Position
        else
            frontPos = front.Position
        end
    end
    Core_teleportToSafe(frontPos)

    local startInmates = cellModel:GetAttribute("Inmates") or 0
    local capacity = cellModel:GetAttribute("Capacity") or 0
    local start = os.clock()
    local npcIn = false

    while os.clock() - start < 10 do
        -- escape-interrupt cuma dipake kalau toggle Tackle nyala
        if Toggles.Tackle and Stage8_findEscapingNpc() then
            return false, "escape_priority"
        end

        local nowInmates = cellModel:GetAttribute("Inmates") or startInmates

        if not npcIn and nowInmates > startInmates then
            npcIn = true
        end

        if not npcIn and nowInmates >= capacity then
            return false, "stolen"
        end

        local doorOpen = cellModel:GetAttribute("DoorOpen")

        if npcIn then
            if doorOpen == false then
                return true, "locked"
            end
            if doorOpen == true then
                Core_tryFirePrompt(prompt)
            end
        else
            if doorOpen == false then
                Core_tryFirePrompt(prompt)
            elseif doorOpen == true then
                local spot = cellModel:GetAttribute("InmateSpot")
                if spot then
                    local spotOk, worldPos = pcall(function()
                        return cellModel:GetPivot():PointToWorldSpace(spot)
                    end)
                    if spotOk and worldPos then
                        Core_teleportTo(worldPos)
                    end
                end
            end
        end

        task.wait(0.3)
    end

    return npcIn, "timeout"
end

-- =====================================================================
-- STAGE 3: FEED NAPI LAPER (-> toggle Feed)
-- =====================================================================

local function Stage3_anyHungryNpc()
    local npcsFolder = Core_getOwnNpcsFolder()
    if not npcsFolder then return nil end
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:GetAttribute("Hungry") == true then
            return npc
        end
    end
    return nil
end

local function Stage3_getTrayZoneCenter(buildings)
    if not buildings then return nil end
    local kitchen = buildings:FindFirstChild("kitchen")
    if not kitchen then return nil end
    local zone = kitchen:FindFirstChild("TrayZone")
    if not zone then return nil end
    return Core_getZoneCenter(zone)
end

local function Stage3_findNearestFoodShelf(buildings, npcPos)
    local bestPrompt, bestCell, bestDist = nil, nil, math.huge
    for _, child in ipairs(buildings:GetChildren()) do
        if child.Name:match("^cell_%d+$") then
            local front = child:FindFirstChild("Front")
            local barsWall = front and front:FindFirstChild("BarsWall")
            local bars = barsWall and barsWall:FindFirstChild("Bars")
            local shelf = bars and bars:FindFirstChild("FoodShelf")
            local prompt = shelf and shelf:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                local shelfPos = shelf:IsA("Model") and shelf:GetPivot().Position or shelf.Position
                local dist = (shelfPos - npcPos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPrompt = prompt
                    bestCell = child
                end
            end
        end
    end
    return bestCell, bestPrompt
end

local function Stage3_deliverTrayAt(buildings, refPos, timeoutSec)
    local _, shelfPrompt = Stage3_findNearestFoodShelf(buildings, refPos)
    if not shelfPrompt then return false end

    local shelfPos = shelfPrompt.Parent:IsA("Model") and shelfPrompt.Parent:GetPivot().Position or shelfPrompt.Parent.Position
    Core_teleportTo(shelfPos)

    local start = os.clock()
    while os.clock() - start < (timeoutSec or 6) do
        if not hasTray() then
            return true
        end

        local _, freshPrompt = Stage3_findNearestFoodShelf(buildings, refPos)
        local target = freshPrompt or shelfPrompt
        if target and target.Enabled then
            Core_tryFirePrompt(target)
        end

        task.wait(0.3)
    end

    return not hasTray()
end

local function Stage3_feedingCycle()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local buildings = Core_getBuildings()
    if not buildings then return false end

    if hasTray() and not Stage3_anyHungryNpc() then
        local hrp = Core_getHRP()
        if not hrp then return false end
        local delivered = Stage3_deliverTrayAt(buildings, hrp.Position, 8)
        if not delivered then
            warn("[PT AutoFarm] masih kepegang tray tanpa target jelas, retry cycle berikutnya")
        end
        return delivered
    end

    local hungryNpc = Stage3_anyHungryNpc()
    if not hungryNpc then return false end

    local hrp = hungryNpc:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    if not hasTray() then
        local trayPos = Stage3_getTrayZoneCenter(buildings)
        if not trayPos then return false end
        Core_teleportTo(trayPos)

        local start = os.clock()
        while os.clock() - start < 5 do
            if hasTray() then break end
            task.wait(0.2)
        end
        if not hasTray() then return false end
    end

    local delivered = Stage3_deliverTrayAt(buildings, hrp.Position, 8)
    if not delivered then
        warn("[PT AutoFarm] gagal deliver tray ke " .. tostring(hungryNpc.Name) .. ", retry cycle berikutnya")
    end
    return delivered
end

-- =====================================================================
-- STAGE 4: AUTO CALM PROTEST (-> toggle Protest)
-- =====================================================================

local function Stage4_getProtestingNpcs()
    local npcsFolder = Core_getOwnNpcsFolder()
    if not npcsFolder then return {} end
    local list = {}
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:GetAttribute("Protest") ~= nil then
            table.insert(list, npc)
        end
    end
    return list
end

local function Stage4_calmProtestCycle()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local list = Stage4_getProtestingNpcs()
    if #list == 0 then return false end

    for _, npc in ipairs(list) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            Core_teleportTo(hrp.Position)
            task.wait(0.6)
        end
    end

    return true
end

-- =====================================================================
-- STAGE 5: AUTO SEARCH / CONTRABAND (-> toggle Search, thread terpisah)
-- =====================================================================

local function Stage5_findSearchPrompt()
    local hrp = Core_getHRP()
    if not hrp then return nil end
    local bestPrompt, bestDist = nil, math.huge
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("Interact") == "search" and prompt.Enabled then
            local part = prompt.Parent
            local pos = part and part:IsA("BasePart") and part.Position
            if pos then
                local dist = (pos - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPrompt = prompt
                end
            end
        end
    end
    return bestPrompt
end

local function Stage5_getCellModel(instance)
    local cur = instance
    for _ = 1, 8 do
        if not cur then return nil end
        if cur.Name:match("^cell_%d+$") then
            return cur
        end
        cur = cur.Parent
    end
    return nil
end

local function Stage5_findSearchItem(cellModel)
    if not cellModel then return nil end
    for _, d in ipairs(cellModel:GetDescendants()) do
        if d.Name:match("^SearchItem_") then
            return d
        end
    end
    return nil
end

local function Stage5_getItemWorldPos(item)
    if not item then return nil end
    if item:IsA("Model") then
        local pOk, pivot = pcall(function() return item:GetPivot() end)
        if pOk then return pivot.Position end
    end
    if item:IsA("BasePart") then
        return item.Position
    end
    for _, d in ipairs(item:GetDescendants()) do
        if d:IsA("BasePart") then
            return d.Position
        end
    end
    return nil
end

local function Stage5_fireTapAt(targetPos)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local direction = (targetPos - origin)
    if direction.Magnitude < 0.01 then return false end
    direction = direction.Unit

    local fireOk = pcall(function()
        SearchRemote:FireServer("tap", origin, direction)
    end)
    return fireOk
end

local function Stage5_runSearch()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local prompt = Stage5_findSearchPrompt()
    if not prompt then return false end

    local part = prompt.Parent
    local pos = part and part:IsA("BasePart") and part.Position
    if not pos then
        warn("[PT AutoFarm] search: prompt ketemu tapi parent bukan BasePart, skip")
        return false
    end

    local cellModel = Stage5_getCellModel(prompt)
    if not cellModel then
        warn("[PT AutoFarm] search: gagal nemu cell_N induk, skip")
        return false
    end

    Core_teleportTo(pos)

    if not Core_tryFirePrompt(prompt) then
        warn("[PT AutoFarm] search: gagal fire prompt")
        return false
    end

    local startWait = os.clock()
    while LocalPlayer:GetAttribute("Search") == nil and os.clock() - startWait < 3 do
        task.wait(0.1)
    end
    if LocalPlayer:GetAttribute("Search") == nil then
        warn("[PT AutoFarm] search: gagal start (prompt basi/kerebut), skip")
        return false
    end

    local item = Stage5_findSearchItem(cellModel)
    if not item then
        warn("[PT AutoFarm] search: SearchItem_* ga ketemu di " .. cellModel:GetFullName() .. ", nunggu timer abis aja")
    end

    local hardTimeout = os.clock() + 40
    local lastTapAt = 0

    while LocalPlayer:GetAttribute("Search") ~= nil and os.clock() < hardTimeout do
        if item and item.Parent and os.clock() - lastTapAt >= 0.4 then
            lastTapAt = os.clock()
            local itemPos = Stage5_getItemWorldPos(item)
            if itemPos then
                Stage5_fireTapAt(itemPos)
            end
        end
        task.wait(0.2)
    end

    return LocalPlayer:GetAttribute("Search") == nil
end

-- =====================================================================
-- STAGE 6: LEAD SICK NAPI KE CLINIC (-> toggle Clinic, tween)
-- =====================================================================

local function Stage6_findSickNpc()
    local npcsFolder = Core_getOwnNpcsFolder()
    if not npcsFolder then return nil end
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:GetAttribute("Sick") == true then
            return npc
        end
    end
    return nil
end

local function Stage6_findLeadPrompt(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt:GetAttribute("Interact") == "lead" and prompt.Enabled then
            local part = prompt.Parent
            local pos = part and part:IsA("BasePart") and part.Position
            if pos and (pos - hrp.Position).Magnitude < 15 then
                return prompt
            end
        end
    end
    return nil
end

local function Stage6_findEmptyBedSlot(clinicModel)
    local npcsFolder = Core_getOwnNpcsFolder()

    local candidates = {}
    for _, d in ipairs(clinicModel:GetDescendants()) do
        if d:IsA("Model") and d:GetAttribute("Role") == "ClinicBed" then
            table.insert(candidates, d)
        end
    end

    if #candidates == 0 then
        warn("[Stage6] no physical bed found in clinic (belum dibeli kemungkinan)")
        return nil
    end

    for _, bedModel in ipairs(candidates) do
        local bedOk, bedPos = pcall(function() return bedModel:GetPivot().Position end)
        if bedOk then
            local taken = false
            if npcsFolder then
                for _, otherNpc in ipairs(npcsFolder:GetChildren()) do
                    local ohrp = otherNpc:FindFirstChild("HumanoidRootPart")
                    if ohrp and (ohrp.Position - bedPos).Magnitude < 4 then
                        taken = true
                        break
                    end
                end
            end
            if not taken then
                return bedPos
            end
        end
    end

    return nil
end

local function Stage6_waitUntilFollowing(npc, timeoutSec)
    local start = os.clock()
    while os.clock() - start < (timeoutSec or 5) do
        local state = npc:GetAttribute("PrisonerState")
        if state == "Following" or state == "Led" then
            return true
        end
        task.wait(0.2)
    end
    return false
end

local function Stage6_runLeadToClinic()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local npc = Stage6_findSickNpc()
    if not npc then return false end

    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    warn("[Stage6] sick npc: " .. npc.Name .. " — walking to npc")
    Core_tweenTo(hrp.Position)

    local prompt = Stage6_findLeadPrompt(npc)
    if not prompt then
        warn("[Stage6] lead prompt not found near npc")
        return false
    end

    if not Core_tryFirePrompt(prompt) then
        warn("[Stage6] fire prompt failed")
        return false
    end

    if not Stage6_waitUntilFollowing(npc, 5) then
        warn("[Stage6] npc never started following, aborting")
        return false
    end

    local plotName = LocalPlayer:GetAttribute("SpacePlot")
    local clinic = workspace:FindFirstChild("Plots")
        and workspace.Plots:FindFirstChild(plotName)
        and workspace.Plots[plotName]:FindFirstChild("Buildings")
        and workspace.Plots[plotName].Buildings:FindFirstChild("clinic")
    if not clinic then
        warn("[Stage6] clinic model not found")
        return false
    end

    local bedPos = Stage6_findEmptyBedSlot(clinic)
    if not bedPos then
        warn("[Stage6] no empty bed found (full or belum dibeli) — leaving npc, retry next loop")
        return false
    end

    warn("[Stage6] walking to bed position: " .. tostring(bedPos))
    Core_tweenTo(bedPos, nil, true)

    warn("[Stage6] npc delivered to clinic bed — flow done")
    return true
end

-- =====================================================================
-- STAGE 7: AUTO BREAK UP FIGHT (-> toggle Fight, teleport)
-- =====================================================================

local function Stage7_findBreakUpPrompt()
    local hrp = Core_getHRP()
    if not hrp then return nil end
    local bestPrompt, bestDist = nil, math.huge
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p:GetAttribute("Interact") == "fight" and p.Enabled then
            local pos = Core_getPos(p.Parent)
            if pos then
                local dist = (pos - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPrompt = p
                end
            end
        end
    end
    return bestPrompt
end

local function Stage7_runBreakUpFight()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local prompt = Stage7_findBreakUpPrompt()
    if not prompt then return false end

    local pos = Core_getPos(prompt.Parent)
    if not pos then return false end

    warn("[Stage7] fight detected, going to break it up")
    Core_teleportTo(pos)

    if Core_tryFirePrompt(prompt) then
        warn("[Stage7] break up prompt fired")
        return true
    end

    warn("[Stage7] fire prompt failed")
    return false
end

-- =====================================================================
-- STAGE 8: TACKLE ESCAPING NAPI + RETURN KE CELL ASAL (-> toggle Tackle)
-- =====================================================================

function Stage8_findEscapingNpc()
    local npcsFolder = Core_getOwnNpcsFolder()
    if not npcsFolder then return nil end
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:GetAttribute("PrisonerState") == "Escaping" then
            return npc
        end
    end
    return nil
end

local function Stage8_findTacklePrompt(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, p in ipairs(hrp:GetChildren()) do
        if p:IsA("ProximityPrompt") and p:GetAttribute("Interact") == "tackle" and p.Enabled then
            return p
        end
    end
    return nil
end

local function Stage8_closeCellDoor(cellModel, timeoutSec)
    local front = cellModel:FindFirstChild("Front")
    local barsWall = front and front:FindFirstChild("BarsWall")
    local lockPart = barsWall and barsWall:FindFirstChild("Lock")
    local prompt = lockPart and lockPart:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then return false end

    local frontPos = Core_getLockStandPos(cellModel)
    if not frontPos then
        frontPos = front:IsA("Model") and front:GetPivot().Position or front.Position
    end
    Core_teleportToSafe(frontPos)

    local start = os.clock()
    while os.clock() - start < (timeoutSec or 6) do
        if cellModel:GetAttribute("DoorOpen") == false then return true end
        Core_tryFirePrompt(prompt)
        task.wait(0.3)
    end
    return cellModel:GetAttribute("DoorOpen") == false
end

local function Stage8_runTackleEscaping()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local npc = Stage8_findEscapingNpc()
    if not npc then return false end

    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local npcName = npc.Name
    local buildings = Core_getBuildings()

    warn("[Stage8] npc escaping: " .. npcName .. " — chasing (teleport)")
    local tackled = false
    local start = os.clock()
    while os.clock() - start < 10 do
        if npc:GetAttribute("PrisonerState") ~= "Escaping" then
            warn("[Stage8] npc state changed mid-chase, stop chase")
            break
        end
        local hrpNow = npc:FindFirstChild("HumanoidRootPart")
        if not hrpNow then break end

        Core_teleportTo(hrpNow.Position)

        local prompt = Stage8_findTacklePrompt(npc)
        if prompt then
            if Core_tryFirePrompt(prompt) then
                warn("[Stage8] tackle fired")
                tackled = true
                break
            end
        end
        task.wait(0.1)
    end

    if not tackled then
        warn("[Stage8] chase timeout, npc escaped or unreachable")
        return false
    end

    task.wait(0.3)
    local cellName = _G.PT_NpcCellMap[npcName]
    if not cellName then
        warn("[Stage8] no cell record for " .. npcName .. " in PT_NpcCellMap — skip return step")
        return true
    end

    local cell = buildings and buildings:FindFirstChild(cellName)
    if not cell then
        warn("[Stage8] cell " .. tostring(cellName) .. " not found in buildings — skip return step")
        return true
    end

    warn("[Stage8] teleporting to origin cell: " .. cell.Name)
    if Stage8_closeCellDoor(cell) then
        warn("[Stage8] cell closed, npc returned: " .. cell.Name)
    else
        warn("[Stage8] failed to confirm door closed for " .. cell.Name)
    end

    return true
end

-- =====================================================================
-- STAGE 9: SAFETY — AUTO TUTUP CELL YANG KEBUKA (-> toggle DoorSafety)
-- =====================================================================

local function Stage9_findOpenDoorCell()
    local buildings = Core_getBuildings()
    if not buildings then return nil end
    for _, child in ipairs(buildings:GetChildren()) do
        if child.Name:match("^cell_%d+$") then
            if child:GetAttribute("DoorOpen") == true then
                return child
            end
        end
    end
    return nil
end

local function Stage9_runDoorSafety()
    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    local cell = Stage9_findOpenDoorCell()
    if not cell then return false end

    warn("[Stage9] pintu kebuka di " .. cell.Name .. " (ga lagi diproses) — nutup lagi")
    if Stage8_closeCellDoor(cell, 6) then
        warn("[Stage9] " .. cell.Name .. " berhasil ditutup")
        return true
    end

    warn("[Stage9] gagal nutup " .. cell.Name .. ", coba lagi loop berikutnya")
    return false
end

-- =====================================================================
-- MAIN: GRAB -> MUGSHOT -> LOCK (-> toggle GrabBook)
-- =====================================================================

_G.PT_PendingLockNpc = _G.PT_PendingLockNpc or nil

local function Main_tryLockLoop(npc)
    local triedCells = {}
    for attempt = 1, 5 do
        if Toggles.Tackle and Stage8_findEscapingNpc() then
            _G.PT_PendingLockNpc = npc
            return false
        end

        if LocalPlayer:GetAttribute("Leading") == nil then
            _G.PT_PendingLockNpc = nil
            return false
        end

        local buildingsNow = Core_getBuildings()
        if not buildingsNow then return false end

        local cell = Stage2_findAvailableCell(buildingsNow, triedCells)
        if not cell then
            return false
        end

        triedCells[cell.Name] = true

        local lockOk, reason = Stage2_lockNpcInCell(cell)
        if lockOk then
            _G.PT_NpcCellMap[npc.Name] = cell.Name
            _G.PT_PendingLockNpc = nil
            return true
        end

        if reason == "escape_priority" then
            _G.PT_PendingLockNpc = npc
            return false
        end
    end

    return false
end

local function Main_cycle()
    if LocalPlayer:GetAttribute("Mugshot") ~= nil then return false end
    if LocalPlayer:GetAttribute("Search") ~= nil then return false end

    if _G.PT_PendingLockNpc then
        local npc = _G.PT_PendingLockNpc
        if not npc.Parent or LocalPlayer:GetAttribute("Leading") == nil then
            _G.PT_PendingLockNpc = nil
        else
            return Main_tryLockLoop(npc)
        end
    end

    if LocalPlayer:GetAttribute("Leading") ~= nil then return false end
    if hasTray() then return false end

    if Toggles.Tackle and Stage8_findEscapingNpc() then return false end

    local buildings = Core_getBuildings()
    if not buildings then return false end

    if not Stage2_findAvailableCell(buildings) then
        return false
    end

    local takePrompt, npc = Stage1_findTakeTarget()
    if not takePrompt or not npc then return false end

    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
    if not npcHRP then return false end

    Core_teleportTo(npcHRP.Position)

    if not Core_tryFirePrompt(takePrompt) then return false end

    task.wait(0.5)
    if LocalPlayer:GetAttribute("Leading") == nil then return false end

    local zonePos = Stage1_findAvailableBookingZone(buildings)
    if zonePos then
        Core_teleportTo(zonePos)
        task.wait(0.3)
        Stage1_runMugshot()
    end

    if LocalPlayer:GetAttribute("Leading") == nil then return false end

    return Main_tryLockLoop(npc)
end

-- =====================================================================
-- AUTO FARM LOOPS — cuma jalanin stage yang togglenya nyala
-- =====================================================================

task.spawn(function()
    while alive do
        if Toggles.Tackle    then Core_runStage("Stage8_tackle",     Stage8_runTackleEscaping) end
        if Toggles.Fight     then Core_runStage("Stage7_fight",      Stage7_runBreakUpFight)   end
        if Toggles.DoorSafety then Core_runStage("Stage9_doorSafety", Stage9_runDoorSafety)     end
        if Toggles.Clinic    then Core_runStage("Stage6_clinic",     Stage6_runLeadToClinic)   end
        if Toggles.Feed      then Core_runStage("Stage3_feeding",    Stage3_feedingCycle)      end
        if Toggles.Protest   then Core_runStage("Stage4_protest",    Stage4_calmProtestCycle)  end
        if Toggles.GrabBook  then Core_runStage("Main_cycle",        Main_cycle)               end

        local activeCount = 0
        for _, v in pairs(Toggles) do if v then activeCount = activeCount + 1 end end
        setFarmStatus(activeCount > 0 and ("Running (" .. activeCount .. " feature active)") or "Idle")

        task.wait(1)
    end
end)

task.spawn(function()
    while alive do
        if Toggles.Search then
            Core_runStage("Stage5_search", Stage5_runSearch)
        end
        task.wait(1)
    end
end)

-- =====================================================================
-- AUTO MAYOR CALL (-> toggle MayorCall + dropdown MayorRiskMode)
-- =====================================================================

local function safeRequireByPath(root, ...)
    local inst = root
    for _, childName in ipairs({ ... }) do
        if not inst then return nil end
        local wOk, found = pcall(function() return inst:WaitForChild(childName, 5) end)
        inst = wOk and found or nil
    end
    if not inst then return nil end
    local rOk, mod = pcall(require, inst)
    if rOk then return mod end
    warn("[PrisonTycoon] gagal require " .. inst:GetFullName() .. ": " .. tostring(mod))
    return nil
end

local Net = safeRequireByPath(RS, "Shared", "Net")
local Hooks = safeRequireByPath(LocalPlayer.PlayerScripts, "Client", "UI", "Hooks")
local MayorAvailable = (Net ~= nil) and (Hooks ~= nil)

if not MayorAvailable then
    warn("[PrisonTycoon] Net/Hooks module ga ketemu — Auto Mayor Call bakal dimatiin otomatis kalau dinyalain")
end

local function findPhonePrompt()
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p:GetAttribute("Interact") == "phone" and p.Enabled then
            local owner = p:GetAttribute("OwnerUserId")
            if owner == nil or owner == LocalPlayer.UserId then
                return p
            end
        end
    end
    return nil
end

local answering = false
task.spawn(function()
    while alive do
        if Toggles.MayorCall and MayorAvailable and not answering then
            local prompt = findPhonePrompt()
            if prompt then
                answering = true
                local part = prompt.Parent
                local pos = part and part:IsA("BasePart") and part.Position
                if pos then
                    warn("[AutoMayor] phone ringing, answering")
                    Core_teleportTo(pos)
                    local fireOk = Core_tryFirePrompt(prompt)
                    warn("[AutoMayor] fire prompt ok? " .. tostring(fireOk))
                end
                task.delay(5, function() answering = false end)
            end
        end
        task.wait(0.5)
    end
end)

local mayorState = { active = false, risk = nil }

local function mayorDecide()
    if not Toggles.MayorCall or not MayorAvailable then return end
    if not mayorState.active then return end

    local threshold = RISK_PRESETS[MayorRiskMode] or RISK_PRESETS.Balance

    if mayorState.risk and mayorState.risk < threshold then
        warn("[AutoMayor] risk " .. tostring(mayorState.risk) .. " < " .. threshold .. " -> MORE")
        pcall(Net.send, "Happening", "more")
        setMayorStatus("Last call: risk " .. tostring(mayorState.risk) .. " -> MORE")
    else
        warn("[AutoMayor] risk " .. tostring(mayorState.risk) .. " >= " .. threshold .. " -> DEAL")
        pcall(Net.send, "Happening", "deal")
        setMayorStatus("Last call: risk " .. tostring(mayorState.risk) .. " -> DEAL")
    end
end

if MayorAvailable then
    Hooks.event("HappeningStarted", function(id, _, _, data)
        if id ~= "mayor" then return end
        warn("[AutoMayor] HappeningStarted mayor, risk=" .. tostring(data.risk))
        mayorState.active = true
        mayorState.risk = data.risk
        mayorDecide()
    end)

    Hooks.event("HappeningUpdate", function(id, data)
        if id ~= "mayor" or not mayorState.active then return end
        warn("[AutoMayor] HappeningUpdate mayor, risk=" .. tostring(data.risk))
        mayorState.risk = data.risk
        mayorDecide()
    end)

    Hooks.event("HappeningEnded", function(id)
        if id == "mayor" then
            warn("[AutoMayor] HappeningEnded mayor")
            mayorState.active = false
        end
    end)
end

-- =====================================================================
-- GUI
-- =====================================================================

local function icon(...)
    for _, name in ipairs({ ... }) do
        local okI, found = pcall(WindUI.Creator.Icon, name)
        if okI and found then return name end
    end
    return "info"
end

WindUI:AddTheme({
    Name = "RansBlox",
    Accent = Color3.fromHex("#FF8200"),
    Background = Color3.fromHex("#0B0B0D"),
    BackgroundTransparency = 0.02,
    Text = Color3.fromHex("#F5F5F5"),
    Outline = Color3.fromHex("#27272A"),
    Placeholder = Color3.fromHex("#FFB066"),
    Button = Color3.fromHex("#EA6F00"),
    Icon = Color3.fromHex("#FF8200"),
    Hover = Color3.fromHex("#1F1F23"),
    WindowBackground = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#1C1006"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#0B0B0D"), Transparency = 0 },
    }, { Rotation = 135 }),
    WindowShadow = Color3.fromHex("#000000"),
    WindowTopbarTitle = Color3.fromHex("#FFFFFF"),
    WindowTopbarAuthor = Color3.fromHex("#FF9F40"),
    WindowTopbarIcon = Color3.fromHex("#FF8200"),
    WindowTopbarButtonIcon = Color3.fromHex("#FF8200"),
    TabBackground = Color3.fromHex("#18181B"),
    TabTitle = Color3.fromHex("#F5F5F5"),
    TabIcon = Color3.fromHex("#FF8200"),
    ElementBackground = Color3.fromHex("#161618"),
    ElementTitle = Color3.fromHex("#F5F5F5"),
    ElementDesc = Color3.fromHex("#A8A29E"),
    ElementIcon = Color3.fromHex("#FF8200"),
    Toggle = Color3.fromHex("#FF8200"),
    ToggleBar = Color3.fromHex("#2A2A2E"),
    Slider = Color3.fromHex("#FF8200"),
    SliderThumb = Color3.fromHex("#FFFFFF"),
})

local Window = WindUI:CreateWindow({
    Title = HUB_NAME,
    Author = "Ransblox Scripts",
    Icon = "youtube",
    Theme = "RansBlox",
    NewElements = true,
    Folder = HUB_NAME,
    Size = UDim2.fromOffset(560, 360),
    Radius = 20,
    ElementsRadius = 16,
    ShadowTransparency = 0.6,
    User = { Enabled = true },
    Topbar = { Height = 44, ButtonsType = "Mac" },
    HideSearchBar = false,
    OpenButton = {
        Title = HUB_NAME,
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(Color3.fromHex("#FF9A1F"), Color3.fromHex("#FF6A00")),
    },
    ToggleKey = Enum.KeyCode.RightControl,
})

Window:Tag({ Title = VERSION, Icon = "youtube", Color = Color3.fromHex("#FF8200"), Border = true })
Window:Tag({ Title = "FREE", Icon = "badge-check", Color = Color3.fromHex("#22C55E"), Border = true })

local Tabs = {}
Tabs.Home   = Window:Tab({ Title = "Home",   Icon = icon("house", "home"),    IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Main   = Window:Tab({ Title = "Main",   Icon = icon("lock", "house"),    IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Events = Window:Tab({ Title = "Events", Icon = icon("phone-call", "bell"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc   = Window:Tab({ Title = "Misc",   Icon = icon("info"),             IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

local function section(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = false })
end

local function openSection(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = true })
end

local function pickValue(v)
    if type(v) == "table" then v = v.Title or v.Name or v[1] end
    return tostring(v)
end

local function copyLink(name, link)
    pcall(function() setclipboard(link) end)
    WindUI:Notify({ Title = name, Content = "Link copied to clipboard!", Icon = "check", Duration = 2 })
end

-- ===== HOME TAB =====
local AboutBox = openSection(Tabs.Home, "Ransblox Scripts", "user")
AboutBox:Paragraph({
    Title = "Welcome!",
    Desc = "I make Roblox script showcases on YouTube and run a free script hub. "
        .. "New scripts drop on the channel and the website, so subscribe to catch them first.",
})

local FreeBox = openSection(Tabs.Home, "100% Free Script", "shield-check")
FreeBox:Paragraph({
    Title = "This script is free",
    Desc = "No key system, no payments, no subscription. It was never sold and it never will be.",
})
FreeBox:Paragraph({
    Title = "Found a version with a key? It's a scam",
    Desc = "If someone is asking you for a key, money, or to complete tasks to use this script, "
        .. "you're looking at a fake copy. Don't pay, don't enter your info. "
        .. "Only trust the official links below.",
})

local LinkBox = openSection(Tabs.Home, "Official Links", "link")
local LinkGroup = LinkBox:Group()
LinkGroup:Button({
    Title = "YouTube", Desc = "Ransblox Scripts - subscribe for more scripts", Icon = "youtube",
    Color = "Red",
    Callback = function() copyLink("YouTube", YT_LINK) end,
})
LinkGroup:Button({
    Title = "Website", Desc = "ransblox.net - script hub & request page", Icon = "globe",
    Callback = function() copyLink("Website", WEB_LINK) end,
})

-- ===== MAIN TAB (Auto Farm) =====
local FarmBox = section(Tabs.Main, "Auto Farm", "lock")

FarmBox:Toggle({
    Title = "Auto Grab & Book",
    Desc = "Captures new inmates, takes mugshots, and locks them in a cell.",
    Value = false,
    Callback = function(v) Toggles.GrabBook = v end,
})
FarmBox:Toggle({
    Title = "Auto Feed",
    Desc = "Delivers food trays to hungry inmates.",
    Value = false,
    Callback = function(v) Toggles.Feed = v end,
})
FarmBox:Toggle({
    Title = "Auto Calm Protest",
    Desc = "Calms down protesting inmates.",
    Value = false,
    Callback = function(v) Toggles.Protest = v end,
})
FarmBox:Toggle({
    Title = "Auto Search",
    Desc = "Searches cells for contraband.",
    Value = false,
    Callback = function(v) Toggles.Search = v end,
})
FarmBox:Toggle({
    Title = "Auto Clinic",
    Desc = "Leads sick inmates to the clinic.",
    Value = false,
    Callback = function(v) Toggles.Clinic = v end,
})
FarmBox:Toggle({
    Title = "Auto Break Fight",
    Desc = "Breaks up inmate fights.",
    Value = false,
    Callback = function(v) Toggles.Fight = v end,
})
FarmBox:Toggle({
    Title = "Auto Tackle Escape",
    Desc = "Catches and returns escaping inmates.",
    Value = false,
    Callback = function(v) Toggles.Tackle = v end,
})
FarmBox:Toggle({
    Title = "Door Safety",
    Desc = "Closes any cell doors left open.",
    Value = false,
    Callback = function(v) Toggles.DoorSafety = v end,
})

local FarmStatusP = FarmBox:Paragraph({ Title = "Status", Desc = "Idle" })
setFarmStatus = function(text)
    pcall(function() FarmStatusP:SetDesc(text) end)
end

-- ===== EVENTS TAB (Mayor) =====
local MayorBox = section(Tabs.Events, "Mayor", "phone-call")

MayorBox:Toggle({
    Title = "Auto Mayor Call",
    Desc = "Answers the Mayor's call and negotiates automatically.",
    Value = false,
    Callback = function(v)
        if v and not MayorAvailable then
            WindUI:Notify({
                Title = "Auto Mayor Call",
                Content = "Required game module not found, can't enable this.",
                Icon = "x",
                Duration = 4,
            })
            Toggles.MayorCall = false
            return
        end
        Toggles.MayorCall = v
    end,
})

MayorBox:Dropdown({
    Title = "Mayor Risk Mode",
    Flag = "MayorRiskMode",
    Desc = "Sets how aggressive the negotiation is (Safe / Balance / Risk).",
    Values = { "Safe", "Balance", "Risk" },
    Value = "Balance",
    Callback = function(v)
        MayorRiskMode = pickValue(v)
    end,
})

local MayorStatusP = MayorBox:Paragraph({ Title = "Status", Desc = "Idle" })
setMayorStatus = function(text)
    pcall(function() MayorStatusP:SetDesc(text) end)
end

-- ===== MISC TAB =====
local UIBox = section(Tabs.Misc, "Interface", "palette")

UIBox:Toggle({
    Title = "Glass Mode", Desc = "Makes the window slightly transparent",
    Value = false,
    Callback = function(v) Window:ToggleTransparency(v) end,
})
UIBox:Slider({
    Title = "UI Scale", Desc = "Lower it if the GUI is too big on mobile", Step = 0.05,
    Value = { Min = 0.7, Max = 1.2, Default = 1 },
    Callback = function(v) Window:SetUIScale(v) end,
})
UIBox:Keybind({
    Title = "Toggle GUI",
    Desc = "Key to show/hide the window",
    Value = "RightControl",
    Callback = function(key)
        local ok2, kc = pcall(function() return Enum.KeyCode[key] end)
        if ok2 and kc then Window:Toggle() end
    end,
})

local ConfigBox = section(Tabs.Misc, "Config", "save")
local ConfigStatusP = ConfigBox:Paragraph({
    Title = "Auto-save",
    Desc = "Dropdowns with a Flag are saved automatically whenever you change them, and loaded back next time you join.",
})

local ConfigGroup = ConfigBox:Group()
ConfigGroup:Button({
    Title = "Save Now", Desc = "Save your current settings", Icon = "save",
    Callback = function()
        if Window.CurrentConfig then
            local saveOk = pcall(function() Window.CurrentConfig:Save() end)
            if saveOk then
                WindUI:Notify({ Title = "Config", Content = "Settings saved!", Icon = "check", Duration = 2 })
                pcall(function() ConfigStatusP:SetDesc("Last saved just now.") end)
            else
                WindUI:Notify({ Title = "Config", Content = "Couldn't save settings.", Icon = "x", Duration = 3 })
            end
        end
    end,
})
ConfigGroup:Button({
    Title = "Load Saved", Desc = "Load your last saved settings", Icon = "upload",
    Callback = function()
        if Window.CurrentConfig then
            local loadOk = pcall(function() Window.CurrentConfig:Load() end)
            if loadOk then
                WindUI:Notify({ Title = "Config", Content = "Settings loaded!", Icon = "check", Duration = 2 })
            else
                WindUI:Notify({ Title = "Config", Content = "No saved settings found.", Icon = "x", Duration = 3 })
            end
        end
    end,
})

-- ===== UNLOAD =====
local function unload()
    if _G.PRISONTYCOON_Unloaded == Window then return end
    _G.PRISONTYCOON_Unloaded = Window
    alive = false
    for key in pairs(Toggles) do Toggles[key] = false end
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.PRISONTYCOON_Unload = nil
end
_G.PRISONTYCOON_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
