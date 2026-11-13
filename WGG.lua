local HUB_NAME   = "Weird Gun Game"
local VERSION    = "v1.0"
local YT_LINK    = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK   = "https://ransblox.net"
local LOGIC_URL  = "https://raw.githubusercontent.com/YTRANSBLOX/RansnloxOnTop/refs/heads/main/free.lua"

if _G.WGG_Unload then pcall(_G.WGG_Unload) end
pcall(function() setclipboard(YT_LINK) end)

-- Load WindUI
local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then return end

-- Load Logic
local okL, Logic = pcall(function()
    return loadstring(game:HttpGet(LOGIC_URL))()
end)
if not okL or not Logic then
    return
end

local SAConfig  = Logic.SAConfig
local ESPConfig = Logic.ESPConfig

-- =====================================================================
-- GUI HELPERS
-- =====================================================================
local function icon(...)
    for _, name in ipairs({ ... }) do
        local okI, found = pcall(WindUI.Creator.Icon, name)
        if okI and found then return name end
    end
    return "info"
end

local function pickValue(v)
    if type(v) == "table" then v = v.Title or v.Name or v[1] end
    return tostring(v)
end

local function copyLink(name, link)
    pcall(function() setclipboard(link) end)
    WindUI:Notify({ Title = name, Content = "Link copied to clipboard!", Icon = "check", Duration = 2 })
end

-- =====================================================================
-- THEME
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

-- =====================================================================
-- WINDOW
-- =====================================================================
local Window = WindUI:CreateWindow({
    Title = HUB_NAME,
    Author = "Ransblox Scripts",
    Icon = "crosshair",
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

Window:Tag({ Title = VERSION, Icon = "crosshair", Color = Color3.fromHex("#FF8200"), Border = true })
Window:Tag({ Title = "FREE", Icon = "badge-check", Color = Color3.fromHex("#22C55E"), Border = true })

local Tabs = {}
Tabs.Home = Window:Tab({ Title = "Home", Icon = icon("house", "home"),    IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Main = Window:Tab({ Title = "Main", Icon = icon("crosshair", "aim"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc = Window:Tab({ Title = "Misc", Icon = icon("settings", "info"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

local function section(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = false })
end
local function openSection(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = true })
end

-- ===== HOME =====
local AboutBox = openSection(Tabs.Home, "Ransblox Scripts", "user")
AboutBox:Paragraph({ Title = "Welcome!", Desc = "Free Roblox scripts on YouTube and ransblox.net. Subscribe to catch new drops first." })

local FreeBox = openSection(Tabs.Home, "100% Free Script", "shield-check")
FreeBox:Paragraph({ Title = "This script is free", Desc = "No key system, no payments, no subscription. It was never sold and it never will be." })
FreeBox:Paragraph({ Title = "Found a version with a key? It's a scam", Desc = "If someone asks for a key or money to use this, it's a fake. Only trust the official links below." })

local LinkBox = openSection(Tabs.Home, "Official Links", "link")
local LinkGroup = LinkBox:Group()
LinkGroup:Button({ Title = "YouTube", Desc = "Ransblox Scripts", Icon = "youtube", Color = "Red", Callback = function() copyLink("YouTube", YT_LINK) end })
LinkGroup:Button({ Title = "Website", Desc = "ransblox.net", Icon = "globe", Callback = function() copyLink("Website", WEB_LINK) end })

-- ===== MAIN =====
local CombatBox = section(Tabs.Main, "Combat", "crosshair")

CombatBox:Dropdown({
    Title = "Hit Part", Flag = "HitPart",
    Desc = "Target body part.",
    Values = { "HumanoidRootPart", "Head" },
    Value = "Head",
    Callback = function(v) SAConfig.HitPart = pickValue(v) end,
})

CombatBox:Toggle({
    Title = "Silent Aim",
    Desc = "Auto-redirects shots to the nearest enemy on screen.",
    Value = true,
    Callback = function(v) SAConfig.Enabled = v end,
})

CombatBox:Toggle({
    Title = "Wallbang",
    Desc = "Shots hit enemies through walls.",
    Value = true,
    Callback = function(v) SAConfig.WBEnabled = v end,
})

local ESPBox = section(Tabs.Main, "ESP", "eye")
ESPBox:Toggle({
    Title = "ESP",
    Desc = "Shows enemy name, HP, and distance.",
    Value = false,
    Callback = function(v) ESPConfig.Enabled = v end,
})

-- ===== MISC =====
local UIBox = section(Tabs.Misc, "Interface", "palette")
UIBox:Toggle({
    Title = "Glass Mode", Desc = "Makes the window slightly transparent.",
    Value = false, Callback = function(v) Window:ToggleTransparency(v) end,
})
UIBox:Slider({
    Title = "UI Scale", Desc = "Lower if the GUI is too big on mobile.", Step = 0.05,
    Value = { Min = 0.7, Max = 1.2, Default = 1 },
    Callback = function(v) Window:SetUIScale(v) end,
})
UIBox:Keybind({
    Title = "Toggle GUI", Desc = "Show/hide the window.",
    Value = "RightControl",
    Callback = function(key)
        local ok2, kc = pcall(function() return Enum.KeyCode[key] end)
        if ok2 and kc then Window:Toggle() end
    end,
})

local ConfigBox = section(Tabs.Misc, "Config", "save")
ConfigBox:Paragraph({ Title = "Auto-save", Desc = "Settings are saved automatically and loaded back next session." })
local CfgGroup = ConfigBox:Group()
CfgGroup:Button({
    Title = "Save Now", Icon = "save",
    Callback = function()
        if Window.CurrentConfig then
            local ok2 = pcall(function() Window.CurrentConfig:Save() end)
            WindUI:Notify({ Title = "Config", Content = ok2 and "Saved!" or "Save failed.", Icon = ok2 and "check" or "x", Duration = 2 })
        end
    end,
})
CfgGroup:Button({
    Title = "Load Saved", Icon = "upload",
    Callback = function()
        if Window.CurrentConfig then
            local ok2 = pcall(function() Window.CurrentConfig:Load() end)
            WindUI:Notify({ Title = "Config", Content = ok2 and "Loaded!" or "Nothing saved.", Icon = ok2 and "check" or "x", Duration = 2 })
        end
    end,
})

-- ===== UNLOAD =====
local function unload()
    if _G.WGG_Unloaded == Window then return end
    _G.WGG_Unloaded = Window
    pcall(function() Logic.Unload() end)
    pcall(function() Window:Destroy() end)
    _G.WGG_Unload = nil
end
_G.WGG_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything.", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
