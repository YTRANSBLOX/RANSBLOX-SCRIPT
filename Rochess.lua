local HUB_NAME = "Ro Chess"
local VERSION  = "v1.2"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"
-- Raw URL of this script. Needed so it relaunches itself after teleports.
local SCRIPT_URL = "https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/Rochess.lua"

-- Re-execute safety: unload the previous instance first
if _G.ROCHESS_Unload then pcall(_G.ROCHESS_Unload) end

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
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
-- GAME (Ro Chess)
-- =====================================================================
local alive = true
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local chessFolder = RS:WaitForChild("Chess", 10)
local clientFolder = RS:WaitForChild("ChessClient", 10)
if not (chessFolder and clientFolder) then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = "Chess game not found. This script only works in Ro Chess.",
        Icon = "x",
        Duration = 5,
    })
    return
end

local okV, VortexBot = pcall(function() return require(chessFolder:WaitForChild("VortexBot", 5)) end)
if not okV then VortexBot = nil end
local okA, app = pcall(function() return require(clientFolder:WaitForChild("App", 5)) end)
if not okA or not app then
    WindUI:Notify({ Title = HUB_NAME, Content = "Couldn't load the chess client.", Icon = "x", Duration = 5 })
    return
end

local httpReq = (syn and syn.request) or http_request or request or (http and http.request)
if not httpReq then
    WindUI:Notify({
        Title = HUB_NAME,
        Content = "No HTTP support in this executor. Cloud engines are unavailable.",
        Icon = "triangle-alert",
        Duration = 6,
    })
end

local START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
local ENGINE_AUTO = "Auto (best available)"
local ENGINE_LIST = { "chess-api.com", "stockfish.online", "Lichess Cloud", "VortexBot" }

local S = {
    running = true,
    mode = "Auto Play",
    engine = ENGINE_AUTO,
    depth = 12,
    thinkTime = 1.5,
    humanize = true,
    quickOpening = true,
    vortexFallback = true,
    vRating = 2800,
    vDepth = 20,
    vTime = 2,
    autoQueue = true,
    queueDelay = 2,
    tcChoice = "Same as last",
    autoExec = true,
}

local busy, lastPly, nextTry = false, -1, 0
local lastSessionSeen = nil
local stats = { played = 0, queued = 0, lastMove = "-", lastEngine = "-", lastEval = "-" }
local statusText = "Running..."
local setStatus = function() end

local function startFenOf(session)
    return session.startFen or (session.engine and session.engine.startFen) or START_FEN
end

------------------------------------------------------------
-- FEN from startFen + UCI moves
------------------------------------------------------------
local function parseFen(fen)
    local parts = string.split(fen, " ")
    local board = {}
    for r = 1, 8 do board[r] = {} end
    local r = 1
    for row in string.gmatch(parts[1], "[^/]+") do
        local f = 1
        for ch in string.gmatch(row, ".") do
            local n = tonumber(ch)
            if n then f = f + n else board[r][f] = ch; f = f + 1 end
        end
        r = r + 1
    end
    return {
        board = board,
        turn = parts[2] or "w",
        castle = parts[3] or "-",
        ep = parts[4] or "-",
        half = tonumber(parts[5]) or 0,
        full = tonumber(parts[6]) or 1,
    }
end

local function sq(s)
    return 9 - tonumber(s:sub(2, 2)), s:byte(1) - 96 -- rank row, file col
end

local function applyMove(pos, uci)
    local r1, f1 = sq(uci:sub(1, 2))
    local r2, f2 = sq(uci:sub(3, 4))
    local promo = uci:sub(5, 5)
    local b = pos.board
    local piece = b[r1][f1]
    if not piece then return end
    local target = b[r2][f2]
    local isPawn = piece:lower() == "p"
    local white = piece == piece:upper()

    if isPawn and f1 ~= f2 and not target then b[r1][f2] = nil end -- en passant
    b[r2][f2] = piece
    b[r1][f1] = nil
    if isPawn and promo ~= "" then
        b[r2][f2] = white and promo:upper() or promo:lower()
    end
    if piece:lower() == "k" and math.abs(f2 - f1) == 2 then -- castling
        if f2 > f1 then b[r2][6] = b[r2][8]; b[r2][8] = nil
        else b[r2][4] = b[r2][1]; b[r2][1] = nil end
    end

    local c = (pos.castle == "-") and "" or pos.castle
    local function rm(chars)
        for ch in chars:gmatch(".") do c = c:gsub(ch, "") end
    end
    if piece == "K" then rm("KQ") elseif piece == "k" then rm("kq") end
    local function touch(r, f)
        if r == 8 and f == 8 then rm("K")
        elseif r == 8 and f == 1 then rm("Q")
        elseif r == 1 and f == 8 then rm("k")
        elseif r == 1 and f == 1 then rm("q") end
    end
    touch(r1, f1); touch(r2, f2)
    pos.castle = (c == "") and "-" or c

    pos.ep = "-"
    if isPawn and math.abs(r2 - r1) == 2 then
        pos.ep = string.char(96 + f1) .. tostring(9 - (r1 + r2) / 2)
    end
    if isPawn or target then pos.half = 0 else pos.half = pos.half + 1 end
    if pos.turn == "b" then pos.full = pos.full + 1 end
    pos.turn = (pos.turn == "w") and "b" or "w"
end

local function toFen(pos)
    local rows = {}
    for r = 1, 8 do
        local s, empty = "", 0
        for f = 1, 8 do
            local p = pos.board[r][f]
            if p then
                if empty > 0 then s = s .. empty; empty = 0 end
                s = s .. p
            else
                empty = empty + 1
            end
        end
        if empty > 0 then s = s .. empty end
        rows[r] = s
    end
    return table.concat(rows, "/") .. " " .. pos.turn .. " " .. pos.castle .. " " .. pos.ep .. " " .. pos.half .. " " .. pos.full
end

local function currentPos(session)
    if type(session.fen) == "string" then return parseFen(session.fen), session.fen end
    local pos = parseFen(startFenOf(session))
    for _, uci in ipairs(session.ucis) do applyMove(pos, uci) end
    return pos, toFen(pos)
end

-- some APIs write castling as king-takes-rook (e1h1); the game wants e1g1
local castleFix = { e1h1 = "e1g1", e1a1 = "e1c1", e8h8 = "e8g8", e8a8 = "e8c8" }
local function normalizeMove(pos, mv)
    local fix = castleFix[mv]
    if fix then
        local r, f = sq(mv:sub(1, 2))
        local p = pos.board[r][f]
        if p and p:lower() == "k" then return fix end
    end
    return mv
end

------------------------------------------------------------
-- ENGINES  (each returns: move, evalText)
------------------------------------------------------------
local function httpJson(req)
    local res = httpReq(req)
    if not res or not res.Body then return nil end
    if res.StatusCode and res.StatusCode >= 400 then return nil end
    local okJ, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
    if okJ and type(data) == "table" then return data end
end

local function fmtEval(v)
    v = tonumber(v)
    if not v then return "?" end
    return string.format("%+.2f", v)
end

local Engines = {}

Engines["chess-api.com"] = function(fen)
    local d = httpJson({
        Url = "https://chess-api.com/v1",
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ fen = fen, depth = math.clamp(S.depth, 1, 18), variants = 1 }),
    })
    if d and type(d.move) == "string" then
        return d.move, d.mate and ("mate " .. tostring(d.mate)) or fmtEval(d.eval)
    end
end

Engines["stockfish.online"] = function(fen)
    local d = httpJson({
        Url = "https://stockfish.online/api/s/v2.php?fen=" .. HttpService:UrlEncode(fen)
            .. "&depth=" .. math.clamp(S.depth, 1, 15),
        Method = "GET",
    })
    if d and d.success and type(d.bestmove) == "string" then
        local mv = d.bestmove:match("bestmove (%S+)")
        return mv, d.mate and ("mate " .. tostring(d.mate)) or fmtEval(d.evaluation)
    end
end

Engines["Lichess Cloud"] = function(fen)
    local d = httpJson({
        Url = "https://lichess.org/api/cloud-eval?multiPv=1&fen=" .. HttpService:UrlEncode(fen),
        Method = "GET",
    })
    local pv = d and d.pvs and d.pvs[1]
    if pv and type(pv.moves) == "string" then
        local mv = pv.moves:match("^(%S+)")
        return mv, pv.mate and ("mate " .. tostring(pv.mate)) or fmtEval((pv.cp or 0) / 100)
    end
end

Engines["VortexBot"] = function(_, session)
    if not VortexBot or not session then return end
    local mv = VortexBot.think(startFenOf(session), table.clone(session.ucis), {
        rating = S.vRating,
        depth = S.vDepth,
        time = S.vTime,
    })
    return mv, "in-game"
end

local function getBestMove(fen, session)
    local order
    if S.engine == ENGINE_AUTO then
        order = ENGINE_LIST
    else
        order = { S.engine }
        if S.vortexFallback and S.engine ~= "VortexBot" then table.insert(order, "VortexBot") end
    end
    for _, name in ipairs(order) do
        local fn = Engines[name]
        if fn and (name == "VortexBot" or httpReq) then
            local okE, mv, info = pcall(fn, fen, session)
            if okE and type(mv) == "string" and #mv >= 4 then return mv, info, name end
        end
    end
end

------------------------------------------------------------
-- AUTO EXECUTE (built in: relaunches the script after every teleport)
------------------------------------------------------------
local Players = game:GetService("Players")
local queueFn = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local function queueSelf()
    if not queueFn then return false, "Executor has no queue_on_teleport" end
    if SCRIPT_URL == "" then return false, "SCRIPT_URL is empty" end
    queueFn(('loadstring(game:HttpGet("%s"))()'):format(SCRIPT_URL))
    return true
end

bind(Players.LocalPlayer.OnTeleport, function()
    if S.autoExec then pcall(queueSelf) end
end)
pcall(queueSelf) -- arm it right away

------------------------------------------------------------
-- PLAY LOOP
------------------------------------------------------------
local function waitThink(t0, ply)
    local target = S.thinkTime
    if S.quickOpening and ply < 8 then target = math.min(target, 0.3) end
    if S.humanize and target > 0 then target = target * (0.6 + math.random() * 0.8) end
    local remain = target - (os.clock() - t0)
    if remain > 0 then task.wait(remain) end
end

local function refreshStatus(text)
    statusText = text or statusText
    setStatus(statusText .. "\nLast: " .. stats.lastMove .. " | " .. stats.lastEngine
        .. " | " .. stats.lastEval .. " | Played: " .. stats.played .. " | Queued: " .. stats.queued)
end

local function step(force)
    local session = app.session
    if not session then return end
    if session ~= lastSessionSeen then -- new game: reset the per-game state
        lastSessionSeen = session
        lastPly = -1
    end
    if busy or session.over then return end
    if not session:isMyTurn() then return end
    if not force and os.clock() < nextTry then return end
    local ply = #session.ucis
    if not force and ply == lastPly then return end

    busy = true
    local t0 = os.clock()
    refreshStatus("Thinking...")

    local pos, fen = currentPos(session)
    local mv, info, name = getBestMove(fen, session)
    if mv then mv = normalizeMove(pos, mv) end

    if not (mv and mv:match("^[a-h][1-8][a-h][1-8][qrbn]?$")) then
        nextTry = os.clock() + 3
        refreshStatus("Engine unavailable, retrying in 3s")
        busy = false
        return
    end

    stats.lastMove, stats.lastEngine, stats.lastEval = mv, name or "?", info or "?"

    if S.mode == "Suggest Only" then
        lastPly = ply
        refreshStatus("Suggestion: " .. mv)
        WindUI:Notify({
            Title = "Best move: " .. mv,
            Content = (name or "?") .. " | eval " .. (info or "?"),
            Icon = "crown",
            Duration = 4,
        })
    else
        waitThink(t0, ply)
        if app.session == session and not session.over and session:isMyTurn() and #session.ucis == ply then
            app.send({ type = "move", id = session.id, uci = mv, ply = ply })
            lastPly = ply
            stats.played = stats.played + 1
            refreshStatus("Played " .. mv)
        else
            refreshStatus("Position changed, recalculating...")
        end
    end
    busy = false
end

task.spawn(function()
    while alive do
        task.wait(0.4)
        if S.running then
            local okS, err = pcall(step, false)
            if not okS then
                busy = false
                nextTry = os.clock() + 3
                warn("[RoChess]", err)
            end
        end
    end
end)

------------------------------------------------------------
-- AUTO QUEUE (starts the next game when one ends)
------------------------------------------------------------
local lastTc = (type(app.selectedTc) == "string" and app.selectedTc) or "3+2"
local lastQueueAt, queuedFor = 0, nil

local function pickTc(session)
    if S.tcChoice ~= "Same as last" then return S.tcChoice end
    if session and session.tc and session.tc.id then lastTc = session.tc.id end
    return lastTc
end

local function isSearching(session)
    return session and session.black and session.black.display == "Searching..."
end

local function queueNow(session)
    local tc = pickTc(session)
    lastQueueAt = os.clock()
    if session and session.over then
        pcall(app.send, { type = "leaveGame" })
        task.wait(0.2)
    end
    pcall(app.send, { type = "queue", tc = tc })
    stats.queued = stats.queued + 1
    refreshStatus("Queued " .. tc)
end

local function queueStep()
    local s = app.session
    local now = os.clock()
    if s and s.over then
        if queuedFor == s and now - lastQueueAt > 15 then queuedFor = nil end -- queue got lost, retry
        if queuedFor ~= s then
            queuedFor = s
            task.wait(S.queueDelay)
            if app.session == s and s.over and S.autoQueue then queueNow(s) end
        end
    elseif (not s or (s.kind == "idle" and not isSearching(s))) and now - lastQueueAt > 10 then
        queueNow(s)
    end
end

task.spawn(function()
    while alive do
        task.wait(1)
        if S.autoQueue then
            local okQ, err = pcall(queueStep)
            if not okQ then warn("[RoChess]", err) end
        end
    end
end)

-- =====================================================================
-- GUI
-- =====================================================================

-- picks the first icon name that really exists in WindUI's icon set
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
Tabs.Home   = Window:Tab({ Title = "Home",   Icon = icon("house", "home"),            IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Auto   = Window:Tab({ Title = "Main",   Icon = icon("crown", "swords", "house"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Engine = Window:Tab({ Title = "Engine", Icon = icon("cpu", "settings", "info"),  IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc   = Window:Tab({ Title = "Misc",   Icon = icon("info"),                     IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

-- sections start closed
local function section(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = false })
end

-- sections start open
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
local PlayBox = openSection(Tabs.Auto, "Auto Play", "crown")

PlayBox:Toggle({
    Title = "Auto Play",
    Desc = "Automatically plays on your turn.",
    Value = true,
    Callback = function(v)
        S.running = v
        if v then lastPly = -1; nextTry = 0 end
        refreshStatus(v and "Running..." or "Stopped")
    end,
})

PlayBox:Dropdown({
    Title = "Mode",
    Flag = "PlayMode",
    Desc = "Auto Play plays for you. Suggest Only just shows the best move.",
    Values = { "Auto Play", "Suggest Only" },
    Value = "Auto Play",
    Callback = function(v)
        S.mode = pickValue(v)
        lastPly = -1
    end,
})

PlayBox:Button({
    Title = "Run Once",
    Desc = "Plays (or suggests) one move for the current turn right now.",
    Icon = "play",
    Callback = function()
        task.spawn(function()
            local okS, err = pcall(step, true)
            if not okS then busy = false; warn("[RoChess]", err) end
        end)
    end,
})

local StatusP = PlayBox:Paragraph({ Title = "Status", Desc = statusText })
setStatus = function(text)
    pcall(function() StatusP:SetDesc(text) end)
end

local TimeBox = openSection(Tabs.Auto, "Timing", "clock")

TimeBox:Slider({
    Title = "Think Time", Flag = "ThinkTime",
    Desc = "Delay before each move, in seconds.", Step = 0.1,
    Value = { Min = 0, Max = 15, Default = 1.5 },
    Callback = function(v) S.thinkTime = tonumber(v) or 1.5 end,
})
TimeBox:Toggle({
    Title = "Humanize", Desc = "Adds slight variation to the delay.",
    Value = true,
    Callback = function(v) S.humanize = v end,
})
TimeBox:Toggle({
    Title = "Quick Opening", Desc = "Keeps the delay short for the first few moves.",
    Value = true,
    Callback = function(v) S.quickOpening = v end,
})

local FarmBox = openSection(Tabs.Auto, "Auto Farm", "repeat")

FarmBox:Toggle({
    Title = "Auto Queue",
    Desc = "Queues the next game when one ends.",
    Value = true,
    Callback = function(v)
        S.autoQueue = v
        queuedFor = nil
        refreshStatus(v and "Auto Queue on" or "Auto Queue off")
    end,
})

FarmBox:Dropdown({
    Title = "Time Control",
    Flag = "TimeControl",
    Desc = "Time control to queue for.",
    Values = { "Same as last", "1+0", "3+0", "3+2", "5+0", "10+0" },
    Value = "Same as last",
    Callback = function(v) S.tcChoice = pickValue(v) end,
})

FarmBox:Slider({
    Title = "Queue Delay", Flag = "QueueDelay",
    Desc = "Pause after a game ends before queueing again.", Step = 0.5,
    Value = { Min = 0, Max = 15, Default = 2 },
    Callback = function(v) S.queueDelay = tonumber(v) or 2 end,
})

-- ===== ENGINE TAB =====
local EngineBox = openSection(Tabs.Engine, "Engine", "cpu")

EngineBox:Dropdown({
    Title = "Engine",
    Flag = "EngineChoice",
    Desc = "Where moves are calculated. Auto selects the best available option.",
    Values = { ENGINE_AUTO, "chess-api.com", "stockfish.online", "Lichess Cloud", "VortexBot" },
    Value = ENGINE_AUTO,
    Callback = function(v) S.engine = pickValue(v) end,
})
EngineBox:Slider({
    Title = "Depth", Flag = "EngineDepth",
    Desc = "Search depth for cloud engines.", Step = 1,
    Value = { Min = 1, Max = 18, Default = 12 },
    Callback = function(v) S.depth = math.floor(tonumber(v) or 12) end,
})
EngineBox:Toggle({
    Title = "Fallback to VortexBot", Desc = "Use the built-in bot if a cloud engine is unavailable.",
    Value = true,
    Callback = function(v) S.vortexFallback = v end,
})
EngineBox:Button({
    Title = "Test Engine",
    Desc = "Runs a quick test and shows the result and response time.",
    Icon = "activity",
    Callback = function()
        task.spawn(function()
            local t = os.clock()
            local okT, mv, info, name = pcall(getBestMove, START_FEN, app.session)
            local dt = os.clock() - t
            if okT and mv then
                WindUI:Notify({
                    Title = "Engine Test",
                    Content = string.format("%s: %s (%s) in %.2fs", name or "?", mv, info or "?", dt),
                    Icon = "check", Duration = 4,
                })
            else
                WindUI:Notify({
                    Title = "Engine Test",
                    Content = "All engines failed. Check your connection.",
                    Icon = "x", Duration = 4,
                })
            end
        end)
    end,
})
EngineBox:Paragraph({
    Title = "Cloud engines",
    Desc = "Cloud engines run on external services (chess-api.com, stockfish.online, Lichess). "
        .. "Only the board position (FEN) is sent in the request. VortexBot runs locally inside the game.",
})

local VortexBox = section(Tabs.Engine, "VortexBot (in-game)", "bot")

VortexBox:Slider({
    Title = "Rating", Flag = "VortexRating", Desc = "Playing strength.", Step = 50,
    Value = { Min = 800, Max = 3200, Default = 2800 },
    Callback = function(v) S.vRating = math.floor(tonumber(v) or 2800) end,
})
VortexBox:Slider({
    Title = "Depth", Flag = "VortexDepth", Desc = "Search depth.", Step = 1,
    Value = { Min = 1, Max = 30, Default = 20 },
    Callback = function(v) S.vDepth = math.floor(tonumber(v) or 20) end,
})
VortexBox:Slider({
    Title = "Time", Flag = "VortexTime", Desc = "Maximum thinking time, in seconds.", Step = 0.5,
    Value = { Min = 0.5, Max = 10, Default = 2 },
    Callback = function(v) S.vTime = tonumber(v) or 2 end,
})

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
    Desc = "Settings are saved automatically and restored on your next launch.",
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
    if _G.ROCHESS_Unloaded == Window then return end
    _G.ROCHESS_Unloaded = Window
    alive = false
    S.running = false
    S.autoQueue = false
    S.autoExec = false
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.ROCHESS_Unload = nil
end
_G.ROCHESS_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

-- auto-save: register the Flag'd elements + autoload last saved values
if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end

if SCRIPT_URL == "" then
    WindUI:Notify({
        Title = "Auto Execute",
        Content = "SCRIPT_URL is empty, so the script won't relaunch after a teleport.",
        Icon = "triangle-alert",
        Duration = 6,
    })
end
