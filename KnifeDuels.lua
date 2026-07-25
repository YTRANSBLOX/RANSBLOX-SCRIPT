local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

getgenv().KnifeConfig = {
  Enabled = true,
  HitPart = "Head",
  FOV = 450
}

getgenv().ESPConfig = {
  PlayerNames = true,
  HealthESP = true,
  BoxESP = true,
  Tracers = true
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Transparency = 1
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(132, 204, 22)
fovCircle.Filled = false
fovCircle.Radius = getgenv().KnifeConfig.FOV

RunService.RenderStepped:Connect(function()
    if getgenv().KnifeConfig.Enabled then
        fovCircle.Visible = true
        fovCircle.Radius = getgenv().KnifeConfig.FOV
        fovCircle.Position = Camera.ViewportSize / 2
    else
        fovCircle.Visible = false
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

local phem1 = game:GetService("Players")
local phem2 = game:GetService("Workspace")
local phem3 = phem1.LocalPlayer
local phem4 = phem2.CurrentCamera
local phem5 = require(phem3.PlayerScripts:WaitForChild("Controllers"):WaitForChild("Combat"):WaitForChild("KnifeController"))

local function phem6()
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
    local phem18 = phem6()
    if phem18 and phem18.Character then
      local phem19 = phem18.Character:FindFirstChild(getgenv().KnifeConfig.HitPart)
      if phem19 then
        return (phem19.Position - phem17.Position).Unit
      end
    end
  end
  return phem15(phem16, phem17)
end
