local HUB_NAME = "Net a Fish"
local VERSION  = "v1.1"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"

-- raw link to logic.lua (the module with every remote/state/feature loop)
local LOGIC_URL = "https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/sjjsjssj.lua"

-- Re-execute safety: unload the previous instance first
if _G.NETAFISH_Unload then pcall(_G.NETAFISH_Unload) end

pcall(function() setclipboard(YT_LINK) end)

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then return end

-- load the logic module (remotes, state, feature loops) — everything in
-- this file talks to the game only through L, the module table it returns
local okL, L = pcall(function()
    return loadstring(game:HttpGet(LOGIC_URL))()
end)
if not okL or not L then return end

local RARITY_NAMES = L.RARITY_NAMES
local money = L.money

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
    Icon = "fish",
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
Tabs.Auto = Window:Tab({ Title = "Main", Icon = icon("fish", "house"),       IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Event = Window:Tab({ Title = "Event", Icon = icon("crosshair", "target", "zap"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Upgrade = Window:Tab({ Title = "Upgrade", Icon = icon("trending-up", "arrow-up-circle"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Shop = Window:Tab({ Title = "Shop", Icon = icon("shopping-bag", "shopping-cart", "store"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Rebirth = Window:Tab({ Title = "Rebirth", Icon = icon("refresh-cw", "rotate-cw"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Quest = Window:Tab({ Title = "Quest", Icon = icon("scroll-text", "clipboard-check", "list-checks"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Hub = Window:Tab({ Title = "Hub", Icon = icon("box", "package", "shopping-bag"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc = Window:Tab({ Title = "Misc", Icon = icon("info"),                IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

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
    Desc = "Roblox script showcases on YouTube, free script hub.",
})

local FreeBox = openSection(Tabs.Home, "100% Free Script", "shield-check")
FreeBox:Paragraph({
    Title = "This script is free",
    Desc = "No key, no payment, no subscription.",
})
FreeBox:Paragraph({
    Title = "Found a version with a key? It's a scam",
    Desc = "Don't pay. Use the official links below.",
})

local LinkBox = openSection(Tabs.Home, "Official Links", "link")
local LinkGroup = LinkBox:Group()
LinkGroup:Button({
    Title = "YouTube", Desc = "Ransblox Scripts", Icon = "youtube",
    Color = "Red",
    Callback = function() copyLink("YouTube", YT_LINK) end,
})
LinkGroup:Button({
    Title = "Website", Desc = "ransblox.net", Icon = "globe",
    Callback = function() copyLink("Website", WEB_LINK) end,
})

-- ===== MAIN TAB =====
local ThrowBox = section(Tabs.Auto, "Auto Throw Net", "anchor")

ThrowBox:Toggle({
    Title = "Auto Throw Net",
    Flag = "AutoThrow",
    Desc = "Keeps throwing your net whenever it's ready.",
    Value = false,
    Callback = function(v)
        L.setThrowRunning(v)
    end,
})

local ThrowStatusP = ThrowBox:Paragraph({ Title = "Status", Desc = L.getThrowStatus() })
L.onThrowStatus(function(text)
    pcall(function() ThrowStatusP:SetDesc(text) end)
end)

local REEL_IN_LABELS = { "Full (100%)", "75%", "50%", "25%" }
local REEL_IN_VALUES = { 1, 0.75, 0.5, 0.25 }

ThrowBox:Dropdown({
    Title = "Reel In At",
    Flag = "ReelInThreshold",
    Desc = "Pulls the net in early once it's this full, instead of waiting for full.",
    Values = REEL_IN_LABELS,
    Multi = false,
    Value = "Full (100%)",
    Callback = function(v)
        for i, label in ipairs(REEL_IN_LABELS) do
            if label == v then
                L.setReelInThreshold(REEL_IN_VALUES[i])
                break
            end
        end
    end,
})

local TakeBox = section(Tabs.Auto, "Auto Take", "arrow-down-to-line")

TakeBox:Dropdown({
    Title = "Rarities to Take",
    Flag = "TakeRarities",
    Desc = "Rarities to move to showcase.",
    Values = RARITY_NAMES,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setTakeSelected(v)
    end,
})

TakeBox:Toggle({
    Title = "Auto Take",
    Flag = "AutoTake",
    Desc = "Moves selected rarities to showcase.",
    Value = false,
    Callback = function(v)
        L.setTakeRunning(v)
    end,
})

local TakeStatusP = TakeBox:Paragraph({ Title = "Status", Desc = L.getTakeStatus() })
L.onTakeStatus(function(text)
    pcall(function() TakeStatusP:SetDesc(text) end)
end)

local SellBox = section(Tabs.Auto, "Auto Sell", "coins")

SellBox:Dropdown({
    Title = "Rarities to Sell",
    Flag = "SellRarities",
    Desc = "Rarities to sell.",
    Values = RARITY_NAMES,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setSellSelected(v)
    end,
})

SellBox:Toggle({
    Title = "Auto Sell",
    Flag = "AutoSell",
    Desc = "Sells selected rarities.",
    Value = false,
    Callback = function(v)
        L.setSellRunning(v)
    end,
})

local SellStatusP = SellBox:Paragraph({ Title = "Status", Desc = L.getSellStatus() })
L.onSellStatus(function(text)
    pcall(function() SellStatusP:SetDesc(text) end)
end)

local PlaceBox = section(Tabs.Auto, "Auto Place", "layout-grid")

PlaceBox:Dropdown({
    Title = "Rarities to Place",
    Flag = "PlaceRarities",
    Desc = "Rarities to place on pedestals.",
    Values = RARITY_NAMES,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setPlaceSelected(v)
    end,
})

PlaceBox:Toggle({
    Title = "Auto Place",
    Flag = "AutoPlace",
    Desc = "Places selected rarities on pedestals.",
    Value = false,
    Callback = function(v)
        L.setPlaceRunning(v)
    end,
})

local PlaceStatusP = PlaceBox:Paragraph({ Title = "Status", Desc = L.getPlaceStatus() })
L.onPlaceStatus(function(text)
    pcall(function() PlaceStatusP:SetDesc(text) end)
end)

local CollectBox = section(Tabs.Auto, "Auto Collect", "coins")

CollectBox:Paragraph({
    Title = "How this works",
    Desc = "Teleports to each podium to collect.",
})

local COLLECT_INTERVAL_LABELS = { "30 seconds", "1 minute", "2 minutes", "5 minutes", "10 minutes" }
local COLLECT_INTERVAL_SECONDS = { 30, 60, 120, 300, 600 }

CollectBox:Dropdown({
    Title = "Auto Collect Interval",
    Flag = "CollectInterval",
    Desc = "Collect interval.",
    Values = COLLECT_INTERVAL_LABELS,
    Multi = false,
    Value = "30 seconds",
    Callback = function(v)
        local picked = pickValue(v)
        for i, label in ipairs(COLLECT_INTERVAL_LABELS) do
            if label == picked then
                L.setCollectInterval(COLLECT_INTERVAL_SECONDS[i])
                break
            end
        end
    end,
})

CollectBox:Toggle({
    Title = "Auto Collect",
    Flag = "AutoCollect",
    Desc = "Collects from every open podium.",
    Value = false,
    Callback = function(v)
        L.setCollectRunning(v)
    end,
})

CollectBox:Button({
    Title = "Collect Now", Desc = "Collect once, right now.", Icon = "coins",
    Callback = function()
        L.collectNow()
    end,
})

local CollectStatusP = CollectBox:Paragraph({ Title = "Status", Desc = L.getCollectStatus() })
L.onCollectStatus(function(text)
    pcall(function() CollectStatusP:SetDesc(text) end)
end)

local DrinkBox = section(Tabs.Auto, "Auto Drink", icon("flask", "droplet"))

DrinkBox:Dropdown({
    Title = "Drink Priority",
    Flag = "PotionDrinkSort",
    Desc = "Highest or lowest tier first.",
    Values = { "Best First", "Worst First" },
    Multi = false,
    Value = "Best First",
    Callback = function(v)
        L.setPotionDrinkSortMode((v == "Worst First") and "Worst" or "Best")
    end,
})

DrinkBox:Dropdown({
    Title = "Kinds to Drink",
    Flag = "PotionDrinkKindSelect",
    Desc = "Pick Cash and/or Net.",
    Values = L.DRINK_KIND_LABELS,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setPotionDrinkKindSelected(v)
    end,
})

DrinkBox:Toggle({
    Title = "Auto Drink",
    Flag = "AutoDrink",
    Desc = "Drinks from your Cooler automatically.",
    Value = false,
    Callback = function(v)
        L.setPotionDrinkRunning(v)
    end,
})

local PotionDrinkStatusP = DrinkBox:Paragraph({ Title = "Status", Desc = L.getPotionDrinkStatus() })
L.onPotionDrinkStatus(function(text)
    pcall(function() PotionDrinkStatusP:SetDesc(text) end)
end)

local MiniGamesBox = section(Tabs.Auto, "Auto Mini Games", icon("gamepad-2", "sparkles", "star"))

MiniGamesBox:Paragraph({
    Title = "How this works",
    Desc = "Handles mini-games that pop up on their own while you're fishing, so you don't miss the bonus.",
})

MiniGamesBox:Toggle({
    Title = "Auto Mini Games",
    Flag = "AutoMiniGames",
    Desc = "Automatically plays mini-games for you when they appear.",
    Value = false,
    Callback = function(v)
        L.setMiniGamesRunning(v)
    end,
})

local MiniGamesStatusP = MiniGamesBox:Paragraph({ Title = "Status", Desc = L.getMiniGamesStatus() })
L.onMiniGamesStatus(function(text)
    pcall(function() MiniGamesStatusP:SetDesc(text) end)
end)

-- ===== UPGRADE TAB =====
local BuyBox = section(Tabs.Upgrade, "Auto Buy", "trending-up")

BuyBox:Dropdown({
    Title = "Buy Priority",
    Flag = "BuyPriority",
    Desc = "Cheapest affordable upgrade first.",
    Values = L.BUY_CATEGORIES,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setBuyPriority(v)
    end,
})

BuyBox:Toggle({
    Title = "Auto Buy",
    Flag = "AutoBuyUpgrades",
    Desc = "Automatically buys upgrades from the categories picked above, cheapest first.",
    Value = false,
    Callback = function(v)
        L.setBuyRunning(v)
    end,
})

local BuyStatusP = BuyBox:Paragraph({ Title = "Status", Desc = L.getBuyStatus() })
L.onBuyStatus(function(text)
    pcall(function() BuyStatusP:SetDesc(text) end)
end)

-- ===== SHOP TAB =====
local BaitBuyBox = section(Tabs.Shop, "Auto Buy Bait", "shopping-bag")

local BaitDropdown = BaitBuyBox:Dropdown({
    Title = "Baits to Buy",
    Flag = "BaitBuySelect",
    Desc = "Pick baits to auto-buy. 🔒 = locked until rebirth.",
    Values = L.BAIT_LABELS,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setBaitSelected(v)
    end,
})

local EquipBaitDropdown -- forward-declared, assigned in the Equip Bait section below

-- re-renders a dropdown's option labels in place, trying whichever refresh
-- method this WindUI build exposes; silently does nothing if none exist,
-- since the background buy logic re-checks rebirth eligibility every pass
-- regardless of what the dropdown currently shows
local function refreshDropdownValues(dropdown, labels)
    if not dropdown then return end
    for _, methodName in ipairs({ "SetValues", "Refresh", "Reload", "UpdateValues" }) do
        local method = dropdown[methodName]
        if type(method) == "function" then
            pcall(method, dropdown, labels)
            break
        end
    end
end

-- re-renders both bait dropdowns' option labels in place after a rebirth
-- (logic.lua rebuilds the label data, then calls this back)
L.setRefreshBaitDropdown(function(labels)
    refreshDropdownValues(BaitDropdown, labels)
    refreshDropdownValues(EquipBaitDropdown, labels)
end)

BaitBuyBox:Dropdown({
    Title = "Buy Amount",
    Flag = "BaitBuyLevel",
    Desc = "How many to buy each time a selected bait runs out.",
    Values = { "20", "40", "60", "Max" },
    Multi = false,
    Value = "20",
    Callback = function(v)
        local picked = pickValue(v)
        if picked == "Max" then
            L.setBaitBuyLevel("max")
        else
            L.setBaitBuyLevel(tonumber(picked) or 20)
        end
    end,
})

BaitBuyBox:Toggle({
    Title = "Auto Buy Bait",
    Flag = "AutoBuyBait",
    Desc = "Rebuys a selected bait to the chosen amount as soon as it runs out.",
    Value = false,
    Callback = function(v)
        L.setBaitBuyRunning(v)
    end,
})

local BaitBuyStatusP = BaitBuyBox:Paragraph({ Title = "Status", Desc = L.getBaitBuyStatus() })
L.onBaitBuyStatus(function(text)
    pcall(function() BaitBuyStatusP:SetDesc(text) end)
end)

local EquipBaitBox = section(Tabs.Shop, "Equip Bait", icon("fish", "anchor", "shopping-bag"))

EquipBaitDropdown = EquipBaitBox:Dropdown({
    Title = "Bait to Use",
    Flag = "EquipBaitSelect",
    Desc = "Pick the bait to equip.",
    Values = L.BAIT_LABELS,
    Multi = false,
    Value = "",
    Callback = function(v)
        local label = pickValue(v)
        local id = L.BAIT_LABEL_TO_ID[label]
        if id then
            L.equipBait(id, label)
        end
    end,
})

local EquipBaitStatusP = EquipBaitBox:Paragraph({ Title = "Status", Desc = L.getEquipBaitStatus() })
L.onEquipBaitStatus(function(text)
    pcall(function() EquipBaitStatusP:SetDesc(text) end)
end)

-- ===== REBIRTH TAB =====
local RebirthBox = section(Tabs.Rebirth, "Auto Rebirth", "refresh-cw")

RebirthBox:Toggle({
    Title = "Auto Rebirth",
    Flag = "AutoRebirth",
    Desc = "Automatically rebirths you when you're ready.",
    Value = false,
    Callback = function(v)
        L.setRebirthRunning(v)
    end,
})

local RebirthStatusP = RebirthBox:Paragraph({ Title = "Status", Desc = L.getRebirthStatus() })
L.onRebirthStatus(function(text)
    pcall(function() RebirthStatusP:SetDesc(text) end)
end)

-- ===== EVENT TAB =====
local TurretBox = section(Tabs.Event, "Auto Turret (Megalodon)", icon("crosshair", "target", "zap"))

TurretBox:Paragraph({
    Title = "How this works",
    Desc = "While THE MEGALODON event is active, automatically enters Turret Mode, aims at the shark, and fires every cooldown as long as it's in range. Leaves on its own once the event ends. Requires Rebirth 2+ (same as the live event).",
})

TurretBox:Toggle({
    Title = "Auto Turret (Megalodon)",
    Flag = "AutoTurretMeg",
    Desc = "Automatically fights the Megalodon event from your Spear Gun's Turret Mode.",
    Value = false,
    Callback = function(v)
        L.setTurretRunning(v)
    end,
})

local TurretStatusP = TurretBox:Paragraph({ Title = "Status", Desc = L.getTurretStatus() })
L.onTurretStatus(function(text)
    pcall(function() TurretStatusP:SetDesc(text) end)
end)

-- ===== QUEST TAB =====
local ContractClaimBox = section(Tabs.Quest, "Auto Claim Contract", icon("clipboard-check", "scroll-text", "check"))

ContractClaimBox:Paragraph({
    Title = "How this works",
    Desc = "Claims finished contracts automatically.",
})

ContractClaimBox:Toggle({
    Title = "Auto Claim Contract",
    Flag = "AutoClaimContract",
    Desc = "Automatically claims finished contracts from the Quests menu.",
    Value = false,
    Callback = function(v)
        L.setContractClaimRunning(v)
    end,
})

local ContractClaimStatusP = ContractClaimBox:Paragraph({ Title = "Status", Desc = L.getContractClaimStatus() })
L.onContractClaimStatus(function(text)
    pcall(function() ContractClaimStatusP:SetDesc(text) end)
end)

local ChallengeClaimBox = section(Tabs.Quest, "Auto Claim Today Challenge", icon("calendar-check", "star", "check"))

ChallengeClaimBox:Paragraph({
    Title = "How this works",
    Desc = "Checks your 3 daily challenge tiers and claims any that are finished but not yet claimed.",
})

ChallengeClaimBox:Toggle({
    Title = "Auto Claim Today Challenge",
    Flag = "AutoClaimChallenge",
    Desc = "Automatically claims finished tiers from Quests > Today.",
    Value = false,
    Callback = function(v)
        L.setChallengeClaimRunning(v)
    end,
})

local ChallengeClaimStatusP = ChallengeClaimBox:Paragraph({ Title = "Status", Desc = L.getChallengeClaimStatus() })
L.onChallengeClaimStatus(function(text)
    pcall(function() ChallengeClaimStatusP:SetDesc(text) end)
end)

local CurrentCallBox = section(Tabs.Quest, "Auto Call Deep Current", icon("waves", "zap", "activity"))

CurrentCallBox:Paragraph({
    Title = "How this works",
    Desc = "Calls the best creature you can afford and catch, one at a time.",
})

CurrentCallBox:Toggle({
    Title = "Auto Call Deep Current",
    Flag = "AutoCallCurrent",
    Desc = "Automatically calls creatures from Quests > Current whenever you have enough charge.",
    Value = false,
    Callback = function(v)
        L.setCurrentCallRunning(v)
    end,
})

local CurrentCallStatusP = CurrentCallBox:Paragraph({ Title = "Status", Desc = L.getCurrentCallStatus() })
L.onCurrentCallStatus(function(text)
    pcall(function() CurrentCallStatusP:SetDesc(text) end)
end)

-- ===== HUB TAB =====
local PotionBuyBox = section(Tabs.Hub, "Potion Shop", icon("flask", "droplet", "shopping-bag"))

PotionBuyBox:Dropdown({
    Title = "Potions to Buy",
    Flag = "PotionBuySelect",
    Desc = "Pick tier(s) to auto-buy when in stock.",
    Values = L.POTION_COMBO_LABELS,
    Multi = true,
    Value = {},
    Callback = function(v)
        L.setPotionComboSelected(v)
    end,
})

PotionBuyBox:Toggle({
    Title = "Auto Buy Potion",
    Flag = "AutoBuyPotion",
    Desc = "Automatically buys any in-stock potion matching the kinds picked above.",
    Value = false,
    Callback = function(v)
        L.setPotionBuyRunning(v)
    end,
})

local PotionBuyStatusP = PotionBuyBox:Paragraph({ Title = "Status", Desc = L.getPotionBuyStatus() })
L.onPotionBuyStatus(function(text)
    pcall(function() PotionBuyStatusP:SetDesc(text) end)
end)

local BlackMarketBox = section(Tabs.Hub, "Black Market", icon("gem", "lock", "package"))

BlackMarketBox:Toggle({
    Title = "Auto Buy Black Market",
    Flag = "AutoBuyBlackMarket",
    Desc = "Buys every affordable item in stock.",
    Value = false,
    Callback = function(v)
        L.setBlackMarketBuyRunning(v)
    end,
})

local BlackMarketStatusP = BlackMarketBox:Paragraph({ Title = "Status", Desc = L.getBlackMarketBuyStatus() })
L.onBlackMarketBuyStatus(function(text)
    pcall(function() BlackMarketStatusP:SetDesc(text) end)
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

-- ===== CONFIG SAVE/LOAD =====
local ConfigBox = section(Tabs.Misc, "Config", "save")
local ConfigStatusP = ConfigBox:Paragraph({
    Title = "Auto-save",
    Desc = "Flagged settings save automatically.",
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
    if _G.NETAFISH_Unloaded == Window then return end
    _G.NETAFISH_Unloaded = Window
    L.unload()
    pcall(function() Window:Destroy() end)
    _G.NETAFISH_Unload = nil
end
_G.NETAFISH_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

-- auto-save
if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
