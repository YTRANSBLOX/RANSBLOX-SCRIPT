setclipboard("https://www.youtube.com/@RANSBLOX")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local playerGui = lp:WaitForChild("PlayerGui")
local bidRemote = RS:WaitForChild("Events"):WaitForChild("Auction"):WaitForChild("Bid")
local VehicleEvents = RS.Events.Vehicles

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()

WindUI:AddTheme({
    Name = "RansBlox",
    Accent = Color3.fromHex("#84cc16"),
    Background = Color3.fromHex("#111111"),
    BackgroundTransparency = 0.05,
    Text = Color3.fromHex("#ffffff"),
    Outline = Color3.fromHex("#1f1f1f"),
    Placeholder = Color3.fromHex("#a3e635"),
    Button = Color3.fromHex("#65a30d"),
    Icon = Color3.fromHex("#84cc16"),
    Hover = Color3.fromHex("#2a2a2a"),
    WindowBackground = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#0d1a0d"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#111111"), Transparency = 0 },
    }, { Rotation = 135 }),
    WindowShadow = Color3.fromHex("#000000"),
    WindowTopbarTitle = Color3.fromHex("#ffffff"),
    WindowTopbarAuthor = Color3.fromHex("#a3e635"),
    WindowTopbarIcon = Color3.fromHex("#84cc16"),
    WindowTopbarButtonIcon = Color3.fromHex("#84cc16"),
    TabBackground = Color3.fromHex("#1e1e1e"),
    TabTitle = Color3.fromHex("#ffffff"),
    TabIcon = Color3.fromHex("#84cc16"),
    ElementBackground = Color3.fromHex("#1c1c1c"),
    ElementTitle = Color3.fromHex("#ffffff"),
    ElementDesc = Color3.fromHex("#a3e635"),
    ElementIcon = Color3.fromHex("#84cc16"),
    PopupBackground = Color3.fromHex("#141414"),
    PopupBackgroundTransparency = 0,
    PopupTitle = Color3.fromHex("#ffffff"),
    PopupContent = Color3.fromHex("#a3e635"),
    PopupIcon = Color3.fromHex("#84cc16"),
    DialogBackground = Color3.fromHex("#141414"),
    DialogBackgroundTransparency = 0,
    DialogTitle = Color3.fromHex("#ffffff"),
    DialogContent = Color3.fromHex("#a3e635"),
    DialogIcon = Color3.fromHex("#84cc16"),
    Toggle = Color3.fromHex("#84cc16"),
    ToggleBar = Color3.fromHex("#2a2a2a"),
    Checkbox = Color3.fromHex("#84cc16"),
    CheckboxIcon = Color3.fromHex("#ffffff"),
    CheckboxBorder = Color3.fromHex("#84cc16"),
    CheckboxBorderTransparency = 0.4,
    Slider = Color3.fromHex("#84cc16"),
    SliderThumb = Color3.fromHex("#ffffff"),
    SliderIconFrom = Color3.fromHex("#65a30d"),
    SliderIconTo = Color3.fromHex("#a3e635"),
    SectionBox = Color3.fromHex("#84cc16"),
    SectionBoxTransparency = 0.85,
    SectionBoxBorder = Color3.fromHex("#84cc16"),
    SectionBoxBorderTransparency = 0.6,
    SectionBoxBackground = Color3.fromHex("#84cc16"),
    SectionBoxBackgroundTransparency = 0.93,
    Tooltip = Color3.fromHex("#111111"),
    TooltipText = Color3.fromHex("#ffffff"),
    TooltipSecondary = Color3.fromHex("#84cc16"),
    TooltipSecondaryText = Color3.fromHex("#ffffff"),
})

local Window = WindUI:CreateWindow({
    Title = "YOUTUBE : RANSBLOX",
    Author = "Storage Hunters",
    Icon = "youtube",
    Theme = "RansBlox",
    NewElements = true,
    Size = UDim2.fromOffset(520, 360),
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
    OpenButton = {
        Title = "RANSBLOX",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#84cc16"),
            Color3.fromHex("#65a30d")
        ),
    },
    MinimizeKey = Enum.KeyCode.RightControl,
})

Window:Tag({
    Title = "v3.3",
    Icon = "youtube",
    Color = Color3.fromHex("#84cc16"),
    Border = true,
})

local Tabs = {
    Main   = Window:Tab({ Title = "Main",   Icon = "house" }),
    Social = Window:Tab({ Title = "Social", Icon = "link" }),
    Misc   = Window:Tab({ Title = "Misc",   Icon = "info" }),
}

-- ═══════════════════════════════
-- STATE
-- ═══════════════════════════════
local autoEnabled    = false
local autoBidEnabled = false
local autoBidConn    = nil
local auctionRunning = false
local stopThreshold  = 0.9
local resumeThreshold = 0.3
local garageKeyword  = "Scrap Garage"

local garageKeywords = {
    ["Junkyard"]        = "Scrap Garage",
    ["Shop Front"]      = "Shop Front",
    ["Stable"]          = "Stable Garage",
    ["Barn"]            = "Barn Garage",
    ["Small Container"] = "Small Container Garage",
    ["Large Container"] = "Large Container Garage",
    ["Warehouse"]       = "Warehouse Garage",
}

-- ═══════════════════════════════
-- HELPERS
-- ═══════════════════════════════
local function isActive()
    return autoEnabled
end

local function getMyCar()
    for _ = 1, 5 do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:GetAttribute("OwnerUserId") == lp.UserId then
                return obj
            end
        end
        task.wait(0.3)
    end
    return nil
end

local function sitInCar()
    local car = getMyCar()
    if not car or not car:FindFirstChild("DriveSeat") then return false end
    car.DriveSeat:Sit(humanoid)
    task.wait(0.8)
    return true
end

local function isFull()
    local car = getMyCar()
    if not car then return false end
    local w   = car:GetAttribute("CargoWeight") or 0
    local lim = car:GetAttribute("CargoWeightLimit") or 1
    if lim == 0 then return false end
    return (w / lim) >= stopThreshold
end

local function isBelowResume()
    local car = getMyCar()
    if not car then return true end
    local w   = car:GetAttribute("CargoWeight") or 0
    local lim = car:GetAttribute("CargoWeightLimit") or 1
    if lim == 0 then return true end
    return (w / lim) <= resumeThreshold
end

local function fireAllPrompts(targetModel)
    for _, v in ipairs(targetModel:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            pcall(function() fireproximityprompt(v) end)
        end
    end
end

local function pickupAllNear(floorPos, radius)
    local found = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            local parent = v.Parent
            local pos = parent:IsA("BasePart") and parent.Position
                or (parent.Parent and parent.Parent:IsA("Model") and parent.Parent:GetPivot().Position)
            if pos and (floorPos - pos).Magnitude <= radius then
                table.insert(found, v)
            end
        end
    end
    for _, v in ipairs(found) do
        if v and v.Parent and v.Enabled then
            pcall(function() fireproximityprompt(v) end)
            task.wait(0.1)
        end
    end
    return #found
end

local function goToPlot()
    local plotsFolder = workspace:FindFirstChild("_Plots")
    if not plotsFolder then return end
    for _, v in ipairs(plotsFolder:GetChildren()) do
        if v:GetAttribute("OwnerUserId") == lp.UserId then
            local parkingBase = v:FindFirstChild("Furniture")
                and v.Furniture:FindFirstChild("Parking Space")
                and v.Furniture["Parking Space"]:FindFirstChild("Base")
            if not parkingBase then return end
            local car = getMyCar()
            if car and car:FindFirstChild("DriveSeat") then
                car.DriveSeat:Sit(humanoid)
                task.wait(1)
                car:PivotTo(CFrame.new(parkingBase.Position + Vector3.new(0, 5, 0)))
                task.wait(1.5)
                humanoid.Sit = false
            end
            return
        end
    end
end

local function checkLNFAvailable()
    for _, area in ipairs(workspace.Areas:GetChildren()) do
        local lnfBox = area:FindFirstChild("Lost and Found Box")
        if lnfBox then
            local lnfPrompt = lnfBox:FindFirstChild("LostFoundPrompt", true)
            if lnfPrompt and lnfPrompt.Enabled then
                return true
            end
        end
    end
    return false
end

-- ─── STEP 1: NAIK MOBIL ───────────────────────────────
local function stepGetInCar()
    if not isActive() then return false end
    local ok = sitInCar()
    if not ok then
        WindUI:Notify({ Title = "Error", Content = "Car not found, twin!", Icon = "ban", Duration = 3 })
        return false
    end
    return true
end

-- ─── STEP 2: COLLECT LNF ─────────────────────────────
local function stepCollectLNF()
    if not isActive() then return false end
    local car = getMyCar()
    if not car then return false end

    for _, area in ipairs(workspace.Areas:GetChildren()) do
        if not isActive() then return false end
        if isFull() then return true end

        local lnfBox = area:FindFirstChild("Lost and Found Box")
        if not lnfBox then continue end

        local lnfPrompt = lnfBox:FindFirstChild("LostFoundPrompt", true)
        if not lnfPrompt or not lnfPrompt.Enabled then continue end

        local promptPart = lnfPrompt.Parent
        car:PivotTo(CFrame.new(promptPart.Position + Vector3.new(0, 5, 5)))
        task.wait(1)
        if not isActive() then return false end

        pcall(function() fireproximityprompt(lnfPrompt) end)
        task.wait(1.5)
        if not isActive() then return false end

        local scanStart = tick()
        local lastCount, stagnant = nil, 0
        repeat
            if isFull() then break end
            if not isActive() then return false end
            if tick() - scanStart > 6 then break end

            local currentCount = 0
            for _, obj in ipairs(playerGui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text:find("%$") and obj.Parent.Name == "InfoFrame" then
                    local itemCard = obj.Parent.Parent
                    if itemCard:IsA("TextButton") then
                        currentCount += 1
                        local conns = getconnections(itemCard.MouseButton1Click)
                        for _, conn in ipairs(conns) do conn.Function() end
                    end
                end
            end
            task.wait(0.3)

            if currentCount == 0 then break end

            if lastCount and currentCount >= lastCount then
                stagnant += 1
                if stagnant >= 2 then break end
            else
                stagnant = 0
            end
            lastCount = currentCount
        until false

        pcall(function() fireproximityprompt(lnfPrompt) end)
        task.wait(0.5)

        if isFull() then return true end
    end
    return true
end

-- ─── STEP 3: AUTO AUCTION ─────────────────────────────
local function stepRunAuction()
    if not isActive() then return false end

    sitInCar()
    task.wait(0.3)
    if not isActive() then return false end

    local garage = nil
    local huntStart = tick()
    repeat
        if not isActive() then return false end
        for _, g in ipairs(workspace._Debris.Garages:GetChildren()) do
            if g.Name:find(garageKeyword) and not g:FindFirstChild("Auctioneer") then
                for _, v in ipairs(g:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Enabled then
                        garage = g; break
                    end
                end
            end
            if garage then break end
        end
        if not garage then task.wait(2) end
    until garage or not isActive() or (tick() - huntStart > 60)

    if not isActive() or not garage then return false end

    local spawnPart = garage:FindFirstChild("AuctioneerSpawn")
    if not spawnPart then return false end

    local car = getMyCar()
    if not car or not car:FindFirstChild("DriveSeat") then return false end

    if humanoid.SeatPart ~= car.DriveSeat then
        car.DriveSeat:Sit(humanoid)
        task.wait(0.5)
    end
    if humanoid.SeatPart ~= car.DriveSeat then return false end

    car:PivotTo(CFrame.new(spawnPart.Position + Vector3.new(0, 3, 0)))
    task.wait(1.5)
    if not isActive() then return false end
    humanoid.Sit = false
    task.wait(0.5)

    local auctionPromptPos = nil
    for _, v in ipairs(garage:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            local part = v.Parent
            if part:IsA("BasePart") then
                auctionPromptPos = part.Position + Vector3.new(0, 3, 0)
                hrp.CFrame = CFrame.new(auctionPromptPos)
                break
            end
        end
    end
    task.wait(1)
    if not isActive() then return false end

    fireAllPrompts(garage)

    local lockConn = nil
    if auctionPromptPos then
        lockConn = RunService.RenderStepped:Connect(function()
            if hrp and hrp.Parent then
                hrp.CFrame = CFrame.new(auctionPromptPos)
            end
        end)
    end

    local spawnWait = tick()
    local spawned = false
    repeat
        task.wait(0.3)
        if garage:FindFirstChild("Auctioneer") then spawned = true; break end
    until (tick() - spawnWait > 15) or not isActive()

    if not isActive() or not spawned then
        if lockConn then lockConn:Disconnect() end
        return false
    end

    repeat task.wait(0.3)
    until not garage:FindFirstChild("Auctioneer") or not isActive()
    if lockConn then lockConn:Disconnect(); lockConn = nil end
    if not isActive() then return false end

    task.wait(2.5)

    local floorspace = garage:FindFirstChild("Floorspace")
    if floorspace and floorspace:IsA("BasePart") then
        local floorPos = floorspace.Position
        hrp.CFrame = CFrame.new(floorPos + Vector3.new(0, 3, 0))
        task.wait(0.5)
        local retries = 0
        repeat
            if isFull() then break end
            local count = pickupAllNear(floorPos, 20)
            if count == 0 then break end
            task.wait(0.6)
            retries += 1
        until retries >= 5
    end

    local carBack = getMyCar()
    if carBack and carBack:FindFirstChild("DriveSeat") then
        carBack.DriveSeat:Sit(humanoid)
        task.wait(1)
    end

    return true
end

-- ═══════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════
local function mainLoop()
    if auctionRunning then return end
    auctionRunning = true

    while isActive() do
        if isFull() then
            WindUI:Notify({
                Title = "Truck Full",
                Content = "Truck's packed twin, heading back to the crib.",
                Icon = "ban", Duration = 3,
            })
            goToPlot()
            task.wait(2)
            WindUI:Notify({
                Title = "At the Crib",
                Content = "Drop the loot twin, farming will resume automatically.",
                Icon = "info", Duration = 3,
            })

            local waitStart = tick()
            repeat
                task.wait(1)
                if not isActive() then break end
            until isBelowResume() or (tick() - waitStart > 120)

            if not isActive() then break end
            continue
        end

        if not stepGetInCar() then
            task.wait(2)
            continue
        end
        if not isActive() then break end

        if checkLNFAvailable() then
            stepCollectLNF()
            if not isActive() then break end
            if isFull() then continue end
        end

        stepRunAuction()
        if not isActive() then break end

        task.wait(0.5)
    end

    auctionRunning = false
end

task.spawn(function()
    while true do
        task.wait(2)
        if autoEnabled and not auctionRunning then
            task.spawn(mainLoop)
        end
    end
end)

-- ═══════════════════════════════
-- AUTO BID
-- ═══════════════════════════════
local function startAutoBid()
    if autoBidConn then return end
    autoBidConn = RunService.RenderStepped:Connect(function()
        if not autoBidEnabled then return end
        local container = playerGui:FindFirstChild("AuctionBiddingContainer", true)
        if container and container.Visible then
            local track = container:FindFirstChild("Track", true)
            local bidZone = track and track:FindFirstChild("BidZone")
            local cursor = track and track:FindFirstChild("Cursor")
            if track and bidZone and cursor then
                local cursorX = cursor.AbsolutePosition.X
                local zoneLeft = bidZone.AbsolutePosition.X
                local zoneRight = zoneLeft + bidZone.AbsoluteSize.X
                if cursorX >= zoneLeft and cursorX <= zoneRight then
                    pcall(function() bidRemote:FireServer() end)
                end
            end
        end
    end)
end

local function stopAutoBid()
    if autoBidConn then
        autoBidConn:Disconnect()
        autoBidConn = nil
    end
end

-- ═══════════════════════════════
-- GUI
-- ═══════════════════════════════
Tabs.Main:Section({ Title = "Auto Auction" })

Tabs.Main:Dropdown({
    Title = "Select Location",
    Values = {
        { Title = "Junkyard",        Desc = "Scrap Garage — Free",              Icon = "wrench" },
        { Title = "Shop Front",      Desc = "Shop Front — $5 Net Worth",        Icon = "store" },
        { Title = "Stable",          Desc = "Stable Garage — $15 Net Worth",    Icon = "star" },
        { Title = "Barn",            Desc = "Barn Garage — $25 Net Worth",      Icon = "warehouse" },
        { Title = "Small Container", Desc = "Small Container — $50 Net Worth",  Icon = "package" },
        { Title = "Large Container", Desc = "Large Container — $100 Net Worth", Icon = "package" },
        { Title = "Warehouse",       Desc = "Warehouse — $200 Net Worth",       Icon = "building" },
    },
    Value = "Junkyard",
    Callback = function(v)
        garageKeyword = garageKeywords[v.Title] or "Scrap Garage"
    end,
})

Tabs.Main:Space()

local ToggleGroup = Tabs.Main:Group({})

ToggleGroup:Toggle({
    Title = "Auto Auction + Auto LNF",
    Default = false,
    Callback = function(v)
        autoEnabled = v
        if v then
            auctionRunning = false
            task.wait(0.1)
            task.spawn(mainLoop)
            WindUI:Notify({
                Title = "Auto Auction ON",
                Content = "Auto Auction is live, let's go twin!",
                Icon = "zap", Duration = 3,
            })
        else
            WindUI:Notify({
                Title = "Auto Auction OFF",
                Content = "Auto Auction has been disabled, we're out twin.",
                Icon = "zap", Duration = 3,
            })
        end
    end,
})

ToggleGroup:Space()

ToggleGroup:Toggle({
    Title = "Auto Bid",
    Default = false,
    Callback = function(v)
        autoBidEnabled = v
        if v then
            startAutoBid()
            WindUI:Notify({ Title = "Auto Bid ON", Content = "Auto Bid is now active, we're locked in twin.", Icon = "zap", Duration = 3 })
        else
            stopAutoBid()
            WindUI:Notify({ Title = "Auto Bid OFF", Content = "Auto Bid has been disabled, we're done twin.", Icon = "zap", Duration = 3 })
        end
    end,
})

Tabs.Main:Space()

Tabs.Main:Slider({
    Title = "Stop Auction At %",
    Icons = { From = "gauge", To = "gauge" },
    Step = 5,
    IsTooltip = true,
    Value = { Min = 50, Max = 100, Default = 90 },
    Callback = function(v)
        stopThreshold = v / 100
    end,
})

Tabs.Main:Space()

Tabs.Main:Slider({
    Title = "Resume Auction At %",
    Icons = { From = "gauge", To = "gauge" },
    Step = 5,
    IsTooltip = true,
    Value = { Min = 0, Max = 80, Default = 30 },
    Callback = function(v)
        resumeThreshold = v / 100
    end,
})

Tabs.Main:Space()
Tabs.Main:Divider()
Tabs.Main:Space()

-- SOCIAL TAB
Tabs.Social:Section({ Title = "Social Links" })

Tabs.Social:Paragraph({
    Title = "YouTube",
    Desc = "youtube.com/@RANSBLOX",
    Image = "youtube",
    Buttons = {{
        Title = "Copy", Icon = "copy",
        Callback = function()
            setclipboard("https://www.youtube.com/@RANSBLOX")
            WindUI:Notify({ Title = "Copied!", Content = "YouTube link copied!", Icon = "youtube", Duration = 3 })
        end,
    }},
})

Tabs.Social:Space()

Tabs.Social:Paragraph({
    Title = "TikTok",
    Desc = "tiktok.com/@ransblox",
    Image = "music",
    Buttons = {{
        Title = "Copy", Icon = "copy",
        Callback = function()
            setclipboard("https://www.tiktok.com/@ransblox")
            WindUI:Notify({ Title = "Copied!", Content = "TikTok link copied!", Icon = "music", Duration = 3 })
        end,
    }},
})

Tabs.Social:Space()

Tabs.Social:Paragraph({
    Title = "Website",
    Desc = "ransblox.pages.dev",
    Image = "globe",
    Buttons = {{
        Title = "Copy", Icon = "copy",
        Callback = function()
            setclipboard("https://ransblox.pages.dev")
            WindUI:Notify({ Title = "Copied!", Content = "Website link copied!", Icon = "globe", Duration = 3 })
        end,
    }},
})

-- MISC TAB
Tabs.Misc:Section({ Title = "⚠️ Anti-Scam Notice" })

Tabs.Misc:Paragraph({
    Title = "⚠️ This script is 100% Keyless",
    Desc = "No key required. Just execute and it works.",
    Color = "Red",
})

Tabs.Misc:Space()

Tabs.Misc:Paragraph({
    Title = "Found a version with a key?",
    Desc = "That's a scam. Get the real script only from RANSBLOX on YouTube.",
    Color = "Red",
})

Tabs.Misc:Space()
Tabs.Misc:Space()

Tabs.Misc:Section({ Title = "Script Info" })

Tabs.Misc:Paragraph({
    Title = "Script Owner",
    Desc = "RANSBLOX | youtube.com/@RANSBLOX",
    Image = "youtube",
})

Tabs.Misc:Space()

Tabs.Misc:Paragraph({
    Title = "Version",
    Desc = "v3.3 WindUI",
    Image = "tag",
})

Tabs.Misc:Space()
Tabs.Misc:Space()

Tabs.Misc:Section({ Title = "Keybinds" })

Tabs.Misc:Keybind({
    Title = "Toggle GUI",
    Desc = "Open/close the window",
    Value = "RightControl",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end,
})

WindUI:Notify({
    Title = "RANSBLOX",
    Content = "Storage Hunters loaded! v3.3",
    Icon = "youtube",
    Duration = 5,
})
