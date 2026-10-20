local HUB_NAME = "RoFront"
local VERSION  = "v1.0"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"

if _G.ROFRONT_Unload then pcall(_G.ROFRONT_Unload) end

pcall(function() setclipboard(YT_LINK) end)


-- =====================================================================
-- BOT (airfront_bot v5.6, embedded)
-- =====================================================================

-- =====================================================================
-- CORE LOGIC (loaded remotely, not embedded in this file)
-- =====================================================================
local LOGIC_URL = "LOGIC_URL_HERE" -- ganti pakai raw link logic.lua lo

local startBot
do
    local ok, fn = pcall(function()
        return loadstring(game:HttpGet(LOGIC_URL))()
    end)
    if not ok or type(fn) ~= "function" then
        warn("[RoFront] Core logic failed to load: " .. tostring(fn))
        return
    end
    startBot = fn
end
local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then
    warn("[RoFront] GUI library failed to load - starting bot without GUI")
    getgenv().AF_HARDCORE = true
    local okH, resH = pcall(startBot)
    if not okH then warn("[RoFront] bot failed: " .. tostring(resH)) end
    return
end

local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- GAME (RoFront / Airfront)
-- =====================================================================
local alive = true
local Bot = nil -- RUN table of the embedded bot: .cfg .paused .setHardcore() .setWarship() .getWarship() .stats()

-- GUI-side desired state (survives bot restarts)
local GuiState = { hardcore = true, warship = true, paused = false }
local StartWanted = true -- bot auto-starts (and keeps waiting for a match) unless the user switches Start off
local UserCfg = {}      -- slider values the user actually touched
local Building = true   -- ignore slider callbacks fired while the GUI is being built
task.delay(1.5, function() Building = false end)

local function applyUserCfg()
    if not (Bot and Bot.cfg) then return end
    for k, v in pairs(UserCfg) do Bot.cfg[k] = v end
end

local function applyGuiState()
    if not Bot then return end
    Bot.paused = GuiState.paused
    if Bot.setWarship then pcall(Bot.setWarship, GuiState.warship) end
    applyUserCfg()
end

local function loadBot()
    if Bot and getgenv().AF_BOT == Bot then return true, "already running" end
    getgenv().AF_HARDCORE = GuiState.hardcore
    local okB, res = pcall(startBot)
    if not okB then
        getgenv().AF_BOT = nil
        return false, res
    end
    if not res then
        getgenv().AF_BOT = nil
        return false, "match not found - join a match first, then start again"
    end
    Bot = getgenv().AF_BOT
    if not Bot then return false, "bot didn't expose RUN" end
    applyGuiState()
    return true, "started"
end

local function stopBot()
    getgenv().AF_BOT = nil
    Bot = nil
end

local function fmtNum(n)
    n = math.floor(tonumber(n) or 0)
    local neg = n < 0
    if neg then n = -n end
    local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    s = s:gsub("^,", "")
    return (neg and "-" or "") .. s
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
    Size = UDim2.fromOffset(620, 420),
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
Tabs.Home     = Window:Tab({ Title = "Home",     Icon = icon("house", "home"),    IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Main     = Window:Tab({ Title = "Main",      Icon = icon("play", "house"),    IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Combat   = Window:Tab({ Title = "Combat",    Icon = icon("swords", "sword"),  IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Economy  = Window:Tab({ Title = "Economy",   Icon = icon("factory", "building"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Defense  = Window:Tab({ Title = "Defense",   Icon = icon("shield", "shield-check"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Debug    = Window:Tab({ Title = "Debug",     Icon = icon("terminal", "bug"),  IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc     = Window:Tab({ Title = "Misc",      Icon = icon("info"),             IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

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

-- generic helper: slider bound straight to a RUN.cfg[key] field, no-op safely if bot isn't loaded yet
local function cfgSlider(box, title, desc, key, min, max, step, default)
    box:Slider({
        Title = title, Desc = desc, Step = step,
        Value = { Min = min, Max = max, Default = default },
        Callback = function(v)
            if Building then return end
            UserCfg[key] = v
            if Bot and Bot.cfg then Bot.cfg[key] = v end
        end,
    })
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
local DisclaimerBox = openSection(Tabs.Main, "Disclaimer", "alert-triangle")
DisclaimerBox:Paragraph({
    Title = "Read before you play",
    Desc = "This script is not a guaranteed auto-win tool. The final outcome of every match still "
        .. "depends on the server itself -- how aggressively your neighbors snowball, how the map is "
        .. "shaped, and how other players behave. What this script actually gives you is decision-making "
        .. "driven by real in-game calculations (troop ratios, reserve math, blast radius coverage, income "
        .. "value) instead of guesswork. It plays smart. It doesn't rig the game.",
})

local ControlBox = openSection(Tabs.Main, "Bot Control", "power")
local StatusP = ControlBox:Paragraph({ Title = "Status", Desc = "Not started." })

local function refreshStatus()
    if not Bot then
        pcall(function() StatusP:SetDesc(StartWanted and "Waiting for a match..." or "Not started.") end)
        return
    end
    local okS, s = pcall(Bot.stats)
    if not okS or not s then
        pcall(function() StatusP:SetDesc("Running, waiting to spawn...") end)
        return
    end
    local line = ("Tiles: %s | Troops: %s/%s | Gold: %s | Income: %s/s | Hardcore: %s | Warship: %s%s"):format(
        fmtNum(s.tiles), fmtNum(s.troops), fmtNum(s.maxTroops), fmtNum(s.gold), fmtNum(s.income or 0),
        s.hardcore and "ON" or "OFF", s.warship and "ON" or "OFF", s.paused and " | PAUSED" or "")
    pcall(function() StatusP:SetDesc(line) end)
end

local StartToggle
local resetting = false
StartToggle = ControlBox:Toggle({
    Title = "Start / Stop Bot",
    Desc = "ON by default: starts by itself and waits for a match if you're in the lobby.",
    Value = true,
    Callback = function(v)
        if resetting or Building then return end
        StartWanted = v
        if v then
            local okL, msg = loadBot()
            WindUI:Notify({
                Title = HUB_NAME,
                Content = okL and "Bot started." or ("Failed to start: " .. tostring(msg)),
                Icon = okL and "check" or "x", Duration = 4,
            })
            if not okL then
                StartWanted = false
                resetting = true
                pcall(function() StartToggle:Set(false) end)
                resetting = false
            end
        else
            stopBot()
            WindUI:Notify({ Title = HUB_NAME, Content = "Bot stopped.", Icon = "check", Duration = 2 })
        end
    end,
})

ControlBox:Toggle({
    Title = "Pause",
    Desc = "Freezes decision-making without killing the bot's memory (fast resume).",
    Value = false,
    Callback = function(v)
        GuiState.paused = v
        if Bot then Bot.paused = v end
    end,
})

ControlBox:Toggle({
    Title = "Hardcore Mode",
    Desc = "Tighter troop reserves, lower defense threshold, more aggressive punish timing.",
    Value = true,
    Callback = function(v)
        GuiState.hardcore = v
        if Bot and Bot.setHardcore then
            Bot.setHardcore(v)
            applyUserCfg()
        end
    end,
})

task.spawn(function()
    while alive do
        task.wait(2)
        pcall(refreshStatus)
    end
end)

-- ===== COMBAT TAB =====
local CombatBox = section(Tabs.Combat, "Attack Tuning", "swords")
cfgSlider(CombatBox, "Attack Power Threshold", "Minimum power ratio before the bot commits to an attack (ATTACK_P). Lower = more aggressive.", "ATTACK_P", 1.0, 3.5, 0.1, 1.8)
cfgSlider(CombatBox, "Max Attack Ratio", "Max share of troops sent per attack wave (ATK_MAX_RATIO).", "ATK_MAX_RATIO", 0.1, 0.8, 0.05, 0.4)
cfgSlider(CombatBox, "Overkill Multiplier", "Extra troops sent on top of the minimum needed, to avoid stalled attacks.", "OVERKILL", 1.0, 2.0, 0.05, 1.3)
cfgSlider(CombatBox, "Focus Overkill Multiplier", "Same as above, but only for the currently focused enemy.", "FOCUS_OVERKILL", 1.0, 2.0, 0.05, 1.25)
cfgSlider(CombatBox, "Momentum Size Boost", "How much a winning streak increases attack size (MOM_SIZE).", "MOM_SIZE", 0.5, 4.0, 0.1, 2.0)

local NavalBox = section(Tabs.Combat, "Naval / Boats", "ship")
cfgSlider(NavalBox, "Max Boat Attack Ratio", "Max share of troops sent per overseas boat attack.", "BOAT_ATTACK_MAX", 0.05, 0.5, 0.05, 0.25)
cfgSlider(NavalBox, "Boat Reach", "How many hops of ocean the bot is willing to cross to invade.", "BOAT_REACH_MAX", 1, 8, 1, 4)
NavalBox:Toggle({
    Title = "Enable Warship",
    Desc = "ON by default. The bot switches it off by itself after 3 failed builds (warship is a unit, not a structure).",
    Value = true,
    Callback = function(v)
        GuiState.warship = v
        if Bot and Bot.setWarship then Bot.setWarship(v) end
    end,
})

-- ===== ECONOMY TAB =====
local EcoBox = section(Tabs.Economy, "Build Caps", "building")
cfgSlider(EcoBox, "City Cap", "Max number of cities the bot will build under normal wealth.", "CITY_CAP", 8, 40, 1, 16)
cfgSlider(EcoBox, "Silo Min City", "How many cities required before the bot starts building a missile silo.", "SILO_MIN_CITY", 1, 8, 1, 2)
cfgSlider(EcoBox, "Warship Cap", "Max number of warships the bot will keep built.", "WARSHIP_CAP", 0, 10, 1, 3)

-- ===== DEFENSE TAB =====
local DefBox = section(Tabs.Defense, "Defense Tuning", "shield")
cfgSlider(DefBox, "Max Defense Structures", "Hard ceiling on defense buildings.", "MAX_DEFENSE", 2, 20, 1, 6)
cfgSlider(DefBox, "Defense Threat Sensitivity", "Lower = bot gets defensive sooner at smaller threats.", "DEF_THREAT_MIN", 0.1, 0.6, 0.05, 0.25)
cfgSlider(DefBox, "SAM Cap", "Max number of anti-air (SAM) structures.", "SAM_CAP", 2, 14, 1, 5)
cfgSlider(DefBox, "Nuke Gold Reserve", "Gold kept untouched for buying a nuke even during a build spree.", "NUKE_RESERVE", 25000, 300000, 5000, 50000)

-- ===== DEBUG TAB =====
local LogBox = openSection(Tabs.Debug, "Live Log", "terminal")
local PostureP = LogBox:Paragraph({ Title = "Posture", Desc = "Not started." })

task.spawn(function()
    while alive do
        task.wait(3)
        local p = getgenv().AF_POSTURE
        if type(p) == "table" then
            local line = ("need=%.2f | assault=%s | aggr=%.2f"):format(
                tonumber(p.need) or 0, tostring(p.assault), tonumber(p.aggr) or 0)
            pcall(function() PostureP:SetDesc(line) end)
        end
    end
end)

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
    Desc = "Dropdowns/sliders with a Flag are saved automatically whenever you change them, and loaded back next time you join.",
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

local function unload()
    if _G.ROFRONT_Unloaded == Window then return end
    _G.ROFRONT_Unloaded = Window
    alive = false
    stopBot()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.ROFRONT_Unload = nil
end
_G.ROFRONT_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Stops the bot, removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts - " .. VERSION })

if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end

-- auto-start: everything ON by default, so the user doesn't have to touch any toggle
task.spawn(function()
    task.wait(1.6) -- let the GUI finish building (Building flag drops at 1.5s)
    local told = false
    while alive and StartWanted and not Bot do
        local okL, msg = loadBot()
        if okL then
            WindUI:Notify({ Title = HUB_NAME, Content = "Bot started.", Icon = "check", Duration = 3 })
            break
        end
        if not told then
            told = true
            WindUI:Notify({ Title = HUB_NAME, Content = "Waiting to start: " .. tostring(msg), Icon = "clock", Duration = 5 })
        end
        task.wait(8)
    end
end)
