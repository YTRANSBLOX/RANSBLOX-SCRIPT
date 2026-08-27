task.wait(6)

if game:GetService("CoreGui"):FindFirstChild("TycoonManagerGui") then
	game:GetService("CoreGui").TycoonManagerGui:Destroy()
end

-- holyyy AURA
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local function applyAuraEffect(character)
	if not character then return end
	if character:FindFirstChild("ExecutorAuraEffect") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ExecutorAuraEffect"
	highlight.Adornee = character
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(120, 0, 255)
	highlight.OutlineTransparency = 0
	highlight.Parent = character

	local head = character:WaitForChild("Head", 5)
	if not head then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AuraTextGui"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = head

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.Arcade
	textLabel.Text = "AURA +9999999"
	textLabel.TextSize = 22
	textLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(15, 5, 25)
	textLabel.Parent = billboard

	local glowLabel = Instance.new("TextLabel")
	glowLabel.Size = UDim2.new(1, 0, 1, 0)
	glowLabel.BackgroundTransparency = 1
	glowLabel.Font = Enum.Font.Arcade
	glowLabel.Text = "AURA +9999999"
	glowLabel.TextSize = 22
	glowLabel.TextColor3 = Color3.fromRGB(70, 0, 120)
	glowLabel.TextStrokeTransparency = 1
	glowLabel.ZIndex = textLabel.ZIndex - 1
	glowLabel.Parent = billboard

	billboard.Parent = character

	local connection
	local startTime = tick()

	connection = RunService.RenderStepped:Connect(function()
		if not character or not character.Parent or not billboard.Parent then
			connection:Disconnect()
			return
		end
		local elapsed = tick() - startTime
		billboard.StudsOffset = Vector3.new(0, 3 + math.sin(elapsed * 3) * 0.3, 0)
		local pulse = (math.sin(elapsed * 5) + 1) / 2
		glowLabel.TextColor3 = Color3.fromRGB(50, 0, 80):Lerp(Color3.fromRGB(180, 0, 255), pulse)
		local scaleOffset = math.sin(elapsed * 4) * 0.05
		textLabel.TextSize = 22 + (scaleOffset * 4)
		glowLabel.TextSize = 22 + (scaleOffset * 4)
	end)
end

if localPlayer.Character then
	task.spawn(function()
		localPlayer.Character:WaitForChild("HumanoidRootPart")
		applyAuraEffect(localPlayer.Character)
	end)
end

localPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild("HumanoidRootPart")
	applyAuraEffect(character)
end)

-- mainGui
local PathfindingService = game:GetService("PathfindingService")

local beamsEnabled = true
local autoBuyEnabled = false
local autoRebirthEnabled = false
local usePathfind = false
local activePathTask = nil

local targetWalkSpeed = 45
local targetJumpPower = 50

local trackedTexts = {}

local function resolvePath(pathParts)
	local current = game
	for _, name in ipairs(pathParts) do
		current = current:FindFirstChild(name)
		if not current then return nil end
	end
	return current
end

local function monitorText(key, pathParts)
	task.spawn(function()
		local activeConnection = nil
		while true do
			local obj = resolvePath(pathParts)
			if obj then
				local actualText = nil
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					actualText = obj.Text
				elseif obj:IsA("StringValue") then
					actualText = obj.Value
				else
					pcall(function() actualText = obj.Text end)
				end

				if actualText ~= nil then
					trackedTexts[key] = tostring(actualText)
					if not activeConnection then
						local propertyToWatch = obj:IsA("StringValue") and "Value" or "Text"
						activeConnection = obj:GetPropertyChangedSignal(propertyToWatch):Connect(function()
							trackedTexts[key] = tostring(obj[propertyToWatch])
						end)
					end
				else
					trackedTexts[key] = nil
				end
			else
				if activeConnection then
					activeConnection:Disconnect()
					activeConnection = nil
				end
				trackedTexts[key] = nil
			end
			task.wait(1.5)
		end
	end)
end

monitorText("EssenceCappedTemp", {"Players", localPlayer.Name, "PlayerGui", "System", "Notifications", "NotiHolder", "EssenceCappedTemp", "Pos", "Text"})
monitorText("RebirthNotification", {"Players", localPlayer.Name, "PlayerGui", "System", "Notifications", "NotiHolder", "RebirthNotification", "Pos", "Text"})

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICornerFrame = Instance.new("UICorner")
local UIStrokeFrame = Instance.new("UIStroke")

local Header = Instance.new("Frame")
local HeaderCorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")

local CategoryBar = Instance.new("ScrollingFrame")
local CategoryList = Instance.new("UIListLayout")

local PanelStats = Instance.new("Frame")
local StatsLabel = Instance.new("TextLabel")
local RebirthContentFrame = Instance.new("Frame")
local PercentLabel = Instance.new("TextLabel")
local RebirthLabel = Instance.new("TextLabel")
local CappedStatusLabel = Instance.new("TextLabel")
local NumbersLabel = Instance.new("TextLabel")
local ProgressBarBg = Instance.new("Frame")
local ProgressBarBgCorner = Instance.new("UICorner")
local ProgressBarFill = Instance.new("Frame")
local ProgressBarFillCorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")

local PanelAutoFarm = Instance.new("Frame")
local AutoFarmList = Instance.new("UIListLayout")
local AutoBuyToggleBtn = Instance.new("TextButton")
local AutoBuyToggleCorner = Instance.new("UICorner")
local AutoRebirthToggleBtn = Instance.new("TextButton")
local AutoRebirthToggleCorner = Instance.new("UICorner")
local MoveModeBtn = Instance.new("TextButton")
local MoveModeCorner = Instance.new("UICorner")

local PanelButtons = Instance.new("Frame")
local autoPickCardEnabled = false

local ButtonsList = Instance.new("UIListLayout")
local BeamToggleBtn = Instance.new("TextButton")
local BeamToggleCorner = Instance.new("UICorner")
local MerchantsListFrame = Instance.new("Frame")
local MerchantsListLayout = Instance.new("UIListLayout")
local merchantListButtons = {}

local PanelMisc = Instance.new("Frame")
local MiscList = Instance.new("UIListLayout")

local ScrollFrame = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

local EtaFrame = Instance.new("Frame")
local EtaCorner = Instance.new("UICorner")
local EtaStroke = Instance.new("UIStroke")
local EtaLabel = Instance.new("TextLabel")

ScreenGui.Name = "TycoonManagerGui"
ScreenGui.Parent = game:GetService("CoreGui")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.ClipsDescendants = true
MainFrame.Active = true

UICornerFrame.CornerRadius = UDim.new(0, 8)
UICornerFrame.Parent = MainFrame

UIStrokeFrame.Parent = MainFrame
UIStrokeFrame.Color = Color3.fromRGB(35, 35, 45)
UIStrokeFrame.Thickness = 1.5

Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Header.Size = UDim2.new(1, 0, 0, 30)

HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Font = Enum.Font.Arcade
Title.RichText = true 
Title.Text = "TBOD^2    [ Held Roblox ]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = Header
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Font = Enum.Font.Arcade
MinimizeBtn.Text = "v"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14

CategoryBar.Name = "CategoryBar"
CategoryBar.Parent = MainFrame
CategoryBar.BackgroundTransparency = 1
CategoryBar.Position = UDim2.new(0, 5, 0, 33)
CategoryBar.Size = UDim2.new(1, -10, 0, 28)
CategoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
CategoryBar.ScrollBarThickness = 2
CategoryBar.AutomaticCanvasSize = Enum.AutomaticSize.X

CategoryList.Parent = CategoryBar
CategoryList.FillDirection = Enum.FillDirection.Horizontal
CategoryList.SortOrder = Enum.SortOrder.LayoutOrder
CategoryList.Padding = UDim.new(0, 5)

-- Stats
PanelStats.Name = "PanelStats"
PanelStats.Parent = MainFrame
PanelStats.BackgroundTransparency = 1
PanelStats.Position = UDim2.new(0, 0, 0, 65)
PanelStats.Size = UDim2.new(1, 0, 0, 170)
PanelStats.Visible = true

StatsLabel.Name = "StatsLabel"
StatsLabel.Parent = PanelStats
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 10, 0, 0)
StatsLabel.Size = UDim2.new(1, -20, 0, 45)
StatsLabel.Font = Enum.Font.Arcade
StatsLabel.Text = "Stats:\nCash: $0\nPlot: Searching..."
StatsLabel.TextColor3 = Color3.fromRGB(60, 200, 120)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

RebirthContentFrame.Name = "RebirthContentFrame"
RebirthContentFrame.Parent = PanelStats
RebirthContentFrame.BackgroundTransparency = 1
RebirthContentFrame.Position = UDim2.new(0, 0, 0, 50)
RebirthContentFrame.Size = UDim2.new(1, 0, 0, 115)

PercentLabel.Name = "PercentLabel"
PercentLabel.Parent = RebirthContentFrame
PercentLabel.BackgroundTransparency = 1
PercentLabel.Position = UDim2.new(0, 10, 0, 2)
PercentLabel.Size = UDim2.new(1, -20, 0, 18)
PercentLabel.Font = Enum.Font.Arcade
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PercentLabel.TextSize = 15

ProgressBarBg.Name = "ProgressBarBg"
ProgressBarBg.Parent = RebirthContentFrame
ProgressBarBg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ProgressBarBg.BorderSizePixel = 0
ProgressBarBg.Position = UDim2.new(0, 10, 0, 22)
ProgressBarBg.Size = UDim2.new(1, -20, 0, 10)
ProgressBarBg.ClipsDescendants = true

ProgressBarBgCorner.CornerRadius = UDim.new(0, 6)
ProgressBarBgCorner.Parent = ProgressBarBg

ProgressBarFill.Name = "ProgressBarFill"
ProgressBarFill.Parent = ProgressBarBg
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)

ProgressBarFillCorner.CornerRadius = UDim.new(0, 6)
ProgressBarFillCorner.Parent = ProgressBarFill

UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
UIGradient.Parent = ProgressBarFill

RebirthLabel.Name = "RebirthLabel"
RebirthLabel.Parent = RebirthContentFrame
RebirthLabel.BackgroundTransparency = 1
RebirthLabel.Position = UDim2.new(0, 10, 0, 36)
RebirthLabel.Size = UDim2.new(1, -20, 0, 16)
RebirthLabel.Font = Enum.Font.Arcade
RebirthLabel.Text = "Progress: Loading..."
RebirthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RebirthLabel.TextSize = 12
RebirthLabel.TextWrapped = true

CappedStatusLabel.Name = "CappedStatusLabel"
CappedStatusLabel.Parent = RebirthContentFrame
CappedStatusLabel.BackgroundTransparency = 1
CappedStatusLabel.Position = UDim2.new(0, 10, 0, 54)
CappedStatusLabel.Size = UDim2.new(1, -20, 0, 16)
CappedStatusLabel.Font = Enum.Font.Arcade
CappedStatusLabel.Text = "Capped: Loading..."
CappedStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CappedStatusLabel.TextSize = 12
CappedStatusLabel.TextWrapped = true

NumbersLabel.Name = "NumbersLabel"
NumbersLabel.Parent = RebirthContentFrame
NumbersLabel.BackgroundTransparency = 1
NumbersLabel.Position = UDim2.new(0, 10, 0, 72)
NumbersLabel.Size = UDim2.new(1, -20, 0, 32)
NumbersLabel.Font = Enum.Font.Arcade
NumbersLabel.Text = "Numbers: Loading..."
NumbersLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
NumbersLabel.TextSize = 12
NumbersLabel.TextWrapped = true

-- Auto Farm
PanelAutoFarm.Name = "PanelAutoFarm"
PanelAutoFarm.Parent = MainFrame
PanelAutoFarm.BackgroundTransparency = 1
PanelAutoFarm.Position = UDim2.new(0, 10, 0, 65)
PanelAutoFarm.Size = UDim2.new(1, -20, 0, 170)
PanelAutoFarm.Visible = false

AutoFarmList.Parent = PanelAutoFarm
AutoFarmList.SortOrder = Enum.SortOrder.LayoutOrder
AutoFarmList.Padding = UDim.new(0, 5)

AutoBuyToggleBtn.Name = "AutoBuyToggleBtn"
AutoBuyToggleBtn.Parent = PanelAutoFarm
AutoBuyToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AutoBuyToggleBtn.Size = UDim2.new(1, 0, 0, 25)
AutoBuyToggleBtn.Font = Enum.Font.Arcade
AutoBuyToggleBtn.Text = "Auto Buy: OFF"
AutoBuyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBuyToggleBtn.TextSize = 12
AutoBuyToggleCorner.CornerRadius = UDim.new(0, 6)
AutoBuyToggleCorner.Parent = AutoBuyToggleBtn

AutoRebirthToggleBtn.Name = "AutoRebirthToggleBtn"
AutoRebirthToggleBtn.Parent = PanelAutoFarm
AutoRebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AutoRebirthToggleBtn.Size = UDim2.new(1, 0, 0, 25)
AutoRebirthToggleBtn.Font = Enum.Font.Arcade
AutoRebirthToggleBtn.Text = "Auto Rebirth: OFF"
AutoRebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRebirthToggleBtn.TextSize = 12
AutoRebirthToggleCorner.CornerRadius = UDim.new(0, 6)
AutoRebirthToggleCorner.Parent = AutoRebirthToggleBtn

local RebirthModeBtn = Instance.new("TextButton")
local RebirthModeCorner = Instance.new("UICorner")
RebirthModeBtn.Name = "RebirthModeBtn"
RebirthModeBtn.Parent = PanelAutoFarm
RebirthModeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
RebirthModeBtn.Size = UDim2.new(1, 0, 0, 25)
RebirthModeBtn.Font = Enum.Font.Arcade
RebirthModeBtn.Text = "Rebirth Trigger: Both"
RebirthModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthModeBtn.TextSize = 12
RebirthModeCorner.CornerRadius = UDim.new(0, 6)
RebirthModeCorner.Parent = RebirthModeBtn

local rebirthTriggerMode = "Any" 

RebirthModeBtn.MouseButton1Click:Connect(function()
	if rebirthTriggerMode == "Any" then
		rebirthTriggerMode = "Essence"
		RebirthModeBtn.Text = "Essence Cap"
	elseif rebirthTriggerMode == "Essence" then
		rebirthTriggerMode = "RebirthNoti"
		RebirthModeBtn.Text = "Progress 100%"
	else
		rebirthTriggerMode = "Any"
		RebirthModeBtn.Text = "Rebirth Trigger: Both"
	end
end)

MoveModeBtn.Name = "MoveModeBtn"
MoveModeBtn.Parent = PanelAutoFarm
MoveModeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MoveModeBtn.Size = UDim2.new(1, 0, 0, 25)
MoveModeBtn.Font = Enum.Font.Arcade
MoveModeBtn.Text = "Mode: Teleport"
MoveModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MoveModeBtn.TextSize = 12
MoveModeCorner.CornerRadius = UDim.new(0, 6)
MoveModeCorner.Parent = MoveModeBtn

-- Buttons
PanelButtons.Name = "PanelButtons"
PanelButtons.Parent = MainFrame
PanelButtons.BackgroundTransparency = 1
PanelButtons.Position = UDim2.new(0, 10, 0, 65)
PanelButtons.Size = UDim2.new(1, -20, 0, 250)
PanelButtons.Visible = false

ButtonsList.Parent = PanelButtons
ButtonsList.SortOrder = Enum.SortOrder.LayoutOrder
ButtonsList.Padding = UDim.new(0, 5)
BeamToggleBtn.Name = "BeamToggleBtn"
BeamToggleBtn.Parent = PanelButtons
BeamToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
BeamToggleBtn.Size = UDim2.new(1, 0, 0, 25)
BeamToggleBtn.Font = Enum.Font.Arcade
BeamToggleBtn.Text = "Guidelines: ON"
BeamToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BeamToggleBtn.TextSize = 12
BeamToggleCorner.CornerRadius = UDim.new(0, 6)
BeamToggleCorner.Parent = BeamToggleBtn

local AutoPickToggleBtn = Instance.new("TextButton")
local AutoPickToggleCorner = Instance.new("UICorner")

AutoPickToggleBtn.Name = "AutoPickToggleBtn"
AutoPickToggleBtn.Parent = PanelButtons
AutoPickToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AutoPickToggleBtn.Size = UDim2.new(1, 0, 0, 25)
AutoPickToggleBtn.Font = Enum.Font.Arcade
AutoPickToggleBtn.Text = "Auto Pick Card: OFF"
AutoPickToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPickToggleBtn.TextSize = 12
AutoPickToggleCorner.CornerRadius = UDim.new(0, 6)
AutoPickToggleCorner.Parent = AutoPickToggleBtn

AutoPickToggleBtn.MouseButton1Click:Connect(function()
	autoPickCardEnabled = not autoPickCardEnabled
	if autoPickCardEnabled then
		AutoPickToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
		AutoPickToggleBtn.Text = "Auto Pick Card: ON"
	else
		AutoPickToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		AutoPickToggleBtn.Text = "Auto Pick Card: OFF"
	end
end)

MerchantsListFrame.Name = "MerchantsListFrame"
MerchantsListFrame.Parent = PanelButtons
MerchantsListFrame.BackgroundTransparency = 1
MerchantsListFrame.Size = UDim2.new(1, 0, 0, 0)
MerchantsListFrame.AutomaticSize = Enum.AutomaticSize.Y
MerchantsListLayout.Parent = MerchantsListFrame
MerchantsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MerchantsListLayout.Padding = UDim.new(0, 3)

-- Misc Panel
PanelMisc.Name = "PanelMisc"
PanelMisc.Parent = MainFrame
PanelMisc.BackgroundTransparency = 1
PanelMisc.Position = UDim2.new(0, 10, 0, 65)
PanelMisc.Size = UDim2.new(1, -20, 0, 170)
PanelMisc.Visible = false

MiscList.Parent = PanelMisc
MiscList.SortOrder = Enum.SortOrder.LayoutOrder
MiscList.Padding = UDim.new(0, 5)

-- WalkSpeed Frame Setup
local WalkSpeedFrame = Instance.new("Frame")
local WSCorner = Instance.new("UICorner")
local WalkSpeedLabel = Instance.new("TextLabel")
local WalkSpeedInput = Instance.new("TextBox")
local WSInputCorner = Instance.new("UICorner")

WalkSpeedFrame.Name = "WalkSpeedFrame"
WalkSpeedFrame.Parent = PanelMisc
WalkSpeedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
WalkSpeedFrame.Size = UDim2.new(1, 0, 0, 25)
WSCorner.CornerRadius = UDim.new(0, 6)
WSCorner.Parent = WalkSpeedFrame

WalkSpeedLabel.Name = "WalkSpeedLabel"
WalkSpeedLabel.Parent = WalkSpeedFrame
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
WalkSpeedLabel.Position = UDim2.new(0, 5, 0, 0)
WalkSpeedLabel.Font = Enum.Font.Arcade
WalkSpeedLabel.Text = "WalkSpeed:"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedLabel.TextSize = 14
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

WalkSpeedInput.Name = "WalkSpeedInput"
WalkSpeedInput.Parent = WalkSpeedFrame
WalkSpeedInput.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
WalkSpeedInput.Size = UDim2.new(0.35, 0, 0.8, 0)
WalkSpeedInput.Position = UDim2.new(0.6, -5, 0.1, 0)
WalkSpeedInput.Font = Enum.Font.Arcade
WalkSpeedInput.Text = "16"
WalkSpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSpeedInput.TextSize = 14
WSInputCorner.CornerRadius = UDim.new(0, 4)
WSInputCorner.Parent = WalkSpeedInput

local speedConnection
local function enforceWalkSpeed(character)
	if not character then return end
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	if speedConnection then speedConnection:Disconnect() end

	-- Immediately override if game script attempts to reset WalkSpeed property
	speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if targetWalkSpeed and humanoid.WalkSpeed ~= targetWalkSpeed then
			humanoid.WalkSpeed = targetWalkSpeed
		end
	end)

	humanoid.WalkSpeed = targetWalkSpeed
end

if localPlayer.Character then enforceWalkSpeed(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(enforceWalkSpeed)

-- JumpPower Frame Setup
local JumpPowerFrame = Instance.new("Frame")
local JPCorner = Instance.new("UICorner")
local JumpPowerLabel = Instance.new("TextLabel")
local JumpPowerInput = Instance.new("TextBox")
local JPInputCorner = Instance.new("UICorner")

JumpPowerFrame.Name = "JumpPowerFrame"
JumpPowerFrame.Parent = PanelMisc
JumpPowerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
JumpPowerFrame.Size = UDim2.new(1, 0, 0, 25)
JPCorner.CornerRadius = UDim.new(0, 6)
JPCorner.Parent = JumpPowerFrame

JumpPowerLabel.Name = "JumpPowerLabel"
JumpPowerLabel.Parent = JumpPowerFrame
JumpPowerLabel.BackgroundTransparency = 1
JumpPowerLabel.Size = UDim2.new(0.6, 0, 1, 0)
JumpPowerLabel.Position = UDim2.new(0, 5, 0, 0)
JumpPowerLabel.Font = Enum.Font.Arcade
JumpPowerLabel.Text = "JumpPower:"
JumpPowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerLabel.TextSize = 14
JumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left

JumpPowerInput.Name = "JumpPowerInput"
JumpPowerInput.Parent = JumpPowerFrame
JumpPowerInput.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
JumpPowerInput.Size = UDim2.new(0.35, 0, 0.8, 0)
JumpPowerInput.Position = UDim2.new(0.6, -5, 0.1, 0)
JumpPowerInput.Font = Enum.Font.Arcade
JumpPowerInput.Text = "50"
JumpPowerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpPowerInput.TextSize = 14
JPInputCorner.CornerRadius = UDim.new(0, 4)
JPInputCorner.Parent = JumpPowerInput

WalkSpeedInput.FocusLost:Connect(function()
	local val = tonumber(WalkSpeedInput.Text)
	if val then
		targetWalkSpeed = val
	else
		WalkSpeedInput.Text = tostring(targetWalkSpeed)
	end
end)

JumpPowerInput.FocusLost:Connect(function()
	local val = tonumber(JumpPowerInput.Text)
	if val then
		targetJumpPower = val
	else
		JumpPowerInput.Text = tostring(targetJumpPower)
	end
end)

-- Tabs setup
local panels = {
	Stats = PanelStats,
	["Auto Farm"] = PanelAutoFarm,
	Merchant = PanelButtons,
	Misc = PanelMisc
}

local panelButtons = {}

local function createPanelTab(name, targetPanel, defaultActive)
	local tabBtn = Instance.new("TextButton")
	local tabCorner = Instance.new("UICorner")
	local tabStroke = Instance.new("UIStroke")

	tabBtn.Name = name .. "Tab"
	tabBtn.Parent = CategoryBar
	tabBtn.Size = UDim2.new(0, 80, 1, 0)
	tabBtn.Font = Enum.Font.Arcade
	tabBtn.Text = name
	tabBtn.TextSize = 12

	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tabBtn

	tabStroke.Parent = tabBtn
	tabStroke.Color = Color3.fromRGB(35, 35, 45)
	tabStroke.Thickness = 1

	if defaultActive then
		tabBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	end

	panelButtons[name] = tabBtn

	tabBtn.MouseButton1Click:Connect(function()
		for pName, panelObj in pairs(panels) do
			panelObj.Visible = (panelObj == targetPanel)
		end
		for bName, buttonObj in pairs(panelButtons) do
			if bName == name then
				buttonObj.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
				buttonObj.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				buttonObj.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				buttonObj.TextColor3 = Color3.fromRGB(180, 180, 180)
			end
		end
	end)
end

createPanelTab("Stats", PanelStats, true)
createPanelTab("Auto Farm", PanelAutoFarm, false)
createPanelTab("Merchant", PanelButtons, false)
createPanelTab("Misc", PanelMisc, false)

local isCompleteRGB = false

task.spawn(function()
	local offset = 0
	while true do
		if isCompleteRGB then
			offset = (offset + 0.02) % 1
			UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV((0 + offset) % 1, 1, 1)),
				ColorSequenceKeypoint.new(0.2, Color3.fromHSV((0.2 + offset) % 1, 1, 1)),
				ColorSequenceKeypoint.new(0.4, Color3.fromHSV((0.4 + offset) % 1, 1, 1)),
				ColorSequenceKeypoint.new(0.6, Color3.fromHSV((0.6 + offset) % 1, 1, 1)),
				ColorSequenceKeypoint.new(0.8, Color3.fromHSV((0.8 + offset) % 1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV((1 + offset) % 1, 1, 1))
			})
		end
		task.wait(0.03)
	end
end)

local function parseSuffixValue(str)
	if not str then return 0 end
	str = string.upper(string.gsub(str, "[%,%$%s]", ""))
	local num, suffix = string.match(str, "([%d%.]+)(%a*)")
	num = tonumber(num) or 0

	local multipliers = { K = 1e3, M = 1e6, B = 1e9, T = 1e12, QA = 1e15, QI = 1e18, SX = 1e21, SP = 1e24, O = 1e27, N = 1e30, D = 1e33 }
	if suffix and multipliers[suffix] then
		return num * multipliers[suffix]
	end
	return num
end

local function parseProgress(text)
	local upperText = string.upper(text)
	if string.find(upperText, "COMPLETE") then return 100 end

	local currentStr, maxStr = string.match(text, "([%d%,%.%a]+)%s*/%s*([%d%,%.%a]+)")
	if currentStr and maxStr then
		local current = parseSuffixValue(currentStr)
		local max = parseSuffixValue(maxStr)

		local leaderstats = localPlayer:FindFirstChild("leaderstats")
		local cashVal = leaderstats and (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money"))
		if cashVal then
			local rawCash = tonumber(cashVal.Value) or 0
			if rawCash > current then current = rawCash end
		end

		if current and max and max > 0 then
			return math.clamp((current / max) * 100, 0, 100)
		end
	end

	local rawPercent = string.match(text, "(%d+%.?%d*)%%")
	if rawPercent then
		return math.clamp(tonumber(rawPercent) or 0, 0, 100)
	end
	return 0
end

local globalProgressLabel
local globalCappedObj
local globalNumbersLabel
local lastNumbersText = ""

local function checkCappedState()
	if not globalCappedObj then
		local playerGui = localPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			local main = playerGui:FindFirstChild("Main")
			if main and main:FindFirstChild("Rebirth", true) then
				globalCappedObj = main.Rebirth:FindFirstChild("Capped", true)
			end
		end
		if not globalCappedObj then
			local starterGui = game:GetService("StarterGui")
			if starterGui:FindFirstChild("Main") then
				globalCappedObj = starterGui.Main:FindFirstChild("Capped", true)
			end
		end
	end

	if not globalCappedObj then return false end

	local targetObj = globalCappedObj
	if globalCappedObj:IsDescendantOf(game:GetService("StarterGui")) then
		local relativePath = globalCappedObj:GetFullName():gsub("^StarterGui", "PlayerGui")
		if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
			local found = localPlayer.PlayerGui
			for part in relativePath:gmatch("[^%.]+") do
				if part ~= "PlayerGui" then
					found = found:FindFirstChild(part)
					if not found then break end
				end
			end
			if found then targetObj = found end
		end
	end

	if targetObj:IsA("GuiObject") and not targetObj.Visible then
		return false
	end

	local current = targetObj
	while current do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		if current:IsA("ScreenGui") then
			return current.Enabled
		end
		current = current.Parent
	end

	return true
end

local function updateMonitor()
	local textVal = globalProgressLabel and globalProgressLabel.Text or ""
	local rawNumbersVal = globalNumbersLabel and globalNumbersLabel.Text or ""
	local numbersVal = rawNumbersVal

	-- Parse raw text if it contains numeric rebirth counts
	if rawNumbersVal ~= "" and rawNumbersVal ~= "N/A" then
		local currentRebirth = tonumber(string.match(rawNumbersVal, "(%d+)"))
		if currentRebirth then
			numbersVal = string.format("(%d --> %d)", currentRebirth, currentRebirth + 1)
		end
	end

	-- Fallback 1: Leaderstats check
	if numbersVal == "" or numbersVal == "N/A" then
		local leaderstats = localPlayer:FindFirstChild("leaderstats") or localPlayer:FindFirstChild("stats")
		local rebirthVal = leaderstats and (leaderstats:FindFirstChild("Rebirths") or leaderstats:FindFirstChild("Rebirth") or leaderstats:FindFirstChild("Rank") or leaderstats:FindFirstChild("RebirthsCount"))
		if rebirthVal then
			local currentRebirth = tonumber(rebirthVal.Value) or 0
			numbersVal = string.format("(%d --> %d)", currentRebirth, currentRebirth + 1)
		end
	end

	-- Fallback 2: Direct PlayerGui deep scan for any TextLabel displaying Rebirth count
	if numbersVal == "" or numbersVal == "N/A" then
		local pGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
		if pGui then
			for _, v in ipairs(pGui:GetDescendants()) do
				if v:IsA("TextLabel") and v.Visible then
					local nameCheck = string.lower(v.Name)
					local textCheck = v.Text
					if (string.find(nameCheck, "reb") or string.find(nameCheck, "rank")) and string.match(textCheck, "%d+") then
						local num = tonumber(string.match(textCheck, "(%d+)"))
						if num then
							numbersVal = string.format("(%d --> %d)", num, num + 1)
							break
						end
					end
				end
			end
		end
	end

	if numbersVal ~= "N/A" and numbersVal ~= "" then
		if lastNumbersText ~= "" and numbersVal ~= lastNumbersText then
			local oldFrom, oldTo = string.match(lastNumbersText, "%((%d+)%s*%-%->%s*(%d+)%)")
			local newFrom, newTo = string.match(numbersVal, "%((%d+)%s*%-%->%s*(%d+)%)")
			if oldFrom and newFrom and tonumber(newFrom) > tonumber(oldFrom) then
				lastNumbersText = numbersVal
			end
		elseif lastNumbersText == "" then
			lastNumbersText = numbersVal
		end
	end

	local displayNumbers = (numbersVal ~= "" and numbersVal ~= "N/A") and numbersVal or (lastNumbersText ~= "" and lastNumbersText or "N/A")
	local isCappedVisible = checkCappedState()

	RebirthLabel.Text = "Progress: " .. (textVal ~= "" and textVal or "N/A")
	CappedStatusLabel.Text = "Capped: " .. (isCappedVisible and "TRUE" or "FALSE")
	NumbersLabel.Text = "Rebirth(s): " .. displayNumbers

	local percent = parseProgress(textVal ~= "" and textVal or displayNumbers)

	if autoRebirthEnabled then
		local shouldRebirth = false
		local essenceText = trackedTexts["EssenceCappedTemp"]
		local rebirthNotiText = trackedTexts["RebirthNotification"]

		local hasEssenceNoti = essenceText and string.find(string.lower(essenceText), "your essence is capped") ~= nil
		local hasRebirthNoti = rebirthNotiText and rebirthNotiText ~= "" and rebirthNotiText ~= "N/A"

		if not hasEssenceNoti then
			local pGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
			if pGui then
				for _, v in ipairs(pGui:GetDescendants()) do
					if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Visible then
						local txt = string.lower(tostring(v.Text or ""))
						if string.find(txt, "your essence is capped") then
							hasEssenceNoti = true
							break
						end
					end
				end
			end
		end

		if rebirthTriggerMode == "Any" then
			shouldRebirth = hasEssenceNoti or hasRebirthNoti
		elseif rebirthTriggerMode == "Essence" then
			-- MaxEssenceCap
			shouldRebirth = hasEssenceNoti
		elseif rebirthTriggerMode == "RebirthNoti" then
			-- MaxProgressBar
			shouldRebirth = hasRebirthNoti
		end

		if shouldRebirth then
			if not _G.isRebirthing then
				_G.isRebirthing = true
				task.spawn(function()
					local success, err = pcall(function()
						local clickPart = workspace:FindFirstChild("Obelisk") and workspace.Obelisk:FindFirstChild("RebirthButton") and workspace.Obelisk.RebirthButton:FindFirstChild("Click")
						if clickPart then
							local detector = clickPart:FindFirstChildOfClass("ClickDetector")
							if detector then
								detector.MaxActivationDistance = math.huge
								fireclickdetector(detector)
							end
						end
					end)
					task.wait(0.6)
					pcall(function()
						local GuiService = game:GetService("GuiService")
						local VirtualInputManager = game:GetService("VirtualInputManager")
						local gui = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 3)
						if gui then
							local function realClick(btn)
								if not btn or not btn:IsA("GuiObject") then return end
								local pos = btn.AbsolutePosition
								local size = btn.AbsoluteSize
								local inset = GuiService:GetGuiInset()
								local centerX = pos.X + (size.X / 2)
								local centerY = pos.Y + (size.Y / 2) + inset.Y
								VirtualInputManager:SendMouseMoveEvent(centerX, centerY, game)
								task.wait(0.02)
								VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
								task.wait(0.05)
								VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
							end

							for _, v in ipairs(gui:GetDescendants()) do
								if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
									local nameCheck = string.upper(tostring(v.Name or ""))
									local textCheck = string.upper(tostring(v.Text or ""))
									if nameCheck == "REBIRTH" or nameCheck == "REBIRTHBUTTON" or string.find(textCheck, "REBIRTH") then
										realClick(v)
										break
									end
								end
							end
						end
					end)
					task.wait(4)
					_G.isRebirthing = false
				end)
			end

			if not _G.isTeleportingPlot then
				_G.isTeleportingPlot = true
				task.spawn(function()
					task.wait(5)
					pcall(function()
						local myPlotName = getMyPlot()
						if myPlotName ~= "None" and localPlayer.Character then
							local plotObj = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(myPlotName)
							if plotObj then
								local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
								if root then
									local targetCFrame = plotObj:GetPivot()
									local spawnPad = plotObj:FindFirstChild("Spawn") or plotObj:FindFirstChild("SpawnLocation") or plotObj:FindFirstChild("ClaimPart")
									if spawnPad and spawnPad:IsA("BasePart") then
										targetCFrame = spawnPad.CFrame + Vector3.new(0, 8, 0)
									else
										targetCFrame = targetCFrame + Vector3.new(0, 8, 0)
									end
									root.CFrame = targetCFrame
								end
							end
						end
					end)
					_G.isTeleportingPlot = false
				end)
			end
		end
	end

	PercentLabel.Text = string.format("%.1f%%", percent)

	if isCappedVisible then
		isCompleteRGB = true
		UIGradient.Rotation = 0
	else
		isCompleteRGB = false
		UIGradient.Rotation = 0
		if autoRebirthEnabled and percent >= 100 then
			UIGradient.Color = ColorSequence.new(Color3.fromRGB(60, 200, 120))
		elseif percent < 99 then
			local t = percent / 100
			local currentColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(60, 200, 120), t)
			UIGradient.Color = ColorSequence.new(currentColor)
		else
			UIGradient.Color = ColorSequence.new(Color3.fromRGB(60, 200, 120))
		end
	end

	local fillScale = percent / 100
	ProgressBarFill:TweenSize(
		UDim2.new(fillScale, 0, 1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.2,
		true
	)
end

task.spawn(function()
	local textConn, cappedConn, numbersConn, leaderConn

	local function hookMonitor(gui)
		if textConn then textConn:Disconnect() textConn = nil end
		if cappedConn then cappedConn:Disconnect() cappedConn = nil end
		if numbersConn then numbersConn:Disconnect() numbersConn = nil end

		pcall(function()
			globalProgressLabel = gui:WaitForChild("System", 2):WaitForChild("RebirthProgress", 2):WaitForChild("Progress", 2):WaitForChild("TextLabel", 2)
		end)

		pcall(function()
			local rebirthFrame = gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Rebirth")
			if rebirthFrame then globalCappedObj = rebirthFrame:FindFirstChild("Capped", true) end
			if not globalCappedObj then
				local starterGui = game:GetService("StarterGui")
				local starterRebirth = starterGui:FindFirstChild("Main") and starterGui.Main:FindFirstChild("Rebirth")
				if starterRebirth then globalCappedObj = starterRebirth:FindFirstChild("Capped", true) end
			end
		end)

		pcall(function()
			local playerList = gui:WaitForChild("System", 2):WaitForChild("PlayerList", 2):WaitForChild("Holder", 2)
			local myHolder = playerList:FindFirstChild(localPlayer.Name) or playerList:FindFirstChildWhichIsA("Frame")
			if myHolder then globalNumbersLabel = myHolder:WaitForChild("RebsText", 2) end
		end)

		pcall(function()
			if not globalNumbersLabel then
				local rebirthFrame = gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Rebirth")
				if rebirthFrame then globalNumbersLabel = rebirthFrame:FindFirstChild("Numbers", true) end
			end
		end)

		if globalProgressLabel then textConn = globalProgressLabel:GetPropertyChangedSignal("Text"):Connect(updateMonitor) end
		if globalCappedObj then cappedConn = globalCappedObj:GetPropertyChangedSignal("Visible"):Connect(updateMonitor) end
		if globalNumbersLabel then numbersConn = globalNumbersLabel:GetPropertyChangedSignal("Text"):Connect(updateMonitor) end

		local leaderstats = localPlayer:FindFirstChild("leaderstats") or localPlayer:FindFirstChild("stats")
		local cashVal = leaderstats and (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money"))
		if cashVal then
			if leaderConn then leaderConn:Disconnect() end
			leaderConn = cashVal:GetPropertyChangedSignal("Value"):Connect(updateMonitor)
		end

		updateMonitor()
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	hookMonitor(playerGui)

	localPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		hookMonitor(localPlayer:WaitForChild("PlayerGui"))
	end)

	while true do
		task.wait(1.2)
		updateMonitor()
	end
end)

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 5, 0, 320)
ScrollFrame.Size = UDim2.new(1, -10, 1, -325)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

UIList.Parent = ScrollFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame
UIPadding.PaddingRight = UDim.new(0, 4)

EtaFrame.Name = "EtaFrame"
EtaFrame.Parent = ScreenGui
EtaFrame.BackgroundTransparency = 1
EtaFrame.Position = UDim2.new(1, -210, 0.5, -42)
EtaFrame.Size = UDim2.new(0, 200, 0, 85)
EtaCorner.CornerRadius = UDim.new(0, 8)
EtaCorner.Parent = EtaFrame
EtaStroke.Parent = EtaFrame
EtaStroke.Color = Color3.fromRGB(35, 35, 45)
EtaStroke.Thickness = 1.5

EtaLabel.Name = "EtaLabel"
EtaLabel.Parent = EtaFrame
EtaLabel.BackgroundTransparency = 1
EtaLabel.Size = UDim2.new(1, -10, 1, -10)
EtaLabel.Position = UDim2.new(0, 5, 0, 5)
EtaLabel.Font = Enum.Font.Arcade
EtaLabel.Text = "Target: None\nLast Earned: $0\nUpdate Interval: N/A\n1-Min Earn Rate: $0/m\nETA: N/A"
EtaLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
EtaLabel.TextSize = 13
EtaLabel.TextWrapped = true
EtaLabel.TextStrokeTransparency = 0
EtaLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

BeamToggleBtn.MouseButton1Click:Connect(function()
	beamsEnabled = not beamsEnabled
	if beamsEnabled then
		BeamToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
		BeamToggleBtn.Text = "Guidelines: ON"
	else
		BeamToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		BeamToggleBtn.Text = "Guidelines: OFF"
	end
end)

AutoBuyToggleBtn.MouseButton1Click:Connect(function()
	autoBuyEnabled = not autoBuyEnabled
	if autoBuyEnabled then
		AutoBuyToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
		AutoBuyToggleBtn.Text = "Auto Buy: ON"
	else
		AutoBuyToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		AutoBuyToggleBtn.Text = "Auto Buy: OFF"
	end
end)

AutoRebirthToggleBtn.MouseButton1Click:Connect(function()
	autoRebirthEnabled = not autoRebirthEnabled
	if autoRebirthEnabled then
		AutoRebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
		AutoRebirthToggleBtn.Text = "Auto Rebirth: ON"
	else
		AutoRebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		AutoRebirthToggleBtn.Text = "Auto Rebirth: OFF"
	end
end)

MoveModeBtn.MouseButton1Click:Connect(function()
	usePathfind = not usePathfind
	if usePathfind then
		MoveModeBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
		MoveModeBtn.Text = "Mode: Pathfind"
	else
		MoveModeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		MoveModeBtn.Text = "Mode: Teleport"
	end
end)

local function isButtonActive(btn)
	if not btn or not btn.Parent then return false end
	if btn:IsA("BasePart") then
		if btn.Transparency >= 1 or not btn.CanCollide or not btn.Parent then return false end
	end
	local head = btn:FindFirstChild("Head") or btn:FindFirstChild("Part") or btn:FindFirstChildWhichIsA("BasePart")
	if head then
		if head.Transparency >= 1 or not head.CanCollide then return false end
	end
	local billboard = btn:FindFirstChildWhichIsA("BillboardGui", true)
	if billboard and not billboard.Enabled then return false end
	if btn:IsDescendantOf(game:GetService("ReplicatedStorage")) or btn:IsDescendantOf(game:GetService("Lighting")) then return false end
	return true
end

local function cancelPath()
	if activePathTask then
		task.cancel(activePathTask)
		activePathTask = nil
	end
end

local function getTargetPosition(target)
	if target:IsA("BasePart") then
		return target.Position
	elseif target:IsA("Model") then
		local head = target:FindFirstChild("Head") or target:FindFirstChild("Part") or target:FindFirstChildWhichIsA("BasePart")
		if head then return head.Position else return target:GetPivot().Position end
	end
	return nil
end

local function moveToTarget(target)
	if not localPlayer or not localPlayer.Character then return end
	local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end

	local targetPos = getTargetPosition(target)
	if not targetPos then return end

	if not usePathfind then
		cancelPath()
		root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
		return
	end

	cancelPath()
	activePathTask = task.spawn(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2.5, AgentHeight = 5, AgentCanJump = false, AgentCanClimb = true, WaypointSpacing = 3,
			Costs = { Water = 20, Danger = math.huge }
		})

		local maxAttempts, attempt = 12, 0
		while attempt < maxAttempts do
			if not root or not root.Parent or not humanoid or humanoid.Health <= 0 then return end
			if not target or not target.Parent or not isButtonActive(target) then return end
			targetPos = getTargetPosition(target)
			if not targetPos then return end

			if (root.Position - targetPos).Magnitude <= 4.5 then
				humanoid:MoveTo(targetPos)
				task.wait(0.35)
				if not target or not target.Parent or not isButtonActive(target) then return end
				attempt = attempt + 1
				continue
			end

			local success = pcall(function() path:ComputeAsync(root.Position, targetPos) end)
			if not success or path.Status ~= Enum.PathStatus.Success then
				humanoid:MoveTo(targetPos)
				task.wait(0.45)
				attempt = attempt + 1
				continue
			end

			local waypoints = path:GetWaypoints()
			if #waypoints < 2 then
				humanoid:MoveTo(targetPos)
				task.wait(0.3)
				attempt = attempt + 1
				continue
			end

			for i = 2, #waypoints do
				if not root or not root.Parent or not humanoid or humanoid.Health <= 0 then return end
				if not target or not target.Parent or not isButtonActive(target) then return end

				local wpPos = waypoints[i].Position
				targetPos = getTargetPosition(target)
				if not targetPos then return end

				if (root.Position - targetPos).Magnitude <= 4.5 then break end
				humanoid:MoveTo(wpPos)

				local startTime = tick()
				local stuckCheck, stuckTimer = root.Position, 0

				while (root.Position - wpPos).Magnitude > 3.2 do
					if not root or not root.Parent or not humanoid or humanoid.Health <= 0 then return end
					if not target or not target.Parent or not isButtonActive(target) then return end
					targetPos = getTargetPosition(target)
					if targetPos and (root.Position - targetPos).Magnitude <= 4.5 then break end
					if tick() - startTime > 2.5 then break end

					if (root.Position - stuckCheck).Magnitude < 0.55 then
						stuckTimer = stuckTimer + 0.08
						if stuckTimer > 0.5 then
							local away = (root.Position - wpPos)
							if away.Magnitude < 0.1 then away = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) end
							root.CFrame = root.CFrame + (away.Unit * 2.2) + Vector3.new(0, 1.2, 0)
							stuckTimer = 0
							stuckCheck = root.Position
							task.wait(0.1)
						end
					else
						stuckTimer = 0
						stuckCheck = root.Position
					end
					task.wait(0.07)
				end
			end
			attempt = attempt + 1
			task.wait(0.12)
		end
	end)
end

local lastMerchantCheck = 0
local function highlightMerchants()
	if tick() - lastMerchantCheck < 2 then return end
	lastMerchantCheck = tick()

	local activeCards = {}
	local validShops = {}

	local bitsShops = game:GetService("Workspace"):FindFirstChild("BitsShops")
	if bitsShops then
		for _, shop in ipairs(bitsShops:GetChildren()) do
			local cardsFolder = shop:FindFirstChild("Cards")
			if cardsFolder then
				table.insert(validShops, shop)
				for _, card in ipairs(cardsFolder:GetChildren()) do
					if card:IsA("Model") or card:IsA("BasePart") then
						table.insert(activeCards, card)
					end
				end
			end
		end
	end

	-- Apply ESP only to the real shop containing the Cards folder
	for _, shop in ipairs(validShops) do
		local head = shop:IsA("Model") and (shop:FindFirstChild("Merchant") or shop:FindFirstChild("Head") or shop:FindFirstChild("Part") or shop.PrimaryPart or shop:FindFirstChildWhichIsA("BasePart")) or shop
		if head then
			local targetPart = head:IsA("Model") and (head:FindFirstChild("Head") or head.PrimaryPart or head:FindFirstChildWhichIsA("BasePart")) or head
			if targetPart then
				local existingTag = targetPart:FindFirstChild("MerchantTag")
				if existingTag then
					existingTag:Destroy()
				end
			end
		end
	end

	-- Remove ESP from fake shops or shops that lost their Cards folder
	if bitsShops then
		for _, shop in ipairs(bitsShops:GetChildren()) do
			local head = shop:IsA("Model") and (shop:FindFirstChild("Merchant") or shop:FindFirstChild("Head") or shop:FindFirstChild("Part") or shop.PrimaryPart or shop:FindFirstChildWhichIsA("BasePart")) or shop
			if head then
				local targetPart = head:IsA("Model") and (head:FindFirstChild("Head") or head.PrimaryPart or head:FindFirstChildWhichIsA("BasePart")) or head
				if targetPart and not shop:FindFirstChild("Cards") then
					local existingTag = targetPart:FindFirstChild("MerchantTag")
					if existingTag then
						existingTag:Destroy()
					end
				end
			end
		end
	end

	-- Populate the UI list with only the individual Cards
	local currentValidCards = {}

	if autoPickCardEnabled and #activeCards >= 5 then
		local bestCard = nil
		local highestBits = -1

		for _, card in ipairs(activeCards) do
			local surfaceGui = card:FindFirstChildWhichIsA("SurfaceGui", true)
			if surfaceGui then
				local bitsDisplay = surfaceGui:FindFirstChild("bitsDisplay") or surfaceGui:FindFirstChild("oldbitsDisplay")
				if bitsDisplay and (bitsDisplay:IsA("TextLabel") or bitsDisplay:IsA("TextButton")) then
					local bitsVal = parseSuffixValue(bitsDisplay.Text)
					if bitsVal > highestBits then
						highestBits = bitsVal
						bestCard = card
					end
				end
			end
		end

		if bestCard then
			local detector = bestCard:FindFirstChildOfClass("ClickDetector") or bestCard:FindFirstChild("ClickDetector", true)
			if detector then
				detector.MaxActivationDistance = math.huge
				fireclickdetector(detector)
			end
		end
	end

	for i, card in ipairs(activeCards) do
		currentValidCards[card] = true
		local btn = merchantListButtons[card]
		if not btn then
			btn = Instance.new("TextButton")
			local corner = Instance.new("UICorner")
			local stroke = Instance.new("UIStroke")
			btn.Name = "CardEntry"
			btn.Parent = MerchantsListFrame
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(60, 200, 120)
			btn.Font = Enum.Font.Arcade
			btn.TextSize = 11
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextWrapped = true
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = btn
			stroke.Parent = btn
			stroke.Color = Color3.fromRGB(35, 35, 45)
			stroke.Thickness = 1
			merchantListButtons[card] = btn

			btn.MouseButton1Click:Connect(function()
				local detector = card:FindFirstChildOfClass("ClickDetector") or card:FindFirstChild("ClickDetector", true)
				if detector then
					detector.MaxActivationDistance = math.huge
					fireclickdetector(detector)
				end
			end)
		end
		local priceText = "N/A"
		local bitsText = "N/A"
		local surfaceGui = card:FindFirstChildWhichIsA("SurfaceGui", true)
		if surfaceGui then
			local priceDisplay = surfaceGui:FindFirstChild("priceDisplay") or surfaceGui:FindFirstChild("oldpriceDisplay")
			local bitsDisplay = surfaceGui:FindFirstChild("bitsDisplay") or surfaceGui:FindFirstChild("oldbitsDisplay")
			if priceDisplay and (priceDisplay:IsA("TextLabel") or priceDisplay:IsA("TextButton")) then
				priceText = priceDisplay.Text
			end
			if bitsDisplay and (bitsDisplay:IsA("TextLabel") or bitsDisplay:IsA("TextButton")) then
				bitsText = bitsDisplay.Text
			end
		end
		btn.Text = string.format("%s | %s | %s", card.Name, priceText, bitsText)
		btn.LayoutOrder = i
		btn.Visible = true
	end

	for item, btn in pairs(merchantListButtons) do
		if not currentValidCards[item] then
			btn:Destroy()
			merchantListButtons[item] = nil
		end
	end
end

local beams = {}
local function clearGuidelines()
	for _, data in pairs(beams) do
		if data.beam then data.beam:Destroy() end
		if data.att0 then data.att0:Destroy() end
		if data.att1 then data.att1:Destroy() end
	end
	table.clear(beams)
end

local function updateGuidelines(validButtons)
	if not beamsEnabled then
		clearGuidelines()
		return
	end
	if not localPlayer or not localPlayer.Character then clearGuidelines(); return end
	local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then clearGuidelines(); return end

	local currentValid = {}
	for _, item in ipairs(validButtons) do
		if item.canAfford then
			local btn = item.instance
			currentValid[btn] = true
			local targetPart = btn:IsA("BasePart") and btn or (btn:IsA("Model") and (btn:FindFirstChild("Head") or btn:FindFirstChild("Part") or btn:FindFirstChildWhichIsA("BasePart") or btn.PrimaryPart))
			if targetPart then
				local dist = (root.Position - targetPart.Position).Magnitude
				if dist <= 400 then
					if not beams[btn] then
						local att0 = Instance.new("Attachment", root)
						local att1 = Instance.new("Attachment", targetPart)
						local beam = Instance.new("Beam")
						beam.Attachment0 = att0
						beam.Attachment1 = att1
						beam.Color = ColorSequence.new(Color3.fromRGB(60, 200, 120))
						beam.Width0, beam.Width1 = 0.6, 0.6
						beam.Texture = "rbxassetid://446111271"
						beam.TextureMode = Enum.TextureMode.Wrap
						beam.TextureSpeed = 3
						beam.TextureLength = 3
						beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.1) })
						beam.FaceCamera = true
						beam.Parent = root
						beams[btn] = {beam = beam, att0 = att0, att1 = att1}
					end
				else
					if beams[btn] then
						beams[btn].beam:Destroy(); beams[btn].att0:Destroy(); beams[btn].att1:Destroy(); beams[btn] = nil
					end
				end
			end
		end
	end

	for btn, data in pairs(beams) do
		if not currentValid[btn] then
			data.beam:Destroy(); data.att0:Destroy(); data.att1:Destroy(); beams[btn] = nil
		end
	end
end

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function updateInput(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then updateInput(input) end
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		MainFrame.Size = UDim2.new(0, 220, 0, 30)
		MinimizeBtn.Text = ">"
		CategoryBar.Visible, PanelStats.Visible, PanelAutoFarm.Visible, PanelButtons.Visible, PanelMisc.Visible, ScrollFrame.Visible = false, false, false, false, false, false
	else
		MainFrame.Size = UDim2.new(0, 220, 0, 300)
		MinimizeBtn.Text = "v"
		CategoryBar.Visible = true
		PanelStats.Visible = panelButtons["Stats"].BackgroundColor3 == Color3.fromRGB(60, 120, 200)
		PanelAutoFarm.Visible = panelButtons["Auto Farm"].BackgroundColor3 == Color3.fromRGB(60, 120, 200)
		PanelButtons.Visible = panelButtons["Merchant"].BackgroundColor3 == Color3.fromRGB(60, 120, 200)
		PanelMisc.Visible = panelButtons["Misc"].BackgroundColor3 == Color3.fromRGB(60, 120, 200)
		ScrollFrame.Visible = true
	end
end)

local function formatNumber(num)
	if num >= 1e18 then return string.format("%.2fQi", num / 1e18)
	elseif num >= 1e15 then return string.format("%.2fQa", num / 1e15)
	elseif num >= 1e12 then return string.format("%.2fT", num / 1e12)
	elseif num >= 1e9 then return string.format("%.2fB", num / 1e9)
	elseif num >= 1e6 then return string.format("%.2fM", num / 1e6)
	elseif num >= 1e3 then return string.format("%.2fK", num / 1e3)
	else return string.format("%.0f", num) end
end

local function parsePrice(str)
	if not str or str == "" then return nil end
	local cleanStr = str:gsub("[$,]", ""):lower()
	if cleanStr:find("free") then return 0 end
	local num = tonumber(cleanStr:match("[%d%.]+"))
	if not num then return nil end
	if cleanStr:find("k") then num = num * 1e3 elseif cleanStr:find("m") then num = num * 1e6 elseif cleanStr:find("b") then num = num * 1e9 elseif cleanStr:find("t") then num = num * 1e12 elseif cleanStr:find("qa") then num = num * 1e15 elseif cleanStr:find("qi") then num = num * 1e18 end
	return num
end

local function getPlayerCash()
	if not localPlayer then return 0, "N/A" end

	-- Direct check matching local player's frame in System -> PlayerList -> Holder
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		local system = playerGui:FindFirstChild("System")
		local playerList = system and system:FindFirstChild("PlayerList")
		local holder = playerList and playerList:FindFirstChild("Holder")
		if holder then
			local myFrame = holder:FindFirstChild(localPlayer.Name)
			if myFrame then
				for _, desc in ipairs(myFrame:GetDescendants()) do
					if desc:IsA("TextLabel") and desc.Text ~= "" then
						local parsed = parsePrice(desc.Text)
						if parsed and parsed > 0 then
							return parsed, desc.Text
						end
					end
				end
			end
		end
	end

	-- Fallback check across all Holder children for matching player name frame
	if playerGui then
		for _, desc in ipairs(playerGui:GetDescendants()) do
			if desc:IsA("TextLabel") and desc.Visible then
				local parentName = desc.Parent and desc.Parent.Name or ""
				if parentName == localPlayer.Name then
					local parsed = parsePrice(desc.Text)
					if parsed then return parsed, desc.Text end
				end
			end
		end
	end

	-- Fallback to Leaderstats
	local leaderstats = localPlayer:FindFirstChild("leaderstats") or localPlayer:FindFirstChild("stats")
	if leaderstats then
		local cashObj = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Coins")
		if cashObj and cashObj:IsA("ValueBase") then
			local val = tonumber(cashObj.Value) or 0
			return val, "$" .. formatNumber(val)
		end
		for _, v in ipairs(leaderstats:GetChildren()) do
			if v:IsA("ValueBase") and tonumber(v.Value) then
				return tonumber(v.Value), "$" .. formatNumber(tonumber(v.Value))
			end
		end
	end

	return 0, "$0"
end

local function getMyPlot()
	if not localPlayer then return "None" end
	local plots = game:GetService("Workspace"):FindFirstChild("Plots")
	if not plots then return "None" end
	for _, plot in ipairs(plots:GetChildren()) do
		local nameLabel = plot:FindFirstChild("SignPlace") and plot.SignPlace:FindFirstChild("DefaultSign") and plot.SignPlace.DefaultSign:FindFirstChild("Screen") and plot.SignPlace.DefaultSign.Screen:FindFirstChild("SurfaceGui") and plot.SignPlace.DefaultSign.Screen.SurfaceGui:FindFirstChild("NameLabel")
		if nameLabel and nameLabel:IsA("TextLabel") then
			if string.lower(nameLabel.Text) == string.lower(localPlayer.Name) or string.lower(nameLabel.Text) == string.lower(localPlayer.DisplayName) then return plot.Name end
		end
	end
	return "None"
end

local function getButtonDetails(btn)
	if not btn or not isButtonActive(btn) then return nil, nil, nil end
	local priceNum, priceStr, buttonName = nil, nil, btn.Name
	local nameDisplay = btn:FindFirstChild("NameDisplay", true)
	if nameDisplay then
		local textLabel = nameDisplay:FindFirstChildWhichIsA("TextLabel", true) or (nameDisplay:IsA("TextLabel") and nameDisplay)
		if textLabel and textLabel.Text ~= "" and textLabel.Visible then buttonName = textLabel.Text end
	end
	local priceDisplay = btn:FindFirstChild("PriceDisplay", true)
	if priceDisplay then
		local textLabel = priceDisplay:FindFirstChildWhichIsA("TextLabel", true) or (priceDisplay:IsA("TextLabel") and priceDisplay)
		if textLabel and textLabel.Text ~= "" and textLabel.Visible then
			priceNum = parsePrice(textLabel.Text)
			priceStr = textLabel.Text
		end
	end
	if not priceNum then
		for _, desc in ipairs(btn:GetDescendants()) do
			if desc:IsA("TextLabel") and desc.Text ~= "" and desc.Visible then
				local parsed = parsePrice(desc.Text)
				if parsed then priceNum = parsed; priceStr = desc.Text; break end
			end
		end
	end
	if not priceNum then
		if buttonName:lower():find("free") then priceNum = 0; priceStr = "Free" end
	end
	return priceNum, priceStr, buttonName
end

local function getClosestTycoon()
	local myPlotName = getMyPlot()
	if myPlotName == "None" then return nil end
	local plots = game:GetService("Workspace"):FindFirstChild("Plots")
	local plotObj = plots and plots:FindFirstChild(myPlotName)
	if not plotObj then return nil end
	local plotPos = plotObj:IsA("Model") and plotObj:GetPivot().Position or (plotObj:FindFirstChildWhichIsA("BasePart") and plotObj:FindFirstChildWhichIsA("BasePart").Position)
	if not plotPos then return nil end
	local tycoons = game:GetService("Workspace"):FindFirstChild("Tycoons")
	if not tycoons then return nil end
	local closestTycoon, shortestDist = nil, math.huge
	for _, tycoon in ipairs(tycoons:GetChildren()) do
		local buttons = tycoon:FindFirstChild("Buttons")
		if buttons then
			local pivot = tycoon:IsA("Model") and tycoon:GetPivot().Position or (tycoon:FindFirstChildWhichIsA("BasePart") and tycoon:FindFirstChildWhichIsA("BasePart").Position)
			if pivot then
				local dist = (plotPos - pivot).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closestTycoon = tycoon
				end
			end
		end
	end
	return closestTycoon
end

local existingUIButtons, lastAutoBuyTime = {}, 0
local lastRecordedCash, lastCashTime, lastEarnedAmount, lastIntervalDuration, liveEarnTimer = nil, 0, 0, 0, 0
local incomeHistory = {}

local function calculateETA(targetPrice, currentCash)
	if currentCash >= targetPrice then
		local total1MinRate = 0
		for _, entry in ipairs(incomeHistory) do total1MinRate = total1MinRate + entry.amount end
		return "Ready!", lastEarnedAmount, lastIntervalDuration, liveEarnTimer, total1MinRate
	end
	local now = tick()
	if lastRecordedCash == nil then lastRecordedCash = currentCash; lastCashTime = now; return "Calculating...", 0, 0, 0, 0 end
	if currentCash > lastRecordedCash then
		lastIntervalDuration = now - lastCashTime
		lastEarnedAmount = currentCash - lastRecordedCash
		table.insert(incomeHistory, {time = now, amount = lastEarnedAmount})
		lastRecordedCash = currentCash; lastCashTime = now; liveEarnTimer = 0
	elseif currentCash < lastRecordedCash then
		lastRecordedCash = currentCash; lastCashTime = now; liveEarnTimer = 0
	else
		liveEarnTimer = now - lastCashTime
	end

	for i = #incomeHistory, 1, -1 do if now - incomeHistory[i].time > 60 then table.remove(incomeHistory, i) end end
	local total1MinRate = 0
	for _, entry in ipairs(incomeHistory) do total1MinRate = total1MinRate + entry.amount end

	if total1MinRate <= 0 then
		if lastEarnedAmount > 0 and lastIntervalDuration > 0 then
			total1MinRate = (lastEarnedAmount / lastIntervalDuration) * 60
		else
			return "Waiting for income...", 0, 0, liveEarnTimer, 0
		end
	end

	local perSecondRate = total1MinRate / 60
	local etaSeconds = math.ceil((targetPrice - currentCash) / perSecondRate)
	if etaSeconds <= 0 then return "Ready!", lastEarnedAmount, lastIntervalDuration, liveEarnTimer, total1MinRate end
	local timeStr = (etaSeconds < 60) and string.format("%ds", etaSeconds) or (etaSeconds < 3600 and string.format("%dm %ds", math.floor(etaSeconds / 60), etaSeconds % 60) or string.format("%dh %dm", math.floor(etaSeconds / 3600), math.floor((etaSeconds % 3600) / 60)))
	return timeStr, lastEarnedAmount, lastIntervalDuration, liveEarnTimer, total1MinRate
end

local function isPlayerOnPlot(plotObj)
	if not localPlayer or not localPlayer.Character then return false end
	local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root or not plotObj then return false end
	local cframe, size = plotObj:GetBoundingBox()
	local relativePos = cframe:PointToObjectSpace(root.Position)
	local margin = 15
	return math.abs(relativePos.X) <= (size.X / 2) + margin and math.abs(relativePos.Y) <= (size.Y / 2) + 20 and math.abs(relativePos.Z) <= (size.Z / 2) + margin
end

local function updateShop()
	local cashNum, cashStr = getPlayerCash()
	local currentPlot = getMyPlot()
	local cappedStatus = "False"
	local cappedText = trackedTexts["EssenceCappedTemp"]
	if cappedText and string.find(string.lower(cappedText), "your essence is capped") then
		cappedStatus = "True"
	else
		local pGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
		if pGui then
			for _, v in ipairs(pGui:GetDescendants()) do
				if (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Visible and string.find(string.lower(v.Text or ""), "your essence is capped") then cappedStatus = "True"; break end
			end
		end
	end

	StatsLabel.Text = string.format("Stats:\nCash: %s\nPlot: %s\nEssence Capped: %s", (cashStr or tostring(cashNum)), currentPlot, cappedStatus)
	local closestTycoon = getClosestTycoon()
	if not closestTycoon or not closestTycoon:FindFirstChild("Buttons") then 
		for btn, uiBtn in pairs(existingUIButtons) do uiBtn:Destroy() end
		table.clear(existingUIButtons); clearGuidelines()
		EtaLabel.Text = "Target: None\nLast Earned: $0\nUpdate Interval: N/A\n1-Min Earn Rate: $0/m\nETA: No Buttons"
		return 
	end

	local affordableButtons, unaffordableButtons, allValidItems = {}, {}, {}
	for _, btn in ipairs(closestTycoon.Buttons:GetChildren()) do
		local priceNum, priceStr, displayName = getButtonDetails(btn)
		if priceNum then
			local canAfford = cashNum >= priceNum
			local itemData = { instance = btn, name = displayName or btn.Name, price = priceNum, priceStr = priceStr or tostring(priceNum), canAfford = canAfford }
			table.insert(allValidItems, itemData)
			table.insert(canAfford and affordableButtons or unaffordableButtons, itemData)
		end
	end

	table.sort(affordableButtons, function(a, b) return a.price < b.price end)
	table.sort(unaffordableButtons, function(a, b) return a.price < b.price end)

