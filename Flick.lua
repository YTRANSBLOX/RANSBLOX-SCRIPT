local HUB_NAME = "FLICK"
local VERSION  = "v1.0"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"

-- Re-execute safety: unload the previous instance first
if _G.FLICK_Unload then pcall(_G.FLICK_Unload) end

pcall(function() setclipboard(YT_LINK) end)

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then
    warn("[" .. HUB_NAME .. "] Failed to load WindUI")
    return
end

-- SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONSTANTS
local ANGLE_TOLERANCE = 20
local MIN_TARGET_DIST = 5

-- CONFIG
local CONFIG = {
    SilentAim     = false,
    RapidFire     = false,
    RapidShots    = 15,
    Triggerbot    = false,
    TriggerDelay  = 0.05,
    Wallcheck     = true,
    TeamCheck     = true,
    ThreeSixty    = false,
    TargetPart    = "Head",
    FOV           = 150,
    ShowFOV       = true,
    MaxTargetDist = 2000,

    ESPEnabled    = true,
    ShowTeammates = true,
    ESPMaxDist    = 1500,
    ESPOpts = {
        Skeleton = true, Box = false, Health = true,
        Name = true, Weapon = true, Distance = true, Tracer = false,
    },

    Colors = {
        Enemy = Color3.fromRGB(255, 80, 80),
        Team  = Color3.fromRGB(0, 200, 255),
        FOV   = Color3.fromRGB(0, 255, 140),
    },
}

-- CONNECTION MANAGER
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- MODULES
local SignalManager
pcall(function()
    SignalManager = require(ReplicatedStorage:WaitForChild("SignalManager", 5))
end)

local BulletHandler = _G.__SA_BulletHandler
if not BulletHandler then
    pcall(function()
        BulletHandler = require(ReplicatedStorage.ModuleScripts.GunModules.BulletHandler)
        _G.__SA_BulletHandler = BulletHandler
    end)
end

local originalFire
local hookReady = false
if type(BulletHandler) == "table" and type(BulletHandler.Fire) == "function" then
    if _G.__SA_HookInstalled and _G.__SA_OriginalBulletFire then
        BulletHandler.Fire = _G.__SA_OriginalBulletFire
        _G.__SA_HookInstalled = false
    end
    originalFire = BulletHandler.Fire
    _G.__SA_OriginalBulletFire = originalFire
    _G.__SA_HookInstalled = true
    hookReady = true
end

-- FOV CIRCLE
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness    = 1
fovCircle.Transparency = 0.55
fovCircle.Filled       = false
fovCircle.NumSides     = 64
fovCircle.Visible      = false

bind(RunService.RenderStepped, function()
    local m = UserInputService:GetMouseLocation()
    fovCircle.Position = Vector2.new(m.X, m.Y + 36)
    fovCircle.Radius   = CONFIG.FOV
    fovCircle.Color    = CONFIG.Colors.FOV
    fovCircle.Visible  = CONFIG.ShowFOV
        and (CONFIG.SilentAim or CONFIG.Triggerbot)
        and not CONFIG.ThreeSixty
end)

-- =====================================================================
-- TARGET SELECTION
-- =====================================================================
local PART_PRIORITY = { "HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Head" }

local function isTeammate(char)
    local owner = Players:GetPlayerFromCharacter(char)
    return owner ~= nil and owner ~= LP and owner.Team ~= nil and owner.Team == LP.Team
end

local function findPart(char, partName)
    local p = char:FindFirstChild(partName)
    if p and p:IsA("BasePart") then return p end
    for _, d in ipairs(char:GetDescendants()) do
        if d.Name == partName and d:IsA("BasePart") then return d end
    end
    return nil
end

local function hasLineOfSight(originPos, partPos, ignoreChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, Camera, ignoreChar }
    params.IgnoreWater = true
    local dir  = partPos - originPos
    local dist = dir.Magnitude
    if dist <= 0 then return false end
    local result = workspace:Raycast(originPos, dir, params)
    if not result then return true end
    return result.Distance >= dist - 0.5
end

local function buildTargetFromChar(char, originPos)
    if not char or not char.Parent then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    if hum.Health <= 0 then
        local spawnTick = char:GetAttribute("__spawnTick")
        if not spawnTick then
            pcall(function() char:SetAttribute("__spawnTick", tick()) end)
            spawnTick = tick()
        end
        if tick() - spawnTick > 5 then return nil end
    end

    local chosenPart, chosenPos
    if CONFIG.Wallcheck then
        local primary = findPart(char, CONFIG.TargetPart)
        if primary and hasLineOfSight(originPos, primary.Position, char) then
            chosenPart, chosenPos = primary, primary.Position
        end
        if not chosenPart then
            for _, name in ipairs(PART_PRIORITY) do
                if name ~= CONFIG.TargetPart then
                    local part = findPart(char, name)
                    if part and hasLineOfSight(originPos, part.Position, char) then
                        chosenPart, chosenPos = part, part.Position
                        break
                    end
                end
            end
        end
        if not chosenPart then return nil end
    else
        local primary = findPart(char, CONFIG.TargetPart)
        if primary then
            chosenPart, chosenPos = primary, primary.Position
        else
            for _, name in ipairs(PART_PRIORITY) do
                local part = findPart(char, name)
                if part then chosenPart, chosenPos = part, part.Position break end
            end
        end
        if not chosenPart then return nil end
    end

    return { character = char, humanoid = hum, part = chosenPart, partPos = chosenPos }
end

local function buildSkipSet()
    local skip = {}
    for _, obj in ipairs(Camera:GetChildren()) do
        skip[obj] = true
        for _, d in ipairs(obj:GetDescendants()) do skip[d] = true end
    end
    local function markVM(root, depth)
        if depth > 3 then return end
        for _, obj in ipairs(root:GetChildren()) do
            if obj.Name == "ViewModel" or obj.Name == "Viewmodel" or obj.Name == "viewModel" then
                skip[obj] = true
                for _, d in ipairs(obj:GetDescendants()) do skip[d] = true end
            end
            markVM(obj, depth + 1)
        end
    end
    markVM(workspace, 0)
    if LP.Character then
        skip[LP.Character] = true
        for _, d in ipairs(LP.Character:GetDescendants()) do skip[d] = true end
    end
    return skip
end

local function getTarget(origin)
    if not CONFIG.SilentAim then return nil end

    local targets, seenChars = {}, {}
    local mouse   = UserInputService:GetMouseLocation()
    local skipSet = buildSkipSet()
    local myChar  = LP.Character

    local function evaluate(char)
        if char == myChar or skipSet[char] then return end
        if CONFIG.TeamCheck and isTeammate(char) then return end

        local info = buildTargetFromChar(char, origin)
        if not info then return end
        local pos = info.partPos

        local dist3D = (pos - origin).Magnitude
        if dist3D < MIN_TARGET_DIST or dist3D > CONFIG.MaxTargetDist then return end

        if CONFIG.ThreeSixty and not hasLineOfSight(origin, pos, char) then return end

        local sp, onScreen = Camera:WorldToViewportPoint(pos)
        local screenDist = onScreen
            and (Vector2.new(sp.X, sp.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
            or 99999

        if not CONFIG.ThreeSixty then
            if not onScreen then return end
            if screenDist > CONFIG.FOV then return end
        end

        table.insert(targets, {
            position = pos, dist = screenDist, dist3D = dist3D,
            onScreen = onScreen, part = info.part, character = char,
        })
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and not seenChars[char] then
                seenChars[char] = true
                evaluate(char)
            end
        end
    end

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and not seenChars[obj] and obj ~= myChar and not skipSet[obj] then
            if obj:FindFirstChildOfClass("Humanoid") then
                local owner = Players:GetPlayerFromCharacter(obj)
                if owner ~= LP then
                    seenChars[obj] = true
                    evaluate(obj)
                end
            end
        end
    end

    table.sort(targets, function(a, b)
        if a.onScreen ~= b.onScreen then return a.onScreen end
        if a.onScreen and b.onScreen then
            if math.abs(a.dist - b.dist) < 30 then return a.dist3D < b.dist3D end
            return a.dist < b.dist
        end
        return a.dist3D < b.dist3D
    end)

    return targets[1]
end

-- =====================================================================
-- HOOK (silent aim + rapid fire)
-- =====================================================================
local function fireRapidCopies(payload, n)
    for i = 2, n do
        local copy = {}
        for k, v in pairs(payload) do copy[k] = v end
        if type(payload.Misc) == "table" then
            local newMisc = {}
            for k, v in pairs(payload.Misc) do newMisc[k] = v end
            copy.Misc = newMisc
        end
        local newId = tick() + (i * 0.0001)
        if copy.Misc then
            copy.Misc.ShotID  = newId
            copy.Misc.NewSeed = (copy.Misc.NewSeed or 0) + 11
        end
        copy.BulletId = newId
        pcall(function() originalFire(copy) end)
    end
end

if hookReady then
    BulletHandler.Fire = function(payload)
        if type(payload) ~= "table" then return originalFire(payload) end

        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local isAirborne = hum and hum.FloorMaterial == Enum.Material.Air

        if isAirborne and hrp and typeof(payload.Origin) == "Vector3" then
            local newOrigin = hrp.Position + Vector3.new(0, 1.5, 0)
            payload.Origin = newOrigin
            if typeof(payload.VisualOrigin) == "Vector3" then
                payload.VisualOrigin = newOrigin
            end
        end

        local originPos = typeof(payload.Origin) == "Vector3" and payload.Origin or nil
        local needsCameraSpoof, spoofCF = false, nil

        if originPos then
            local target = getTarget(originPos)
            if target then
                local newDir = (target.position - originPos).Unit
                payload.Direction = newDir

                if type(payload.Misc) == "table" then
                    if typeof(payload.Misc.CamCFrame) == "CFrame" then
                        payload.Misc.CamCFrame = CFrame.lookAt(originPos, originPos + newDir)
                    end
                    payload.Misc.Spread = 0
                end

                local dot   = math.clamp(Camera.CFrame.LookVector:Dot(newDir), -1, 1)
                local angle = math.deg(math.acos(dot))

                if CONFIG.ThreeSixty then
                    needsCameraSpoof = true
                    spoofCF = CFrame.lookAt(originPos, originPos + newDir)
                elseif angle > ANGLE_TOLERANCE and not isAirborne then
                    needsCameraSpoof = true
                    spoofCF = CFrame.lookAt(originPos, originPos + newDir)
                end
            end
        end

        local n = CONFIG.RapidFire and CONFIG.RapidShots or 1

        local oldCF
        if needsCameraSpoof then
            oldCF = Camera.CFrame
            Camera.CFrame = spoofCF
        end

        local result = originalFire(payload)
        if n > 1 then fireRapidCopies(payload, n) end

        if needsCameraSpoof and oldCF then Camera.CFrame = oldCF end
        return result
    end
end

-- =====================================================================
-- TRIGGERBOT
-- =====================================================================
local lastTrigger = 0

local function triggerbotFindTarget()
    local char = LP.Character
    if not char then return nil end
    if not char:FindFirstChildOfClass("Tool") then return nil end

    local origin  = Camera.CFrame.Position
    local mouse   = UserInputService:GetMouseLocation()
    local skipSet = buildSkipSet()
    local candidates = {}

    for _, player in ipairs(Players:GetPlayers()) do
        local c = player.Character
        if player ~= LP and c and not skipSet[c] then
            if not (CONFIG.TeamCheck and isTeammate(c)) then
                local info = buildTargetFromChar(c, origin)
                if info then
                    local pos = info.partPos
                    local dist3D = (pos - origin).Magnitude
                    if dist3D >= MIN_TARGET_DIST and dist3D <= CONFIG.MaxTargetDist
                       and hasLineOfSight(origin, pos, c) then
                        local sp, onScreen = Camera:WorldToViewportPoint(pos)
                        local screenDist = onScreen
                            and (Vector2.new(sp.X, sp.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            or math.huge
                        if CONFIG.ThreeSixty or (onScreen and screenDist <= CONFIG.FOV) then
                            table.insert(candidates, {
                                screenDist = screenDist, dist3D = dist3D, onScreen = onScreen,
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if CONFIG.ThreeSixty then
            if a.onScreen ~= b.onScreen then return a.onScreen end
            return a.dist3D < b.dist3D
        end
        return a.screenDist < b.screenDist
    end)
    return candidates[1]
end

bind(RunService.Heartbeat, function()
    if not CONFIG.Triggerbot or not SignalManager then return end
    if not LP.Character then return end
    local now = tick()
    if now - lastTrigger < CONFIG.TriggerDelay then return end
    if not triggerbotFindTarget() then return end
    lastTrigger = now
    pcall(function() SignalManager.Fire("FireWeapon", Enum.UserInputState.Begin) end)
    pcall(function() SignalManager.Fire("FireWeapon", Enum.UserInputState.End) end)
end)

-- =====================================================================
-- ESP
-- =====================================================================
local ESP = { players = {} }

local BONES_R15 = {
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"UpperTorso","RightUpperArm"},
    {"LowerTorso","LeftUpperLeg"}, {"LowerTorso","RightUpperLeg"},
}
local BONES_R6 = {
    {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
    {"Torso","Left Leg"}, {"Torso","Right Leg"},
}

local function newLine()
    local l = Drawing.new("Line")
    l.Thickness, l.Visible, l.Transparency = 1, false, 1
    return l
end
local function newText()
    local t = Drawing.new("Text")
    t.Size, t.Center, t.Outline, t.Font = 13, true, true, 2
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Visible = false
    return t
end
local function newSquare()
    local s = Drawing.new("Square")
    s.Thickness, s.Filled, s.Visible = 1, false, false
    return s
end

local function buildESP()
    local tbl = {
        lines = {}, tracer = newLine(),
        box = newSquare(), healthBg = newSquare(), healthFg = newSquare(),
    }
    for i = 1, 15 do tbl.lines[i] = newLine() end
    tbl.nameText, tbl.weaponText, tbl.distanceText = newText(), newText(), newText()
    return tbl
end

local function hideAll(tbl)
    for _, l in ipairs(tbl.lines) do l.Visible = false end
    tbl.tracer.Visible = false
    tbl.box.Visible, tbl.healthBg.Visible, tbl.healthFg.Visible = false, false, false
    tbl.nameText.Visible, tbl.weaponText.Visible, tbl.distanceText.Visible = false, false, false
end

local function clearESP(player)
    local tbl = ESP.players[player]
    if not tbl then return end
    for _, l in ipairs(tbl.lines) do pcall(function() l:Remove() end) end
    for _, k in ipairs({ "tracer", "box", "healthBg", "healthFg", "nameText", "weaponText", "distanceText" }) do
        pcall(function() tbl[k]:Remove() end)
    end
    ESP.players[player] = nil
end

local function setupPlayer(player)
    if player == LP then return end
    if not ESP.players[player] then ESP.players[player] = buildESP() end
end

for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
bind(Players.PlayerAdded, setupPlayer)
bind(Players.PlayerRemoving, clearESP)

bind(RunService.RenderStepped, function()
    if not CONFIG.ESPEnabled then
        for _, tbl in pairs(ESP.players) do hideAll(tbl) end
        return
    end

    local O = CONFIG.ESPOpts
    local viewport = Camera.ViewportSize

    for player, tbl in pairs(ESP.players) do
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))

        if not (char and hum and root and hum.Health > 0) then
            hideAll(tbl)
            continue
        end

        local isTeam = player.Team ~= nil and player.Team == LP.Team
        if isTeam and not CONFIG.ShowTeammates then
            hideAll(tbl)
            continue
        end

        local distCam = (Camera.CFrame.Position - root.Position).Magnitude
        if distCam > CONFIG.ESPMaxDist then
            hideAll(tbl)
            continue
        end

        local baseColor = isTeam and CONFIG.Colors.Team or CONFIG.Colors.Enemy

        -- Skeleton
        if O.Skeleton then
            local bones = char:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6
            local thick = math.clamp(1.0 - (distCam - 20) / 200, 0.3, 1.0)
            local i = 0
            for _, pair in ipairs(bones) do
                i = i + 1
                local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                if a and b then
                    local a3, aOn = Camera:WorldToViewportPoint(a.Position)
                    local b3, bOn = Camera:WorldToViewportPoint(b.Position)
                    if aOn and bOn then
                        local ln = tbl.lines[i]
                        ln.From, ln.To = Vector2.new(a3.X, a3.Y), Vector2.new(b3.X, b3.Y)
                        ln.Color, ln.Thickness, ln.Visible = baseColor, thick, true
                    else
                        tbl.lines[i].Visible = false
                    end
                else
                    tbl.lines[i].Visible = false
                end
            end
            for j = i + 1, #tbl.lines do tbl.lines[j].Visible = false end
        else
            for _, l in ipairs(tbl.lines) do l.Visible = false end
        end

        -- Tracer
        if O.Tracer then
            local feet, feetOn = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            if feetOn then
                tbl.tracer.From  = Vector2.new(viewport.X / 2, viewport.Y)
                tbl.tracer.To    = Vector2.new(feet.X, feet.Y)
                tbl.tracer.Color = baseColor
                tbl.tracer.Visible = true
            else
                tbl.tracer.Visible = false
            end
        else
            tbl.tracer.Visible = false
        end

        -- Box (also used to place the health bar)
        local head = char:FindFirstChild("Head")
        local boxOn = false
        if (O.Box or O.Health) and head then
            local headTop = head.Position + Vector3.new(0, head.Size.Y / 2, 0)
            local feetPos = root.Position - Vector3.new(0, 3, 0)
            local top, topOn = Camera:WorldToViewportPoint(headTop)
            local bot, botOn = Camera:WorldToViewportPoint(feetPos)
            if topOn and botOn then
                local height = math.abs(bot.Y - top.Y)
                local width  = height * 0.55
                tbl.box.Size     = Vector2.new(width, height)
                tbl.box.Position = Vector2.new(top.X - width / 2, top.Y)
                tbl.box.Color    = baseColor
                boxOn = true
            end
        end
        tbl.box.Visible = O.Box and boxOn or false

        -- Health bar
        if O.Health and boxOn then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barW, barH = 3, tbl.box.Size.Y
            local barX, barY = tbl.box.Position.X - 8, tbl.box.Position.Y

            tbl.healthBg.Size, tbl.healthBg.Position = Vector2.new(barW, barH), Vector2.new(barX, barY)
            tbl.healthBg.Color, tbl.healthBg.Filled, tbl.healthBg.Visible = Color3.fromRGB(30, 30, 30), true, true

            local fillH = barH * pct
            tbl.healthFg.Size     = Vector2.new(barW, fillH)
            tbl.healthFg.Position = Vector2.new(barX, barY + (barH - fillH))
            tbl.healthFg.Color    = pct > 0.5 and Color3.fromRGB(0, 255, 80)
                                 or pct > 0.25 and Color3.fromRGB(255, 200, 0)
                                 or Color3.fromRGB(255, 50, 50)
            tbl.healthFg.Filled, tbl.healthFg.Visible = true, true
        else
            tbl.healthBg.Visible, tbl.healthFg.Visible = false, false
        end

        -- Text (name / weapon / distance)
        if not head then
            tbl.nameText.Visible, tbl.weaponText.Visible, tbl.distanceText.Visible = false, false, false
            continue
        end

        local headTop = head.Position + Vector3.new(0, head.Size.Y / 2, 0)
        local sh, onHead = Camera:WorldToViewportPoint(headTop)
        if not onHead then
            tbl.nameText.Visible, tbl.weaponText.Visible, tbl.distanceText.Visible = false, false, false
            continue
        end

        local y = sh.Y - 20

        if O.Name then
            tbl.nameText.Text, tbl.nameText.Position = player.Name, Vector2.new(sh.X, y)
            tbl.nameText.Color, tbl.nameText.Visible = baseColor, true
            y = y - 16
        else
            tbl.nameText.Visible = false
        end

        local tool = char:FindFirstChildOfClass("Tool")
        if O.Weapon and tool then
            tbl.weaponText.Text, tbl.weaponText.Position = "[" .. tool.Name .. "]", Vector2.new(sh.X, y)
            tbl.weaponText.Color, tbl.weaponText.Visible = Color3.fromRGB(255, 220, 100), true
            y = y - 16
        else
            tbl.weaponText.Visible = false
        end

        if O.Distance then
            tbl.distanceText.Text = string.format("%d studs", math.floor(distCam))
            tbl.distanceText.Position = Vector2.new(sh.X, y)
            tbl.distanceText.Color, tbl.distanceText.Visible = Color3.fromRGB(200, 200, 200), true
        else
            tbl.distanceText.Visible = false
        end
    end
end)

-- =====================================================================
-- GUI
-- =====================================================================
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
    Size = UDim2.fromOffset(560, 360),
    Radius = 20,
    ElementsRadius = 16,
    ShadowTransparency = 0.6,
    User = { Enabled = true },
    Topbar = { Height = 44, ButtonsType = "Mac" },
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
    MinimizeKey = Enum.KeyCode.RightControl,
})

Window:Tag({ Title = VERSION, Icon = "youtube", Color = Color3.fromHex("#FF8200"), Border = true })

local Tabs = {}
Tabs.Main   = Window:Tab({ Title = "Main", Icon = "zap" })
Tabs.ESP    = Window:Tab({ Title = "ESP",  Icon = "eye" })
Window:Divider()
Tabs.Social = Window:Tab({ Title = "Social", Icon = "link" })
Tabs.Misc   = Window:Tab({ Title = "Misc",   Icon = "info" })

-- helper: flip a feature from a keybind and keep the toggle visual in sync
local function flip(key, toggleObj)
    CONFIG[key] = not CONFIG[key]
    if toggleObj then pcall(function() toggleObj:Set(CONFIG[key]) end) end
end

-- ===== MAIN: COMBAT =====
local CombatBox = Tabs.Main:Section({ Title = "Combat", Icon = "swords", Box = true, BoxBorder = true, Opened = true })

local SilentToggle = CombatBox:Toggle({
    Title = "Silent Aim", Desc = "Redirects your bullets to the best target",
    Value = CONFIG.SilentAim,
    Callback = function(v) CONFIG.SilentAim = v end,
})
local RapidToggle = CombatBox:Toggle({
    Title = "Rapid Fire", Desc = "Fires multiple bullets per shot",
    Value = CONFIG.RapidFire,
    Callback = function(v) CONFIG.RapidFire = v end,
})
local TriggerToggle = CombatBox:Toggle({
    Title = "Triggerbot", Desc = "Auto-shoots when a target is in range",
    Value = CONFIG.Triggerbot,
    Callback = function(v) CONFIG.Triggerbot = v end,
})
local ThreeSixtyToggle = CombatBox:Toggle({
    Title = "360 Aim", Desc = "Targets enemies from every angle",
    Value = CONFIG.ThreeSixty,
    Callback = function(v) CONFIG.ThreeSixty = v end,
})
CombatBox:Toggle({
    Title = "Wall Check", Desc = "Only targets enemies you can see",
    Value = CONFIG.Wallcheck,
    Callback = function(v) CONFIG.Wallcheck = v end,
})
CombatBox:Toggle({
    Title = "Team Check", Desc = "Ignores your teammates",
    Value = CONFIG.TeamCheck,
    Callback = function(v) CONFIG.TeamCheck = v end,
})

-- ===== MAIN: TARGETING =====
local TargetBox = Tabs.Main:Section({ Title = "Targeting", Icon = "crosshair", Box = true, BoxBorder = true, Opened = true })

TargetBox:Dropdown({
    Title = "Target Part",
    Desc = "Body part to aim at",
    MenuWidth = 170,
    Values = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso" },
    Value = CONFIG.TargetPart,
    Callback = function(v) CONFIG.TargetPart = v end,
})

TargetBox:Slider({
    Title = "FOV Radius",
    Step = 5,
    Value = { Min = 25, Max = 500, Default = CONFIG.FOV },
    Callback = function(v) CONFIG.FOV = math.floor(v) end,
})

TargetBox:Slider({
    Title = "Max Target Distance",
    Desc = "Ignore targets further than this (studs)",
    Step = 50,
    Value = { Min = 100, Max = 5000, Default = CONFIG.MaxTargetDist },
    Callback = function(v) CONFIG.MaxTargetDist = math.floor(v) end,
})

TargetBox:Slider({
    Title = "Trigger Delay",
    Desc = "Seconds between triggerbot shots",
    Step = 0.01,
    Value = { Min = 0, Max = 0.5, Default = CONFIG.TriggerDelay },
    Callback = function(v) CONFIG.TriggerDelay = v end,
})

TargetBox:Slider({
    Title = "Rapid Fire Bullets",
    Desc = "Bullets per shot while Rapid Fire is on",
    Step = 1,
    Value = { Min = 2, Max = 15, Default = CONFIG.RapidShots },
    Callback = function(v) CONFIG.RapidShots = math.floor(v) end,
})

TargetBox:Toggle({
    Title = "Show FOV Circle",
    Value = CONFIG.ShowFOV,
    Callback = function(v) CONFIG.ShowFOV = v end,
})

TargetBox:Colorpicker({
    Title = "FOV Color",
    Default = CONFIG.Colors.FOV,
    Callback = function(c) CONFIG.Colors.FOV = c end,
})

-- ===== MAIN: KEYBINDS =====
local BindBox = Tabs.Main:Section({ Title = "Keybinds", Icon = "command", Box = true, BoxBorder = true, Opened = false })

BindBox:Keybind({ Title = "Silent Aim", Value = "X",
    Callback = function() flip("SilentAim", SilentToggle) end })
BindBox:Keybind({ Title = "Rapid Fire", Value = "R",
    Callback = function() flip("RapidFire", RapidToggle) end })
BindBox:Keybind({ Title = "Triggerbot", Value = "T",
    Callback = function() flip("Triggerbot", TriggerToggle) end })
BindBox:Keybind({ Title = "360 Aim", Value = "G",
    Callback = function() flip("ThreeSixty", ThreeSixtyToggle) end })

-- ===== ESP =====
local ESPBox = Tabs.ESP:Section({ Title = "ESP", Icon = "eye", Box = true, BoxBorder = true, Opened = true })

ESPBox:Toggle({
    Title = "ESP Enabled",
    Value = CONFIG.ESPEnabled,
    Callback = function(v) CONFIG.ESPEnabled = v end,
})

ESPBox:Dropdown({
    Title = "ESP Options",
    Desc = "Choose what to display",
    MenuWidth = 170,
    Multi = true,
    AllowNone = true,
    Values = { "Skeleton", "Box", "Health", "Name", "Weapon", "Distance", "Tracer" },
    Value = { "Skeleton", "Health", "Name", "Weapon", "Distance" },
    Callback = function(selected)
        for k in pairs(CONFIG.ESPOpts) do CONFIG.ESPOpts[k] = false end
        if type(selected) == "table" then
            for _, opt in ipairs(selected) do CONFIG.ESPOpts[opt] = true end
        elseif type(selected) == "string" then
            CONFIG.ESPOpts[selected] = true
        end
    end,
})

ESPBox:Toggle({
    Title = "Show Teammates",
    Desc = "Also draw ESP on your team",
    Value = CONFIG.ShowTeammates,
    Callback = function(v) CONFIG.ShowTeammates = v end,
})

ESPBox:Slider({
    Title = "ESP Max Distance",
    Desc = "Hide players further than this (studs)",
    Step = 50,
    Value = { Min = 100, Max = 5000, Default = CONFIG.ESPMaxDist },
    Callback = function(v) CONFIG.ESPMaxDist = math.floor(v) end,
})

local ColorBox = Tabs.ESP:Section({ Title = "Colors", Icon = "palette", Box = true, BoxBorder = true, Opened = false })

ColorBox:Colorpicker({
    Title = "Enemy Color",
    Default = CONFIG.Colors.Enemy,
    Callback = function(c) CONFIG.Colors.Enemy = c end,
})
ColorBox:Colorpicker({
    Title = "Team Color",
    Default = CONFIG.Colors.Team,
    Callback = function(c) CONFIG.Colors.Team = c end,
})

-- ===== SOCIAL =====
local function copyLink(name, link)
    pcall(function() setclipboard(link) end)
    WindUI:Notify({ Title = name, Content = "Link copied to clipboard!", Icon = "check", Duration = 2 })
end

local SocialBox = Tabs.Social:Section({ Title = "Join the Community", Icon = "users", Box = true, BoxBorder = true, Opened = true })
SocialBox:Button({
    Title = "YouTube", Desc = "Ransblox Scripts - subscribe for more scripts", Icon = "youtube",
    Callback = function() copyLink("YouTube", YT_LINK) end,
})
SocialBox:Button({
    Title = "Website", Desc = "Script hub & request page", Icon = "globe",
    Callback = function() copyLink("Website", WEB_LINK) end,
})

-- ===== MISC =====
local UIBox = Tabs.Misc:Section({ Title = "Interface", Icon = "palette", Box = true, BoxBorder = true, Opened = true })

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

Tabs.Misc:Paragraph({
    Title = "Status",
    Desc = hookReady
        and "Bullet hook: Active"
        or  "Bullet hook: Not found (Silent Aim and Rapid Fire unavailable in this game)",
})

local function unload()
    if _G.FLICK_Unloaded == Window then return end
    _G.FLICK_Unloaded = Window
    CONFIG.SilentAim, CONFIG.RapidFire, CONFIG.Triggerbot, CONFIG.ESPEnabled = false, false, false, false
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    for player in pairs(ESP.players) do clearESP(player) end
    pcall(function() fovCircle:Remove() end)
    if hookReady and originalFire then
        pcall(function() BulletHandler.Fire = originalFire end)
        _G.__SA_HookInstalled = false
    end
    pcall(function() Window:Destroy() end)
    _G.FLICK_Unload = nil
end
_G.FLICK_Unload = unload

local DangerBox = Tabs.Misc:Section({ Title = "Script", Icon = "power", Box = true, BoxBorder = true, Opened = true })
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI, ESP and restores the original hook", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

WindUI:Notify({
    Title = HUB_NAME,
    Content = hookReady and "Loaded successfully!" or "Loaded, but bullet hook not found (different game?)",
    Icon = "zap",
    Duration = 4,
})
