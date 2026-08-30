-- ==============================================================================
-- HOUSE OF THE LOCUST — ULTIMATE SURVIVAL SUITE
-- Inspired by Hub V3.0 & built on VindUI
-- Location: C:\Users\Admin\Documents\lunascripts\HouseOfTheLocust.lua
-- ==============================================================================

local VindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Skinny-yz/VVind-UI/refs/heads/main/src.lua"
))()

-- ==============================================================================
-- SERVICES
-- ==============================================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = game:GetService("VirtualUser")
local StatsService     = game:GetService("Stats")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

pcall(function()
    if VindUI.SetBlurEnabled then
        VindUI:SetBlurEnabled(false)
    end
end)

-- ==============================================================================
-- CONFIGURATION
-- ==============================================================================
local Config = {
    -- Locust (Single closest active killer)
    LocustESP          = true,
    LocustTracer       = false,
    LocustColor        = Color3.fromRGB(255, 35, 60),

    -- Items / WireCutter / Keycard
    WireCutterESP      = true,
    WireCutterColor    = Color3.fromRGB(255, 215, 0),

    KeycardESP         = true,
    KeycardColor       = Color3.fromRGB(255, 140, 0),

    -- Puzzles & Locked Doors
    CubesESP           = true,
    CubesColor         = Color3.fromRGB(0, 230, 255),

    DoorsESP           = true,
    DoorsColor         = Color3.fromRGB(180, 70, 255),

    -- Smart Unlooted Cabinets
    CabinetsESP        = false,
    CabinetsColor      = Color3.fromRGB(0, 255, 100),

    -- Players
    PlayerESP          = false,
    PlayerColor        = Color3.fromRGB(0, 150, 255),

    -- Atmosphere
    Fullbright         = true,
    BrightnessLevel    = 2,
    ClockTime          = 14,
    RemoveFog          = true,
    ThirdPerson        = false,
    ThirdPersonDist    = 12,

    -- Threat Defense
    LocustAlert        = true,
    AlertDistance      = 70,
    AutoSafeAscend     = false,
    SafeSpotHeight     = 22,

    -- Automation
    InstantInteract    = true,
    AutoGrabItems      = false,
    AutoSearchCabinets = false,
    InteractRadius     = 16,

    -- Movement
    SpeedBoost         = false,
    WalkSpeed          = 22,
    InfiniteStamina    = true,
    Noclip             = false,
    InfiniteJump       = false,
    Fly                = false,
    FlySpeed           = 35,
    FlyKey             = Enum.KeyCode.F,

    -- Misc / FPS Overlay
    ShowStatsOverlay   = false,
    AntiAFK            = true,
}

local OriginalLighting = {
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    FogEnd         = Lighting.FogEnd,
    FogStart       = Lighting.FogStart,
    GlobalShadows  = Lighting.GlobalShadows,
}

local DrawingCache   = { Locust = {}, WireCutter = {}, Keycard = {}, Cubes = {}, Doors = {}, Cabinets = {}, Players = {} }
local LootedCabinets = {}
local CachedPrompts  = {}
local Connections    = {}
local FlyingActive   = false
local FlyBodyVel     = nil
local FlyBodyGyro    = nil
local LastAlertTime  = 0
local ActiveSafePos  = nil

-- ==============================================================================
-- FPS / PING STATS OVERLAY
-- ==============================================================================
local StatsGui = Instance.new("ScreenGui")
StatsGui.Name = "LocustStatsOverlay"
StatsGui.ResetOnSpawn = false
StatsGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local statsFrame = Instance.new("TextLabel")
statsFrame.Name = "StatsLabel"
statsFrame.Size = UDim2.new(0, 150, 0, 26)
statsFrame.Position = UDim2.new(1, -160, 0, 12)
statsFrame.BackgroundColor3 = Color3.fromRGB(14, 20, 16)
statsFrame.BackgroundTransparency = 0.2
statsFrame.BorderSizePixel = 0
statsFrame.Text = "FPS: -- | Ping: -- ms"
statsFrame.TextColor3 = Color3.fromRGB(0, 255, 120)
statsFrame.Font = Enum.Font.SourceSansBold
statsFrame.TextSize = 13
statsFrame.Visible = false
statsFrame.Parent = StatsGui

local statsCorner = Instance.new("UICorner", statsFrame)
statsCorner.CornerRadius = UDim.new(0, 6)

local statsStroke = Instance.new("UIStroke", statsFrame)
statsStroke.Color = Color3.fromRGB(0, 200, 80)
statsStroke.Thickness = 1.2
statsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local frameCount = 0
local lastStatsTime = tick()

-- ==============================================================================
-- UTILITY FUNCTIONS
-- ==============================================================================
local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChildWhichIsA("BasePart")
end

local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function clearGroup(group)
    for obj, items in pairs(group) do
        for _, d in pairs(items) do
            pcall(function() d:Remove() end)
        end
        group[obj] = nil
    end
end

-- ==============================================================================
-- TARGETED OBJECT RESOLUTION (SINGLE CLOSEST KILLER & EXACT OBJECTIVES)
-- ==============================================================================
local TargetData = {
    Locust     = nil, -- Single closest active killer
    WireCutter = nil, -- Workspace.WireCutter
    Keycard    = nil, -- Keycard on Locust or dropped
    Cubes      = {},  -- CubeYellow, CubeRed, CubeBlue
    Doors      = {},  -- DoorWire, Keyhole, KeycardReader
    Cabinets   = {},  -- Searchable unlooted cabinets
}

local function findTargets()
    local myChar = LocalPlayer.Character
    local myRoot = getRoot(myChar)
    local myPos  = myRoot and myRoot.Position or Vector3.zero

    -- 1. SINGLE CLOSEST REAL LOCUST (Ignores Jumpscare/Cutscenes)
    local entities = Workspace:FindFirstChild("Entities")
    local closestLoc = nil
    local shortestDist = math.huge

    if entities then
        for _, obj in ipairs(entities:GetChildren()) do
            if obj.Name == "Locust" and obj:IsA("Model") then
                local hrp = getRoot(obj)
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myPos).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        closestLoc = { Model = obj, Root = hrp, Dist = math.floor(d) }
                    end
                end
            end
        end
    end
    TargetData.Locust = closestLoc

    -- 2. WIRECUTTER ONLY
    local wc = Workspace:FindFirstChild("WireCutter")
    if wc then
        local p = wc:FindFirstChild("Handle") or wc:FindFirstChildWhichIsA("BasePart")
        if p then
            TargetData.WireCutter = { Object = wc, Part = p }
        else
            TargetData.WireCutter = nil
        end
    else
        TargetData.WireCutter = nil
    end

    -- 3. KEYCARD ONLY
    if TargetData.Locust and TargetData.Locust.Model then
        local h = TargetData.Locust.Model:FindFirstChild("Handle")
        if h and h:FindFirstChildWhichIsA("ProximityPrompt") then
            TargetData.Keycard = { Object = h, Part = h }
        else
            TargetData.Keycard = nil
        end
    else
        TargetData.Keycard = nil
    end

    -- 4. CUBES (Yellow, Red, Blue)
    local newCubes = {}
    local cy = Workspace:FindFirstChild("CubeYellow")
    if cy and cy:IsA("BasePart") then table.insert(newCubes, { Part = cy, Name = "🟡 Yellow Cube", Raw = "CubeYellow", Det = "YellowDetector" }) end
    local cr = Workspace:FindFirstChild("CubeRed")
    if cr and cr:IsA("BasePart") then table.insert(newCubes, { Part = cr, Name = "🔴 Red Cube", Raw = "CubeRed", Det = "RedDetector" }) end
    local cb = Workspace:FindFirstChild("CubeBlue")
    if cb and cb:IsA("BasePart") then table.insert(newCubes, { Part = cb, Name = "🔵 Blue Cube", Raw = "CubeBlue", Det = "BlueDetector" }) end
    TargetData.Cubes = newCubes

    -- 5. DOORS & READERS
    local newDoors = {}
    local dw = Workspace:FindFirstChild("DoorWire")
    if dw then
        local p = dw:IsA("BasePart") and dw or dw:FindFirstChildWhichIsA("BasePart")
        if p then table.insert(newDoors, { Part = p, Name = "🔒 Wire Door" }) end
    end
    local kh = Workspace:FindFirstChild("Keyhole")
    if kh then
        local p = kh:IsA("BasePart") and kh or kh:FindFirstChildWhichIsA("BasePart")
        if p then table.insert(newDoors, { Part = p, Name = "🔑 Keyhole" }) end
    end
    local kr = Workspace:FindFirstChild("KeycardReader")
    if kr then
        local p = kr:IsA("BasePart") and kr or kr:FindFirstChildWhichIsA("BasePart")
        if p then table.insert(newDoors, { Part = p, Name = "💳 Keycard Reader" }) end
    end
    TargetData.Doors = newDoors

    -- 6. UNLOOTED CABINETS ONLY (Tracks looted state when within 6.5 studs)
    local newCabinets = {}
    local cabFolder = Workspace:FindFirstChild("Cabinets")
    if cabFolder then
        for _, cab in ipairs(cabFolder:GetChildren()) do
            local interact = cab:FindFirstChild("Interact") or cab:FindFirstChildWhichIsA("BasePart")
            if interact then
                local dist = myRoot and (interact.Position - myPos).Magnitude or 100
                if dist <= 6.5 then
                    LootedCabinets[cab] = true
                end

                if not LootedCabinets[cab] then
                    table.insert(newCabinets, { Object = cab, Part = interact })
                end
            end
        end
    end
    TargetData.Cabinets = newCabinets

    -- 7. PROXIMITY PROMPTS
    local newPrompts = {}
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            table.insert(newPrompts, p)
        end
    end
    CachedPrompts = newPrompts
end

-- ==============================================================================
-- AUTO SOLVE CUBES
-- ==============================================================================
local function autoSolveCubes()
    local count = 0
    local function moveCube(cubeName, detName)
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == cubeName then
                for _, det in ipairs(Workspace:GetDescendants()) do
                    if det.Name == detName then
                        local targetPos = (det:IsA("Model") and det:GetPivot() or det.CFrame) + Vector3.new(0, 2.5, 0)
                        if obj:IsA("Model") then
                            obj:PivotTo(targetPos)
                            count = count + 1
                        elseif obj:IsA("BasePart") then
                            obj.CFrame = targetPos
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    moveCube("CubeRed", "RedDetector")
    moveCube("CubeYellow", "YellowDetector")
    moveCube("CubeBlue", "BlueDetector")

    VindUI:Notify({
        Title = "Auto Solve Cubes",
        Text  = string.format("Moved %d cubes directly onto their detectors!", count),
        Type  = count > 0 and "success" or "warn",
        Duration = 4,
    })
end

-- ==============================================================================
-- TELEPORT TO SAFE ZONE
-- ==============================================================================
local function teleportSafeZone()
    local char = LocalPlayer.Character
    local hrp = getRoot(char)
    if not hrp then return end

    local spawnLocation = nil
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("SpawnLocation") then
            spawnLocation = v
            break
        end
    end

    hrp.CFrame = (spawnLocation and spawnLocation.CFrame or CFrame.new(0, 10, 0)) + Vector3.new(0, 3, 0)
    VindUI:Notify({
        Title = "Safe Zone Teleport",
        Text  = "Warped to safe spawn location!",
        Type  = "success",
        Duration = 3,
    })
end

-- ==============================================================================
-- CLEAN ZERO-LAG ESP RENDER
-- ==============================================================================
local function updateESP()
    local myChar = LocalPlayer.Character
    local myRoot = getRoot(myChar)
    local myPos  = myRoot and myRoot.Position or Vector3.zero

    -- 1. SINGLE CLOSEST LOCUST
    if Config.LocustESP and TargetData.Locust then
        local loc = TargetData.Locust.Model
        local hrp = TargetData.Locust.Root
        local dist = TargetData.Locust.Dist
        local data = DrawingCache.Locust[loc]
        if not data then
            data = {
                Text   = Drawing.new("Text"),
                Tracer = Drawing.new("Line"),
            }
            data.Text.Size = 15
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Color = Config.LocustColor
            data.Text.Font = 2

            data.Tracer.Thickness = 2
            data.Tracer.Color = Config.LocustColor
            DrawingCache.Locust[loc] = data
        end

        local sPos, onScreen = worldToScreen(hrp.Position + Vector3.new(0, 1.5, 0))
        if onScreen then
            data.Text.Visible = true
            data.Text.Position = Vector2.new(sPos.X, sPos.Y)
            data.Text.Text = string.format("💀 LOCUST [%dm]", dist)
            data.Text.Color = Config.LocustColor

            if Config.LocustTracer then
                data.Tracer.Visible = true
                data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                data.Tracer.To = Vector2.new(sPos.X, sPos.Y + 16)
                data.Tracer.Color = Config.LocustColor
            else
                data.Tracer.Visible = false
            end
        else
            data.Text.Visible = false
            data.Tracer.Visible = false
        end
    else
        clearGroup(DrawingCache.Locust)
    end

    -- 2. WIRECUTTER
    if Config.WireCutterESP and TargetData.WireCutter then
        local wc = TargetData.WireCutter.Object
        local part = TargetData.WireCutter.Part
        local dist = myRoot and math.floor((part.Position - myPos).Magnitude) or 0
        local data = DrawingCache.WireCutter[wc]
        if not data then
            data = { Text = Drawing.new("Text") }
            data.Text.Size = 14
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Color = Config.WireCutterColor
            data.Text.Font = 2
            DrawingCache.WireCutter[wc] = data
        end

        local sPos, onScreen = worldToScreen(part.Position)
        if onScreen then
            data.Text.Visible = true
            data.Text.Position = Vector2.new(sPos.X, sPos.Y)
            data.Text.Text = string.format("✂️ WireCutter [%dm]", dist)
            data.Text.Color = Config.WireCutterColor
        else
            data.Text.Visible = false
        end
    else
        clearGroup(DrawingCache.WireCutter)
    end

    -- 3. KEYCARD
    if Config.KeycardESP and TargetData.Keycard then
        local kc = TargetData.Keycard.Object
        local part = TargetData.Keycard.Part
        local dist = myRoot and math.floor((part.Position - myPos).Magnitude) or 0
        local data = DrawingCache.Keycard[kc]
        if not data then
            data = { Text = Drawing.new("Text") }
            data.Text.Size = 14
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Color = Config.KeycardColor
            data.Text.Font = 2
            DrawingCache.Keycard[kc] = data
        end

        local sPos, onScreen = worldToScreen(part.Position)
        if onScreen then
            data.Text.Visible = true
            data.Text.Position = Vector2.new(sPos.X, sPos.Y)
            data.Text.Text = string.format("💳 Keycard [%dm]", dist)
            data.Text.Color = Config.KeycardColor
        else
            data.Text.Visible = false
        end
    else
        clearGroup(DrawingCache.Keycard)
    end

    -- 4. CUBES
    if Config.CubesESP then
        local found = {}
        for _, c in ipairs(TargetData.Cubes) do
            found[c.Part] = true
            local dist = myRoot and math.floor((c.Part.Position - myPos).Magnitude) or 0
            local data = DrawingCache.Cubes[c.Part]
            if not data then
                data = { Text = Drawing.new("Text") }
                data.Text.Size = 13
                data.Text.Center = true
                data.Text.Outline = true
                data.Text.Color = Config.CubesColor
                data.Text.Font = 2
                DrawingCache.Cubes[c.Part] = data
            end

            local sPos, onScreen = worldToScreen(c.Part.Position)
            if onScreen then
                data.Text.Visible = true
                data.Text.Position = Vector2.new(sPos.X, sPos.Y)
                data.Text.Text = string.format("%s [%dm]", c.Name, dist)
                data.Text.Color = Config.CubesColor
            else
                data.Text.Visible = false
            end
        end
        for obj, d in pairs(DrawingCache.Cubes) do
            if not found[obj] or not obj.Parent then
                pcall(function() d.Text:Remove() end)
                DrawingCache.Cubes[obj] = nil
            end
        end
    else
        clearGroup(DrawingCache.Cubes)
    end

    -- 5. DOORS & READERS
    if Config.DoorsESP then
        local found = {}
        for _, d in ipairs(TargetData.Doors) do
            found[d.Part] = true
            local dist = myRoot and math.floor((d.Part.Position - myPos).Magnitude) or 0
            local data = DrawingCache.Doors[d.Part]
            if not data then
                data = { Text = Drawing.new("Text") }
                data.Text.Size = 13
                data.Text.Center = true
                data.Text.Outline = true
                data.Text.Color = Config.DoorsColor
                data.Text.Font = 2
                DrawingCache.Doors[d.Part] = data
            end

            local sPos, onScreen = worldToScreen(d.Part.Position)
            if onScreen then
                data.Text.Visible = true
                data.Text.Position = Vector2.new(sPos.X, sPos.Y)
                data.Text.Text = string.format("%s [%dm]", d.Name, dist)
                data.Text.Color = Config.DoorsColor
            else
                data.Text.Visible = false
            end
        end
        for obj, dr in pairs(DrawingCache.Doors) do
            if not found[obj] or not obj.Parent then
                pcall(function() dr.Text:Remove() end)
                DrawingCache.Doors[obj] = nil
            end
        end
    else
        clearGroup(DrawingCache.Doors)
    end

    -- 6. UNLOOTED CABINETS ONLY (Green, hides once searched)
    if Config.CabinetsESP then
        local found = {}
        for _, cab in ipairs(TargetData.Cabinets) do
            local dist = myRoot and math.floor((cab.Part.Position - myPos).Magnitude) or 0
            if dist <= 120 then
                found[cab.Object] = true
                local data = DrawingCache.Cabinets[cab.Object]
                if not data then
                    data = { Text = Drawing.new("Text") }
                    data.Text.Size = 12
                    data.Text.Center = true
                    data.Text.Outline = true
                    data.Text.Color = Config.CabinetsColor
                    data.Text.Font = 2
                    DrawingCache.Cabinets[cab.Object] = data
                end

                local sPos, onScreen = worldToScreen(cab.Part.Position)
                if onScreen then
                    data.Text.Visible = true
                    data.Text.Position = Vector2.new(sPos.X, sPos.Y)
                    data.Text.Text = string.format("🗄️ Unlooted Cabinet [%dm]", dist)
                    data.Text.Color = Config.CabinetsColor
                else
                    data.Text.Visible = false
                end
            elseif DrawingCache.Cabinets[cab.Object] then
                DrawingCache.Cabinets[cab.Object].Text.Visible = false
            end
        end
        for obj, dr in pairs(DrawingCache.Cabinets) do
            if not found[obj] or not obj.Parent then
                pcall(function() dr.Text:Remove() end)
                DrawingCache.Cabinets[obj] = nil
            end
        end
    else
        clearGroup(DrawingCache.Cabinets)
    end

    -- 7. SURVIVOR PLAYERS
    if Config.PlayerESP then
        local found = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and isAlive(p.Character) then
                local pRoot = getRoot(p.Character)
                if pRoot then
                    found[p] = true
                    local dist = myRoot and math.floor((pRoot.Position - myPos).Magnitude) or 0
                    local data = DrawingCache.Players[p]
                    if not data then
                        data = { Text = Drawing.new("Text") }
                        data.Text.Size = 13
                        data.Text.Center = true
                        data.Text.Outline = true
                        data.Text.Color = Config.PlayerColor
                        data.Text.Font = 2
                        DrawingCache.Players[p] = data
                    end

                    local sPos, onScreen = worldToScreen(pRoot.Position + Vector3.new(0, 2, 0))
                    if onScreen then
                        data.Text.Visible = true
                        data.Text.Position = Vector2.new(sPos.X, sPos.Y)
                        data.Text.Text = string.format("👤 %s [%dm]", p.DisplayName, dist)
                        data.Text.Color = Config.PlayerColor
                    else
                        data.Text.Visible = false
                    end
                end
            end
        end
        for p, d in pairs(DrawingCache.Players) do
            if not found[p] or not p.Parent then
                pcall(function() d.Text:Remove() end)
                DrawingCache.Players[p] = nil
            end
        end
    else
        clearGroup(DrawingCache.Players)
    end
end

-- ==============================================================================
-- LIGHTING & ATMOSPHERE
-- ==============================================================================
local function applyAtmosphere()
    if Config.Fullbright then
        Lighting.Ambient = Color3.fromRGB(245, 245, 245)
        Lighting.OutdoorAmbient = Color3.fromRGB(245, 245, 245)
        Lighting.Brightness = Config.BrightnessLevel
        Lighting.ClockTime = Config.ClockTime
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end

    if Config.RemoveFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
    else
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
    end
end

-- ==============================================================================
-- PROXIMITY & INTERACT LOOP
-- ==============================================================================
local function checkThreatsAndInteract()
    local myChar = LocalPlayer.Character
    local myRoot = getRoot(myChar)
    if not myRoot then return end
    local myPos = myRoot.Position

    -- Alert check
    if Config.LocustAlert and TargetData.Locust then
        local hrp = TargetData.Locust.Root
        local dist = (hrp.Position - myPos).Magnitude
        if dist <= Config.AlertDistance then
            if tick() - LastAlertTime > 3.5 then
                LastAlertTime = tick()
                VindUI:Notify({
                    Title = "⚠️ LOCUST NEARBY!",
                    Text = string.format("The killer is %d studs away!", math.floor(dist)),
                    Type = "danger",
                    Duration = 3,
                })
            end

            if Config.AutoSafeAscend and dist <= 22 then
                if not ActiveSafePos then
                    ActiveSafePos = myRoot.CFrame
                    myRoot.CFrame = myRoot.CFrame + Vector3.new(0, Config.SafeSpotHeight, 0)
                    myRoot.Anchored = true
                    VindUI:Notify({
                        Title = "🛡️ Safe Spot Ascend",
                        Text = "Lifted to avoid attack.",
                        Type = "info",
                        Duration = 3
                    })
                end
            end
        end
    end

    -- Instant Interacts & Auto Grab
    if Config.InstantInteract or Config.AutoSearchCabinets or Config.AutoGrabItems then
        for _, prompt in ipairs(CachedPrompts) do
            if prompt.Parent and prompt.Enabled then
                if Config.InstantInteract then
                    prompt.HoldDuration = 0
                end

                local parent = prompt.Parent
                local pPos = parent:IsA("BasePart") and parent.Position or (parent:IsA("Model") and getRoot(parent) and getRoot(parent).Position)
                if pPos then
                    local dist = (pPos - myPos).Magnitude
                    local act = string.lower(prompt.ActionText or "")
                    local obj = string.lower(prompt.ObjectText or "")

                    if Config.AutoSearchCabinets and dist <= Config.InteractRadius and string.find(obj, "cabinet") then
                        fireproximityprompt(prompt)
                    elseif Config.AutoGrabItems and dist <= (Config.InteractRadius * 1.5) and (string.find(act, "pick") or string.find(act, "grab") or string.find(obj, "wirecutter") or string.find(obj, "keycard")) then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end
end

-- ==============================================================================
-- FLY ENGINE
-- ==============================================================================
local function startFly()
    local char = LocalPlayer.Character
    local hrp = getRoot(char)
    if not hrp then return end

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyBodyVel.Velocity = Vector3.zero
    FlyBodyVel.Parent = hrp

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    FlyBodyGyro.D = 200
    FlyBodyGyro.P = 10000
    FlyBodyGyro.Parent = hrp
    FlyingActive = true
end

local function stopFly()
    if FlyBodyVel then FlyBodyVel:Destroy(); FlyBodyVel = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
    FlyingActive = false
end

local function updateFly()
    if not FlyingActive or not FlyBodyVel or not FlyBodyGyro then return end
    local camCF = Camera.CFrame
    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

    FlyBodyVel.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * Config.FlySpeed or Vector3.zero
    FlyBodyGyro.CFrame = camCF
end

-- ==============================================================================
-- SCHEDULING
-- ==============================================================================

-- Scanner: 0.8s
task.spawn(function()
    while true do
        pcall(findTargets)
        task.wait(0.8)
    end
end)

-- Heartbeat: 0.15s
task.spawn(function()
    while true do
        pcall(checkThreatsAndInteract)
        task.wait(0.15)
    end
end)

-- Render Loop
table.insert(Connections, RunService.RenderStepped:Connect(function()
    pcall(updateESP)
    pcall(updateFly)

    -- Movement
    local char = LocalPlayer.Character
    if char and isAlive(char) then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Config.SpeedBoost then
                hum.WalkSpeed = Config.WalkSpeed
            end
            if Config.InfiniteStamina then
                if char:FindFirstChild("Stamina") then
                    pcall(function() char.Stamina.Value = 100 end)
                end
                if LocalPlayer:FindFirstChild("Stamina") then
                    pcall(function() LocalPlayer.Stamina.Value = 100 end)
                end
            end
        end
    end

    -- Third Person
    if Config.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = Config.ThirdPersonDist
        LocalPlayer.CameraMinZoomDistance = Config.ThirdPersonDist
    end

    -- Stats Overlay
    if Config.ShowStatsOverlay then
        frameCount = frameCount + 1
        local now = tick()
        if now - lastStatsTime >= 1 then
            local fps = frameCount
            frameCount = 0
            lastStatsTime = now
            local ping = 0
            pcall(function()
                ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            statsFrame.Text = string.format("FPS: %d | Ping: %d ms", fps, ping)
        end
    end
end))

-- Noclip Stepped
table.insert(Connections, RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

-- Jump Request
table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Fly Keybind
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Config.FlyKey then
        if Config.Fly then
            if FlyingActive then stopFly() else startFly() end
        end
    end
end))

-- Anti-AFK
table.insert(Connections, LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

-- ==============================================================================
-- BUILD VINDUI WINDOW
-- ==============================================================================
local Window = VindUI:CreateWindow({
    Title = "House of the Locust",
    Subtitle = "Survival Suite v3.0 Hub Edition",
    Size = UDim2.fromOffset(630, 430),
    Icon = "Lucide:ghost",
    ToggleKeybind = Enum.KeyCode.RightShift,
    UseBlur = false,
})

-- ── 1. SURVIVAL & AUTOMATION TAB ─────────────────────────────────────────────
local TabSurvival = Window:AddTab({ Name = "Survival", Icon = "Lucide:shield-alert" })

TabSurvival:AddSection("Targeted Locust Radar (Single Closest)")
TabSurvival:AddToggle({
    Text = "Real Locust ESP (Entities.Locust)",
    Description = "Highlights only the real active killer, ignoring fake jumpscare clones",
    Default = Config.LocustESP,
    Callback = function(v) Config.LocustESP = v end,
})
TabSurvival:AddToggle({
    Text = "Locust Tracer Line",
    Description = "Draws direct tracer line to the real monster",
    Default = Config.LocustTracer,
    Callback = function(v) Config.LocustTracer = v end,
})
TabSurvival:AddToggle({
    Text = "Threat Alarm Banner",
    Description = "Visual alert when the Locust gets within range",
    Default = Config.LocustAlert,
    Callback = function(v) Config.LocustAlert = v end,
})

TabSurvival:AddSection("Puzzles & Safe Zones (Hub V3.0 Features)")
TabSurvival:AddButton({
    Text = "Auto Solve Cubes",
    Description = "Instantly pivots Red, Yellow & Blue cubes onto their detectors",
    Callback = autoSolveCubes,
})
TabSurvival:AddButton({
    Text = "Teleport Safe Zone",
    Description = "Warp directly to spawn / safe zone",
    Callback = teleportSafeZone,
})
TabSurvival:AddToggle({
    Text = "Auto Ascend on Attack",
    Description = "Lifts you to ceiling if killer enters strike radius (22 studs)",
    Default = Config.AutoSafeAscend,
    Callback = function(v)
        Config.AutoSafeAscend = v
        if not v and ActiveSafePos and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
            getRoot(LocalPlayer.Character).Anchored = false
            getRoot(LocalPlayer.Character).CFrame = ActiveSafePos
            ActiveSafePos = nil
        end
    end,
})

-- ── 2. VISUALS & ITEMS TAB ───────────────────────────────────────────────────
local TabVisuals = Window:AddTab({ Name = "Visuals & Items", Icon = "Lucide:eye" })

TabVisuals:AddSection("Items & Objectives ESP")
TabVisuals:AddToggle({
    Text = "✂️ WireCutter ESP",
    Description = "Shows exact location of the WireCutter",
    Default = Config.WireCutterESP,
    Callback = function(v) Config.WireCutterESP = v end,
})
TabVisuals:AddButton({
    Text = "Teleport to WireCutter",
    Description = "Instantly teleports your character to the WireCutter",
    Callback = function()
        local myRoot = getRoot(LocalPlayer.Character)
        if not myRoot then return end
        if TargetData.WireCutter and TargetData.WireCutter.Part then
            myRoot.CFrame = TargetData.WireCutter.Part.CFrame + Vector3.new(0, 3, 0)
            VindUI:Notify({
                Title = "Teleported",
                Text = "Teleported to WireCutter!",
                Type = "success",
                Duration = 3,
            })
        else
            VindUI:Notify({
                Title = "Not Found",
                Text = "WireCutter not found in workspace.",
                Type = "warn",
                Duration = 3,
            })
        end
    end,
})
TabVisuals:AddToggle({
    Text = "💳 Keycard ESP",
    Description = "Highlights Keycard prompt on Locust",
    Default = Config.KeycardESP,
    Callback = function(v) Config.KeycardESP = v end,
})
TabVisuals:AddToggle({
    Text = "🎯 Puzzles (Yellow, Red, Blue Cubes)",
    Description = "Highlights all 3 puzzle cubes",
    Default = Config.CubesESP,
    Callback = function(v) Config.CubesESP = v end,
})
TabVisuals:AddToggle({
    Text = "🚪 Locked Doors & Card Readers",
    Description = "Highlights DoorWire, Keyholes, and Keycard Readers",
    Default = Config.DoorsESP,
    Callback = function(v) Config.DoorsESP = v end,
})
TabVisuals:AddToggle({
    Text = "🗄️ Unlooted Cabinets ESP (Green)",
    Description = "Smart cabinet tracker — disappears once searched (within 6.5 studs)",
    Default = Config.CabinetsESP,
    Callback = function(v) Config.CabinetsESP = v end,
})
TabVisuals:AddToggle({
    Text = "👤 Survivor Players ESP (Blue)",
    Description = "Shows teammates in the house",
    Default = Config.PlayerESP,
    Callback = function(v) Config.PlayerESP = v end,
})

TabVisuals:AddSection("Atmosphere & Lighting")
TabVisuals:AddToggle({
    Text = "Fullbright (Night Vision)",
    Description = "Locks daylight lighting, removes all darkness and shadows",
    Default = Config.Fullbright,
    Callback = function(v) Config.Fullbright = v; applyAtmosphere() end,
})
TabVisuals:AddToggle({
    Text = "Remove Fog & Dark Smog",
    Description = "Clears heavy darkness and distance fog limits",
    Default = Config.RemoveFog,
    Callback = function(v) Config.RemoveFog = v; applyAtmosphere() end,
})
TabVisuals:AddToggle({
    Text = "Third Person View",
    Description = "Over-the-shoulder FOV expansion",
    Default = Config.ThirdPerson,
    Callback = function(v)
        Config.ThirdPerson = v
        if not v then
            LocalPlayer.CameraMaxZoomDistance = 400
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end,
})

-- ── 3. AUTOMATION TAB ────────────────────────────────────────────────────────
local TabAutomation = Window:AddTab({ Name = "Automation", Icon = "Lucide:zap" })

TabAutomation:AddSection("Interaction Automation")
TabAutomation:AddToggle({
    Text = "Instant Proximity Prompts",
    Description = "Removes hold time on Cabinets, WireCutters, and Doors (0s)",
    Default = Config.InstantInteract,
    Callback = function(v) Config.InstantInteract = v end,
})
TabAutomation:AddToggle({
    Text = "Auto Grab WireCutters & Keycard",
    Description = "Automatically picks up tools when in range",
    Default = Config.AutoGrabItems,
    Callback = function(v) Config.AutoGrabItems = v end,
})
TabAutomation:AddToggle({
    Text = "Auto Search Nearby Cabinets",
    Description = "Automatically searches cabinets you walk past",
    Default = Config.AutoSearchCabinets,
    Callback = function(v) Config.AutoSearchCabinets = v end,
})

-- ── 4. MOVEMENT TAB ──────────────────────────────────────────────────────────
local TabMovement = Window:AddTab({ Name = "Movement", Icon = "Lucide:footprints" })

TabMovement:AddSection("Speed & Stamina")
TabMovement:AddToggle({
    Text = "WalkSpeed Boost",
    Description = "Run faster than normal speed",
    Default = Config.SpeedBoost,
    Callback = function(v)
        Config.SpeedBoost = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})
TabMovement:AddSlider({
    Text = "Sprint Speed",
    Min = 16,
    Max = 55,
    Default = Config.WalkSpeed,
    Increment = 1,
    Callback = function(v) Config.WalkSpeed = v end,
})
TabMovement:AddToggle({
    Text = "Infinite Stamina",
    Description = "Never get exhausted",
    Default = Config.InfiniteStamina,
    Callback = function(v) Config.InfiniteStamina = v end,
})

TabMovement:AddSection("Physics Exploits")
TabMovement:AddToggle({
    Text = "Noclip (Walk Through Walls & Locked Doors)",
    Description = "Walk right through DoorWire, Keyholes, and walls",
    Default = Config.Noclip,
    Callback = function(v) Config.Noclip = v end,
})
TabMovement:AddToggle({
    Text = "Infinite Jump",
    Description = "Jump repeatedly in mid-air",
    Default = Config.InfiniteJump,
    Callback = function(v) Config.InfiniteJump = v end,
})
TabMovement:AddToggle({
    Text = "Fly Mode (Keybind 'F')",
    Description = "Press 'F' to toggle free flight",
    Default = Config.Fly,
    Callback = function(v)
        Config.Fly = v
        if not v then stopFly() end
    end,
})
TabMovement:AddSlider({
    Text = "Fly Speed",
    Min = 10,
    Max = 90,
    Default = Config.FlySpeed,
    Increment = 5,
    Callback = function(v) Config.FlySpeed = v end,
})

-- ── 5. SETTINGS & STATS TAB ──────────────────────────────────────────────────
local TabSettings = Window:AddTab({ Name = "Settings", Icon = "Lucide:settings" })

TabSettings:AddSection("HUD Overlays")
TabSettings:AddToggle({
    Text = "Show FPS & Ping Overlay",
    Description = "Displays live frame-rate & server latency on the top right",
    Default = Config.ShowStatsOverlay,
    Callback = function(v)
        Config.ShowStatsOverlay = v
        statsFrame.Visible = v
    end,
})
TabSettings:AddToggle({
    Text = "Anti-AFK Disconnect",
    Description = "Prevents idle kicks",
    Default = Config.AntiAFK,
    Callback = function(v) Config.AntiAFK = v end,
})

TabSettings:AddSection("Utilities")
TabSettings:AddButton({
    Text = "Rejoin Server",
    Description = "Rejoins current server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})
TabSettings:AddButton({
    Text = "Reset Looted Cabinets Cache",
    Description = "Makes all cabinets visible on ESP again",
    Callback = function()
        LootedCabinets = {}
        VindUI:Notify({
            Title = "Cache Reset",
            Text  = "All cabinets are now marked as unlooted.",
            Type  = "info",
            Duration = 3,
        })
    end,
})
TabSettings:AddButton({
    Text = "Unload Script",
    Description = "Cleans up drawings, loops, and destroys UI",
    Callback = function()
        for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
        stopFly()
        clearGroup(DrawingCache.Locust)
        clearGroup(DrawingCache.WireCutter)
        clearGroup(DrawingCache.Keycard)
        clearGroup(DrawingCache.Cubes)
        clearGroup(DrawingCache.Doors)
        clearGroup(DrawingCache.Cabinets)
        clearGroup(DrawingCache.Players)
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        if StatsGui then StatsGui:Destroy() end
        Window:Destroy()
    end,
})

applyAtmosphere()

VindUI:Notify({
    Title = "House of the Locust",
    Text  = "V3.0 Hub Features Integrated · Zero Lag",
    Type  = "success",
    Duration = 4,
})

print("[House of the Locust] Hub V3.0 features loaded with VindUI.")
