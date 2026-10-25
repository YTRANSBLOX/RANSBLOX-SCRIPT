--[[ Robot Fighter by Ransblox Scripts
loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/CreateRobitFighter.lua"))()
]]

local HUB_NAME  = "Robot Fighter"
local VERSION   = "v1.0"
local YT_LINK   = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK  = "https://ransblox.net"
local LOGIC_URL = "https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/secret.lua"

-- Re-execute safety: unload the previous instance first
if _G.ROBOTFIGHTER_Unload then pcall(_G.ROBOTFIGHTER_Unload) end

pcall(function() setclipboard(YT_LINK) end)

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then return end

-- =====================================================================
-- LOAD LOGIC
-- =====================================================================
local okL, Core, coreErr = pcall(function()
    return loadstring(game:HttpGet(LOGIC_URL))()
end)
if not okL or not Core then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = tostring(okL and coreErr or Core or "Failed to load logic."),
        Icon = "x",
        Duration = 5,
    })
    return
end

-- Old logic (before the override system) turned GUI switches off by itself. Warn loudly.
if not Core.Version then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = "OLD logic detected, switches can turn off by themselves. Re-upload the new logic file.",
        Icon = "x",
        Duration = 8,
    })
end

-- =====================================================================
-- GUI HELPERS
-- =====================================================================
local toggles = {} -- feature id -> WindUI toggle (so the logic can flip the switch)

-- picks the first icon name that really exists in WindUI's icon set
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

-- dropdown value (multi) -> plain array of strings for the logic
local function toList(v)
    local list = {}
    if type(v) == "table" then
        for _, item in ipairs(v) do table.insert(list, pickValue(item)) end
    end
    return list
end

local function copyLink(name, link)
    pcall(function() setclipboard(link) end)
    WindUI:Notify({ Title = name, Content = "Link copied to clipboard!", Icon = "check", Duration = 2 })
end

-- =====================================================================
-- WINDOW
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
    Folder = HUB_NAME, -- needed for ConfigManager (auto-save settings)
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

-- version tag + a green "FREE" tag next to it
Window:Tag({ Title = VERSION, Icon = "youtube", Color = Color3.fromHex("#FF8200"), Border = true })
Window:Tag({ Title = "FREE", Icon = "badge-check", Color = Color3.fromHex("#22C55E"), Border = true })

local Tabs = {}
Tabs.Home = Window:Tab({ Title = "Home", Icon = icon("house", "home"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Auto = Window:Tab({ Title = "Main", Icon = icon("bot", "house"),  IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Quest = Window:Tab({ Title = "Quest", Icon = icon("list-checks", "target", "scroll"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Tournament = Window:Tab({ Title = "Tournament", Icon = icon("swords", "trophy"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Extra = Window:Tab({ Title = "Extra", Icon = icon("gift", "star"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc = Window:Tab({ Title = "Misc", Icon = icon("info"),          IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

local function section(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = false })
end

local function openSection(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = true })
end

-- toggle bound to a logic feature id. The logic handles all side effects.
local function addToggle(box, title, desc, id, iconName)
    local t = box:Toggle({
        Title = title,
        Desc = desc,
        Icon = iconName,
        Value = false,
        Callback = function(v) Core.SetFeature(id, v) end,
    })
    toggles[id] = t
    return t
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
local StatusBox = openSection(Tabs.Auto, "Status", "activity")
local StatusP = StatusBox:Paragraph({ Title = "Last action", Desc = "Ready" })

-- logic -> GUI hooks
Core.OnStatus = function(text)
    pcall(function() StatusP:SetDesc(text) end)
end
Core.OnNotify = function(content, duration)
    WindUI:Notify({ Title = HUB_NAME, Content = content, Icon = "x", Duration = duration or 4 })
end
-- only used when picking Fight turns the Train switch off (and vice versa)
Core.OnFeatureChanged = function(id, on)
    local t = toggles[id]
    if t then pcall(function() t:Set(on) end) end
end

local PartsBox = section(Tabs.Auto, "Parts", "puzzle")
addToggle(PartsBox, "Auto Pull", "Pulls the gacha lever for new parts.", "Pull", "disc")
addToggle(PartsBox, "Auto Buy Parts", "Buys and places parts automatically.", "Buy", "shopping-cart")

local function copyList(t)
    local out = {}
    for i, v in ipairs(t) do out[i] = v end
    return out
end

local function rarityDropdown(title, flag, desc, slot)
    PartsBox:Dropdown({
        Title = title,
        Flag = flag,
        Desc = desc,
        Values = copyList(Core.RARITIES),
        Value = copyList(Core.RARITIES),
        Multi = true,
        Callback = function(v) Core.SetRarity(slot, toList(v)) end,
    })
end
rarityDropdown("Head Rarity", "HeadRarity", "Which rarities to buy for the Head slot.", "Head")
rarityDropdown("Body Rarity", "BodyRarity", "Which rarities to buy for the Body slot.", "Upper")
rarityDropdown("Leg Rarity",  "LegRarity",  "Which rarities to buy for the Leg slot.",  "Lower")

addToggle(PartsBox, "Auto Store Part", "Stores picked rarities on the Parts Shelf instead of building them.", "Store", "archive")
PartsBox:Dropdown({
    Title = "Store Rarity",
    Flag = "StoreRarity",
    Desc = "Which rarities to store instead of build.",
    Values = Core.RARITIES,
    Value = {},
    Multi = true,
    Callback = function(v) Core.SetStoreRarity(toList(v)) end,
})

local ScrapBox = section(Tabs.Auto, "Scrap", "recycle")
addToggle(ScrapBox, "Auto Farm Scrap", "Collects and sells scrap automatically.", "Scrap", "recycle")

local BuildBox = section(Tabs.Auto, "Robot", "bot")
addToggle(BuildBox, "Auto Build Robot", "Builds your robot automatically.", "Build", "wrench")
addToggle(BuildBox, "Auto Fight", "Keeps your robot fighting.", "Fight", "swords")
addToggle(BuildBox, "Auto Train", "Keeps your robot training.", "Train", "dumbbell")
BuildBox:Dropdown({
    Title = "Fight Round",
    Flag = "FightRound",
    Desc = "Which round to start.",
    Values = { "Highest", "Round 1" },
    Value = "Highest",
    Callback = function(v) Core.SetRound(pickValue(v)) end,
})
BuildBox:Dropdown({
    Title = "Fight Speed",
    Flag = "FightSpeed",
    Desc = "How fast fights play out.",
    Values = { "1x", "2x" },
    Value = "1x",
    Callback = function(v) Core.SetSpeed(tonumber(pickValue(v):match("%d+"))) end,
})

local UpBox = section(Tabs.Extra, "Upgrades", "trending-up")
addToggle(UpBox, "Auto Upgrade", "Buys upgrades from the signs on your plot.", "Upgrade", "trending-up")
UpBox:Dropdown({
    Title = "Upgrades",
    Flag = "UpgradeList",
    Desc = "Which upgrades to buy.",
    Values = { "Luck", "Punching Bag", "Storage", "Shredder" },
    Value = { "Luck" },
    Multi = true,
    Callback = function(v) Core.SetUpgrades(toList(v)) end,
})
UpBox:Dropdown({
    Title = "Buy Amount",
    Flag = "UpgradeAmount",
    Desc = "How many levels to buy at once.",
    Values = { "Max", "One" },
    Value = "Max",
    Callback = function(v) Core.SetBuyMax(pickValue(v) == "Max") end,
})

-- ===== QUEST TAB =====
local QuestInfoBox = openSection(Tabs.Quest, "How it works", "info")
QuestInfoBox:Paragraph({
    Title = "Auto Quest Mode",
    Desc = "When you turn this ON, it takes over your bot completely:\n\n"
        .. "- Auto Buy Parts, Auto Build Robot, Auto Upgrade, Auto Store Part, Auto Open Crates "
        .. "and Auto Rebirth are paused while this is ON. Your switches stay where you left them.\n\n"
        .. "- It reads today's 3 quests and only runs what each unfinished quest actually needs: "
        .. "Fight or Train (whichever quest needs it), Pull the gacha for Spin quests, and Farm Scrap "
        .. "for scrap quests. Nothing else runs while this is ON.\n\n"
        .. "- Finished quests are claimed automatically, the moment they're done - no extra toggle needed.\n\n"
        .. "- Once all 3 quests are done, the bot just idles and waits to claim, until new quests reset.\n\n"
        .. "Turn this OFF and everything goes back to exactly what your switches say.",
})

local QuestBox = section(Tabs.Quest, "Auto Quest", "target")
addToggle(QuestBox, "Auto Quest Mode", "Stops every other automation and only does what's needed to finish and claim today's quests.", "QuestMode", "target")

-- ===== TOURNAMENT TAB =====
local TourneyInfoBox = openSection(Tabs.Tournament, "How it works", "info")
TourneyInfoBox:Paragraph({
    Title = "Auto Tournament",
    Desc = "Your bot can't join the Underground Tournament while it's busy with a normal fight. "
        .. "Turning this ON handles that for you, no manual cancelling needed:\n\n"
        .. "- The moment the tournament's join window opens, it pauses Auto Fight and sends "
        .. "a Retreat command if your bot is mid-fight or walking to the Arena, so it's instantly "
        .. "free to join.\n\n"
        .. "- It then joins the tournament automatically.\n\n"
        .. "- Once the tournament is over, Auto Fight runs again by itself if your switch is ON. "
        .. "Your Auto Fight switch is never touched.\n\n"
        .. "You never have to babysit this or press Retreat yourself.",
})

local TourneyBox = section(Tabs.Tournament, "Tournament", "swords")
addToggle(TourneyBox, "Auto Tournament", "Auto-joins the Underground Tournament, retreating from any current fight first, and resumes Auto Fight once it's over.", "Tournament", "trophy")

local RewardBox = section(Tabs.Extra, "Rewards", "gift")
addToggle(RewardBox, "Auto Open Crates", "Opens crates you are holding.", "Crate", "gift")

local RebirthBox = section(Tabs.Extra, "Rebirth", "rotate-ccw")
addToggle(RebirthBox, "Auto Rebirth", "Rebirths as soon as it is available.", "Rebirth", "rotate-ccw")

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

local MoveBox = section(Tabs.Misc, "Movement", "move")
MoveBox:Toggle({
    Title = "Allow Teleport", Desc = "Allows auto-features to teleport your character.",
    Value = true,
    Callback = function(v) Core.SetAllowTP(v) end,
})

-- ===== CONFIG SAVE/LOAD =====
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
    if _G.ROBOTFIGHTER_Unloaded == Window then return end
    _G.ROBOTFIGHTER_Unloaded = Window
    pcall(Core.Unload)
    pcall(function() Window:Destroy() end)
    _G.ROBOTFIGHTER_Unload = nil
end
_G.ROBOTFIGHTER_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION .. " • logic " .. tostring(Core.Version or "old") })

-- auto-save: register the Flag'd dropdowns + autoload last saved values
if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
