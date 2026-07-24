setclipboard("https://www.youtube.com/@RANSBLOX")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local playerGui = lp:WaitForChild("PlayerGui")

getgenv().KnifeConfig = {
  Enabled = false,
  HitPart = "Head",
  FOV = 450
}

getgenv().ESPConfig = {
  PlayerNames = false,
  HealthESP = false,
  BoxESP = false,
  Tracers = false
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RansBlox_Visualizer"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = playerGui
end

local fovFrame = Instance.new("Frame")
fovFrame.Name = "FOVCircle"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundColor3 = Color3.fromRGB(132, 204, 22)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Size = UDim2.fromOffset(getgenv().KnifeConfig.FOV * 2, getgenv().KnifeConfig.FOV * 2)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = fovFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromHex("#84cc16")
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0
uiStroke.Parent = fovFrame

RunService.RenderStepped:Connect(function()
    if getgenv().KnifeConfig.Enabled then
        fovFrame.Visible = true
        local size = getgenv().KnifeConfig.FOV * 2
        fovFrame.Size = UDim2.fromOffset(size, size)
    else
        fovFrame.Visible = false
    end
end)

local function createESP(player)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(132, 204, 22)
    line.Thickness = 1
    line.Transparency = 1

    local boxTop = Drawing.new("Line")
    local boxBottom = Drawing.new("Line")
    local boxLeft = Drawing.new("Line")
    local boxRight = Drawing.new("Line")

    for _, boxLine in ipairs({boxTop, boxBottom, boxLeft, boxRight}) do
        boxLine.Visible = false
        boxLine.Color = Color3.fromRGB(132, 204, 22)
        boxLine.Thickness = 1
        boxLine.Transparency = 1
    end

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true

    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = Color3.fromRGB(132, 204, 22)
    healthText.Size = 13
    healthText.Center = true
    healthText.Outline = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player == lp then
            line.Visible = false
            boxTop.Visible = false
            boxBottom.Visible = false
            boxLeft.Visible = false
            boxRight.Visible = false
            nameText.Visible = false
            healthText.Visible = false
            if not player.Parent then
                line:Remove()
                boxTop:Remove()
                boxBottom:Remove()
                boxLeft:Remove()
                boxRight:Remove()
                nameText:Remove()
                healthText:Remove()
                connection:Disconnect()
            end
            return
        end

        local character = player.Character
        local rootPart = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")

        if humanoid and humanoid.Health > 0 and head then
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headVector = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
            local legVector = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local height = math.abs(headVector.Y - legVector.Y)
                local width = height / 2
                
                local topLeft = Vector2.new(vector.X - width / 2, headVector.Y)
                local topRight = Vector2.new(vector.X + width / 2, headVector.Y)
                local bottomLeft = Vector2.new(vector.X - width / 2, legVector.Y)
                local bottomRight = Vector2.new(vector.X + width / 2, legVector.Y)

                if getgenv().ESPConfig.Tracers then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end

                if getgenv().ESPConfig.BoxESP then
                    boxTop.From = topLeft
                    boxTop.To = topRight
                    boxTop.Visible = true

                    boxBottom.From = bottomLeft
                    boxBottom.To = bottomRight
                    boxBottom.Visible = true

                    boxLeft.From = topLeft
                    boxLeft.To = bottomLeft
                    boxLeft.Visible = true

                    boxRight.From = topRight
                    boxRight.To = bottomRight
                    boxRight.Visible = true
                else
                    boxTop.Visible = false
                    boxBottom.Visible = false
                    boxLeft.Visible = false
                    boxRight.Visible = false
                end

                if getgenv().ESPConfig.PlayerNames then
                    nameText.Text = player.Name
                    nameText.Position = Vector2.new(vector.X, headVector.Y - 18)
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end

                if getgenv().ESPConfig.HealthESP then
                    healthText.Text = math.floor(humanoid.Health) .. " HP"
                    healthText.Position = Vector2.new(vector.X, legVector.Y + 2)
                    healthText.Visible = true
                else
                    healthText.Visible = false
                end
            else
                line.Visible = false
                boxTop.Visible = false
                boxBottom.Visible = false
                boxLeft.Visible = false
                boxRight.Visible = false
                nameText.Visible = false
                healthText.Visible = false
            end
        else
            line.Visible = false
            boxTop.Visible = false
            boxBottom.Visible = false
            boxLeft.Visible = false
            boxRight.Visible = false
            nameText.Visible = false
            healthText.Visible = false
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= lp then
        coroutine.wrap(createESP)(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= lp then
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end
end)

local guiModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/main/RansGUI.lua"))()
local WindUI = guiModule.WindUI
local Window = guiModule.Window
local Tabs = guiModule.Tabs

local phem1 = game:GetService("Players")
local phem2 = game:GetService("Workspace")
local phem3 = phem1.LocalPlayer
local phem4 = phem2.CurrentCamera
local phem5 = require(phem3.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))

local function FindTarget()
  local phem7 = nil
  local phem8 = getgenv().KnifeConfig.FOV
  local phem9 = phem4.ViewportSize / 2
  for phem20, phem10 in phem1:GetPlayers() do
    if phem10 ~= phem3 and phem10.Character and phem10.Character:FindFirstChild("Humanoid") and phem10.Character.Humanoid.Health > 0 then
      local phem11 = phem10.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
      if phem11 then
        local phem12, phem13 = phem4:WorldToViewportPoint(phem11.Position)
        if phem13 then
          local phem14 = (Vector2.new(phem12.X, phem12.Y) - phem9).Magnitude
          if phem14 < phem8 then
            phem7 = phem10
            phem8 = phem14
          end
        end
      end
    end
  end
  return phem7
end

local phem15 = phem5._GetThrowDirection
phem5._GetThrowDirection = function(phem16, phem17)
  if getgenv().KnifeConfig.Enabled then
    local phem18 = FindTarget()
    if phem18 and phem18.Character then
      local phem19 = phem18.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
      if phem19 then
        return (phem19.Position - phem17.Position).Unit
      end
    end
  end
  return phem15(phem16, phem17)
end

Tabs.Main:Section({ Title = "Silent Aim" })

local fovSlider = nil

Tabs.Main:Toggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(v)
        getgenv().KnifeConfig.Enabled = v
        local status = v and "✓ ON" or "✗ OFF"
        WindUI:Notify({ Title = "Silent Aim", Content = status, Icon = "crosshair", Duration = 2 })
        
        if fovSlider then
            fovSlider.Enabled = v
        end
    end,
})

Tabs.Main:Space()

fovSlider = Tabs.Main:Slider({
    Title = "FOV Size",
    Step = 50,
    IsTooltip = true,
    Value = { Min = 100, Max = 800, Default = 450 },
    Enabled = false,
    Callback = function(v)
        getgenv().KnifeConfig.FOV = v
    end,
})

Tabs.Main:Space()

Tabs.Main:Dropdown({
    Title = "Hit Part",
    Values = {
        { Title = "Head", Icon = "target" },
        { Title = "Torso", Icon = "target" },
        { Title = "UpperTorso", Icon = "target" },
        { Title = "LowerTorso", Icon = "target" },
    },
    Value = "Head",
    Callback = function(v)
        getgenv().KnifeConfig.HitPart = v.Title
    end,
})

Tabs.ESP:Section({ Title = "Visual ESP Settings" })

Tabs.ESP:Toggle({
    Title = "Box ESP",
    Default = false,
    Callback = function(v)
        getgenv().ESPConfig.BoxESP = v
        WindUI:Notify({ Title = "ESP Box", Content = v and "✓ ON" or "✗ OFF", Icon = "eye", Duration = 2 })
    end,
})

Tabs.ESP:Space()

Tabs.ESP:Toggle({
    Title = "Tracers",
    Default = false,
    Callback = function(v)
        getgenv().ESPConfig.Tracers = v
        WindUI:Notify({ Title = "ESP Tracers", Content = v and "✓ ON" or "✗ OFF", Icon = "eye", Duration = 2 })
    end,
})

Tabs.ESP:Space()

Tabs.ESP:Toggle({
    Title = "Player Names",
    Default = false,
    Callback = function(v)
        getgenv().ESPConfig.PlayerNames = v
        WindUI:Notify({ Title = "ESP Names", Content = v and "✓ ON" or "✗ OFF", Icon = "user", Duration = 2 })
    end,
})

Tabs.ESP:Space()

Tabs.ESP:Toggle({
    Title = "Health Bar / Text",
    Default = false,
    Callback = function(v)
        getgenv().ESPConfig.HealthESP = v
        WindUI:Notify({ Title = "ESP Health", Content = v and "✓ ON" or "✗ OFF", Icon = "heart", Duration = 2 })
    end,
})

WindUI:Notify({
    Title = "RANSBLOX",
    Content = "Knife Duels loaded!",
    Icon = "youtube",
    Duration = 5,
})
