-- Ransblox Dump: remote + attribute dumper with a WindUI front end.
-- Reads what the game does and exports it as plain text (clipboard + file),
-- so the data can be pasted straight into a new script project.

local TOOL    = "Ransblox Dump"
local VERSION = "v1.0"

-- Re-execute safety: unload the previous instance first
if _G.RANSDUMP_Unload then pcall(_G.RANSDUMP_Unload) end

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then return end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local alive = true
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- HELPERS
-- =====================================================================
local t0 = os.clock()

local function icon(...)
    for _, name in ipairs({ ... }) do
        local okI, found = pcall(WindUI.Creator.Icon, name)
        if okI and found then return name end
    end
    return "info"
end

local function notify(title, content, ic)
    pcall(function()
        WindUI:Notify({ Title = title, Content = content, Icon = ic or "check", Duration = 4 })
    end)
end

local function safePath(inst)
    local okP, p = pcall(inst.GetFullName, inst)
    return okP and p or tostring(inst)
end

-- strips digits so Plot1 / Plot2 / Customer12 collapse into one group
local function norm(p) return (p:gsub("%d+", "#")) end

-- value -> short readable text (depth and size limited)
local function ser(v, depth, short)
    local t = typeof(v)
    if t == "string" then
        local s = v
        local lim = short and 100 or 200
        if #s > lim then s = s:sub(1, lim) .. "..." end
        s = s:gsub("\n", "\\n")
        return '"' .. s .. '"'
    elseif t == "number" then
        if short and v ~= math.floor(v) then return (string.format("%.3f", v):gsub("0+$", ""):gsub("%.$", "")) end
        return tostring(v)
    elseif t == "boolean" or t == "nil" then
        return tostring(v)
    elseif short and t == "Vector3" then
        return string.format("V3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
    elseif short and t == "Vector2" then
        return string.format("V2(%.2f, %.2f)", v.X, v.Y)
    elseif short and t == "CFrame" then
        local p = v.Position
        return string.format("CF(%.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
    elseif short and t == "Color3" then
        return string.format("C3(%.2f, %.2f, %.2f)", v.R, v.G, v.B)
    elseif t == "Instance" then
        return "<" .. v.ClassName .. ":" .. safePath(v) .. ">"
    elseif t == "table" then
        if depth >= 3 then return "{...}" end
        local len = #v
        local total = 0
        for _ in pairs(v) do
            total = total + 1
            if total > 200 then break end
        end
        local isArr = len > 0 and total == len
        local parts, n = {}, 0
        for k, val in pairs(v) do
            n = n + 1
            if n > 12 then
                parts[#parts + 1] = "..."
                break
            end
            if isArr then
                parts[#parts + 1] = ser(val, depth + 1, short)
            else
                local ks = type(k) == "string" and k or ("[" .. ser(k, depth + 1, short) .. "]")
                parts[#parts + 1] = ks .. "=" .. ser(val, depth + 1, short)
            end
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return t .. ":" .. tostring(v)
end

-- =====================================================================
-- STATE
-- =====================================================================
local Spy = { on = false, incoming = false }
local Watch = { on = false }
local Ignored = {}
local AttrFilter = ""
local ExcludePaths = {}   -- lowercase substrings: instances whose path contains one are skipped
local ExcludeAttrs = { "rbx" }   -- lowercase prefixes: attributes starting with one are ignored

local function parseList(text)
    local list = {}
    for item in tostring(text):gmatch("[^,]+") do
        item = item:gsub("^%s+", ""):gsub("%s+$", ""):lower()
        if item ~= "" then list[#list + 1] = item end
    end
    return list
end

local function pathExcluded(pathLower)
    for _, token in ipairs(ExcludePaths) do
        if pathLower:find(token, 1, true) then return true end
    end
    return false
end

local function attrExcluded(name)
    local n = name:lower()
    for _, prefix in ipairs(ExcludeAttrs) do
        if n:sub(1, #prefix) == prefix then return true end
    end
    return false
end

-- attribute table without the excluded keys (nil when nothing is left)
local function cleanAttrs(attrs)
    local out, any = {}, false
    for k, v in pairs(attrs) do
        if not attrExcluded(k) then
            out[k] = v
            any = true
        end
    end
    return any and out or nil
end

local Remotes, remoteOrder, totalCalls = {}, {}, 0
local AttrRecs, attrOrder, attrChanges = {}, {}, 0

local Timeline, TL_MAX = {}, 300
local function tl(line)
    Timeline[#Timeline + 1] = string.format("[%.1f] %s", os.clock() - t0, line)
    if #Timeline > TL_MAX then table.remove(Timeline, 1) end
end

-- =====================================================================
-- REMOTE SPY
-- =====================================================================
local function recordRemote(dir, remote, method, args, tag)
    if Ignored[remote.Name:lower()] then return end
    local path = safePath(remote)
    local key = dir .. "|" .. path
    local rec = Remotes[key]
    if not rec then
        rec = { dir = dir, path = path, method = method, count = 0, samples = {}, seen = {}, lastPush = 0 }
        Remotes[key] = rec
        remoteOrder[#remoteOrder + 1] = key
    end
    rec.count = rec.count + 1
    totalCalls = totalCalls + 1

    local now = os.clock()
    -- spammy remote that already has its samples: just count it
    if rec.count > 50 and #rec.samples >= 6 and now - rec.lastPush < 1 then return end

    local parts = {}
    for i = 1, args.n do parts[i] = ser(args[i], 0) end
    local argStr = table.concat(parts, ", ")
    if #argStr > 400 then argStr = argStr:sub(1, 400) .. "..." end

    if #rec.samples < 6 and not rec.seen[argStr] then
        rec.seen[argStr] = true
        rec.samples[#rec.samples + 1] = argStr
    end
    if rec.count <= 15 or now - rec.lastPush >= 1 then
        rec.lastPush = now
        tl(string.format("%-3s %s:%s(%s)%s", dir, path, method, argStr, tag or ""))
    end
end

local hooked = false
local function installHook()
    if hooked then return true end
    if not (hookmetamethod and getnamecallmethod and newcclosure) then return false end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if alive and Spy.on then
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local okC, cn = pcall(function() return self.ClassName end)
                if okC and (cn == "RemoteEvent" or cn == "RemoteFunction" or cn == "UnreliableRemoteEvent") then
                    local tag = ""
                    if checkcaller and checkcaller() then tag = "  [script]" end
                    pcall(recordRemote, "OUT", self, method, table.pack(...), tag)
                end
            end
        end
        return old(self, ...)
    end))
    hooked = true
    return true
end

-- server -> client (no hook needed, plain OnClientEvent connections)
local inConns, inAdded = {}, nil
local function hookIncoming(remote)
    if inConns[remote] or remote.ClassName ~= "RemoteEvent" then return end
    local okC, c = pcall(function()
        return remote.OnClientEvent:Connect(function(...)
            if alive and Spy.incoming then pcall(recordRemote, "IN", remote, "OnClientEvent", table.pack(...)) end
        end)
    end)
    if okC then inConns[remote] = c end
end

local function setIncoming(on)
    Spy.incoming = on
    if on then
        for _, d in ipairs(RS:GetDescendants()) do hookIncoming(d) end
        if not inAdded then
            inAdded = RS.DescendantAdded:Connect(function(d) hookIncoming(d) end)
        end
    else
        for r, c in pairs(inConns) do
            pcall(function() c:Disconnect() end)
            inConns[r] = nil
        end
        if inAdded then
            inAdded:Disconnect()
            inAdded = nil
        end
    end
end

-- =====================================================================
-- ATTRIBUTE WATCHER
-- =====================================================================
local function recordAttr(d, name)
    if attrExcluded(name) then return end
    local okV, v = pcall(d.GetAttribute, d, name)
    if not okV then return end
    local path = safePath(d)
    local parentPath = d.Parent and safePath(d.Parent) or ""
    local key = d.ClassName .. "|" .. norm(parentPath) .. "|" .. name
    local rec = AttrRecs[key]
    if not rec then
        rec = { name = name, example = path, count = 0, samples = {}, seen = {}, lastPush = 0 }
        AttrRecs[key] = rec
        attrOrder[#attrOrder + 1] = key
    end
    rec.count = rec.count + 1
    attrChanges = attrChanges + 1

    local vs = ser(v, 1, true)
    if #vs > 200 then vs = vs:sub(1, 200) .. "..." end
    if #rec.samples < 6 and not rec.seen[vs] then
        rec.seen[vs] = true
        rec.samples[#rec.samples + 1] = vs
    end
    local now = os.clock()
    if rec.count <= 10 or now - rec.lastPush >= 1 then
        rec.lastPush = now
        tl(string.format("ATTR %s.%s = %s", path, name, vs))
    end
end

local watchConns = setmetatable({}, { __mode = "k" })
local watchAdded = {}

local function watchInst(d)
    if watchConns[d] then return end
    local okA, attrs = pcall(d.GetAttributes, d)
    if not (okA and next(attrs)) then return end
    if not cleanAttrs(attrs) then return end
    local pl = safePath(d):lower()
    local filter = AttrFilter:lower()
    if filter ~= "" and not pl:find(filter, 1, true) then return end
    if pathExcluded(pl) then return end
    local okC, c = pcall(function()
        return d.AttributeChanged:Connect(function(name)
            if alive and Watch.on then pcall(recordAttr, d, name) end
        end)
    end)
    if okC then watchConns[d] = c end
end

local function setWatch(on)
    Watch.on = on
    if on then
        task.spawn(function()
            local n = 0
            for _, root in ipairs({ workspace, RS }) do
                for _, d in ipairs(root:GetDescendants()) do
                    if not (alive and Watch.on) then return end
                    n = n + 1
                    if n % 600 == 0 then task.wait() end
                    watchInst(d)
                end
            end
        end)
        if #watchAdded == 0 then
            for _, root in ipairs({ workspace, RS }) do
                watchAdded[#watchAdded + 1] = root.DescendantAdded:Connect(function(d)
                    task.delay(0.3, function()
                        if alive and Watch.on then watchInst(d) end
                    end)
                end)
            end
        end
    else
        for d, c in pairs(watchConns) do
            pcall(function() c:Disconnect() end)
            watchConns[d] = nil
        end
        for i, c in ipairs(watchAdded) do
            pcall(function() c:Disconnect() end)
            watchAdded[i] = nil
        end
    end
end

-- =====================================================================
-- DUMP BUILDERS
-- =====================================================================
local gameName
local function header(kind)
    if not gameName then
        gameName = "Unknown"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
    end
    return table.concat({
        "== " .. TOOL .. " " .. VERSION .. " (" .. kind .. ") ==",
        "Game: " .. gameName,
        "PlaceId: " .. tostring(game.PlaceId) .. "   GameId: " .. tostring(game.GameId),
        "Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
    }, "\n")
end

local function buildRemoteList()
    local rows, n = {}, 0
    for _, root in ipairs({ RS, workspace }) do
        for _, d in ipairs(root:GetDescendants()) do
            n = n + 1
            if n % 800 == 0 then task.wait() end
            local c = d.ClassName
            if c == "RemoteEvent" or c == "RemoteFunction" or c == "UnreliableRemoteEvent" then
                rows[#rows + 1] = string.format("%-22s %s", c, safePath(d))
            end
        end
    end
    table.sort(rows)
    return "== REMOTE LIST (" .. #rows .. ") ==\n" .. table.concat(rows, "\n")
end

local function buildSpySummary()
    if #remoteOrder == 0 then return "" end
    local recs = {}
    for _, k in ipairs(remoteOrder) do recs[#recs + 1] = Remotes[k] end
    table.sort(recs, function(a, b) return a.count > b.count end)
    local out = { string.format("== REMOTE CALLS (%d remotes, %d calls) ==", #recs, totalCalls) }
    for _, r in ipairs(recs) do
        out[#out + 1] = string.format("%-3s x%d  %s:%s", r.dir, r.count, r.path, r.method)
        for _, s in ipairs(r.samples) do out[#out + 1] = "      (" .. s .. ")" end
    end
    return table.concat(out, "\n")
end

local MAX_ATTR_CHARS = 150000

local function buildAttrDump()
    local filter = AttrFilter:lower()
    local groups, order = {}, {}
    local n, total = 0, 0
    for _, root in ipairs({ workspace, RS }) do
        for _, d in ipairs(root:GetDescendants()) do
            n = n + 1
            if n % 600 == 0 then task.wait() end
            local okA, raw = pcall(d.GetAttributes, d)
            local attrs = okA and next(raw) and cleanAttrs(raw) or nil
            if attrs then
                local path = safePath(d)
                local pl = path:lower()
                if (filter == "" or pl:find(filter, 1, true)) and not pathExcluded(pl) then
                    total = total + 1
                    local keys = {}
                    for k in pairs(attrs) do keys[#keys + 1] = k end
                    table.sort(keys)
                    local parts = {}
                    for _, k in ipairs(keys) do parts[#parts + 1] = k .. "=" .. ser(attrs[k], 1, true) end
                    local vals = table.concat(parts, ", ")
                    if #vals > 500 then vals = vals:sub(1, 500) .. "..." end

                    local parentPath = d.Parent and safePath(d.Parent) or ""
                    local gk = d.ClassName .. "|" .. norm(parentPath) .. "|" .. table.concat(keys, ",")
                    local g = groups[gk]
                    if not g then
                        g = { count = 0, ex = {} }
                        groups[gk] = g
                        order[#order + 1] = gk
                    end
                    g.count = g.count + 1
                    if #g.ex < 3 then
                        g.ex[#g.ex + 1] = string.format("%s [%s]\n    { %s }", path, d.ClassName, vals)
                    end
                end
            end
        end
    end

    local notes = {}
    if filter ~= "" then notes[#notes + 1] = "filter: " .. filter end
    if #ExcludePaths > 0 then notes[#notes + 1] = "skip paths: " .. table.concat(ExcludePaths, " ") end
    if #ExcludeAttrs > 0 then notes[#notes + 1] = "skip attrs: " .. table.concat(ExcludeAttrs, " ") end
    local out = { string.format("== ATTRIBUTES (%d instances, %d groups%s) ==", total, #order,
        #notes > 0 and (", " .. table.concat(notes, "; ")) or "") }

    local size, shown = #out[1], 0
    for _, gk in ipairs(order) do
        local g = groups[gk]
        local block = {}
        for _, e in ipairs(g.ex) do block[#block + 1] = e end
        if g.count > #g.ex then block[#block + 1] = "  ... +" .. (g.count - #g.ex) .. " similar" end
        local text = table.concat(block, "\n")
        if size + #text > MAX_ATTR_CHARS then
            out[#out + 1] = string.format("... size limit reached, %d of %d groups shown. Use the path filter or exclude lists to narrow it down.", shown, #order)
            break
        end
        out[#out + 1] = text
        size = size + #text + 1
        shown = shown + 1
    end
    return table.concat(out, "\n")
end

local function buildWatchSummary()
    if #attrOrder == 0 then return "" end
    local recs = {}
    for _, k in ipairs(attrOrder) do recs[#recs + 1] = AttrRecs[k] end
    table.sort(recs, function(a, b) return a.count > b.count end)
    local out = { string.format("== ATTRIBUTE CHANGES (%d keys, %d changes) ==", #recs, attrChanges) }
    for _, r in ipairs(recs) do
        out[#out + 1] = string.format("x%d  %s.%s", r.count, r.example, r.name)
        out[#out + 1] = "      values: " .. table.concat(r.samples, " | ")
    end
    return table.concat(out, "\n")
end

local function buildTimeline()
    if #Timeline == 0 then return "" end
    return "== TIMELINE (last " .. #Timeline .. ") ==\n" .. table.concat(Timeline, "\n")
end

-- =====================================================================
-- EXPORT
-- =====================================================================
local lastDump = ""
local busy = false

local function export(text, label)
    lastDump = text
    local lines = select(2, text:gsub("\n", "\n")) + 1
    local copied = false
    if setclipboard then copied = pcall(setclipboard, text) end

    local saved
    if writefile then
        pcall(function()
            if makefolder and not (isfolder and isfolder("RansDump")) then makefolder("RansDump") end
        end)
        local name = string.format("RansDump/%s_%s.txt", label, os.date("%H%M%S"))
        if pcall(writefile, name, text) then saved = name end
    end

    local msg = lines .. " lines. "
    if copied then msg = msg .. "Copied to clipboard. " end
    if saved then msg = msg .. "Saved to " .. saved end
    if not copied and not saved then msg = msg .. "Executor can't copy or save files." end
    notify("Dump ready", msg)
end

local function runDump(kind)
    if busy then
        notify(TOOL, "A dump is already running.", "x")
        return
    end
    busy = true
    task.spawn(function()
        local okD, err = pcall(function()
            local parts = { header(kind) }
            local function add(s) if s and s ~= "" then parts[#parts + 1] = s end end
            if kind == "remotes" or kind == "all" then
                add(buildRemoteList())
                add(buildSpySummary())
            end
            if kind == "attributes" or kind == "all" then
                add(buildAttrDump())
                add(buildWatchSummary())
            end
            if kind == "all" then add(buildTimeline()) end
            export(table.concat(parts, "\n\n"), kind)
        end)
        busy = false
        if not okD then notify("Dump failed", tostring(err), "x") end
    end)
end


-- generic background job: builds a text, then exports it
local Job = { cancel = false }
local function runJob(label, builder)
    if busy then
        notify(TOOL, "A dump is already running.", "x")
        return
    end
    busy = true
    Job.cancel = false
    task.spawn(function()
        local okD, err = pcall(function()
            local body = builder()
            if body and body ~= "" then export(header(label) .. "\n\n" .. body, label) end
        end)
        busy = false
        if not okD then notify("Dump failed", tostring(err), "x") end
    end)
end

-- =====================================================================
-- SCRIPT DUMP (list / decompile / search / module values)
-- =====================================================================
local ScriptInclude = {}
local ScriptExclude = parseList("playermodule, chatscript, bubblechat, rbxcharactersounds")
local ScriptNeedle = "FireServer"
local sstatus = function() end

local MAX_SRC_CHARS = 600000
local MAX_HIT_CHARS = 150000
local MAX_MOD_CHARS = 200000

local function capText()
    local function yn(f) return f and "yes" or "no" end
    return string.format("decompile: %s • getscripts: %s • getloadedmodules: %s",
        yn(decompile), yn(getscripts), yn(getloadedmodules))
end

local function scriptMatch(pathLower)
    for _, t in ipairs(ScriptExclude) do
        if pathLower:find(t, 1, true) then return false end
    end
    if #ScriptInclude == 0 then return true end
    for _, t in ipairs(ScriptInclude) do
        if pathLower:find(t, 1, true) then return true end
    end
    return false
end

-- every LocalScript / ModuleScript the client can see (also nil-parented ones when the executor allows)
local function collectScripts()
    local list, seen = {}, {}
    local function add(inst)
        if seen[inst] then return end
        local okC, cn = pcall(function() return inst.ClassName end)
        if okC and (cn == "LocalScript" or cn == "ModuleScript") then
            seen[inst] = true
            list[#list + 1] = inst
        end
    end
    if getscripts then
        pcall(function() for _, x in ipairs(getscripts()) do add(x) end end)
    end
    if getloadedmodules then
        pcall(function() for _, x in ipairs(getloadedmodules()) do add(x) end end)
    end
    local n = 0
    local roots = {
        RS, game:GetService("ReplicatedFirst"), game:GetService("StarterPlayer"),
        game:GetService("StarterGui"), game:GetService("StarterPack"), workspace, lp,
    }
    for _, root in ipairs(roots) do
        for _, d in ipairs(root:GetDescendants()) do
            n = n + 1
            if n % 800 == 0 then task.wait() end
            add(d)
        end
    end
    local out = {}
    for _, inst in ipairs(list) do
        local path = safePath(inst)
        if scriptMatch(path:lower()) then out[#out + 1] = { inst = inst, path = path } end
    end
    table.sort(out, function(a, b) return a.path < b.path end)
    return out
end

local srcCache, cacheChars = setmetatable({}, { __mode = "k" }), 0
local function getSource(inst)
    local cached = srcCache[inst]
    if cached then return cached end
    local okD, res = pcall(decompile, inst)
    local text
    if okD and type(res) == "string" then
        text = res
    else
        text = "-- decompile failed: " .. tostring(res)
    end
    if #text > 80000 then text = text:sub(1, 80000) .. "\n-- [truncated]" end
    if cacheChars < 6000000 then
        srcCache[inst] = text
        cacheChars = cacheChars + #text
    end
    return text
end

local function buildScriptList()
    local items = collectScripts()
    local loaded = {}
    if getloadedmodules then
        pcall(function() for _, m in ipairs(getloadedmodules()) do loaded[m] = true end end)
    end
    local out = { string.format("== SCRIPTS (%d) ==  %s", #items, capText()) }
    for _, it in ipairs(items) do
        out[#out + 1] = string.format("%-12s %-8s %s", it.inst.ClassName, loaded[it.inst] and "[loaded]" or "", it.path)
    end
    sstatus(string.format("Listed %d scripts", #items))
    return table.concat(out, "\n")
end

local function buildDecompile()
    if not decompile then return "-- This executor has no decompile function." end
    local items = collectScripts()
    local out = { string.format("== DECOMPILED SCRIPTS (%d matches) ==", #items) }
    local size, done = 0, 0
    local skipped = {}
    for i, it in ipairs(items) do
        if Job.cancel or not alive then
            out[#out + 1] = "\n-- stopped by user"
            break
        end
        local src = getSource(it.inst)
        local block = string.format("\n-- ===== %s [%s] =====\n%s", it.path, it.inst.ClassName, src)
        if size + #block > MAX_SRC_CHARS then
            for j = i, #items do skipped[#skipped + 1] = items[j].path end
            break
        end
        out[#out + 1] = block
        size = size + #block
        done = done + 1
        if done % 4 == 0 then
            sstatus(string.format("Decompiling %d / %d", i, #items))
            task.wait()
        end
    end
    if #skipped > 0 then
        out[#out + 1] = string.format("\n-- size limit reached, %d scripts not included (narrow the include filter):", #skipped)
        for i, p in ipairs(skipped) do
            if i > 150 then
                out[#out + 1] = "--   ..."
                break
            end
            out[#out + 1] = "--   " .. p
        end
    end
    sstatus(string.format("Done: %d scripts decompiled", done))
    return table.concat(out, "\n")
end

local function buildSearch()
    if not decompile then return "-- This executor has no decompile function." end
    local needle = ScriptNeedle:lower()
    if needle == "" then return "-- Enter a search text first." end
    local items = collectScripts()
    local out = { "" }
    local size, hits, capped = 0, 0, false
    for i, it in ipairs(items) do
        if Job.cancel or not alive then
            out[#out + 1] = "-- stopped by user"
            break
        end
        local src = getSource(it.inst)
        if src and src:lower():find(needle, 1, true) then
            local lines = {}
            for line in (src .. "\n"):gmatch("([^\n]*)\n") do lines[#lines + 1] = line end
            local perScript = 0
            for ln, line in ipairs(lines) do
                if line:lower():find(needle, 1, true) then
                    perScript = perScript + 1
                    if perScript > 30 then
                        out[#out + 1] = "   ... more hits in " .. it.path
                        break
                    end
                    local chunk = { string.format("%s:%d", it.path, ln) }
                    for k = math.max(1, ln - 1), math.min(#lines, ln + 2) do
                        local t = lines[k]:gsub("^%s+", "")
                        if #t > 200 then t = t:sub(1, 200) .. "..." end
                        chunk[#chunk + 1] = (k == ln and "  > " or "    ") .. t
                    end
                    local text = table.concat(chunk, "\n")
                    out[#out + 1] = text
                    size = size + #text + 1
                    hits = hits + 1
                    if size > MAX_HIT_CHARS then
                        capped = true
                        break
                    end
                end
            end
        end
        if capped then break end
        if i % 8 == 0 then
            sstatus(string.format("Searching %d / %d (%d hits)", i, #items, hits))
            task.wait()
        end
    end
    if capped then out[#out + 1] = "-- size limit reached, narrow the search text or the include filter" end
    out[1] = string.format('== SEARCH "%s" in %d scripts: %d hits ==', ScriptNeedle, #items, hits)
    sstatus(string.format("Done: %d hits", hits))
    return table.concat(out, "\n")
end

-- values returned by already-loaded ModuleScripts (configs, prices, remote names...)
local function fname(f)
    local okI, name = pcall(debug.info, f, "n")
    if okI and type(name) == "string" and name ~= "" then return name end
    return "anonymous"
end

local function modTable(t, depth, seen)
    if seen[t] then return "<cycle>" end
    if depth > 4 then return "{...}" end
    seen[t] = true
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    pcall(table.sort, keys, function(a, b) return tostring(a) < tostring(b) end)
    local pad = string.rep("  ", depth + 1)
    local lines = {}
    for n, k in ipairs(keys) do
        if n > 60 then
            lines[#lines + 1] = pad .. "..."
            break
        end
        local val = t[k]
        local ks = type(k) == "string" and k or ("[" .. tostring(k) .. "]")
        local vs
        if type(val) == "table" then
            vs = modTable(val, depth + 1, seen)
        elseif type(val) == "function" then
            vs = "<function " .. fname(val) .. ">"
        else
            vs = ser(val, 1, true)
        end
        lines[#lines + 1] = pad .. ks .. " = " .. vs
    end
    seen[t] = nil
    if #lines == 0 then return "{}" end
    return "{\n" .. table.concat(lines, "\n") .. "\n" .. string.rep("  ", depth) .. "}"
end

local function buildModules()
    if not getloadedmodules then return "-- This executor has no getloadedmodules function." end
    local items = {}
    pcall(function()
        for _, m in ipairs(getloadedmodules()) do
            local path = safePath(m)
            if m.ClassName == "ModuleScript" and scriptMatch(path:lower()) then
                items[#items + 1] = { inst = m, path = path }
            end
        end
    end)
    table.sort(items, function(a, b) return a.path < b.path end)
    local out = { string.format("== MODULE VALUES (%d loaded modules) ==", #items) }
    local size, done = 0, 0
    for i, it in ipairs(items) do
        if Job.cancel or not alive then
            out[#out + 1] = "\n-- stopped by user"
            break
        end
        local okR, val = pcall(require, it.inst)
        local body
        if not okR then
            body = "<require failed: " .. tostring(val) .. ">"
        elseif type(val) == "table" then
            local okS, res = pcall(modTable, val, 0, {})
            body = okS and res or ("<could not read: " .. tostring(res) .. ">")
        elseif type(val) == "function" then
            body = "<function " .. fname(val) .. ">"
        else
            body = ser(val, 0, true)
        end
        if #body > 8000 then body = body:sub(1, 8000) .. "\n... [truncated]" end
        local block = "\n-- ===== " .. it.path .. " =====\n" .. body
        if size + #block > MAX_MOD_CHARS then
            out[#out + 1] = "\n-- size limit reached, use the include filter to narrow it down"
            break
        end
        out[#out + 1] = block
        size = size + #block
        done = done + 1
        if done % 5 == 0 then
            sstatus(string.format("Reading modules %d / %d", i, #items))
            task.wait()
        end
    end
    sstatus(string.format("Done: %d modules", done))
    return table.concat(out, "\n")
end

local function clearLogs()
    Remotes, remoteOrder, totalCalls = {}, {}, 0
    AttrRecs, attrOrder, attrChanges = {}, {}, 0
    Timeline = {}
    notify(TOOL, "Logs cleared.")
end

-- =====================================================================
-- GUI
-- =====================================================================
local Window = WindUI:CreateWindow({
    Title = TOOL,
    Author = "Ransblox Scripts",
    Icon = "youtube",
    NewElements = true,
    Size = UDim2.fromOffset(560, 360),
    Radius = 20,
    ElementsRadius = 16,
    User = { Enabled = true },
    Topbar = { Height = 44, ButtonsType = "Mac" },
    OpenButton = {
        Title = TOOL,
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
    },
    ToggleKey = Enum.KeyCode.RightControl,
})

Window:Tag({ Title = VERSION, Icon = "youtube", Color = Color3.fromHex("#FF8200"), Border = true })

local Tabs = {}
Tabs.Spy = Window:Tab({ Title = "Remote Spy", Icon = icon("radio", "activity", "eye") })
Tabs.Attr = Window:Tab({ Title = "Attributes", Icon = icon("tag", "list", "database") })
Tabs.Scripts = Window:Tab({ Title = "Scripts", Icon = icon("file-code", "code", "scroll-text") })
Tabs.Export = Window:Tab({ Title = "Export", Icon = icon("download", "save", "file") })

local function openSection(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = true })
end

local function setDesc(paragraph, text)
    pcall(function() paragraph:SetDesc(text) end)
end

-- ===== REMOTE SPY TAB =====
local SpyBox = openSection(Tabs.Spy, "Remote Spy", "radio")
SpyBox:Toggle({
    Title = "Log client → server",
    Desc = "Records every FireServer / InvokeServer call with its arguments.",
    Value = false,
    Callback = function(v)
        if v and not installHook() then
            notify(TOOL, "This executor has no hookmetamethod. Only server → client logging will work.", "x")
        end
        Spy.on = v
    end,
})
SpyBox:Toggle({
    Title = "Log server → client",
    Desc = "Records OnClientEvent for every RemoteEvent in ReplicatedStorage.",
    Value = false,
    Callback = function(v) setIncoming(v) end,
})
SpyBox:Input({
    Title = "Ignore remotes",
    Desc = "Names to skip, separated by commas (use it for spammy remotes).",
    Value = "",
    Placeholder = "UpdatePosition, Ping",
    Callback = function(text)
        Ignored = {}
        for name in tostring(text):gmatch("[^,]+") do
            name = name:gsub("^%s+", ""):gsub("%s+$", "")
            if name ~= "" then Ignored[name:lower()] = true end
        end
    end,
})
local SpyStatusP = SpyBox:Paragraph({ Title = "Status", Desc = "0 calls • 0 remotes" })

-- ===== ATTRIBUTES TAB =====
local AttrBox = openSection(Tabs.Attr, "Attributes", "tag")
AttrBox:Input({
    Title = "Path filter",
    Desc = "Only objects whose path contains this text (example: Plots). Empty = everything.",
    Value = "",
    Placeholder = "Workspace.Plots",
    Callback = function(text) AttrFilter = tostring(text) end,
})
AttrBox:Input({
    Title = "Exclude paths",
    Desc = "Skip objects whose path contains any of these (comma separated).",
    Value = "",
    Placeholder = "Workspace.Map, Workspace.Camera, .Building.",
    Callback = function(text) ExcludePaths = parseList(text) end,
})
AttrBox:Input({
    Title = "Exclude attributes",
    Desc = "Ignore attributes that start with these. Objects left with none are skipped.",
    Value = "RBX",
    Placeholder = "RBX, MapFix, StoreColor",
    Callback = function(text) ExcludeAttrs = parseList(text) end,
})
AttrBox:Button({
    Title = "Dump Attributes",
    Desc = "Scans Workspace and ReplicatedStorage. Similar objects are grouped.",
    Icon = "download",
    Callback = function() runDump("attributes") end,
})
AttrBox:Toggle({
    Title = "Watch attribute changes",
    Desc = "Logs live changes. On big games set a path filter first.",
    Value = false,
    Callback = function(v) setWatch(v) end,
})
local AttrStatusP = AttrBox:Paragraph({ Title = "Status", Desc = "0 changes • 0 keys" })

-- ===== SCRIPTS TAB =====
local ScrBox = openSection(Tabs.Scripts, "Script Dump", "file-code")
ScrBox:Paragraph({ Title = "Executor support", Desc = capText() })
ScrBox:Input({
    Title = "Include scripts",
    Desc = "Only scripts whose path contains one of these (comma separated). Empty = all.",
    Value = "",
    Placeholder = "Plots, Customer, Cashier",
    Callback = function(text) ScriptInclude = parseList(text) end,
})
ScrBox:Input({
    Title = "Exclude scripts",
    Desc = "Skip scripts whose path contains one of these.",
    Value = "playermodule, chatscript, bubblechat, rbxcharactersounds",
    Placeholder = "playermodule, chatscript",
    Callback = function(text) ScriptExclude = parseList(text) end,
})
ScrBox:Button({
    Title = "List Scripts",
    Desc = "Every LocalScript and ModuleScript the client can see.",
    Icon = "list",
    Callback = function() runJob("scriptlist", buildScriptList) end,
})
ScrBox:Button({
    Title = "Decompile Matching",
    Desc = "Decompiles the scripts that match the filters into one file.",
    Icon = "download",
    Callback = function() runJob("scriptsrc", buildDecompile) end,
})
ScrBox:Input({
    Title = "Search text",
    Desc = "Finds this text inside the scripts (not case sensitive).",
    Value = "FireServer",
    Placeholder = "FireServer, Mess, Clean",
    Callback = function(text) ScriptNeedle = tostring(text) end,
})
ScrBox:Button({
    Title = "Search In Scripts",
    Desc = "Shows every hit with the lines around it. Great for finding how a remote is called.",
    Icon = "search",
    Callback = function() runJob("scriptsearch", buildSearch) end,
})
ScrBox:Button({
    Title = "Dump Module Values",
    Desc = "Reads what loaded ModuleScripts return (configs, prices, remote names).",
    Icon = "database",
    Callback = function() runJob("modules", buildModules) end,
})
ScrBox:Button({
    Title = "Stop",
    Desc = "Stops the running script job.",
    Icon = "x",
    Callback = function() Job.cancel = true end,
})
local ScriptStatusP = ScrBox:Paragraph({ Title = "Status", Desc = "Ready" })
sstatus = function(text) setDesc(ScriptStatusP, text) end

-- ===== EXPORT TAB =====
local ExBox = openSection(Tabs.Export, "Export", "download")
ExBox:Button({
    Title = "Dump Remotes",
    Desc = "Remote list + everything the spy caught. Copies and saves a file.",
    Icon = "download",
    Callback = function() runDump("remotes") end,
})
ExBox:Button({
    Title = "Dump Everything",
    Desc = "Remotes, attributes, changes and the timeline in one file.",
    Icon = "download",
    Callback = function() runDump("all") end,
})
ExBox:Button({
    Title = "Copy Last Dump",
    Desc = "Copies the previous dump to the clipboard again.",
    Icon = "copy",
    Callback = function()
        if lastDump == "" then
            notify(TOOL, "Nothing dumped yet.", "x")
        elseif setclipboard and pcall(setclipboard, lastDump) then
            notify(TOOL, "Copied to clipboard.")
        else
            notify(TOOL, "Executor can't copy to the clipboard.", "x")
        end
    end,
})
ExBox:Button({
    Title = "Clear Logs",
    Desc = "Wipes the remote and attribute logs.",
    Icon = "trash-2",
    Callback = clearLogs,
})

-- ===== STATUS LOOP =====
task.spawn(function()
    local l1, l2
    while alive do
        task.wait(1)
        local s1 = string.format("%d calls • %d remotes", totalCalls, #remoteOrder)
        if s1 ~= l1 then
            l1 = s1
            setDesc(SpyStatusP, s1)
        end
        local s2 = string.format("%d changes • %d keys", attrChanges, #attrOrder)
        if s2 ~= l2 then
            l2 = s2
            setDesc(AttrStatusP, s2)
        end
    end
end)

-- ===== UNLOAD =====
local function unload()
    if not alive then return end
    alive = false
    Job.cancel = true
    Spy.on = false
    pcall(setIncoming, false)
    pcall(setWatch, false)
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.RANSDUMP_Unload = nil
end
_G.RANSDUMP_Unload = unload

local ScriptBox = Tabs.Export:Section({ Title = "Script", Icon = icon("power"), Box = true, BoxBorder = true, Opened = false })
ScriptBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})
