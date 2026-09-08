local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local ToggleBtn = Instance.new("TextButton")

local Sidebar = Instance.new("Frame")
local ContentArea = Instance.new("Frame")

local Tab1Btn = Instance.new("TextButton")
local Tab2Btn = Instance.new("TextButton")
local Tab3Btn = Instance.new("TextButton")

local WarningLabel = Instance.new("TextLabel")

-- Protect GUI
ScreenGui.Name = "CHAOS_RF_V9_ULTRA"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Main Frame Setup (Advanced Cyber Neon)
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 170)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.12, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 620, 0, 480)
MainFrame.Active = true
MainFrame.Draggable = true

-- Header
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 24)

Title.Parent = Header
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ CHAOS MASTER HUB V9 - RAINBOW FRIENDS"
Title.TextColor3 = Color3.fromRGB(0, 255, 170)
Title.TextSize = 17
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Parent = Header
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.BackgroundColor3 = Color3.fromRGB(230, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Screen Toggle Side Button
ToggleBtn.Parent = ScreenGui
ToggleBtn.Position = UDim2.new(0, 8, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 100, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
ToggleBtn.Text = "CHAOS V9"
ToggleBtn.TextColor3 = Color3.fromRGB(10, 10, 15)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Danger Warning Radar Box
WarningLabel.Parent = ScreenGui
WarningLabel.Position = UDim2.new(0.32, 0, 0.02, 0)
WarningLabel.Size = UDim2.new(0, 380, 0, 40)
WarningLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
WarningLabel.BorderColor3 = Color3.fromRGB(0, 255, 170)
WarningLabel.BorderSizePixel = 2
WarningLabel.Text = "🛡️ RADAR: SEARCHING FOR MONSTERS..."
WarningLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
WarningLabel.Font = Enum.Font.SourceSansBold
WarningLabel.TextSize = 16

-- Sidebar & Content Layout
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 52)
Sidebar.Size = UDim2.new(0, 150, 1, -60)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)

ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 166, 0, 52)
ContentArea.Size = UDim2.new(1, -174, 1, -60)
ContentArea.BackgroundTransparency = 1

local function MakeTabBtn(btn, pos, text)
    btn.Parent = Sidebar
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
end

MakeTabBtn(Tab1Btn, UDim2.new(0, 0, 0, 0), "1. Main & Auto-Farm")
MakeTabBtn(Tab2Btn, UDim2.new(0, 0, 0, 50), "2. ESP & Visuals")
MakeTabBtn(Tab3Btn, UDim2.new(0, 0, 0, 100), "3. VIP Move (🔑)")

local function MakeScroll()
    local sc = Instance.new("ScrollingFrame", ContentArea)
    sc.Size = UDim2.new(1, 0, 1, 0)
    sc.CanvasSize = UDim2.new(0, 0, 0, 950)
    sc.BackgroundTransparency = 1
    sc.Visible = false
    local l = Instance.new("UIListLayout", sc)
    l.Padding = UDim.new(0, 7)
    return sc
end

local S1 = MakeScroll(); S1.Visible = true
local S2 = MakeScroll()
local S3 = MakeScroll()

-- KEY SYSTEM CONTAINER FOR TAB 3
local KeyUnlocked = false
local KeyLockFrame = Instance.new("Frame", ContentArea)
KeyLockFrame.Size = UDim2.new(1, 0, 1, 0)
KeyLockFrame.BackgroundTransparency = 1
KeyLockFrame.Visible = false

local function SwitchTab(activeTab, activeBtn)
    S1.Visible = false; S2.Visible = false; S3.Visible = false
    KeyLockFrame.Visible = false
    
    activeTab.Visible = true
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
end

Tab1Btn.MouseButton1Click:Connect(function() SwitchTab(S1, Tab1Btn) end)
Tab2Btn.MouseButton1Click:Connect(function() SwitchTab(S2, Tab2Btn) end)
Tab3Btn.MouseButton1Click:Connect(function()
    if KeyUnlocked then
        SwitchTab(S3, Tab3Btn)
    else
        SwitchTab(KeyLockFrame, Tab3Btn)
    end
end)

-- Core Helpers
local Plr = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function GetChar() return Plr.Character end
local function GetHum() return GetChar() and GetChar():FindFirstChildOfClass("Humanoid") end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end

local function AddButton(parent, text, bgColor, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -8, 0, 40)
    Btn.BackgroundColor3 = bgColor or Color3.fromRGB(28, 28, 42)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function AddToggle(parent, text, callback)
    local Enabled = false
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -8, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
    Btn.Text = text .. " : [ OFF ]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        if Enabled then
            Btn.BackgroundColor3 = Color3.fromRGB(25, 60, 35)
            Btn.Text = text .. " : [ ON ]"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 120)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
            Btn.Text = text .. " : [ OFF ]"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(Enabled)
    end)
    return Btn
end

-- =================================================================
-- MONSTER RADAR LOGIC
-- =================================================================
local MonstersList = {"Blue", "Green", "Orange", "Purple", "Yellow", "Cyan"}

RunService.RenderStepped:Connect(function()
    pcall(function()
        if GetRoot() then
            local NearestDist = 9999
            local NearestName = "None"
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and table.find(MonstersList, obj.Name) then
                    local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                    if part then
                        local dist = (part.Position - GetRoot().Position).Magnitude
                        if dist < NearestDist then
                            NearestDist = math.floor(dist)
                            NearestName = obj.Name
                        end
                    end
                end
            end
            
            if NearestDist < 35 then
                WarningLabel.Text = "⚠️ WARNING: " .. NearestName .. " is " .. tostring(NearestDist) .. "m away!"
                WarningLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                WarningLabel.BorderColor3 = Color3.fromRGB(255, 50, 50)
            else
                WarningLabel.Text = "🛡️ RADAR: SAFE (Nearest: " .. tostring(NearestDist) .. "m)"
                WarningLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                WarningLabel.BorderColor3 = Color3.fromRGB(0, 255, 170)
            end
        end
    end)
end)

-- =================================================================
-- TAB 1: MAIN & AUTO-FARM (ULTRA ENHANCED)
-- =================================================================

-- Fast Auto Complete Loop
AddButton(S1, "⚡ Instant Collect & Place All Items (Auto Win)", Color3.fromRGB(0, 180, 120), function()
    pcall(function()
        if GetRoot() then
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("TouchTransmitter") and item.Parent then
                    firetouchinterest(GetRoot(), item.Parent, 0)
                    firetouchinterest(GetRoot(), item.Parent, 1)
                elseif item:IsA("ProximityPrompt") then
                    fireproximityprompt(item)
                end
            end
            task.wait(0.3)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trigger" or obj.Name == "Deposit" or obj.Name == "Center" then
                    if obj:IsA("BasePart") then
                        GetRoot().CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end)
end)

-- Continuous Auto Collect Items
local AutoCollectLoop
AddToggle(S1, "🔄 Auto Loop Collect Items", function(v)
    if v then
        AutoCollectLoop = task.spawn(function()
            while v do
                pcall(function()
                    if GetRoot() then
                        for _, item in pairs(workspace:GetDescendants()) do
                            if item:IsA("TouchTransmitter") and item.Parent then
                                firetouchinterest(GetRoot(), item.Parent, 0)
                                firetouchinterest(GetRoot(), item.Parent, 1)
                            elseif item:IsA("ProximityPrompt") then
                                fireproximityprompt(item)
                            end
                        end
                    end
                end)
                task.wait(0.4)
            end
        end)
    else
        if AutoCollectLoop then task.cancel(AutoCollectLoop) end
    end
end)

-- Auto Hide In Box On Threat
local SmartBoxLoop
AddToggle(S1, "📦 Smart Auto-Box (When Monster Near)", function(v)
    if v then
        SmartBoxLoop = task.spawn(function()
            while v do
                pcall(function()
                    if GetRoot() then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and table.find(MonstersList, obj.Name) then
                                local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")
                                if part and (part.Position - GetRoot().Position).Magnitude < 30 then
                                    local boxEvent = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBox", true)
                                    if boxEvent then boxEvent:FireServer() end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    else
        if SmartBoxLoop then task.cancel(SmartBoxLoop) end
    end
end)

AddButton(S1, "📦 Equip Box Instantly", Color3.fromRGB(170, 110, 0), function()
    pcall(function()
        local boxEvent = game:GetService("ReplicatedStorage"):FindFirstChild("EquipBox", true)
        if boxEvent then boxEvent:FireServer() end
    end)
end)

AddButton(S1, "☀️ Fullbright & Remove Dark Fog", Color3.fromRGB(50, 80, 140), function()
    game:GetService("Lighting").ClockTime = 12
    game:GetService("Lighting").FogEnd = 1000000
    game:GetService("Lighting").Brightness = 3
end)

-- =================================================================
-- TAB 2: ESP & VISUALS
-- =================================================================

AddToggle(S2, "👹 Monster ESP (Red Glow)", function(v)
    task.spawn(function()
        while v do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and table.find(MonstersList, obj.Name) then
                    local hl = obj:FindFirstChild("ChaosMonsterESP")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "ChaosMonsterESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = obj
                    end
                end
            end
            task.wait(1)
        end
        if not v then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:FindFirstChild("ChaosMonsterESP") then
                    obj.ChaosMonsterESP:Destroy()
                end
            end
        end
    end)
end)

AddToggle(S2, "🎁 Quest Items ESP (Green Glow)", function(v)
    task.spawn(function()
        while v do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n, "block") or string.find(n, "fuse") or string.find(n, "battery") or string.find(n, "food") or string.find(n, "ticket") then
                        local hl = obj:FindFirstChild("ChaosItemESP")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "ChaosItemESP"
                            hl.FillColor = Color3.fromRGB(0, 255, 100)
                            hl.Parent = obj
                        end
                    end
                end
            end
            task.wait(1)
        end
        if not v then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:FindFirstChild("ChaosItemESP") then
                    obj.ChaosItemESP:Destroy()
                end
            end
        end
    end)
end)

AddToggle(S2, "👤 Player ESP (Cyan Glow)", function(v)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Plr and p.Character then
            local hl = p.Character:FindFirstChild("PlrESP")
            if v then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "PlrESP"
                    hl.FillColor = Color3.fromRGB(0, 200, 255)
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end)

-- =================================================================
-- TAB 3: VIP MOVEMENT & TELEPORTS (LOCKED)
-- =================================================================

AddToggle(S3, "🏃 Speed Boost (WalkSpeed 50)", function(v)
    if GetHum() then GetHum().WalkSpeed = v and 50 or 16 end
end)

AddToggle(S3, "⚡ God Speed Boost (WalkSpeed 120)", function(v)
    if GetHum() then GetHum().WalkSpeed = v and 120 or 16 end
end)

local NoclipConn
AddToggle(S3, "🛡️ Noclip (Walk Through Walls)", function(v)
    if v then
        NoclipConn = RunService.Stepped:Connect(function()
            if GetChar() then
                for _, part in pairs(GetChar():GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NoclipConn then NoclipConn:Disconnect() end
    end
end)

local FlyBv
AddToggle(S3, "✈️ Fly Mode (Camera Facing)", function(v)
    if v and GetRoot() then
        FlyBv = Instance.new("BodyVelocity", GetRoot())
        FlyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while FlyBv and FlyBv.Parent do
                FlyBv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 110
                task.wait()
            end
        end)
    else
        if FlyBv then FlyBv:Destroy() end
    end
end)

local InfJumpConn
AddToggle(S3, "🦘 Infinite Jump", function(v)
    if v then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            if GetHum() then GetHum():ChangeState("Jumping") end
        end)
    else
        if InfJumpConn then InfJumpConn:Disconnect() end
    end
end)

AddButton(S3, "🏰 Teleport to Safe Theater Stage", Color3.fromRGB(30, 90, 130), function()
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Theater" or v.Name == "GroupWalls" then
                GetRoot().CFrame = v.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end)
end)

-- =================================================================
-- KEY LOCK SYSTEM FOR TAB 3
-- =================================================================
local KInfo = Instance.new("TextLabel", KeyLockFrame)
KInfo.Size = UDim2.new(1, 0, 0, 32)
KInfo.Position = UDim2.new(0, 0, 0, 12)
KInfo.BackgroundTransparency = 1
KInfo.Text = "🔑 VIP Key Required! Get key from Discord:"
KInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
KInfo.Font = Enum.Font.SourceSansBold
KInfo.TextSize = 16

local CopyDisc = Instance.new("TextButton", KeyLockFrame)
CopyDisc.Size = UDim2.new(1, -10, 0, 44)
CopyDisc.Position = UDim2.new(0, 5, 0, 55)
CopyDisc.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
CopyDisc.Text = "📋 Copy Discord Link"
CopyDisc.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyDisc.Font = Enum.Font.SourceSansBold
CopyDisc.TextSize = 15

CopyDisc.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/FCCVREsjF")
        CopyDisc.Text = "✅ Discord Link Copied!"
        task.wait(2)
        CopyDisc.Text = "📋 Copy Discord Link"
    end
end)

local KeyInput = Instance.new("TextBox", KeyLockFrame)
KeyInput.Size = UDim2.new(1, -10, 0, 46)
KeyInput.Position = UDim2.new(0, 5, 0, 115)
KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
KeyInput.PlaceholderText = "Enter Key..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 215, 0)
KeyInput.Font = Enum.Font.SourceSansBold
KeyInput.TextSize = 16

local SubmitBtn = Instance.new("TextButton", KeyLockFrame)
SubmitBtn.Size = UDim2.new(1, -10, 0, 46)
SubmitBtn.Position = UDim2.new(0, 5, 0, 175)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
SubmitBtn.Text = "UNLOCK VIP TAB 3"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.TextSize = 16

local KeyStatus = Instance.new("TextLabel", KeyLockFrame)
KeyStatus.Size = UDim2.new(1, 0, 0, 25)
KeyStatus.Position = UDim2.new(0, 0, 0, 235)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = "Status: Waiting for key..."
KeyStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyStatus.Font = Enum.Font.SourceSans
KeyStatus.TextSize = 14

SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "RainbowFriends297" then
        KeyUnlocked = true
        KeyLockFrame:Destroy() -- Removes key input, button, and lock screen completely
        SwitchTab(S3, Tab3Btn) -- Unlocks Tab 3 automatically
    else
        KeyStatus.Text = "❌ Invalid Key! Please check Discord."
        KeyStatus.TextColor3 = Color3.fromRGB(255, 60, 60)
    end
end)
