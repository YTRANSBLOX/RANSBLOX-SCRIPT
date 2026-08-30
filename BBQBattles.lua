local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/VVind-UI/refs/heads/main/src.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StatsService = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if VindUI.SetBlurEnabled then VindUI:SetBlurEnabled(false) end
end)

local Config = {
    KillAura = false,
    AuraRange = 30,
    SpeedBoost = false,
    WalkSpeed = 16,
    InfiniteJump = false,
    Noclip = false,
    ShowStatsOverlay = false,
    AntiAFK = true,
}

local Connections = {}
local AuraThread = nil

local CombatUtility = {
    target = nil,
    Initialized = false
}

function CombatUtility:GetCamera()
    local s, r = pcall(function() return Workspace.CurrentCamera end)
    return (s and r) and r or nil
end

function CombatUtility:GetCameraUnit()
    local cam = self:GetCamera()
    if cam then
        return cam.CFrame.LookVector.Unit
    end
    return nil
end

function CombatUtility:GetLocalPosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.CFrame
    end
    return nil
end

function CombatUtility:ReturnCharacters()
    local c = {}
    if self.Bots then
        for _, bot in pairs(self.Bots:GetChildren()) do
            table.insert(c, bot)
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            table.insert(c, plr.Character)
        end
    end
    return c
end

function CombatUtility:GetClosestPlayer()
    local closestdist = Config.AuraRange
    local closest = nil

    for _, char in ipairs(self:ReturnCharacters()) do
        if tostring(char) == LocalPlayer.Name or tostring(char) == LocalPlayer.DisplayName then
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local distance = LocalPlayer:DistanceFromCharacter(hrp.Position)
        if distance <= Config.AuraRange and distance < closestdist then
            closest = hrp
            closestdist = distance
        end
    end
    return closest
end

function CombatUtility:attack(t)
    if not self.Initialized then return end

    pcall(function()
        local attackid = debug.getupvalue(self.M1, 3)
        if not attackid then return end

        local localpos = self:GetLocalPosition()
        if not localpos then return end

        local cameraunit = self:GetCameraUnit()
        if not cameraunit then return end

        local timestamp = self.SynchronizedTime.timestamp()
        if not timestamp then return end

        self.SwingInit:FireServer(attackid, cameraunit)
        self.RegisterHit:FireServer(t, timestamp, localpos, attackid, cameraunit)
    end)
end

function CombatUtility:Init()
    if self.Initialized then return true end

    if not filtergc then
        return false
    end

    self.M1 = filtergc("function", {Name = "M1"}, true)
    if not self.M1 then
        return false
    end

    self.Modules = ReplicatedStorage:FindFirstChild("Modules")
    if not self.Modules then return false end

    local syncTimeModule = self.Modules:FindFirstChild("SynchronizedTime")
    if not syncTimeModule then return false end
    self.SynchronizedTime = require(syncTimeModule)

    self.Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not self.Remotes then return false end

    self.Hitreg = self.Remotes:FindFirstChild("Hitreg")
    if not self.Hitreg then return false end

    self.SwingInit = self.Hitreg:FindFirstChild("SwingInit")
    self.RegisterHit = self.Hitreg:FindFirstChild("RegisterHit")
    if not self.SwingInit or not self.RegisterHit then return false end

    self.Bots = Workspace:FindFirstChild("Bots")
    self.Initialized = true
    return true
end

local function StartKillAura()
    if AuraThread then return end
    AuraThread = task.spawn(function()
        local ready = CombatUtility:Init()
        if not ready then
            Config.KillAura = false
            return
        end

        while Config.KillAura do
            local target = CombatUtility:GetClosestPlayer()
            if target then
                CombatUtility:attack(target)
            end
            task.wait(0.05)
        end
        AuraThread = nil
    end)
end

local StatsGui = Instance.new("ScreenGui")
StatsGui.Name = "BBQStatsOverlay"
StatsGui.ResetOnSpawn = false
StatsGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

local statsFrame = Instance.new("TextLabel")
statsFrame.Name = "StatsLabel"
statsFrame.Size = UDim2.new(0, 150, 0, 26)
statsFrame.Position = UDim2.new(1, -160, 0, 12)
statsFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
statsFrame.BackgroundTransparency = 0.2
statsFrame.BorderSizePixel = 0
statsFrame.Text = "FPS: -- | Ping: -- ms"
statsFrame.TextColor3 = Color3.fromRGB(255, 170, 0)
statsFrame.Font = Enum.Font.SourceSansBold
statsFrame.TextSize = 13
statsFrame.Visible = false
statsFrame.Parent = StatsGui

local statsCorner = Instance.new("UICorner", statsFrame)
statsCorner.CornerRadius = UDim.new(0, 6)

local statsStroke = Instance.new("UIStroke", statsFrame)
statsStroke.Color = Color3.fromRGB(255, 120, 0)
statsStroke.Thickness = 1.2
statsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local frameCount = 0
local lastStatsTime = tick()

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if Config.SpeedBoost then
            hum.WalkSpeed = Config.WalkSpeed
        end
    end

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

table.insert(Connections, RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

table.insert(Connections, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

table.insert(Connections, LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

local Window = VindUI:CreateWindow({
    Title = "BBQ Battles 🍢",
    Subtitle = "Script Suite",
    Size = UDim2.fromOffset(630, 430),
    Icon = "Lucide:flame",
    ToggleKeybind = Enum.KeyCode.RightShift,
    UseBlur = false,
})

local TabMain = Window:AddTab({ Name = "Combat", Icon = "Lucide:swords" })
TabMain:AddSection("Kill Aura")

TabMain:AddToggle({
    Text = "Enable Kill Aura",
    Description = "Auto swing & register hit to nearby players/bots",
    Default = Config.KillAura,
    Callback = function(v)
        Config.KillAura = v
        if v then
            StartKillAura()
        end
    end,
})

TabMain:AddSlider({
    Text = "Aura Distance Range",
    Min = 5,
    Max = 50,
    Default = Config.AuraRange,
    Increment = 1,
    Callback = function(v)
        Config.AuraRange = v
    end,
})

local TabMovement = Window:AddTab({ Name = "Movement", Icon = "Lucide:footprints" })
TabMovement:AddSection("Speed Settings")

TabMovement:AddToggle({
    Text = "WalkSpeed Boost",
    Description = "Enable custom WalkSpeed",
    Default = Config.SpeedBoost,
    Callback = function(v)
        Config.SpeedBoost = v
        if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})

TabMovement:AddSlider({
    Text = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = Config.WalkSpeed,
    Increment = 1,
    Callback = function(v)
        Config.WalkSpeed = v
    end,
})

TabMovement:AddSection("Physics Exploit")

TabMovement:AddToggle({
    Text = "Noclip",
    Description = "Walk through walls",
    Default = Config.Noclip,
    Callback = function(v)
        Config.Noclip = v
    end,
})

TabMovement:AddToggle({
    Text = "Infinite Jump",
    Description = "Jump infinitely in mid-air",
    Default = Config.InfiniteJump,
    Callback = function(v)
        Config.InfiniteJump = v
    end,
})

local TabSettings = Window:AddTab({ Name = "Settings", Icon = "Lucide:settings" })
TabSettings:AddSection("HUD Overlays")

TabSettings:AddToggle({
    Text = "Show FPS & Ping Overlay",
    Description = "Displays live frame-rate & server latency",
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
    Callback = function(v)
        Config.AntiAFK = v
    end,
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
    Text = "Unload Script",
    Description = "Cleans up loops and destroys UI",
    Callback = function()
        Config.KillAura = false
        for _, c in ipairs(Connections) do
            pcall(function() c:Disconnect() end)
        end
        if StatsGui then StatsGui:Destroy() end
        Window:Destroy()
    end,
})
