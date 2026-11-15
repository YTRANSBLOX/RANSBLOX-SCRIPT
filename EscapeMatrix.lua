local HUB_NAME = "Escape Matrix"
local VERSION  = "v1.0"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"
local LOGIC_URL = "https://raw.githubusercontent.com/YTRANSBLOX/RansnloxOnTop/refs/heads/main/Logic.lua"

-- Re-execute safety: unload the previous instance first
if _G.ESCAPEMATRIX_Unload then pcall(_G.ESCAPEMATRIX_Unload) end

pcall(function() setclipboard(YT_LINK) end)

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua?v=" .. tostring(math.random(1, 1e9))))()
end)
if not ok or not WindUI then return end

-- CONNECTION MANAGER
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- LOGIC (hosted separately -- see LOGIC_URL above)
-- =====================================================================
local okCore, Core = pcall(function()
    return loadstring(game:HttpGet(LOGIC_URL .. "?v=" .. tostring(math.random(1, 1e9))))(VERSION)
end)

if not okCore or not Core then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = "Failed to load engine (logic.lua unreachable).",
        Icon = "x",
        Duration = 5,
    })
    return
end

if not Core.ok then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = Core.err or "Engine failed to initialize.",
        Icon = "x",
        Duration = 5,
    })
    return
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
Tabs.Home = Window:Tab({ Title = "Home", Icon = icon("house", "home"),      IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Auto = Window:Tab({ Title = "Main", Icon = icon("briefcase", "house"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc = Window:Tab({ Title = "Misc", Icon = icon("info"),               IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

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

-- ===== MAIN TAB =====
local AutoBox = section(Tabs.Auto, "Roblux Studio Auto", "briefcase")

AutoBox:Paragraph({
    Title = "Not a bug: slow dev progress",
    Desc = "Slow dev progress isn't a bug -- Polish only grows through a long cooldown the game itself sets, unlike Content/Stability which have none.",
})

AutoBox:Toggle({
    Title = "Auto Run",
    Desc = "Auto-create, develop and publish Roblux Studio projects.",
    Value = false,
    Callback = function(v) Core.RobluxBot.running = v end,
})

-- Build each dropdown's name list straight from RobluxData / ADS_TIERS
-- (never hardcoded) so it always matches what the game actually offers.
local function nameList(tbl)
    local names = {}
    for _, e in ipairs(tbl or {}) do names[#names + 1] = e.name end
    return names
end
local function nameOf(tbl, key, matchField)
    tbl = tbl or {}
    for _, e in ipairs(tbl) do
        if e[matchField] == Core.CONFIG[key] then return e.name end
    end
    return tbl[1] and tbl[1].name
end
local function idByName(tbl, name, field)
    for i, e in ipairs(tbl or {}) do
        if e.name == name then return field == "index" and i or e.id end
    end
end

AutoBox:Dropdown({
    Title = "Scope", Flag = "ScopeDropdown",
    Desc = "Project size for new projects.",
    Values = nameList(Core.RobluxData.SCOPES),
    Value = nameOf(Core.RobluxData.SCOPES, "scope", "id"),
    Callback = function(v) Core.CONFIG.scope = idByName(Core.RobluxData.SCOPES, pickValue(v), "id") end,
})

AutoBox:Dropdown({
    Title = "Budget", Flag = "BudgetDropdown",
    Desc = "Starting budget for new projects.",
    Values = nameList(Core.RobluxData.BUDGETS),
    Value = Core.RobluxData.BUDGETS[Core.CONFIG.budgetIdx] and Core.RobluxData.BUDGETS[Core.CONFIG.budgetIdx].name,
    Callback = function(v) Core.CONFIG.budgetIdx = idByName(Core.RobluxData.BUDGETS, pickValue(v), "index") end,
})

AutoBox:Dropdown({
    Title = "Thumbnail", Flag = "ThumbDropdown",
    Desc = "Thumbnail used when publishing.",
    Values = nameList(Core.RobluxData.THUMBS),
    Value = Core.RobluxData.THUMBS[Core.CONFIG.thumbIdx] and Core.RobluxData.THUMBS[Core.CONFIG.thumbIdx].name,
    Callback = function(v) Core.CONFIG.thumbIdx = idByName(Core.RobluxData.THUMBS, pickValue(v), "index") end,
})

AutoBox:Dropdown({
    Title = "Description", Flag = "DescDropdown",
    Desc = "Game description used when publishing.",
    Values = nameList(Core.RobluxData.DESCS),
    Value = Core.RobluxData.DESCS[Core.CONFIG.descIdx] and Core.RobluxData.DESCS[Core.CONFIG.descIdx].name,
    Callback = function(v) Core.CONFIG.descIdx = idByName(Core.RobluxData.DESCS, pickValue(v), "index") end,
})

AutoBox:Dropdown({
    Title = "Monetization", Flag = "MonetDropdown",
    Desc = "Monetization style used when publishing.",
    Values = nameList(Core.RobluxData.MONET),
    Value = Core.RobluxData.MONET[Core.CONFIG.monetIdx] and Core.RobluxData.MONET[Core.CONFIG.monetIdx].name,
    Callback = function(v) Core.CONFIG.monetIdx = idByName(Core.RobluxData.MONET, pickValue(v), "index") end,
})

AutoBox:Dropdown({
    Title = "Launch Timing", Flag = "TimingDropdown",
    Desc = "When to publish for best reach.",
    Values = nameList(Core.RobluxData.TIMING),
    Value = Core.RobluxData.TIMING[Core.CONFIG.timingIdx] and Core.RobluxData.TIMING[Core.CONFIG.timingIdx].name,
    Callback = function(v) Core.CONFIG.timingIdx = idByName(Core.RobluxData.TIMING, pickValue(v), "index") end,
})

AutoBox:Dropdown({
    Title = "Launch Ads", Flag = "AdsDropdown",
    Desc = "Ad spend at launch for more visits.",
    Values = nameList(ADS_TIERS),
    Value = ADS_TIERS[Core.CONFIG.adsIdx] and ADS_TIERS[Core.CONFIG.adsIdx].name,
    Callback = function(v) Core.CONFIG.adsIdx = idByName(ADS_TIERS, pickValue(v), "index") end,
})

AutoBox:Toggle({
    Title = "Auto Updates",
    Desc = "Once a game is live: start an update, work it (Scripting/Building/UI/Animation/Debugging), release when done.",
    Value = Core.CONFIG.autoUpdates,
    Callback = function(v) Core.CONFIG.autoUpdates = v end,
})

local UPDATE_TYPE_LABEL = "Auto (bot decides)"
local function updateTypeNames()
    local names = { UPDATE_TYPE_LABEL }
    for _, u in ipairs(Core.RobluxData.UPDATES or {}) do names[#names + 1] = u.name end
    return names
end
AutoBox:Dropdown({
    Title = "Update Type", Flag = "UpdateTypeDropdown",
    Desc = "Pick one or more. Auto = bugfix when bugs pile up, else weighted toward Content/Features/Feedback. Untick Auto and pick specific types to only cycle through those.",
    Multi = true,
    Values = updateTypeNames(),
    Value = updateTypeNames(), -- default: everything ticked, including Auto
    Callback = function(v)
        local labels = (type(v) == "table" and (v.Title == nil and v.Name == nil)) and v or { v }
        local sel = {}
        for _, raw in ipairs(labels) do
            local label = pickValue(raw)
            if label == UPDATE_TYPE_LABEL then
                sel.auto = true
            else
                for _, u in ipairs(Core.RobluxData.UPDATES or {}) do
                    if u.name == label then sel[u.id] = true; break end
                end
            end
        end
        if next(sel) == nil then sel.auto = true end -- block an empty selection from going live
        Core.CONFIG.updateTypes = sel
    end,
})

-- ===== SHIPIFY (same Main tab, below Roblux Studio) =====
local ShipifyBox = section(Tabs.Auto, "Shipify Auto", "package")

ShipifyBox:Toggle({
    Title = "Auto Run",
    Desc = "Auto fulfill, resolve tickets, list/ads, sample, AI pitches, upgrade.",
    Value = false,
    Callback = function(v)
        if v and not Core.Shipify.ok then
            WindUI:Notify({ Title = "Shipify", Content = "Shipify module not found (job not unlocked here?).", Icon = "x", Duration = 3 })
            return
        end
        Core.Shipify.running = v
    end,
})

-- Same demand tiers as DEMAND_RANK in the engine (low/medium/high/very high).
-- Default stays "Medium", matching the engine's original MIN_AI_DEMAND default.
local DEMAND_DISPLAY = { "Low", "Medium", "High", "Very High" }
local DEMAND_KEY = { Low = "low", Medium = "medium", High = "high", ["Very High"] = "very high" }
local DEMAND_LABEL = { low = "Low", medium = "Medium", high = "High", ["very high"] = "Very High" }

ShipifyBox:Dropdown({
    Title = "Min AI Demand", Flag = "ShipifyMinDemandDropdown",
    Desc = "Minimum real demand (after AiAnalyze) required to adopt an AI pitch.",
    Values = DEMAND_DISPLAY,
    Value = DEMAND_LABEL[Core.Shipify.minDemand] or "Medium",
    Callback = function(v)
        Core.Shipify.minDemand = DEMAND_KEY[pickValue(v)] or "medium"
    end,
})

local ShipifyStatusP = ShipifyBox:Paragraph({ Title = "Status", Desc = Core.Shipify.ok and "Idle." or "Shipify module not found in this game." })

-- ===== TRADE X (same Main tab, below Shipify) =====
local TradeXBox = section(Tabs.Auto, "Trade X Auto", "candlestick-chart")

TradeXBox:Paragraph({
    Title = "Not a bug: idle on a small account",
    Desc = "TradeX staying idle on a small account isn't a bug -- it only trades once you have enough cash for at least 1 share. Low balance = it just waits, not stuck.",
})

TradeXBox:Toggle({
    Title = "Auto Run",
    Desc = "Auto buy (outlook/momentum/dip) and sell (TP/SL/outlook-bearish).",
    Value = false,
    Callback = function(v)
        if v and not Core.TradeX.ok then
            WindUI:Notify({ Title = "Trade X", Content = "MarketData module not found (job not unlocked here?).", Icon = "x", Duration = 3 })
            return
        end
        Core.TradeX.running = v
    end,
})

TradeXBox:Slider({
    Title = "Trail Arm %", Flag = "TradeXTrailArmSlider",
    Desc = "Start trailing once live profit hits this %.",
    Value = { Min = 1, Max = 15, Default = Core.TradeX.cfg.trailArmPct },
    Step = 0.5,
    Callback = function(v) Core.TradeX.cfg.trailArmPct = v end,
})

TradeXBox:Slider({
    Title = "Trail Drop %", Flag = "TradeXTrailDropSlider",
    Desc = "Base trailing margin from peak candle-high (used when symbol trend isn't positive).",
    Value = { Min = 1, Max = 10, Default = Core.TradeX.cfg.trailDropPct },
    Step = 0.5,
    Callback = function(v) Core.TradeX.cfg.trailDropPct = v end,
})

TradeXBox:Slider({
    Title = "Trail Drop Wide %", Flag = "TradeXTrailDropWideSlider",
    Desc = "Wider trailing margin used when the symbol's trend score is still positive.",
    Value = { Min = 1, Max = 15, Default = Core.TradeX.cfg.trailDropWidePct },
    Step = 0.5,
    Callback = function(v) Core.TradeX.cfg.trailDropWidePct = v end,
})

TradeXBox:Slider({
    Title = "Stop Loss %", Flag = "TradeXStopLossSlider",
    Desc = "Hard safety-net stop loss, checked live every cycle regardless of candles.",
    Value = { Min = 2, Max = 20, Default = Core.TradeX.cfg.slPct },
    Step = 0.5,
    Callback = function(v) Core.TradeX.cfg.slPct = v end,
})

TradeXBox:Paragraph({
    Title = "Risk",
    Desc = "Price/candle movement comes from the game's own real candle history (via TxChart), "
        .. "not from this bot -- it only reacts to that server data with trailing-TP, outlook, "
        .. "momentum/trend and dip rules. It's been net profitable in testing but doesn't win "
        .. "every cycle, so use at your own risk; the sliders above let you tune how aggressively it sells.",
})

local TradeXStatusP = TradeXBox:Paragraph({ Title = "Status", Desc = Core.TradeX.ok and "Idle." or "Trade X module not found in this game." })

-- ===== FLEXGRAM (same Main tab, below Trade X) =====
local FlexGramBox = section(Tabs.Auto, "FlexGram", "image")

FlexGramBox:Toggle({
    Title = "Auto Run",
    Desc = "Auto-create profile, auto-post (subject/caption/filter/promo), handle sponsors & scandals.",
    Value = false,
    Callback = function(v)
        if v and not Core.FlexGram.ok then
            WindUI:Notify({ Title = "FlexGram", Content = "FlexData module not found (job not unlocked here?).", Icon = "x", Duration = 3 })
            return
        end
        Core.FlexGram.running = v
    end,
})

local FlexSubjectDropdown = FlexGramBox:Dropdown({
    Title = "What are you posting?", Flag = "FlexGramSubjectDropdown",
    Desc = "Auto = bot picks the highest-scoring subject each post. Pick one to force it (falls back to Auto if it's unaffordable/too risky).",
    Values = Core.FlexGram.dropdownValues,
    Value = Core.FlexGram.dropdownValues[1],
    Callback = function(v)
        local label = pickValue(v)
        Core.FlexGram.selectedId = (label == AUTO_SUBJECT_LABEL) and nil or Core.FlexGram.labelToId[label]
    end,
})

FlexGramBox:Toggle({
    Title = "Accept Sponsors",
    Desc = "Auto-accept sponsor offers (declines if pay is below Min Sponsor Pay, or negative-influence unless allowed).",
    Value = Core.FlexGram.cfg.acceptSponsors,
    Callback = function(v) Core.FlexGram.cfg.acceptSponsors = v end,
})

FlexGramBox:Toggle({
    Title = "Use Promotion",
    Desc = "Spend on paid promo when it's worth it (based on Insights reach, or highest affordable tier otherwise).",
    Value = Core.FlexGram.cfg.usePromotion,
    Callback = function(v) Core.FlexGram.cfg.usePromotion = v end,
})

FlexGramBox:Slider({
    Title = "Max Fake Risk %", Flag = "FlexGramMaxFakeRiskSlider",
    Desc = "Ceiling on a subject's fake score (game's own 'high risk' cutoff is 40%).",
    Value = { Min = 0, Max = 39, Default = Core.FlexGram.cfg.maxFakeRisk },
    Step = 1,
    Callback = function(v) Core.FlexGram.cfg.maxFakeRisk = v end,
})

FlexGramBox:Slider({
    Title = "Max Promo Level", Flag = "FlexGramMaxPromoLevelSlider",
    Desc = "Promo tier ceiling: 1=no promo, 2=$50, 3=$500, 4=$5,000.",
    Value = { Min = 1, Max = 4, Default = Core.FlexGram.cfg.maxPromoLevel },
    Step = 1,
    Callback = function(v) Core.FlexGram.cfg.maxPromoLevel = v end,
})

if Core.FlexGram.ok then
    Core.Net.onState("core", function()
        local nw = (Core.Net.state.core or {}).nw or 0
        Core.FlexGram.dropdownValues, Core.FlexGram.labelToId = Core.FlexGram.buildSubjectDropdownValues(nw)
        pcall(function() FlexSubjectDropdown:Refresh(Core.FlexGram.dropdownValues) end)
    end)
end

local FlexGramStatusP = FlexGramBox:Paragraph({ Title = "Status", Desc = Core.FlexGram.ok and "Idle." or "FlexData module not found in this game." })

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
            local ok2 = pcall(function() Window.CurrentConfig:Save() end)
            if ok2 then
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
            local ok2 = pcall(function() Window.CurrentConfig:Load() end)
            if ok2 then
                WindUI:Notify({ Title = "Config", Content = "Settings loaded!", Icon = "check", Duration = 2 })
            else
                WindUI:Notify({ Title = "Config", Content = "No saved settings found.", Icon = "x", Duration = 3 })
            end
        end
    end,
})

-- ===== UNLOAD =====
local function unload()
    if _G.ESCAPEMATRIX_Unloaded == Window then return end
    _G.ESCAPEMATRIX_Unloaded = Window
    Core.unload()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.ESCAPEMATRIX_Unload = nil
end
_G.ESCAPEMATRIX_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts - " .. VERSION })

if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
