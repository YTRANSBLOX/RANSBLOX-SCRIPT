local HUB_NAME = "Pet Store Tycoon"
local VERSION  = "v2.6"
local YT_LINK  = "https://www.youtube.com/@RansbloxScript"
local WEB_LINK = "https://ransblox.net"

-- Re-execute safety: unload the previous instance first
if _G.PETSTORETYCOON_Unload then pcall(_G.PETSTORETYCOON_Unload) end

pcall(function() setclipboard(YT_LINK) end)
print("[Pet Store Tycoon] " .. VERSION .. " starting...")

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/YTRANSBLOX/RANSBLOX-SCRIPT/refs/heads/main/maingui.lua"))()
end)
if not ok or not WindUI then
    warn("[Pet Store Tycoon] could not load the UI library (WindUI): " .. tostring(WindUI))
    return
end

-- CONNECTION MANAGER
local Connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- GAME (Pet Store Tycoon)
-- =====================================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local function gameMissing(msg)
    WindUI:Notify({
        Title = HUB_NAME,
        Content = msg,
        Icon = "x",
        Duration = 5,
    })
end

local remotesFolder = RS:WaitForChild("Remotes", 10)
if not remotesFolder then
    gameMissing("Pet Store Tycoon not found. This script only works in Pet Store Tycoon.")
    return
end

local alive = true

-- shared state between Auto Cashier and Auto Restock (filled in further down)
local Auto = { restockOn = false, buyOn = false, cashierStarting = false, thiefNow = function() return false end }

-- any feature that needs the player OFF the register takes a hold here.
-- While at least one hold exists, the cashier will not (re)start a shift.
local deskHolds = {}
Auto.hold = function(owner, on) deskHolds[owner] = on and true or nil end
Auto.held = function() return next(deskHolds) ~= nil end

-- shared noclip: every feature takes / releases its own hold, so one can never switch the other off
local noclipOwners, noclipConn = {}, nil
local function NC(owner, on)
    noclipOwners[owner] = on and true or nil
    local any = next(noclipOwners) ~= nil
    if any and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local ch = lp.Character
            if not ch then return end
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    elseif not any and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

-- shared movement mode: every feature asks Move.isTp() before it walks.
-- Walk = legit (humanoid walks, noclip). Teleport = jumps straight to the spot (same height, no walking).
local Move = { teleport = false }
function Move.isTp() return Move.teleport end
function Move.tp(pos, fast)
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not (hrp and pos) then return false end
    if hum and hum.Health <= 0 then return false end
    local cur = hrp.CFrame
    hrp.CFrame = CFrame.new(pos.X, cur.Position.Y, pos.Z) * (cur - cur.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
    if not fast then task.wait(0.15) end -- let the server see the new position
    return true
end

-- log (saved to petstore_tycoon_log.txt for debugging)
local buf, logN, t0 = {}, 0, os.clock()
local function log(tag, name, ...)
    local a, p = table.pack(...), {}
    for i = 1, a.n do p[i] = tostring(a[i]) end
    buf[#buf + 1] = string.format("[%.2f] %s %s(%s)", os.clock() - t0, tag, tostring(name), table.concat(p, ", "))
    if #buf > 400 then table.remove(buf, 1) end
    logN += 1
end
task.spawn(function()
    local last = 0
    while alive do
        task.wait(2)
        if logN ~= last then
            last = logN
            if writefile then pcall(writefile, "petstore_tycoon_log.txt", table.concat(buf, "\n")) end
        end
    end
end)

-- =====================================================================
-- AUTO CASHIER
-- =====================================================================
local HttpService = game:GetService("HttpService")
local CO = remotesFolder:WaitForChild("Checkout", 10)
local ScanCurrent = CO and CO:FindFirstChild("ScanCurrent")
local BeginShift = CO and CO:FindFirstChild("BeginShift")
local EndShift = CO and CO:FindFirstChild("EndShift")

local cashRunning = false
local cStatus = "Ready"
local setCashierStatus = function() end

local function cashActive() return alive and cashRunning and not Auto.thiefNow() end
local function clog(tag, name, ...)
    log("CASH:" .. tag, name, ...)
    if tag == "BOT" then setCashierStatus(tostring(name)) end
end

-- register (your plot's checkout, falls back to the nearest one)
local CHK
local function findCheckout()
    local plots = workspace:WaitForChild("Plots")
    for _, p in ipairs(plots:GetChildren()) do
        if p:GetAttribute("OwnerUserId") == lp.UserId then return p:FindFirstChild("Checkout") end
    end
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local best, bd
    for _, p in ipairs(plots:GetChildren()) do
        local c = p:FindFirstChild("Checkout")
        local pp = c and c:FindFirstChild("PlayerPoint")
        if pp and hrp then
            local d = (pp.Position - hrp.Position).Magnitude
            if not bd or d < bd then best, bd = c, d end
        end
    end
    return best
end

local function payload()
    if not CHK then return nil end
    local s = CHK:GetAttribute("CheckoutDisplayPayload")
    if type(s) ~= "string" then return nil end
    local okJ, d = pcall(HttpService.JSONDecode, HttpService, s)
    return okJ and d or nil
end
local function phase() return (payload() or {}).phase end

-- ===== customer waiting detection =====
-- From the logger: customers live in Plot.NPCs. Shopping ones have Phase=Search/Choose
-- (Status "Looking around"/"Browsing"); the ones at the register have Phase=Buy
-- (Status "Waiting to pay"). Only those count, never the ones still choosing.
local busyCache, busyAt, lastBusy = false, 0, 0
local function customerBusy()
    local now = os.clock()
    if now - busyAt < 0.5 then return busyCache end
    busyAt = now
    local n = 0
    local plot = CHK and CHK.Parent
    local npcs = plot and plot:FindFirstChild("NPCs")
    for _, m in ipairs(npcs and npcs:GetChildren() or {}) do
        local ph = m:GetAttribute("Phase")
        local st = tostring(m:GetAttribute("Status") or ""):lower()
        if ph == "Buy" or st:find("pay") or st:find("queue") or st:find("line") then n += 1 end
    end
    local d = payload()
    if d and ((d.totalCents or 0) > 0 or #(d.lines or {}) > 0) then n += 1 end
    busyCache = n > 0
    if busyCache then lastBusy = now end
    return busyCache
end

-- true while Auto Cashier is on and someone is waiting / being served
Auto.yield = function() return cashRunning and customerBusy() end
-- Once restock / care has STARTED a run, it finishes that whole run before the cashier takes over.
-- The cashier in turn serves until nobody is waiting, then the next task starts.
-- Auto.yieldTask is what a RUNNING task asks ("must I stop now?"): customers never interrupt it
-- (only a thief does, set in the thief section). Auto.yield stays for the cashier.
Auto.yieldTask = function() return false end
-- ok for restock / buy to leave the register: no customer now AND none for IdleBefore seconds
Auto.canLeaveDesk = function()
    if not cashRunning then return true end
    if customerBusy() then return false end
    return os.clock() - lastBusy >= ((Auto.RCfg and Auto.RCfg.IdleBefore) or 0)
end

-- ===== diagnostics (written to petstore_tycoon_log.txt) =====
local dumped = false
local function dumpRegister()
    if not CHK then return end
    log("DUMP", "register", CHK:GetFullName())
    for _, d in ipairs(CHK:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            log("DUMP", "ProximityPrompt", d:GetFullName(), d.ActionText, d.HoldDuration, d.Enabled)
        elseif d:IsA("ClickDetector") then
            log("DUMP", "ClickDetector", d:GetFullName())
        elseif d:IsA("TouchTransmitter") then
            log("DUMP", "TouchInterest", d.Parent:GetFullName())
        end
    end
end

-- logs what the GAME sends when you tap / exit the register yourself
pcall(function()
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if alive and not checkcaller() then
            local m = getnamecallmethod()
            if (m == "InvokeServer" or m == "FireServer")
                and (self == BeginShift or self == EndShift or self.Name == "AcceptPresentedPayment") then
                log("HOOK", self.Name .. ":" .. m, ...)
            end
        end
        return old(self, ...)
    end))
end)

local function snapshot()
    local parts = {}
    if CHK then
        for k, v in pairs(CHK:GetAttributes()) do
            if k ~= "CheckoutDisplayPayload" then parts[#parts + 1] = k .. "=" .. tostring(v) end
        end
    end
    for k, v in pairs(lp:GetAttributes()) do parts[#parts + 1] = "lp." .. k .. "=" .. tostring(v) end
    table.sort(parts)
    return table.concat(parts, "|")
end

-- GUI buttons (no VirtualInputManager)
local cmethods = {
    function(b) firesignal(b.Activated) end,
    function(b) firesignal(b.MouseButton1Click) end,
    function(b) for _, c in ipairs(getconnections(b.Activated)) do c:Fire() end end,
    function(b) for _, c in ipairs(getconnections(b.MouseButton1Click)) do c:Fire() end end,
}
local cmi = 1
local function cpress(btn, probe)
    local before = probe()
    for k = 0, #cmethods - 1 do
        local idx = ((cmi - 1 + k) % #cmethods) + 1
        pcall(cmethods[idx], btn)
        local t = os.clock()
        while os.clock() - t < 0.8 do -- wait long enough to avoid double-firing
            task.wait(0.03)
            if probe() ~= before then cmi = idx return true end
        end
    end
    clog("BOT", "Button press failed", btn:GetFullName())
    return false
end

local function panel()
    local g = pg:FindFirstChild("UI2Checkout")
    local f = g and g:FindFirstChild("Frame")
    local p = f and f:FindFirstChild("Panel")
    return p and p:FindFirstChild("Panel")
end
local function waitPanel(childName)
    local t = os.clock()
    while os.clock() - t < 3 do
        local p = panel()
        if p and p:FindFirstChild(childName, true) then return p end
        task.wait(0.1)
    end
end

-- ===== scan (skips items that were already scanned) =====
local seq, shiftTx = 0, nil
local function pickItem(d)
    local done = {}
    for _, l in ipairs(d.lines or {}) do done[l.sourceIndex] = true end
    local best, bi
    for _, c in ipairs(CHK:GetChildren()) do
        if c.Name == "ScanItem" then
            local i = c:GetAttribute("CheckoutItemIndex")
            if i and not done[i] and (not bi or i < bi) then best, bi = c, i end
        end
    end
    return best
end
local function scanAll()
    local fails, waits = 0, 0
    while cashActive() do
        local d = payload()
        if not d or d.phase ~= "Scanning" then return end
        local item = pickItem(d)
        if not item then
            waits += 1
            if waits > 30 then return end
            task.wait(0.2)
        else
            waits = 0
            local tx = item:GetAttribute("CheckoutTransactionId")
            if tx ~= shiftTx then
                shiftTx = tx
                task.spawn(function() pcall(BeginShift.InvokeServer, BeginShift, CHK) end)
                task.wait(0.5)
            end
            local before = d.scannedCount or 0
            seq += 1
            ScanCurrent:FireServer(item, tx, seq)
            local scanned, t = false, os.clock()
            while os.clock() - t < 1.0 do
                task.wait(0.05)
                local n = payload()
                if not n or n.phase ~= "Scanning" or (n.scannedCount or 0) > before then scanned = true break end
            end
            if scanned then
                fails = 0
                task.wait(0.15)
            else
                fails += 1
                clog("SCAN", "Scan rejected", seq, item:GetAttribute("CheckoutItemIndex"), tx)
                if fails > 8 then clog("BOT", "Gave up scanning") return end
            end
        end
    end
end

-- ===== open the payment panel (through the remote, no clicking) =====
local acceptIdx = 1
local function openPayment(method)
    local pay = CHK:FindFirstChild("CheckoutPayment")
    local part = pay and pay:FindFirstChild(method == "Card" and "Card" or "Band", true)
    local rem = CO:FindFirstChild("AcceptPresentedPayment")
    if not rem then clog("BOT", "AcceptPresentedPayment remote not found") return end
    local shapes = {
        table.pack(CHK, shiftTx),
        table.pack(shiftTx),
        table.pack(CHK),
        table.pack(part),
        table.pack(),
        table.pack(CHK, shiftTx, method),
        table.pack(part, shiftTx),
    }
    for k = 0, #shapes - 1 do
        local idx = ((acceptIdx - 1 + k) % #shapes) + 1
        local s = shapes[idx]
        pcall(function() rem:FireServer(table.unpack(s, 1, s.n)) end)
        local t = os.clock()
        while os.clock() - t < 1.2 do
            task.wait(0.05)
            if phase() ~= "AwaitingPayment" then
                if acceptIdx ~= idx then clog("PAY", "Accept argument shape worked", idx) end
                acceptIdx = idx
                return
            end
        end
    end
    clog("BOT", "All payment accept shapes failed", tostring(shiftTx))
end

-- ===== cash: reads the real label and learns the click multiplier =====
local DEN = {
    { "Bills", "bill100", 10000 }, { "Bills", "bill50", 5000 }, { "Bills", "bill20", 2000 },
    { "Bills", "bill10", 1000 }, { "Bills", "bill5", 500 }, { "Bills", "bill1", 100 },
    { "Coins", "coin50", 50 }, { "Coins", "coin25", 25 }, { "Coins", "coin10", 10 },
    { "Coins", "coin5", 5 }, { "Coins", "coin1", 1 },
}
local function toCents(s) return math.floor((tonumber((s:gsub(",", ""))) or 0) * 100 + 0.5) end
local function givingState(lbl)
    local cur, tgt = lbl.Text:match("Giving%s*%$([%d,%.]+)%s*of%s*%$([%d,%.]+)")
    return cur and toCents(cur), tgt and toCents(tgt)
end
local function doCash()
    local p = waitPanel("Giving")
    if not p then clog("BOT", "Cash panel didn't appear") return end
    local lbl = p:FindFirstChild("Giving")
    local probe = function() return lbl.Text end
    local _, target = givingState(lbl)
    if not target then clog("BOT", "Couldn't read the cash target", lbl.Text) return end
    local mult, resets, dbg = 1, 0, 0
    for _ = 1, 160 do
        if not cashActive() or phase() ~= "CashChange" then return end
        local c = (givingState(lbl)) or 0
        if c == target then break end
        if c > target then
            resets += 1
            if resets > 4 then clog("BOT", "Gave up: overshot the cash target", c, target) return end
            local clr = p:FindFirstChild("ClearAll")
            if clr then cpress(clr, probe) end
            continue
        end
        local remaining, btn, den = target - c, nil, nil
        for _, dn in ipairs(DEN) do
            if dn[3] * mult <= remaining then
                local b = p:FindFirstChild(dn[2], true)
                b = b and b:FindFirstChild("Button")
                if b then btn, den = b, dn break end
            end
        end
        if not btn then clog("BOT", "No matching bill or coin button", remaining, mult) return end
        if not cpress(btn, probe) then return end
        task.wait(0.1)
        local after = (givingState(lbl)) or c
        local m = math.floor((after - c) / den[3] + 0.5)
        if dbg < 6 then dbg += 1 clog("DELTA", den[2], after - c, m, cmi) end
        if m >= 1 then mult = m end
    end
    local c = (givingState(lbl)) or 0
    if c == target then
        local okBtn = p:FindFirstChild("OK")
        if okBtn then cpress(okBtn, phase) end
    else
        clog("BOT", "Cash total doesn't match", c, target)
    end
end

-- ===== card =====
local function doCard()
    local p = waitPanel("DueValue")
    if not p then clog("BOT", "Card panel didn't appear") return end
    local due = p:FindFirstChild("DueValue", true)
    local entered = p:FindFirstChild("Entered", true)
    local amt = string.format("%.2f", toCents((due.Text:gsub("[^%d%.]", ""))) / 100)
    local probe = function() return entered.Text end
    for ch in amt:gmatch(".") do
        local name = ch == "." and "KeyDot" or ("Key" .. ch)
        local btn = p:FindFirstChild(name)
        if not btn or not cpress(btn, probe) then clog("BOT", "Keypad press failed", name) return end
        task.wait(0.03)
    end
    local ck = p:FindFirstChild("ConfirmKey")
    if ck then cpress(ck, phase) end
end

-- ===== register: walk there, start / end the shift =====
local shiftOn = false
local lastCashPhase = nil
local returnPos = nil -- where the character stood before walking to the desk

local function regPoint()
    local pp = CHK and CHK:FindFirstChild("PlayerPoint")
    return pp and pp.Position
end

local function goToRegister()
    local ch = lp.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local target = regPoint()
    if not (hum and hrp and target) then return false end
    if Move.isTp() then return Move.tp(target) end
    local tStart = os.clock()
    while cashActive() and not Auto.held() and os.clock() - tStart < 20 do
        local p = hrp.Position
        if Vector3.new(p.X - target.X, 0, p.Z - target.Z).Magnitude <= 2 then
            hum:MoveTo(p)
            return true
        end
        hum:MoveTo(target)
        task.wait(0.1)
    end
    return false
end

-- ===== face the register (we can't serve customers with our back to them) =====
local faceConn, faceTarget

-- a point on the counter, so the character looks at the register from where it stands
-- (kalau masih salah arah, ganti isi fungsi ini pake versi PlayerPoint LookVector:
--   local pp = CHK and CHK:FindFirstChild("PlayerPoint")
--   if not pp then return nil end
--   return pp.Position + pp.CFrame.LookVector * 5
--  kalau kebalik, ganti + jadi -)
local function regLookPoint()
    local pp = CHK and CHK:FindFirstChild("PlayerPoint")
    if not pp then return nil end
    local sum, n = Vector3.zero, 0
    for _, d in ipairs(CHK:GetDescendants()) do
        if d:IsA("BasePart") and d ~= pp and (d.Position - pp.Position).Magnitude < 12 then
            sum += d.Position
            n += 1
        end
    end
    if n > 0 then
        local c = sum / n
        if Vector3.new(c.X - pp.Position.X, 0, c.Z - pp.Position.Z).Magnitude > 0.5 then
            return c
        end
    end
    return pp.Position + pp.CFrame.LookVector * 5
end

-- on: lock the character's facing toward the register every frame; off: release it
local function setFacing(on)
    if faceConn then
        faceConn:Disconnect()
        faceConn = nil
    end
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = not on end
    if on then
        faceConn = RunService.Heartbeat:Connect(function()
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and faceTarget then
                local p = hrp.Position
                local look = Vector3.new(faceTarget.X, p.Y, faceTarget.Z)
                if (look - p).Magnitude > 0.1 then
                    hrp.CFrame = CFrame.lookAt(p, look)
                end
            end
        end)
    end
end

-- ===== start shift: ONE touch tap on the desk (no FireServer) =====
local VIM = game:GetService("VirtualInputManager")

local function deskPos()
    if CHK:IsA("Model") then return CHK:GetPivot().Position end
    return regPoint()
end

local function unlockChar()
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    if hrp then hrp.Anchored = false end
    if cam then
        cam.CameraType = Enum.CameraType.Custom
        if hum then cam.CameraSubject = hum end
    end
end

-- lock character (anchor) + camera on the desk, tap once, release
local function tapDesk()
    local ch = lp.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    local desk = deskPos()
    if not (hrp and cam and desk) then return false end

    hrp.Anchored = true
    cam.CameraType = Enum.CameraType.Scriptable
    local side = Vector3.new(hrp.Position.X - desk.X, 0, hrp.Position.Z - desk.Z)
    side = side.Magnitude > 0.1 and side.Unit or Vector3.new(0, 0, 1)
    cam.CFrame = CFrame.lookAt(desk + Vector3.new(0, 10, 0) + side * 3, desk)
    task.wait(0.3)

    local v, onScreen = cam:WorldToViewportPoint(desk)
    log("CASH:SHIFT", "tap at", math.floor(v.X), math.floor(v.Y), onScreen)
    local okT, errT = pcall(function()
        VIM:SendTouchEvent(1, 0, v.X, v.Y) -- begin
        task.wait(0.08)
        VIM:SendTouchEvent(1, 2, v.X, v.Y) -- end
    end)
    log("CASH:SHIFT", "touch sent", okT, tostring(errT))
    task.wait(0.8)

    unlockChar()
    return true -- best-effort: same as the standalone cashier that works (scanAll also calls BeginShift per customer)
end

local function startShift()
    if not CHK then return false end
    local hrp0 = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp0 and not returnPos then returnPos = hrp0.Position end
    setCashierStatus("Walking to the register...")
    NC("cashier", true) -- noclip so nothing blocks the walk
    if not goToRegister() then
        NC("cashier", false)
        setCashierStatus("Couldn't reach the register, retrying...")
        return false
    end
    if Auto.held() or not cashActive() then NC("cashier", false) return false end

    faceTarget = regLookPoint()
    setFacing(true)
    task.wait(0.6)
    if Auto.held() or not cashActive() then
        setFacing(false)
        NC("cashier", false)
        return false
    end

    setCashierStatus("Tapping the register...")
    local before = snapshot()
    local tapped = tapDesk()
    NC("cashier", false)
    log("CASH:SHIFT", "tap", tapped, before ~= snapshot() and "state changed" or "no visible change")

    shiftOn = tapped
    if shiftOn then
        lastCashPhase = nil
        setCashierStatus("Shift started")
    else
        setFacing(false)
        setCashierStatus("Tap failed, retrying...")
    end
    return shiftOn
end

local function endShift()
    setFacing(false)
    if EndShift then pcall(function() EndShift:FireServer() end) end
    shiftOn = false
    returnPos = nil
    log("CASH:SHIFT", "end")
end

-- walk back to where the character was. Stops early when a new customer shows up or another feature takes over.
-- returns: "home" / "customer" / "other" / "timeout" / "none"
local function walkBack(pos)
    local ch = lp.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp and pos) then return "none" end
    if Move.isTp() then Move.tp(pos) return "home" end
    NC("cashier", true)
    local reason, t = "timeout", os.clock()
    while os.clock() - t < 15 do
        if not cashActive() or Auto.held() then reason = "other" break end
        if customerBusy() then reason = "customer" break end
        local p = hrp.Position
        if Vector3.new(p.X - pos.X, 0, p.Z - pos.Z).Magnitude <= 2 then reason = "home" break end
        hum:MoveTo(pos)
        task.wait(0.1)
    end
    NC("cashier", false)
    hum:MoveTo(hrp.Position)
    return reason
end

-- nobody left to serve: close the shift and go back to where we were
local function leaveDesk()
    local back = returnPos
    endShift()
    if not back then
        lastCashPhase = "waiting"
        setCashierStatus("Waiting for a customer...")
        return
    end
    setCashierStatus("Walking back to where you were...")
    local reason = walkBack(back)
    if reason == "customer" then
        returnPos = back -- keep the original spot for the next shift
    elseif cashActive() then
        lastCashPhase = "waiting"
        setCashierStatus("Waiting for a customer...")
    end
end

-- runs startShift with a flag so Auto Restock can wait for it, and always releases the locks
local function startShiftSafe()
    Auto.cashierStarting = true
    local okS, res = pcall(startShift)
    Auto.cashierStarting = false
    NC("cashier", false)
    unlockChar()
    if not okS then error(res, 0) end
    -- cashier was switched off (or restock took over) while we were starting: leave the register
    if shiftOn and (not cashActive() or Auto.held()) then endShift() end
    return res
end

-- Auto Restock calls this before it leaves the register:
-- let the current customer finish (up to 8s), then end the shift
Auto.pauseCashier = function()
    if not shiftOn then return end
    local tStart = os.clock()
    while customerBusy() and os.clock() - tStart < 8 do task.wait(0.2) end
    endShift()
end

-- ===== main loop =====
local cBusy, cLastRun = false, {}
local function cRun(name, fn)
    if cBusy or os.clock() - (cLastRun[name] or 0) < 0.6 then return end
    cBusy, cLastRun[name] = true, os.clock()
    task.spawn(function()
        local okR, e = pcall(fn)
        if not okR then clog("ERR", name, e) end
        cBusy = false
    end)
end

local PHASE_TEXT = {
    Scanning = "Scanning items...",
    AwaitingPayment = "Accepting payment...",
    CashChange = "Giving change...",
    CardEntry = "Entering card amount...",
}

local IDLE_LEAVE = 1 -- quiet seconds on shift before the character leaves the desk

-- status text that only changes when the key changes (no spam every 0.2s)
local function stat(key, text)
    if lastCashPhase ~= key then
        lastCashPhase = key
        setCashierStatus(text)
    end
end

local function cashierStep()
    if not (CO and ScanCurrent and BeginShift) then
        setCashierStatus("Checkout remotes not found")
        return
    end
    if not CHK then
        CHK = findCheckout()
        if not CHK then
            setCashierStatus("Register not found")
            return
        end
    end

    if not dumped then dumped = true dumpRegister() end

    -- off the desk: stay free until somebody is actually waiting to pay
    if not shiftOn then
        if not customerBusy() then
            stat("waiting", "Waiting for a customer...")
        elseif Auto.held() then
            returnPos = nil -- another feature is moving the character, so don't walk back to an old spot later
            stat("held", "Waiting for restock to finish...")
        else
            lastCashPhase = nil
            cRun("shift", startShiftSafe)
        end
        return
    end

    -- on the desk: did something move us away from the register?
    local pp = regPoint()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local away = false
    if pp and root then
        local p = root.Position
        away = Vector3.new(p.X - pp.X, 0, p.Z - pp.Z).Magnitude > 6
    end
    if away then
        if Auto.held() then
            stat("held", "Waiting for restock to finish...")
        else
            endShift() -- the branch above starts a new shift if someone is waiting
        end
        return
    end

    local d = payload()

    -- nobody being served for a while: leave the desk
    if not cBusy and not customerBusy() and os.clock() - lastBusy >= IDLE_LEAVE
        and not (d and PHASE_TEXT[d.phase]) then
        cRun("leave", leaveDesk)
        return
    end

    if not d then
        stat("idle", "Waiting for the next customer...")
        return
    end
    if d.phase ~= lastCashPhase then
        lastCashPhase = d.phase
        setCashierStatus(PHASE_TEXT[d.phase] or ("Phase: " .. tostring(d.phase)))
    end
    if d.phase == "Scanning" then cRun("scan", scanAll)
    elseif d.phase == "AwaitingPayment" then cRun("open", function() openPayment(d.paymentMethod) end)
    elseif d.phase == "CashChange" then cRun("cash", doCash)
    elseif d.phase == "CardEntry" then cRun("card", doCard)
    end
end

task.spawn(function()
    while alive do
        task.wait(0.2)
        if cashRunning then pcall(cashierStep) end
    end
end)

-- =====================================================================
-- AUTO RESTOCK + AUTO BUY
-- =====================================================================
local Mods = nil
do
    local folder = RS:FindFirstChild("Modules")
    if folder then
        local okR, res = pcall(function()
            return {
                AP  = require(folder.ActivePlot),
                GC  = require(folder.GoodsCatalogue),
                SR  = require(folder.ShelfRules),
                GR  = require(folder.ShelfGuideRules),
                GCO = require(folder.GoodsCommitOutcome),
                PDC = require(folder.PlayerDataClient),
                LC  = require(folder.LevelConfig),
            }
        end)
        if okR then Mods = res end
    end
end
local GoodsRem = remotesFolder:FindFirstChild("Goods")

local RCfg = {
    PickDist = 3,          -- stand this far from a box when picking it up
    PickRetries = 4,       -- try this many other spots around a box before giving up
    StandDist = 2.5,       -- distance to stand in front of a shelf slot
    FireFrom = 6,          -- start spamming PickUpBox at this distance
    UseEmptySlots = true,  -- allow filling never-used slots
    Reassign = false,      -- allow overwriting empty slots of other goods
    MaxFail = 2,           -- skip a box after this many failures
    MaxLoops = 300,        -- safety cap per run
    DoGoods = true,        -- shelve goods boxes (Restock what > Shelves)
    FishRestock = true,    -- also place fish/pet boxes into your tanks (Restock what > Fish tanks)
    EnclosureTry = 6,      -- try at most this many tanks per box
    IdleBefore = 0,        -- cashier on: quiet seconds before restocking (0 = go right after the last customer)
    RunGap = 0,            -- cashier on: minimum seconds between two restock runs (0 = none)
    FullRun = true,        -- FULL RESTOCK: keep buying + shelving until every shelf is full before the cashier takes over
    FillMax = 180,         -- full restock: give up after this many seconds
    FillWait = 8,          -- full restock: seconds to wait for freshly bought boxes to show up
}
local BCfg = {
    BuyDelay = 0.4,        -- seconds between purchases
    Cooldown = 6,          -- seconds to leave a good alone after buying it, so its boxes can show up
    Safety = 15,           -- seconds between quiet local re-checks (no remotes) in case an event was missed
    LevelCheck = 5,        -- seconds between level checks
}

Auto.ready = (Mods ~= nil and GoodsRem ~= nil)
Auto.RCfg = RCfg
Auto.BCfg = BCfg
Auto.getOptions = function() return {} end
Auto.getLevel = function() return 1 end
Auto.setSelected = function() end
Auto.setNoclip = function() end
Auto.clearSkip = function() end
Auto.buyWake = function() end
Auto.buyReset = function() end
Auto.fishRoom = nil   -- (petType, petName) -> room, waiting boxes, tanks; set below
Auto.getPlot = function() return nil end

-- FULL RESTOCK session
-- Auto Buy puts a good in fillSet when its shelves need stock. While fillSet is not empty,
-- Auto Restock does NOT go back to the cashier: it keeps ordering (fillStep) and shelving
-- until every shelf that takes the good is full (or cash / shelves run out / timeout).
Auto.fillSet, Auto.fillStart = {}, nil
Auto.fillEnd = function(why)
    if next(Auto.fillSet) ~= nil then log("FILL", "end", tostring(why)) end
    Auto.fillQuota, Auto.fillOrdered = {}, {}
    Auto.fillSet, Auto.fillStart = {}, nil
    Auto.buyWake()
end
Auto.fillQuota, Auto.fillOrdered = {}, {} -- boxes still to order per good, noted ONCE when the session starts
Auto.fillActive = function()
    if not (RCfg.FullRun and Auto.restockOn and RCfg.DoGoods and next(Auto.fillSet) ~= nil) then return false end
    if os.clock() - (Auto.fillStart or 0) > RCfg.FillMax + 30 then Auto.fillEnd("stale") return false end
    return true
end
Auto.fillStep = function() return 0, true, false end -- bought, allFull, blocked (real one is set in AUTO BUY)
local setRestockStatus = function() end
local setBuyStatus = function() end
local setScanText = function() end

if Auto.ready then
    local AP, GC, SR, GR, GCO, PDC, LC = Mods.AP, Mods.GC, Mods.SR, Mods.GR, Mods.GCO, Mods.PDC, Mods.LC
    local Skip, FailCount = {}, {}

    local rLast
    local function rstatus(text)
        if text ~= rLast then
            rLast = text
            setRestockStatus(text)
        end
    end
    local yielded = false
    local function rActive()
        if not (alive and Auto.restockOn) then return false end
        -- customers do NOT stop us mid-shelf (runRestock yields after the shelf is done); only a thief does
        if Auto.thiefNow() then yielded = true return false end
        return true
    end

    -- ===== noclip & walking =====
    -- shelves ghost while restocking: a shelf pushed against a wall can trap the character,
    -- so their parts stop colliding (client side only) and get their old value back afterwards
    local shelfParts = {} -- part -> original CanCollide
    local lastGhost = 0
    local function shelvesGhost(on)
        if on then
            if os.clock() - lastGhost < 2 then return end
            lastGhost = os.clock()
            local plot = AP.getPlot()
            local items = plot and plot:FindFirstChild("Items")
            for _, sh in ipairs(items and items:GetChildren() or {}) do
                if sh:IsA("Model") and SR.isShelf(sh) then
                    for _, p in ipairs(sh:GetDescendants()) do
                        if p:IsA("BasePart") and shelfParts[p] == nil then
                            shelfParts[p] = p.CanCollide
                            p.CanCollide = false
                        end
                    end
                end
            end
        else
            for p, c in pairs(shelfParts) do
                if p.Parent then p.CanCollide = c end
                shelfParts[p] = nil
            end
            lastGhost = 0
        end
    end

    local function setNoclip(on)
        NC("restock", on)
        pcall(shelvesGhost, on)
    end
    Auto.setNoclip = setNoclip

    local function posOf(inst)
        if inst:IsA("Model") then return inst:GetPivot().Position end
        if inst:IsA("BasePart") then return inst.Position end
    end

    local function walkToPos(getPos, tol, timeout)
        local ch = lp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return false end
        setNoclip(true)
        local tStart = os.clock()
        if Move.isTp() then
            local target = getPos()
            if not target then return false end
            return Move.tp(target)
        end
        while rActive() and os.clock() - tStart < (timeout or 20) do
            local target = getPos()
            if not target then return false end
            if (hrp.Position - target).Magnitude <= tol then
                hum:MoveTo(hrp.Position)
                return true
            end
            hum:MoveTo(target)
            task.wait(0.1)
        end
        return false
    end

    -- ===== slot scan (game's own rules) =====
    local function scanSlots(item, goodKey, boxQty, tried, onlyShelf)
        local list = {}
        local plot = AP.getPlot()
        local items = plot and plot:FindFirstChild("Items")
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not (items and hrp) then return list end
        local goods = PDC.getGoods()
        local shelvesData = typeof(goods) == "table" and goods.Shelves or {}
        for _, sh in ipairs(items:GetChildren()) do
            local itemId = sh:IsA("Model") and sh:GetAttribute("ItemId")
            if itemId and (not onlyShelf or itemId == onlyShelf) and SR.isShelf(sh) and SR.acceptsGood(sh, item) then
                local data = shelvesData[itemId]
                for _, sl in ipairs(SR.slotModels(sh)) do
                    local idx = sl:GetAttribute("SlotIndex")
                    local gp = SR.goodsPartOf(sl)
                    if idx and gp and not (tried and tried[itemId .. ":" .. idx]) then
                        local rec = typeof(data) == "table" and data[tostring(idx)] or nil
                        local good = typeof(rec) == "table" and typeof(rec.Good) == "string" and rec.Good or nil
                        local qty = typeof(rec) == "table" and typeof(rec.Qty) == "number" and rec.Qty or 0
                        if GR.targetable({ good = good, qty = qty }, goodKey, boxQty) then
                            local pri
                            if good == goodKey and qty > 0 then pri = 1
                            elseif good == goodKey then pri = 2
                            elseif good == nil and RCfg.UseEmptySlots then pri = 3
                            elseif RCfg.Reassign then pri = 4 end
                            local look = gp.CFrame.LookVector
                            local flat = Vector3.new(look.X, 0, look.Z)
                            if pri and flat.Magnitude > 0.1 then
                                local stand = Vector3.new(gp.Position.X, hrp.Position.Y, gp.Position.Z)
                                    + flat.Unit * RCfg.StandDist
                                local dist = (gp.Position - hrp.Position).Magnitude
                                table.insert(list, { pri = pri, dist = dist, itemId = itemId, index = idx, stand = stand, qty = qty })
                            end
                        end
                    end
                end
            end
        end
        return list
    end

    local function pickTarget(item, goodKey, boxQty, tried, onlyShelf)
        local best
        for _, c in ipairs(scanSlots(item, goodKey, boxQty, tried, onlyShelf)) do
            if not best or c.pri < best.pri or (c.pri == best.pri and c.dist < best.dist) then
                best = c
            end
        end
        return best
    end

    local function boxInfo(box)
        local cat, name = box:GetAttribute("Category"), box:GetAttribute("GoodName")
        local item = GC.find(cat, name)
        if not item then return end
        return item, GC.keyOf(cat, name), SR.boxQuantityOf(item)
    end

    -- how many slots can still take this box (0 = shelves full for this good)
    local function countRoom(box, onlyShelf)
        local okI, item, goodKey, boxQty = pcall(boxInfo, box)
        if not okI or not item then return 0 end
        return #scanSlots(item, goodKey, boxQty, nil, onlyShelf)
    end

    -- ===== boxes =====
    local function getBoxes()
        local plot = AP.getPlot()
        local f = plot and plot:FindFirstChild("Boxes")
        return f and f:GetChildren() or {}
    end

    local function boxKeyOf(box)
        return box:GetAttribute("BoxKey") or box.Name
    end

    local function carriedBox()
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Carrier") == lp.UserId then return b end
        end
    end

    -- nearest free box whose shelves still have room
    -- onlyShelf (optional ItemId): only boxes that still fit on that one shelf
    local function nearestFreeBox(onlyShelf)
        if not RCfg.DoGoods then return end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local best, bd
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Carrier") == nil and not Skip[boxKeyOf(b)] and countRoom(b, onlyShelf) > 0 then
                local d = (posOf(b) - hrp.Position).Magnitude
                if not bd or d < bd then best, bd = b, d end
            end
        end
        return best
    end

    -- ===== fish / pet boxes =====
    -- a box that is NOT in the goods catalogue is treated as a pet (fish) box
    local PetsRem = remotesFolder:FindFirstChild("Pets")

    local function isGoodsBox(b)
        local okI, item = pcall(boxInfo, b)
        return okI and item ~= nil
    end
    local function isPetBox(b)
        return b:GetAttribute("Kind") == "Pet" or b:GetAttribute("PetName") ~= nil or not isGoodsBox(b)
    end

    -- the box in hand, but only if its type is switched on in "Restock what"
    local function workBox()
        local b = carriedBox()
        if not b then return end
        if isPetBox(b) then
            if RCfg.FishRestock then return b end
        elseif RCfg.DoGoods then
            return b
        end
    end

    local function boxLabel(b)
        return tostring(b:GetAttribute("GoodName") or b:GetAttribute("PetName")
            or b:GetAttribute("Pet") or b:GetAttribute("PetKey") or b.Name)
    end

    -- ===== shelf scan (what the Shelf scan line in the GUI shows) =====
    -- shelves you own, how many slots are filled, how many are empty, how many loose boxes are waiting
    local function shelfSummary()
        local plot = AP.getPlot()
        local folder = plot and plot:FindFirstChild("Items")
        if not folder then return "No plot found yet" end
        local goods = PDC.getGoods()
        local data = typeof(goods) == "table" and goods.Shelves or {}
        local shelves, slots, empty, partial = 0, 0, 0, 0
        for _, sh in ipairs(folder:GetChildren()) do
            local id = sh:IsA("Model") and sh:GetAttribute("ItemId")
            if id and SR.isShelf(sh) then
                shelves += 1
                local d = typeof(data) == "table" and data[id] or nil
                for _, sl in ipairs(SR.slotModels(sh)) do
                    local idx = sl:GetAttribute("SlotIndex")
                    if idx then
                        slots += 1
                        local rec = typeof(d) == "table" and d[tostring(idx)] or nil
                        local good = typeof(rec) == "table" and typeof(rec.Good) == "string" and rec.Good or nil
                        local qty = typeof(rec) == "table" and typeof(rec.Qty) == "number" and rec.Qty or 0
                        if not good or qty <= 0 then empty += 1 else partial += 1 end
                    end
                end
            end
        end
        local waiting = 0
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Carrier") == nil then waiting += 1 end
        end
        return ("Shelves: %d  |  Slots in use: %d/%d  |  Empty slots: %d  |  Boxes waiting: %d")
            :format(shelves, partial, slots, empty, waiting)
    end

    -- pick up / drop: use the Pets remote if the game has one, else the Goods one
    local function remoteFor(box, name)
        if PetsRem and isPetBox(box) then
            local r = PetsRem:FindFirstChild(name)
            if r then return r end
        end
        return GoodsRem[name]
    end

    -- ===== tanks: real data from the game =====
    -- tank model attrs: Capacity / AcceptsType / ItemId; pets placed: PlayerDataClient.getPets()
    local ModF = RS:FindFirstChild("Modules")
    local okE, ER = pcall(function() return require(ModF.EnclosureRules) end)
    if not okE then ER = nil end
    local okPC, PCat = pcall(function() return require(ModF.PetCatalogue) end)
    if not okPC then PCat = nil end

    -- how much room one pet takes (1 for normal fish, more for big ones if the game says so)
    local spaceCache = {}
    local function petSpaceOf(petType, petName)
        local key = tostring(petType) .. "/" .. tostring(petName)
        if spaceCache[key] then return spaceCache[key] end
        local sp = 1
        if PCat then
            local okI, inst = pcall(PCat.find, petType, petName)
            if okI and typeof(inst) == "Instance" then
                local v = tonumber(inst:GetAttribute((ER and ER.SPACE_ATTRIBUTE) or "Space"))
                if v and v > 0 then sp = v end
            end
        end
        spaceCache[key] = sp
        return sp
    end

    -- ItemId -> space already used in that tank
    local function usageMap()
        local used = {}
        local okG, pets = pcall(PDC.getPets)
        if okG and typeof(pets) == "table" then
            for _, p in pairs(pets) do
                if typeof(p) == "table" and p.State == "Enclosure" and p.Enclosure then
                    used[p.Enclosure] = (used[p.Enclosure] or 0) + petSpaceOf(p.Type, p.Name)
                end
            end
        end
        return used
    end

    -- tanks that accept this box's pet AND still have room for it, nearest first
    local function tanksFor(box, used)
        used = used or usageMap()
        local plot = AP.getPlot()
        local folder = plot and plot:FindFirstChild("Items")
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local list = {}
        if not (folder and hrp) then return list end
        local petType = box:GetAttribute("PetType")
        local need = petSpaceOf(petType, box:GetAttribute("PetName"))
        for _, m in ipairs(folder:GetChildren()) do
            local id = m:IsA("Model") and m:GetAttribute("ItemId")
            local cap = m:IsA("Model") and tonumber(m:GetAttribute("Capacity"))
            local accepts = m:GetAttribute("AcceptsType")
            if id and cap and (accepts == nil or accepts == petType) and (used[id] or 0) + need <= cap then
                list[#list + 1] = {
                    id = id, model = m,
                    dist = (m:GetPivot().Position - hrp.Position).Magnitude,
                }
            end
        end
        table.sort(list, function(a, b) return a.dist < b.dist end)
        return list
    end

    Auto.getPlot = function()
        local okP, p = pcall(AP.getPlot)
        return okP and typeof(p) == "Instance" and p or nil
    end

    -- fish side of one pet (same idea as shelfNeed for goods):
    -- how many of it the tanks can still take, how many of its boxes are already waiting, how many tanks accept it
    Auto.fishRoom = function(petType, petName)
        local used = usageMap()
        local plot = AP.getPlot()
        local folder = plot and plot:FindFirstChild("Items")
        local need = petSpaceOf(petType, petName)
        local room, tanks = 0, 0
        for _, m in ipairs(folder and folder:GetChildren() or {}) do
            local id = m:IsA("Model") and m:GetAttribute("ItemId")
            local cap = m:IsA("Model") and tonumber(m:GetAttribute("Capacity"))
            local accepts = m:GetAttribute("AcceptsType")
            if id and cap and (accepts == nil or accepts == petType) then
                tanks += 1
                room += math.max(math.floor((cap - (used[id] or 0)) / need), 0)
            end
        end
        local waiting = 0
        for _, b in ipairs(getBoxes()) do
            if isPetBox(b) and b:GetAttribute("PetType") == petType and b:GetAttribute("PetName") == petName then
                waiting += 1
            end
        end
        return room, waiting, tanks
    end

    Auto.fishSpace = petSpaceOf

    -- free tank space (in fish spots) for one pet type, counted per tank:
    --   "Tank empty": only tanks with NO fish in them count, each one with its full capacity
    --   "Always":     every free spot in every tank counts
    -- boxes already waiting (any fish of that type) are subtracted.
    -- returns: space still to fill, number of tanks that accept this pet type
    Auto.fishPool = function(petType, mode)
        local used = usageMap()
        local plot = AP.getPlot()
        local folder = plot and plot:FindFirstChild("Items")
        local tanks, emptySpace, freeSpace = 0, 0, 0
        for _, m in ipairs(folder and folder:GetChildren() or {}) do
            local id = m:IsA("Model") and m:GetAttribute("ItemId")
            local cap = m:IsA("Model") and tonumber(m:GetAttribute("Capacity"))
            local accepts = m:GetAttribute("AcceptsType")
            if id and cap and (accepts == nil or accepts == petType) then
                tanks += 1
                local u = used[id] or 0
                freeSpace += math.max(cap - u, 0)
                if u == 0 then emptySpace += cap end
            end
        end
        local waitingSpace = 0
        for _, b in ipairs(getBoxes()) do
            if isPetBox(b) and b:GetAttribute("PetType") == petType then
                waitingSpace += petSpaceOf(petType, b:GetAttribute("PetName"))
            end
        end
        local pool = (mode == "Always") and freeSpace or emptySpace
        return math.max(pool - waitingSpace, 0), tanks
    end

    -- nearest free fish box that some tank can still take (all tanks full -> nothing is picked up)
    local function nearestPetBox()
        if not (RCfg.FishRestock and PetsRem and PetsRem:FindFirstChild("PlacePetFromBox")) then return end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local used = usageMap()
        local roomCache = {}
        local best, bd
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Carrier") == nil and not Skip[boxKeyOf(b)] and isPetBox(b) then
                local ck = tostring(b:GetAttribute("PetType")) .. "/" .. tostring(b:GetAttribute("PetName"))
                if roomCache[ck] == nil then roomCache[ck] = #tanksFor(b, used) > 0 end
                if roomCache[ck] then
                    local d = (posOf(b) - hrp.Position).Magnitude
                    if not bd or d < bd then best, bd = b, d end
                end
            end
        end
        return best
    end

    -- ===== tell the user WHY a box can't be shelved =====
    -- (from the logger: every good has a SizeClass Small / Medium / Large, and each shelf type only holds certain sizes)
    local warned = {}
    local allGoodsCache

    local function allGoods()
        if allGoodsCache then return allGoodsCache end
        local list, cats = {}, {}
        local okF, folders = pcall(GC.categoryFolders)
        if okF and typeof(folders) == "table" then
            for _, v in ipairs(folders) do cats[#cats + 1] = typeof(v) == "Instance" and v.Name or tostring(v) end
        end
        if #cats == 0 then cats = { "Food", "Toys", "Habitat", "Equipment" } end
        for _, cat in ipairs(cats) do
            local okA, l = pcall(GC.allOf, cat)
            if okA and typeof(l) == "table" then
                for _, inst in ipairs(l) do
                    local name = typeof(inst) == "Instance" and inst.Name or tostring(inst)
                    local okI, item = pcall(GC.find, cat, name)
                    list[#list + 1] = (okI and item) or inst
                end
            end
        end
        allGoodsCache = list
        return list
    end

    local function sizeOf(item)
        return typeof(item) == "Instance" and item:GetAttribute("SizeClass") or nil
    end

    -- which sizes a shelf holds: ask the game's own rule against every good
    local function sizesHeldBy(sh)
        local set, out = {}, {}
        for _, g in ipairs(allGoods()) do
            local sz = sizeOf(g)
            if sz and not set[sz] then
                local okS, yes = pcall(SR.acceptsGood, sh, g)
                if okS and yes then set[sz] = true end
            end
        end
        for sz in pairs(set) do out[#out + 1] = sz end
        table.sort(out)
        return #out > 0 and table.concat(out, "/") or "?"
    end

    -- your shelves: how many, what each holds, and how many accept this good
    local function shelfReport(item)
        local plot = AP.getPlot()
        local folder = plot and plot:FindFirstChild("Items")
        local total, accepts, tally, order, held = 0, 0, {}, {}, {}
        for _, sh in ipairs(folder and folder:GetChildren() or {}) do
            if sh:IsA("Model") and sh:GetAttribute("ItemId") and SR.isShelf(sh) then
                total += 1
                local acc = SR.acceptsGood(sh, item) and true or false
                if acc then accepts += 1 end
                held[sh.Name] = held[sh.Name] or sizesHeldBy(sh)
                local label = sh.Name .. " (" .. held[sh.Name] .. ")"
                if not tally[label] then tally[label] = 0 order[#order + 1] = label end
                tally[label] += 1
                log("NOSHELF", "shelf", sh.Name, sh:GetAttribute("ItemId"), #SR.slotModels(sh) .. " slots", acc and "accepts" or "rejects")
            end
        end
        local parts = {}
        for _, label in ipairs(order) do
            parts[#parts + 1] = tally[label] > 1 and (tally[label] .. "x " .. label) or label
        end
        return total, accepts, table.concat(parts, ", ")
    end

    -- shelf models the client can see (shop copies) that DO hold this good: suggests what to buy
    local shelfCandidates
    local function shelfThatHolds(item)
        if not shelfCandidates then
            shelfCandidates = {}
            local seenName = {}
            for _, d in ipairs(RS:GetDescendants()) do
                if d:IsA("Model") and not seenName[d.Name] then
                    local ln = d.Name:lower()
                    if ln:find("shelf") or ln:find("rack") then
                        seenName[d.Name] = true
                        shelfCandidates[#shelfCandidates + 1] = d
                    end
                end
            end
        end
        local names = {}
        for _, m in ipairs(shelfCandidates) do
            local okS, yes = pcall(SR.acceptsGood, m, item)
            if okS and yes then names[#names + 1] = m.Name end
            if #names >= 3 then break end
        end
        return table.concat(names, ", ")
    end

    local function warnUnshelvable()
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Carrier") == nil and not Skip[boxKeyOf(b)] then
                local okI, item, goodKey = pcall(boxInfo, b)
                if okI and item and (warned[goodKey] or 0) < os.clock() and countRoom(b) == 0 then
                    local name = tostring(b:GetAttribute("GoodName"))
                    local label = (typeof(item) == "Instance" and item:GetAttribute("Label")) or name
                    local size = sizeOf(item) or "?"
                    local total, accepts, summary = shelfReport(item)
                    local msg
                    if total == 0 then
                        msg = label .. " (" .. size .. " good): you have no shelves yet. Place a shelf that holds " .. size .. " goods."
                    elseif accepts == 0 then
                        local try = shelfThatHolds(item)
                        msg = label .. " is a " .. size .. " good, so it needs a shelf that holds " .. size
                            .. " goods. Your shelves: " .. summary .. "."
                            .. (try ~= "" and (" Try: " .. try .. ".") or "")
                    else
                        msg = label .. ": the " .. accepts .. " shelf(s) that hold " .. size .. " goods are full or taken by other goods."
                    end
                    log("NOSHELF", name, size, total, summary, accepts)
                    WindUI:Notify({ Title = HUB_NAME, Content = msg, Icon = "info", Duration = 8 })
                    warned[goodKey] = os.clock() + (accepts == 0 and 90 or 300)
                end
            end
        end
    end

    -- Walks to a spot BESIDE the box (never onto it) and spams PickUpBox.
    -- If the character ends up on top of the box, or the server doesn't
    -- confirm within 1.5s, it moves to another side of the box and retries.
    local function pickUp(box)
        local key = boxKeyOf(box)
        local ch = lp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return false, "no character" end

        setNoclip(true)
        if Move.isTp() then
            for k = 0, RCfg.PickRetries do
                if not rActive() then return false, "stopped" end
                if box:GetAttribute("Carrier") == lp.UserId then return true end
                if not box.Parent then return false, "box vanished" end
                local tp = posOf(box)
                local off = CFrame.Angles(0, math.rad(90 * k), 0):VectorToWorldSpace(Vector3.new(RCfg.PickDist, 0, 0))
                Move.tp(Vector3.new(tp.X + off.X, 0, tp.Z + off.Z))
                local t1 = os.clock()
                while rActive() and os.clock() - t1 < 1.2 do
                    remoteFor(box, "PickUpBox"):FireServer(key)
                    task.wait(0.25)
                    if box:GetAttribute("Carrier") == lp.UserId then return true end
                    if not box.Parent then return false, "box vanished" end
                end
            end
            return false, "pickup not confirmed"
        end
        local tStart, lastFire, lastMove = os.clock(), 0, 0
        local attempt, arrivedAt, baseDir = 0, nil, nil

        -- a spot beside the box; each retry rotates to a new side
        local function standPoint(tp)
            if not baseDir then
                local away = Vector3.new(hrp.Position.X - tp.X, 0, hrp.Position.Z - tp.Z)
                baseDir = away.Magnitude > 0.5 and away.Unit or Vector3.new(0, 0, 1)
            end
            local dir = CFrame.Angles(0, math.rad(90 * attempt), 0):VectorToWorldSpace(baseDir)
            local radius = attempt % 2 == 0 and RCfg.PickDist or (RCfg.PickDist + 1)
            return Vector3.new(tp.X, hrp.Position.Y, tp.Z) + dir * radius
        end

        local function nextSpot(reason)
            attempt += 1
            arrivedAt = nil
            lastMove = os.clock()
            log("RESTOCK", "pickup reposition", attempt, reason)
        end

        while rActive() and os.clock() - tStart < 25 do
            if box:GetAttribute("Carrier") == lp.UserId then
                hum:MoveTo(hrp.Position)
                return true
            end
            if not box.Parent then return false, "box vanished" end
            if attempt > RCfg.PickRetries then return false, "pickup not confirmed" end

            local tp = posOf(box)
            local pos = hrp.Position
            local flatBox = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(tp.X, 0, tp.Z)).Magnitude
            local stand = standPoint(tp)
            local flatStand = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(stand.X, 0, stand.Z)).Magnitude
            local now = os.clock()

            if (pos - tp).Magnitude <= RCfg.FireFrom and now - lastFire > 0.25 then
                lastFire = now
                remoteFor(box, "PickUpBox"):FireServer(key)
            end

            if flatBox < 1.5 and now - lastMove > 0.6 then
                nextSpot("on top of box")
            elseif flatStand <= 1.2 then
                arrivedAt = arrivedAt or now
                if now - arrivedAt > 1.5 then nextSpot("no confirmation") end
            else
                arrivedAt = nil
            end

            hum:MoveTo(stand)
            task.wait(0.05)
        end
        return false, "pickup timeout"
    end

    local function dropBox(box)
        remoteFor(box, "DropBox"):FireServer()
        local tStart = os.clock()
        while os.clock() - tStart < 2 do
            if box.Parent == nil or box:GetAttribute("Carrier") ~= lp.UserId then
                return true
            end
            task.wait(0.1)
        end
        return false
    end

    -- returns: ok, reason, shelvesFull, shelfItemIdUsed
    -- onlyShelf (optional): try that shelf first, fall back to any shelf if the box doesn't fit there
    local function placeBox(box, onlyShelf)
        local boxKey = boxKeyOf(box)
        local item, goodKey, boxQty = boxInfo(box)
        if not item then return false, "item not in catalogue", false end
        local tried = {}
        for _ = 1, 15 do
            if not rActive() then return false, "stopped", false end
            if box:GetAttribute("Carrier") ~= lp.UserId then return false, "box no longer carried", false end
            local t = pickTarget(item, goodKey, boxQty, tried, onlyShelf)
                or (onlyShelf and pickTarget(item, goodKey, boxQty, tried))
            if not t then
                -- shelves full: always drop the box we're holding
                local dropped = dropBox(box)
                log("RESTOCK", "shelves full, box dropped", dropped)
                return false, "shelves full / no matching slot", true
            end
            tried[t.itemId .. ":" .. t.index] = true
            if walkToPos(function() return t.stand end, 1.5, 15) then
                local okC, res = pcall(function()
                    return GoodsRem.PlaceGoods:InvokeServer(boxKey, t.itemId, t.index)
                end)
                local o = GCO.classify(okC, res)
                log("RESTOCK", "PlaceGoods", t.itemId, t.index, o.kind, tostring(o.reason or o.remainder or ""))
                if o.kind == "consumed" then return true, "box emptied", false, t.itemId end
                if GCO.nextAction(o) == "stop" then return false, o.reason or o.kind, false end
                task.wait(0.3)
            end
        end
        return false, "too many attempts", false
    end

    -- fish: walk in front of a tank that has room and fire PlacePetFromBox({ boxKey, enclosureKey })
    -- returns: ok, reason, noRoom
    local petWarned = 0
    local function placePet(box)
        local boxKey = boxKeyOf(box)
        local rem = PetsRem and PetsRem:FindFirstChild("PlacePetFromBox")
        if not rem then return false, "PlacePetFromBox remote not found", false end

        local tanks = tanksFor(box)
        for i, t in ipairs(tanks) do
            if not rActive() then return false, "stopped", false end
            if box:GetAttribute("Carrier") ~= lp.UserId then
                return box.Parent == nil, "box no longer carried", false
            end
            if i > RCfg.EnclosureTry then break end

            -- stand just outside the tank, on the side we're coming from
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false, "no character", false end
            local center = t.model:GetPivot().Position
            local size = t.model:GetExtentsSize()
            local radius = math.max(size.X, size.Z) / 2 + 2
            local away = Vector3.new(hrp.Position.X - center.X, 0, hrp.Position.Z - center.Z)
            local dir = away.Magnitude > 0.5 and away.Unit or Vector3.new(0, 0, 1)
            local stand = Vector3.new(center.X, hrp.Position.Y, center.Z) + dir * radius

            if walkToPos(function() return stand end, 2, 15) then
                pcall(function()
                    rem:FireServer({ boxKey = boxKey, enclosureKey = t.id })
                end)
                local tStart = os.clock()
                while os.clock() - tStart < 2 do
                    task.wait(0.1)
                    if box.Parent == nil or box:GetAttribute("Carrier") ~= lp.UserId then
                        log("RESTOCK", "PlacePetFromBox ok", boxKey, t.id, t.model.Name)
                        return true, "box emptied", false
                    end
                end
                log("RESTOCK", "PlacePetFromBox no effect", boxKey, t.id, t.model.Name)
            end
        end

        if yielded then return false, "stopped", false end
        -- tanks got full while filling (or nothing worked): always drop the box we're holding
        Skip[boxKey] = true
        local dropped = dropBox(box)
        log("RESTOCK", "tanks full, box dropped", boxKey, #tanks, dropped)
        -- full tanks are normal, so stay quiet; only warn when a tank had room but placing failed
        if #tanks > 0 and os.clock() > petWarned then
            petWarned = os.clock() + 120
            WindUI:Notify({
                Title = HUB_NAME,
                Content = "Couldn't place " .. boxLabel(box) .. " in any tank.",
                Icon = "info",
                Duration = 8,
            })
        end
        return false, "no tank accepted the box", true
    end

    local function markFail(box, why)
        local key = boxKeyOf(box)
        FailCount[key] = (FailCount[key] or 0) + 1
        log("RESTOCK", "fail", box.Name, FailCount[key], tostring(why))
        if FailCount[key] >= RCfg.MaxFail then
            Skip[key] = true
            log("RESTOCK", "box skipped", box.Name)
        end
    end

    -- FULL RESTOCK: no loose box left but the fill session isn't done -> order the next round,
    -- wait for the boxes to appear and hand one back. Returns nil (and ends the session) when
    -- everything is full, cash ran out, nothing could be ordered, or it timed out.
    local function fillNext()
        if not Auto.fillActive() then return end
        if os.clock() - (Auto.fillStart or os.clock()) > RCfg.FillMax then
            Auto.fillEnd("timeout")
            return
        end
        rstatus("Full restock: ordering more boxes...")
        local bought, allFull, blocked = Auto.fillStep()
        if blocked then Auto.fillEnd("blocked (cash / refused)") return end
        if bought <= 0 then Auto.fillEnd(allFull and "all shelves full" or "nothing left to order") return end
        local t = os.clock()
        while rActive() and os.clock() - t < RCfg.FillWait do
            local b = nearestFreeBox() or nearestPetBox()
            if b then return b end
            task.wait(0.2)
        end
        Auto.fillEnd("boxes did not show up")
    end

    local function runRestock()
        local done, full, failed = 0, 0, 0
        local curShelf = nil   -- the shelf being filled right now: it gets finished before customers are served
        local worked = false   -- did we handle at least one box since this run started
        yielded = false
        for _ = 1, RCfg.MaxLoops do
            if not rActive() then break end

            -- 1. a box already in hand, unless it's marked to skip
            local box = workBox()
            if box and Skip[boxKeyOf(box)] then
                dropBox(box)
                box = nil
            end

            -- customers first: when someone is waiting, pause between boxes (never with a box in hand)
            if not box and worked and RCfg.Priority == "Customers first" and Auto.yield() then
                yielded = true
                rstatus("Customer waiting, restock paused")
                break
            end
            -- 2. otherwise grab the next box: first one that still fits the current shelf
            if not box then
                local nxt = curShelf and nearestFreeBox(curShelf) or nil
                if not nxt then
                    -- current shelf is done (full / no matching boxes left): customers get their turn now
                    curShelf = nil
                    if worked and Auto.yieldTask() then
                        yielded = true
                        rstatus("Interrupted, stepping aside")
                        break
                    end
                    nxt = nearestFreeBox() or nearestPetBox()
                end
                box = nxt
                if not box and Auto.fillActive() then box = fillNext() end
                if not box then break end
                worked = true
                rstatus("Picking up " .. boxLabel(box))
                local okP, why = pickUp(box)
                if not okP then
                    failed += 1
                    if not yielded then markFail(box, why) end
                    continue
                end
            end
            worked = true

            -- 3. shelve it
            local pet = isPetBox(box)
            rstatus((pet and "Placing fish " or "Shelving ") .. boxLabel(box))
            local okB, why, isFull, usedShelf
            if pet then
                okB, why, isFull = placePet(box)
                curShelf = nil
            else
                okB, why, isFull, usedShelf = placeBox(box, curShelf)
                if okB and usedShelf then curShelf = usedShelf else curShelf = nil end
            end
            if okB then
                done += 1
            elseif isFull then
                full += 1
            else
                failed += 1
                if not yielded then markFail(box, why) end
                if box.Parent and box:GetAttribute("Carrier") == lp.UserId then
                    dropBox(box)
                end
            end
            task.wait(0.3)
        end
        log("RESTOCK", "summary", done, full, failed)
        if yielded and not Auto.thiefNow() then rstatus("Customer waiting, restock paused") end
        return done, full, failed
    end

    Auto.clearSkip = function()
        for k in pairs(Skip) do Skip[k] = nil end
        for k in pairs(FailCount) do FailCount[k] = nil end
    end

    -- restock main loop
    task.spawn(function()
        local busy = false
        local lastClear = os.clock()
        local lastWarn = 0
        local lastScan, lastRunText = 0, ""
        while alive do
            task.wait(0.3)
            -- keep the Shelf scan line fresh while restock or buy is on
            if (Auto.restockOn or Auto.buyOn) and os.clock() - lastScan > 1.5 then
                lastScan = os.clock()
                local okS, txt = pcall(shelfSummary)
                if okS then
                    setScanText(txt .. (lastRunText ~= "" and ("  |  " .. lastRunText) or ""))
                end
            end
            if Auto.restockOn and not busy then
                if RCfg.DoGoods and os.clock() - lastWarn > 5 then
                    lastWarn = os.clock()
                    pcall(warnUnshelvable)
                end
                if os.clock() - lastClear > 120 then
                    Auto.clearSkip()
                    lastClear = os.clock()
                end
                local okH, has = pcall(function()
                    return workBox() ~= nil or nearestFreeBox() ~= nil or nearestPetBox() ~= nil
                end)
                -- no customer waiting = go right away (no idle delay, no gap between runs)
                local canGo = Auto.canLeaveDesk()
                -- full restock already started: customers wait, we finish the job first
                if not canGo and Auto.fillActive() and not Auto.thiefNow() and not deskHolds.care and not deskHolds.clean and RCfg.Priority ~= "Customers first" then canGo = true end
                if okH and has and not canGo then
                    rstatus(Auto.yield() and "Customer waiting, restock paused" or "Waiting for a quiet moment...")
                elseif okH and has then
                    busy = true
                    Auto.hold("restock", true) -- also stops the cashier from (re)starting a shift
                    -- a shift that is mid-start (lock + tap) must finish first
                    local tw = os.clock()
                    while Auto.cashierStarting and os.clock() - tw < 15 do task.wait(0.1) end
                    -- leave the register first: finish the current customer, then end the shift
                    if Auto.pauseCashier then pcall(Auto.pauseCashier) end
                    local okR, dn, fu, fa = pcall(runRestock)
                    if not okR then
                        log("ERR", "restock", dn)
                    else
                        lastRunText = ("Last run: %d placed, %d failed%s"):format(
                            dn or 0, fa or 0, yielded and " (paused for customers)" or "")
                    end
                    busy = false
                    Auto.hold("restock", false)
                    setNoclip(false)
                    if Auto.restockOn then rstatus("Waiting for boxes...") end
                elseif Auto.restockOn then
                    rstatus((RCfg.DoGoods or RCfg.FishRestock) and "Waiting for boxes..." or "No restock type selected")
                end
            end
        end
    end)

    -- ===== AUTO BUY =====
    local Selected, Map = {}, {}

    local lvLabel
    local function getLevel()
        if not (lvLabel and lvLabel.Parent) then
            lvLabel = nil
            for _, d in ipairs(pg:GetDescendants()) do
                if d:IsA("TextLabel") and d.Name == "Level" and d.Text:upper():match("^LV%s*%d+") then
                    lvLabel = d
                    break
                end
            end
        end
        if lvLabel then
            local n = tonumber(lvLabel.Text:match("%d+"))
            if n then return n end
        end
        local xp = lp:GetAttribute("Exp")
        if xp and LC.levelForXp then
            local okL, res = pcall(LC.levelForXp, xp)
            if okL and typeof(res) == "number" then return math.floor(res) end
        end
        return 1
    end
    Auto.getLevel = getLevel

    local function getCategories()
        local out = {}
        local okF, folders = pcall(GC.categoryFolders)
        if okF and typeof(folders) == "table" then
            for _, v in ipairs(folders) do
                out[#out + 1] = typeof(v) == "Instance" and v.Name or tostring(v)
            end
        end
        if #out == 0 then out = { "Food", "Toys", "Habitat", "Equipment" } end
        return out
    end

    -- every good unlocked at the current level, straight from the game's catalogue
    Auto.getOptions = function()
        local level = getLevel()
        local rows = {}
        for _, cat in ipairs(getCategories()) do
            local okA, list = pcall(GC.allOf, cat)
            if okA and typeof(list) == "table" then
                for _, inst in ipairs(list) do
                    local name = typeof(inst) == "Instance" and inst.Name or tostring(inst)
                    local okL, lv = pcall(LC.unlockLevelForGood, inst)
                    lv = okL and tonumber(lv) or 1
                    if lv <= level then
                        local sz = typeof(inst) == "Instance" and inst:GetAttribute("SizeClass")
                        table.insert(rows, {
                            label = cat .. "/" .. name .. (sz and (" [" .. sz .. "]") or ""),
                            cat = cat, name = name, lv = lv,
                        })
                    end
                end
            end
        end
        table.sort(rows, function(a, b)
            if a.lv ~= b.lv then return a.lv < b.lv end
            return a.label < b.label
        end)
        local values = {}
        Map = {}
        for _, r in ipairs(rows) do
            values[#values + 1] = r.label
            Map[r.label] = r
        end
        return values
    end

    Auto.setSelected = function(list)
        Selected = {}
        for _, label in ipairs(list) do Selected[label] = true end
        Auto.buyWake()
    end

    local function countBoxes(cat, name)
        local n = 0
        for _, b in ipairs(getBoxes()) do
            if b:GetAttribute("Category") == cat and b:GetAttribute("GoodName") == name then
                n = n + 1
            end
        end
        return n
    end

    local function buyOnce(cat, name)
        local okB, res = pcall(function()
            return GoodsRem.PurchaseGood:InvokeServer(cat, name)
        end)
        return okB and res == true
    end

    local bLast
    local function bstatus(text)
        if text ~= bLast then
            bLast = text
            setBuyStatus(text)
        end
    end
    local function bActive() return alive and Auto.buyOn end

    -- Auto Buy follows what the SHELVES need (game's own slot rules), on every shelf.
    -- Cooldown: a good we just bought is left alone for a moment so its boxes can appear.
    -- Refused: purchase was refused (usually not enough cash), retried when cash goes up.
    local Cooldown, Refused = {}, {}
    local buyBusy = false -- buyCycle / fillStep never order at the same time

    Auto.buyReset = function()
        Cooldown, Refused = {}, {}
        bLast = nil
    end

    -- shelf side of one good: slots that can take another box, total stock, slots it could start on
    local function shelfNeed(d)
        if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then return nil end
        local item = GC.find(d.cat, d.name)
        if not item then return nil end
        local goodKey = GC.keyOf(d.cat, d.name)
        local boxQty = SR.boxQuantityOf(item)
        local need, homes = 0, 0
        for _, c in ipairs(scanSlots(item, goodKey, boxQty)) do
            if c.pri <= 2 then need += 1 else homes += 1 end
        end
        local stock = 0
        local goods = PDC.getGoods()
        local data = typeof(goods) == "table" and goods.Shelves or nil
        if typeof(data) == "table" then
            for _, slots in pairs(data) do
                if typeof(slots) == "table" then
                    for _, rec in pairs(slots) do
                        if typeof(rec) == "table" and rec.Good == goodKey and typeof(rec.Qty) == "number" then
                            stock += rec.Qty
                        end
                    end
                end
            end
        end
        return need, stock, homes, item, goodKey
    end

    -- how full this good's shelves are (0..100): slots holding it that cannot take another box,
    -- out of every slot that holds it or is still empty
    local function fillPct(d)
        local plot = AP.getPlot()
        local items = plot and plot:FindFirstChild("Items")
        if not items then return 0 end
        local item = GC.find(d.cat, d.name)
        if not item then return 0 end
        local goodKey = GC.keyOf(d.cat, d.name)
        local boxQty = SR.boxQuantityOf(item)
        local goods = PDC.getGoods()
        local data = typeof(goods) == "table" and goods.Shelves or {}
        local total, full = 0, 0
        for _, sh in ipairs(items:GetChildren()) do
            local itemId = sh:IsA("Model") and sh:GetAttribute("ItemId")
            if itemId and SR.isShelf(sh) and SR.acceptsGood(sh, item) then
                local sd = typeof(data) == "table" and data[itemId] or nil
                for _, sl in ipairs(SR.slotModels(sh)) do
                    local idx = sl:GetAttribute("SlotIndex")
                    if idx and SR.goodsPartOf(sl) then
                        local rec = typeof(sd) == "table" and sd[tostring(idx)] or nil
                        local good = typeof(rec) == "table" and typeof(rec.Good) == "string" and rec.Good or nil
                        local qty = typeof(rec) == "table" and typeof(rec.Qty) == "number" and rec.Qty or 0
                        if good == goodKey or good == nil then
                            total += 1
                            if good == goodKey and qty > 0
                                and not GR.targetable({ good = good, qty = qty }, goodKey, boxQty) then
                                full += 1
                            end
                        end
                    end
                end
            end
        end
        return total > 0 and (full / total * 100) or 0
    end

    -- how many boxes to order. Second value = true when there is nowhere at all to put this good.
    local function planBuy(d)
        local need, stock, homes, item, goodKey = shelfNeed(d)
        if not need then return 0 end
        local waiting = countBoxes(d.cat, d.name)
        if need == 0 and stock == 0 and homes == 0 then
            return 0, waiting == 0, item, goodKey
        end
        local want
        local extra = RCfg.FullRun and homes or 0 -- full restock: also claim the free slots, not only the ones the good already owns
        if need == 0 and stock == 0 then
            want = homes -- not on any shelf yet: buy enough to claim every free slot, not just 1
        else
            -- the % threshold slider (below) is the only refill trigger now
            want = need + ((stock == 0) and extra or 0)
        end
        return math.max(want - waiting, 0), false, item, goodKey, want
    end

    local function warnNoRoom(d, item, goodKey)
        if (warned[goodKey] or 0) >= os.clock() then return end
        local label = (typeof(item) == "Instance" and item:GetAttribute("Label")) or d.name
        local size = sizeOf(item) or "?"
        local total, accepts, summary = shelfReport(item)
        local msg
        if total == 0 then
            msg = label .. " (" .. size .. " good): you have no shelves yet. Place a shelf that holds " .. size .. " goods. Not buying."
        elseif accepts == 0 then
            local try = shelfThatHolds(item)
            msg = label .. " is a " .. size .. " good, so it needs a shelf that holds " .. size
                .. " goods. Your shelves: " .. summary .. "."
                .. (try ~= "" and (" Try: " .. try .. ".") or "") .. " Not buying."
        else
            msg = label .. ": the " .. accepts .. " shelf(s) that hold " .. size .. " goods are full or taken by other goods. Not buying."
        end
        log("NOSHELF", d.name, size, total, summary, accepts)
        bstatus("Shelves full: " .. label)
        WindUI:Notify({ Title = HUB_NAME, Content = msg, Icon = "info", Duration = 8 })
        warned[goodKey] = os.clock() + (accepts == 0 and 90 or 300)
    end

    -- FULL RESTOCK step (called by the restock run): orders another round for every good in the
    -- fill session. A good leaves the session once nothing can take another box of it.
    -- returns: bought, allFull, blocked
    Auto.fillStep = function()
        local tw = os.clock()
        while buyBusy and os.clock() - tw < 15 do task.wait(0.2) end
        buyBusy = true
        local bought, allFull, blocked = 0, true, false
        local okF, e = pcall(function()
            for key, label in pairs(Auto.fillSet) do
                if not bActive() then blocked = true return end
                local d = Map[label]
                if not d then
                    Auto.fillSet[key] = nil
                else
                    local need, stock, homes = shelfNeed(d)
                    if not need then
                        allFull = false
                    else
                        local room = need + homes
                        if room <= 0 then
                            Auto.fillSet[key] = nil -- this good is full
                        else
                            allFull = false
                            local left = (Auto.fillQuota[key] or math.huge) - (Auto.fillOrdered[key] or 0)
                            if left <= 0 then
                                -- noted target reached: no more ordering for this good, even if customers emptied more shelves meanwhile
                                Auto.fillSet[key] = nil
                            end
                            local n = math.min(room - countBoxes(d.cat, d.name), left)
                            for i = 1, n do
                                if not bActive() then blocked = true return end
                                if buyOnce(d.cat, d.name) then
                                    bought += 1
                                    bstatus(("Full restock: buying %s (%d/%d)"):format(label, i, n))
                                    Auto.fillOrdered[key] = (Auto.fillOrdered[key] or 0) + 1
                                    task.wait(BCfg.BuyDelay)
                                else
                                    blocked = true
                                    Refused[key] = true
                                    bstatus("Purchase refused (not enough cash?): " .. label)
                                    log("BUY", "refused (full restock)", label)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
        buyBusy = false
        if not okF then log("ERR", "fillStep", e) blocked = true end
        return bought, allFull, blocked
    end

    -- Auto Buy only orders goods: remind once in a while that Auto Restock is what shelves them
    local restockNudge = 0
    local function nudgeRestock()
        if (Auto.restockOn and RCfg.DoGoods) or os.clock() < restockNudge then return end
        restockNudge = os.clock() + 120
        WindUI:Notify({
            Title = HUB_NAME,
            Content = "Auto Buy only orders goods. Turn on Auto Restock with \"Shelves (goods)\" picked (Stock tab) so the boxes get shelved.",
            Icon = "info",
            Duration = 6,
        })
    end

    local function buyCycle()
        local any, bought, refused, full = false, 0, false, false
        for label in pairs(Selected) do
            if not bActive() then return end
            local d = Map[label]
            if d then
                any = true
                local key = d.cat .. "/" .. d.name
                if (Cooldown[key] or 0) < os.clock() and not Refused[key] then
                    local n, noRoom, item, goodKey, want = planBuy(d)
                    -- refill only when this good's shelves dropped below the slider
                    if not noRoom and (want or 0) > 0 and not Auto.fillSet[key]
                        and fillPct(d) >= (BCfg.Threshold or 70) then
                        n, want = 0, 0
                    end
                    if (want or 0) > 0 and not noRoom and RCfg.FullRun and Auto.restockOn and RCfg.DoGoods then
                        -- start / join the full restock session: restock keeps going until this good is full
                        if next(Auto.fillSet) == nil then Auto.fillStart = os.clock() end
                        if not Auto.fillSet[key] then
                            -- note the target ONCE: boxes needed to fill this good right now.
                            -- Customers buying stock while we work do not move it.
                            local needS, _, homesS = shelfNeed(d)
                            Auto.fillQuota[key] = math.max((needS or 0) + (homesS or 0) - countBoxes(d.cat, d.name), 0)
                            Auto.fillOrdered[key] = 0
                            log("FILL", "target", label, Auto.fillQuota[key])
                        end
                        Auto.fillSet[key] = label
                    end
                    if Auto.fillSet[key] then
                        n = math.min(n, (Auto.fillQuota[key] or n) - (Auto.fillOrdered[key] or 0))
                    end
                    if noRoom then
                        full = true
                        warnNoRoom(d, item, goodKey)
                    elseif n > 0 then
                        for i = 1, n do
                            if not bActive() then return end
                            if buyOnce(d.cat, d.name) then
                                bought += 1
                                bstatus(("Buying %s (%d/%d)"):format(label, i, n))
                                if Auto.fillSet[key] then Auto.fillOrdered[key] = (Auto.fillOrdered[key] or 0) + 1 end
                                task.wait(BCfg.BuyDelay)
                            else
                                refused = true
                                Refused[key] = true
                                bstatus("Purchase refused (not enough cash?): " .. label)
                                log("BUY", "refused", label)
                                break
                            end
                        end
                        Cooldown[key] = os.clock() + BCfg.Cooldown
                    end
                end
            end
        end
        if not any then
            bstatus("Pick items in the dropdown")
        elseif bought > 0 then
            nudgeRestock()
        elseif not refused and not full and next(Refused) == nil then
            bstatus("Shelves stocked, waiting...")
        end
    end

    -- ===== events (no polling of purchases) =====
    -- wake: something changed, re-check the shelves once the burst of changes settles
    local wakeEv = Instance.new("BindableEvent")
    local pending = false
    Auto.buyWake = function()
        if Auto.buyOn then
            pending = true
            wakeEv:Fire()
        end
    end

    -- boxes appearing / being shelved, and customers leaving (they empty the shelves)
    local hookedPlot, hookConns = nil, {}
    local function hookPlot()
        local okP, plot = pcall(AP.getPlot)
        if not okP or typeof(plot) ~= "Instance" or plot == hookedPlot then return end
        hookedPlot = plot
        for _, c in ipairs(hookConns) do pcall(function() c:Disconnect() end) end
        hookConns = {}
        local boxes, npcs = plot:FindFirstChild("Boxes"), plot:FindFirstChild("NPCs")
        if boxes then
            hookConns[#hookConns + 1] = bind(boxes.ChildAdded, function() Auto.buyWake() end)
            hookConns[#hookConns + 1] = bind(boxes.ChildRemoved, function() Auto.buyWake() end)
        end
        if npcs then
            hookConns[#hookConns + 1] = bind(npcs.ChildRemoved, function() Auto.buyWake() end)
        end
    end

    -- a refused purchase is retried when cash goes up (at most once per 10s)
    local lastCash, lastRetry = lp:GetAttribute("Cash") or 0, 0
    bind(lp:GetAttributeChangedSignal("Cash"), function()
        local c = lp:GetAttribute("Cash") or 0
        local up = c > lastCash
        lastCash = c
        if up and Auto.buyOn and next(Refused) ~= nil and os.clock() - lastRetry >= 10 then
            lastRetry = os.clock()
            for k in pairs(Refused) do Refused[k] = nil end
            Auto.buyWake()
        end
    end)

    task.spawn(function()
        while alive do
            wakeEv.Event:Wait()
            while alive and pending do
                task.wait(0.6) -- let a burst of changes settle into one check
                pending = false
                if Auto.buyOn then
                    pcall(hookPlot)
                    if Auto.fillActive() or buyBusy then
                        -- the restock run is filling the shelves and does the ordering itself
                    elseif not Auto.canLeaveDesk() then
                        -- customers first: try again shortly
                        bstatus("Customer waiting, buying paused")
                        task.delay(2, Auto.buyWake)
                    else
                        buyBusy = true
                        local okR, e = pcall(buyCycle)
                        buyBusy = false
                        if not okR then log("ERR", "buy", e) end
                    end
                end
            end
        end
    end)

    -- slow safety net: reads local data only, in case a change had no event (e.g. you moved to another plot)
    task.spawn(function()
        while alive do
            task.wait(BCfg.Safety)
            pcall(hookPlot)
            Auto.buyWake()
        end
    end)
end

-- =====================================================================
-- FISH TANK (Auto Buy Fish)
-- =====================================================================
local Fish = { on = false, ready = false }
local FCfg = {
    Types = { "Fish" },  -- nil = semua tipe pet yang kebuka di level lo
    Mode = "Tank empty", -- Buy when: "Tank empty" (isi tank yang kosong sampai penuh) / "Always"
    CashReserve = 500,   -- jangan belanja kalau cash jadi di bawah ini
    BuyDelay = 0.4,      -- detik antar pembelian
    Cooldown = 6,        -- detik ikan dibiarin setelah dibeli, biar box-nya sempet muncul
    Safety = 15,         -- detik antar re-check lokal (tanpa remote) kalau ada event kelewat
}
Fish.FCfg = FCfg
Fish.getOptions = function() return {} end
Fish.getLevel = function() return 1 end
Fish.setSelected = function() end
Fish.setEnabled = function() end
Fish.wake = function() end
local setFishStatus = function() end

do
    local okM, FM = pcall(function()
        local folder = RS:WaitForChild("Modules", 10)
        local pets = remotesFolder:WaitForChild("Pets", 10)
        return {
            PC = require(folder.PetCatalogue),
            LC = require(folder.LevelConfig),
            Purchase = pets:WaitForChild("PurchaseCrate", 10),
        }
    end)

    if okM and FM and FM.PC and FM.LC and FM.Purchase and Auto.fishRoom then
        Fish.ready = true
        local PC, LC, Purchase = FM.PC, FM.LC, FM.Purchase
        local Selected, Map = {}, {}
        -- Cooldown: a fish we just bought is left alone for a moment so its box can appear.
        -- Refused: purchase was refused (usually not enough cash), retried when cash goes up.
        local Cooldown, Refused = {}, {}
        local wakeEv = Instance.new("BindableEvent")
        local pending = false
        Fish.wake = function()
            if Fish.on then
                pending = true
                wakeEv:Fire()
            end
        end

        local lastStatus
        local function fstatus(text)
            if text ~= lastStatus then
                lastStatus = text
                setFishStatus(text)
            end
        end

        local function level()
            local okL, lv = pcall(LC.levelForXp, lp:GetAttribute("Exp") or 0)
            return okL and tonumber(lv) and math.floor(lv) or 1
        end
        Fish.getLevel = level

        -- tipe pet yang level unlock-nya udah tercapai (yang butuh wing pass dilewat)
        local function unlockedTypes(lv)
            local list = {}
            for _, t in ipairs(FCfg.Types or LC.TYPE_ORDER) do
                local okU, need = pcall(LC.typeUnlockLevel, t)
                local okR, req = pcall(LC.typeRequirement, t)
                if okU and (tonumber(need) or 1) <= lv and not (okR and req) then
                    list[#list + 1] = t
                end
            end
            return list
        end

        -- isi dropdown: semua item yang kebuka di level sekarang
        Fish.getOptions = function()
            local lv = level()
            local rows = {}
            for _, t in ipairs(unlockedTypes(lv)) do
                local okA, all = pcall(PC.allOf, t)
                for _, inst in ipairs(okA and all or {}) do
                    local locked = false
                    for k, v in pairs(inst:GetAttributes()) do
                        k = k:lower()
                        if (k:find("level") or k:find("unlock")) and type(v) == "number" and v > lv then
                            locked = true
                        end
                    end
                    if not locked and not inst:GetAttribute("OffSale") then
                        local rarity = inst:GetAttribute("Rarity")
                        local price = tonumber(inst:GetAttribute("Price")) or 0
                        rows[#rows + 1] = {
                            label = t .. "/" .. inst.Name .. (rarity and (" [" .. rarity .. "]") or ""),
                            type = t, name = inst.Name, price = price,
                        }
                    end
                end
            end
            table.sort(rows, function(a, b)
                if a.price ~= b.price then return a.price < b.price end
                return a.label < b.label
            end)
            local values = {}
            Map = {}
            for _, r in ipairs(rows) do
                values[#values + 1] = r.label
                Map[r.label] = r
            end
            return values
        end

        Fish.setSelected = function(list)
            Selected = {}
            for _, label in ipairs(list) do Selected[label] = true end
            Fish.wake()
        end

        -- toggle: tiap kali dinyalain, counter beli di-reset
        Fish.setEnabled = function(v)
            Fish.on = v and true or false
            if Fish.on then
                Cooldown, Refused = {}, {}
                lastStatus = nil
                if not next(Map) then Fish.getOptions() end
            end
            fstatus(Fish.on and "Running..." or "Stopped")
            Fish.wake()
        end

        -- sukses = server bilang yes ATAU cash lo berkurang
        local function buyOnce(r)
            local before = lp:GetAttribute("Cash") or 0
            local okC, res = pcall(Purchase.InvokeServer, Purchase, r.type, r.name)
            task.wait(0.15)
            local after = lp:GetAttribute("Cash") or 0
            return okC and (res == true or after < before)
        end

        -- One cycle. Fish are grouped by pet type (each type has its own tanks). Inside a group the free
        -- tank space is shared out one fish at a time, round and round over the picked fish (cheapest first),
        -- so picking 4 fish for 1 tank of 10 spots gives 3/3/2/2 instead of 10 of just one kind.
        local warnedFish = {}
        local function buyList(r, n)
            local key = r.type .. "/" .. r.name
            local label = r.type .. "/" .. r.name
            local got, refused, noCash = 0, false, false
            for i = 1, n do
                if not (alive and Fish.on) then return got, refused, noCash, true end
                local cash = lp:GetAttribute("Cash") or 0
                if cash - r.price < FCfg.CashReserve then
                    noCash = true
                    Refused[key] = true -- retried when cash goes up
                    break
                end
                if buyOnce(r) then
                    got += 1
                    fstatus(("Buying %s (%d/%d)"):format(r.name, i, n))
                    task.wait(FCfg.BuyDelay)
                else
                    refused = true
                    Refused[key] = true
                    fstatus("Purchase refused (not enough cash?): " .. r.name)
                    log("FISH", "refused", label)
                    break
                end
            end
            Cooldown[key] = os.clock() + FCfg.Cooldown
            return got, refused, noCash, false
        end

        local function cycle()
            local any, bought, refused, noCash, full = false, 0, false, false, false
            local groups = {}
            for label in pairs(Selected) do
                local r = Map[label]
                if r then
                    any = true
                    groups[r.type] = groups[r.type] or {}
                    table.insert(groups[r.type], r)
                end
            end

            for ptype, list in pairs(groups) do
                table.sort(list, function(a, b)
                    if a.price ~= b.price then return a.price < b.price end
                    return a.name < b.name
                end)
                local okP, space, tanks = pcall(Auto.fishPool, ptype, FCfg.Mode)
                if okP then
                    if tanks == 0 then
                        full = true
                        fstatus("No tank accepts " .. ptype)
                        if (warnedFish[ptype] or 0) < os.clock() then
                            warnedFish[ptype] = os.clock() + 120
                            log("FISH", "no tank", ptype)
                            WindUI:Notify({
                                Title = HUB_NAME,
                                Content = "You have no " .. ptype .. " tank to put them in. Not buying.",
                                Icon = "info", Duration = 8,
                            })
                        end
                    else
                        -- share the space: one fish per picked fish per round
                        local counts, remaining, progress = {}, space, true
                        while progress do
                            progress = false
                            for _, r in ipairs(list) do
                                local key = r.type .. "/" .. r.name
                                if (Cooldown[key] or 0) < os.clock() and not Refused[key] then
                                    local need = Auto.fishSpace(r.type, r.name)
                                    if need <= remaining then
                                        remaining -= need
                                        counts[key] = (counts[key] or 0) + 1
                                        progress = true
                                    end
                                end
                            end
                        end
                        for _, r in ipairs(list) do
                            local n = counts[r.type .. "/" .. r.name] or 0
                            if n > 0 then
                                local got, ref, nc, stop = buyList(r, n)
                                if stop then return end
                                bought += got
                                refused = refused or ref
                                noCash = noCash or nc
                            end
                        end
                    end
                end
            end

            if not any then
                fstatus("Pick fish in the dropdown")
            elseif noCash and bought == 0 then
                fstatus("Not enough cash")
            elseif bought == 0 and not refused and not full and not noCash and next(Refused) == nil then
                fstatus("Tanks full, waiting...")
            end
        end

        -- ===== events (no polling) =====
        -- boxes appearing / being placed into a tank (that is when tank room changes)
        local hookedPlot, hookConns = nil, {}
        local function hookPlot()
            local plot = Auto.getPlot()
            if not plot or plot == hookedPlot then return end
            hookedPlot = plot
            for _, c in ipairs(hookConns) do pcall(function() c:Disconnect() end) end
            hookConns = {}
            local boxes, items = plot:FindFirstChild("Boxes"), plot:FindFirstChild("Items")
            if boxes then
                hookConns[#hookConns + 1] = bind(boxes.ChildAdded, function() Fish.wake() end)
                hookConns[#hookConns + 1] = bind(boxes.ChildRemoved, function() Fish.wake() end)
            end
            if items then -- a new / removed tank changes the room
                hookConns[#hookConns + 1] = bind(items.ChildAdded, function() Fish.wake() end)
                hookConns[#hookConns + 1] = bind(items.ChildRemoved, function() Fish.wake() end)
            end
        end

        -- a refused purchase is retried when cash goes up (at most once per 10s)
        local lastCash, lastRetry = lp:GetAttribute("Cash") or 0, 0
        bind(lp:GetAttributeChangedSignal("Cash"), function()
            local c = lp:GetAttribute("Cash") or 0
            local up = c > lastCash
            lastCash = c
            if up and Fish.on and next(Refused) ~= nil and os.clock() - lastRetry >= 10 then
                lastRetry = os.clock()
                for k in pairs(Refused) do Refused[k] = nil end
                Fish.wake()
            end
        end)

        task.spawn(function()
            while alive do
                wakeEv.Event:Wait()
                while alive and pending do
                    task.wait(0.6) -- let a burst of changes settle into one check
                    pending = false
                    if Fish.on then
                        pcall(hookPlot)
                        if not Auto.canLeaveDesk() then
                            -- customers first: try again shortly
                            fstatus("Customer waiting, buying paused")
                            task.delay(2, Fish.wake)
                        else
                            local okC, e = pcall(cycle)
                            if not okC then log("ERR", "fish", e) end
                        end
                    end
                end
            end
        end)

        -- slow safety net: reads local data only, in case a change had no event (e.g. you moved to another plot)
        task.spawn(function()
            while alive do
                task.wait(FCfg.Safety)
                pcall(hookPlot)
                Fish.wake()
            end
        end)
    end
end

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
Tabs.Home = Window:Tab({ Title = "Home", Icon = icon("house", "home"),       IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Cashier = Window:Tab({ Title = "Cashier", Icon = icon("banknote", "house"),   IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Stock = Window:Tab({ Title = "Stock", Icon = icon("package", "shopping-cart"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Fish = Window:Tab({ Title = "Fish Tank", Icon = icon("fish", "paw-print"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Security = Window:Tab({ Title = "Security", Icon = icon("shield", "shield-check", "info"), IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })
Tabs.Misc = Window:Tab({ Title = "Misc", Icon = icon("info"),                IconColor = Color3.fromHex("#FF8200"), IconShape = "Circle" })

-- sections start closed (Main / Misc)
local function section(tab, title, iconName)
    return tab:Section({ Title = title, Icon = icon(iconName), Box = true, BoxBorder = true, Opened = false })
end

-- sections start open (Home, info that should be read)
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

-- ===== CASHIER TAB =====
-- layout rule for every feature: main toggle on top, then what / how much, then the live status
local CashierBox = openSection(Tabs.Cashier, "Auto Cashier", "banknote")
CashierBox:Toggle({
    Title = "Auto Cashier",
    Desc = "Serves customers at the register for you.",
    Value = false,
    Callback = function(v)
        cashRunning = v
        if v then
            cLastRun = {}
            lastCashPhase = "waiting"
            shiftOn = false
            returnPos = nil
            setCashierStatus("Waiting for a customer...")
        else
            endShift()
            setCashierStatus("Stopped")
        end
    end,
})
local CashierStatusP = CashierBox:Paragraph({ Title = "Status", Desc = cStatus })
setCashierStatus = function(text)
    cStatus = text
    pcall(function() CashierStatusP:SetDesc(text) end)
end

-- ===== STOCK TAB =====
local RestockBox = openSection(Tabs.Stock, "Auto Restock", "package")
RestockBox:Toggle({
    Title = "Auto Restock",
    Desc = "Picks up boxes and stocks them on shelves or in fish tanks.",
    Value = false,
    Callback = function(v)
        if v and not Auto.ready then
            gameMissing("Game modules not found, Auto Restock can't run.")
            return
        end
        Auto.restockOn = v
        if v then Auto.clearSkip() else Auto.setNoclip(false) Auto.fillEnd("restock off") end
        setRestockStatus(v and "Running..." or "Stopped")
    end,
})
RestockBox:Dropdown({
    Title = "Restock what",
    Desc = "Choose whether Auto Restock handles shelves, fish tanks, or both.",
    Flag = "RestockTypes",
    Values = { "Shelves (goods)", "Fish tanks" },
    Value = { "Shelves (goods)", "Fish tanks" },
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        local list = {}
        if type(v) == "table" then
            for _, x in ipairs(v) do list[#list + 1] = pickValue(x) end
        elseif v ~= nil then
            list[1] = pickValue(v)
        end
        local goods, fish = false, false
        for _, label in ipairs(list) do
            if label == "Shelves (goods)" then goods = true
            elseif label == "Fish tanks" then fish = true end
        end
        Auto.RCfg.DoGoods = goods
        Auto.RCfg.FishRestock = fish
    end,
})
RestockBox:Toggle({
    Title = "Full restock (finish before cashier)",
    Desc = "Keeps restocking until everything's full before letting the cashier take over.",
    Value = true,
    Flag = "FullRestock",
    Callback = function(v)
        Auto.RCfg.FullRun = v
        if not v then Auto.fillEnd("full restock off") end
    end,
})
RestockBox:Toggle({
    Title = "Reuse empty slots of other goods",
    Desc = "Allows restock to use empty slots that belong to another good.",
    Value = false,
    Callback = function(v) Auto.RCfg.Reassign = v end,
})
RestockBox:Dropdown({
    Title = "Priority",
    Desc = "Finish restock first: completes the whole restock before serving customers. Serve customers first: pauses restocking to serve waiting customers.",
    Flag = "RestockPriority",
    Values = { "Finish restock first", "Serve customers first" },
    Value = "Finish restock first",
    Callback = function(v)
        Auto.RCfg.Priority = pickValue(v):find("customers") and "Customers first" or "Restock first"
    end,
})
local RestockStatusP = RestockBox:Paragraph({ Title = "Status", Desc = "Ready" })
setRestockStatus = function(text)
    pcall(function() RestockStatusP:SetDesc(text) end)
end

-- Auto Buy
local BuyBox = openSection(Tabs.Stock, "Auto Buy", "shopping-cart")
BuyBox:Toggle({
    Title = "Auto Buy",
    Desc = "Orders the goods you picked when your shelves need them. Turn on Auto Restock too so the boxes get shelved.",
    Value = false,
    Callback = function(v)
        if v and not Auto.ready then
            gameMissing("Game modules not found, Auto Buy can't run.")
            return
        end
        Auto.buyOn = v
        if v then Auto.buyReset() else Auto.fillEnd("buy off") end
        setBuyStatus(v and "Running..." or "Stopped")
        if v then Auto.buyWake() end
    end,
})
local BuyDropdown = BuyBox:Dropdown({
    Title = "Goods to buy",
    Desc = "Pick which goods Auto Buy orders. List grows as you level up.",
    Flag = "BuyItems",
    Values = Auto.getOptions(),
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        local list = {}
        if type(v) == "table" then
            for _, x in ipairs(v) do list[#list + 1] = pickValue(x) end
        elseif v ~= nil then
            list[1] = pickValue(v)
        end
        Auto.setSelected(list)
    end,
})
BuyBox:Slider({
    Title = "Refill when shelves below (%)",
    Desc = "Orders more once shelf stock drops below this percent. 100 = refill the moment anything's missing.",
    Flag = "BuyThreshold",
    Step = 5,
    Value = { Min = 10, Max = 100, Default = 70 },
    Callback = function(v)
        Auto.BCfg.Threshold = v
        Auto.buyWake()
    end,
})
local BuyStatusP = BuyBox:Paragraph({ Title = "Status", Desc = "Ready" })
setBuyStatus = function(text)
    pcall(function() BuyStatusP:SetDesc(text) end)
end

-- refresh the dropdown whenever your level goes up
task.spawn(function()
    local lv = Auto.getLevel()
    while alive do
        task.wait(Auto.BCfg.LevelCheck)
        local now = Auto.getLevel()
        if now ~= lv then
            lv = now
            local values = Auto.getOptions()
            pcall(function() BuyDropdown:Refresh(values) end)
            WindUI:Notify({
                Title = HUB_NAME,
                Content = "Level " .. now .. ": goods list updated (" .. #values .. " goods)",
                Icon = "check",
                Duration = 3,
            })
        end
    end
end)

-- ===== FISH TANK TAB =====
Tabs.Fish:Paragraph({
    Title = "Restocking fish boxes?",
    Desc = "That lives in Stock > Auto Restock. Pick \"Fish tanks\" in Restock what.",
})

local FishBox = openSection(Tabs.Fish, "Auto Buy Fish", "fish")
FishBox:Toggle({
    Title = "Auto Buy Fish",
    Desc = "Orders the fish you picked based on your tanks. Turn on Auto Restock with \"Fish tanks\" picked so the boxes get placed.",
    Value = false,
    Callback = function(v)
        if v and not Fish.ready then
            gameMissing("Fish modules not found, Auto Buy Fish can't run.")
            return
        end
        Fish.setEnabled(v)
    end,
})
local FishDropdown = FishBox:Dropdown({
    Title = "Fish to buy",
    Desc = "Pick which fish Auto Buy Fish orders. List grows as you level up.",
    Flag = "FishItems",
    Values = Fish.getOptions(),
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        local list = {}
        if type(v) == "table" then
            for _, x in ipairs(v) do list[#list + 1] = pickValue(x) end
        elseif v ~= nil then
            list[1] = pickValue(v)
        end
        Fish.setSelected(list)
    end,
})
FishBox:Dropdown({
    Title = "Buy when",
    Desc = "Tank empty: only refills tanks with no fish left. Always: fills any open spot right away.",
    Flag = "FishBuyWhen",
    Values = { "Tank empty", "Always" },
    Value = "Tank empty",
    Callback = function(v)
        Fish.FCfg.Mode = pickValue(v)
        Fish.wake()
    end,
})
local FishStatusP = FishBox:Paragraph({ Title = "Status", Desc = "Ready" })
setFishStatus = function(text)
    pcall(function() FishStatusP:SetDesc(text) end)
end

-- refresh the fish dropdown whenever your level goes up
task.spawn(function()
    local lv = Fish.getLevel()
    while alive do
        task.wait(5)
        local now = Fish.getLevel()
        if now ~= lv then
            lv = now
            pcall(function() FishDropdown:Refresh(Fish.getOptions()) end)
        end
    end
end)

-- =====================================================================
-- AUTO CARE (Fish Tank): feed / clean / replace filter
-- =====================================================================
do
    local Care = { on = false }
    local CCfg = {
        Threshold = 60,   -- care kalau bar di bawah ini
        Feats = { Food = true, Glass = true, Filter = true },
        Wait = 4,         -- jangan di bawah 3
        Interval = 1,
        RunGap = 0,       -- Auto Cashier on: jeda minimum antar run (0 = langsung)
        Backoff = 60,     -- detik skip setelah gagal
    }
    local CBackoff = {}
    local CareStatusP, lastS
    local function cstatus(t)
        if t ~= lastS then
            lastS = t
            pcall(function() CareStatusP:SetDesc(t) end)
        end
    end

    -- popup so the user always knows what Auto Care is doing
    local function cnotify(text, iconName, dur)
        WindUI:Notify({
            Title = "Auto Care",
            Content = text,
            Icon = iconName or icon("heart", "info"),
            Duration = dur or 4,
        })
    end

    -- dropdown label <-> game feature name, plus a readable verb for the popups
    local CARE_TYPES = {
        { label = "Feed (Food)",       feat = "Food",   verb = "feeding" },
        { label = "Clean (Glass)",     feat = "Glass",  verb = "cleaning the glass" },
        { label = "Replace (Filter)",  feat = "Filter", verb = "replacing the filter" },
    }
    local CARE_FEAT, CARE_VERB = {}, {}
    for _, t in ipairs(CARE_TYPES) do
        CARE_FEAT[t.label] = t.feat
        CARE_VERB[t.feat] = t.verb
    end

    local EnclRem = remotesFolder:FindFirstChild("Enclosures")
    local Begin = EnclRem and EnclRem:FindFirstChild("BeginCare")
    local Complete = EnclRem and EnclRem:FindFirstChild("CompleteCare")
    local Cancel = EnclRem and EnclRem:FindFirstChild("CancelCare")
    local careReady = (Begin and Complete and Cancel) and true or false

    local function active() return alive and Care.on and not Auto.thiefNow() end

    -- restock / buy nunggu selama care jalan
    local baseCanLeave = Auto.canLeaveDesk
    Auto.canLeaveDesk = function()
        if deskHolds.care then return false end
        return baseCanLeave()
    end

    local function myPlot()
        if Mods and Mods.AP then
            local okP, p = pcall(Mods.AP.getPlot)
            if okP and typeof(p) == "Instance" then return p end
        end
        local plots = workspace:FindFirstChild("Plots")
        for _, p in ipairs(plots and plots:GetChildren() or {}) do
            if p:GetAttribute("OwnerUserId") == lp.UserId then return p end
        end
    end

    local function tanksNeeding()
        local plot = myPlot()
        local items = plot and plot:FindFirstChild("Items")
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local list = {}
        if not (items and hrp) then return list end
        for _, m in ipairs(items:GetChildren()) do
            local id = m:IsA("Model") and m:GetAttribute("ItemId")
            local feats = m:IsA("Model") and m:GetAttribute("MaintenanceFeatures")
            if id and feats and m:GetAttribute("AcceptsType") == "Fish" then
                local need = {}
                for f in tostring(feats):gmatch("[^,]+") do
                    local c = tonumber(m:GetAttribute("MaintenanceCondition_" .. f))
                    if CCfg.Feats[f] and c and c < CCfg.Threshold
                        and (CBackoff[id .. ":" .. f] or 0) < os.clock() then
                        need[#need + 1] = { feat = f, cond = c }
                    end
                end
                if #need > 0 then
                    list[#list + 1] = {
                        id = id, model = m, need = need,
                        dist = (m:GetPivot().Position - hrp.Position).Magnitude,
                    }
                end
            end
        end
        table.sort(list, function(a, b) return a.dist < b.dist end)
        return list
    end

    -- jalan kaki ke sisi tank yang searah posisi kita (noclip cuma pas jalan)
    local function walkNear(model, pad)
        local ch = lp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return false end
        local center = model:GetPivot().Position
        local size = model:GetExtentsSize()
        local radius = math.max(size.X, size.Z) / 2 + pad
        local p0 = hrp.Position
        local flat = Vector3.new(p0.X - center.X, 0, p0.Z - center.Z)
        if flat.Magnitude <= radius + 0.5 then return true end
        local dir = flat.Magnitude > 0.5 and flat.Unit or Vector3.new(0, 0, 1)
        local stand = Vector3.new(center.X, p0.Y, center.Z) + dir * radius

        NC("care", true)
        if Move.isTp() then
            NC("care", false)
            return Move.tp(stand)
        end
        local tw0, lastPos, lastMove = os.clock(), p0, os.clock()
        while active() and os.clock() - tw0 < 30 do
            local p = hrp.Position
            if Vector3.new(p.X - stand.X, 0, p.Z - stand.Z).Magnitude <= 1.5 then
                hum:MoveTo(p)
                NC("care", false)
                return true
            end
            hum:MoveTo(stand)
            if (p - lastPos).Magnitude > 1 then
                lastPos, lastMove = p, os.clock()
            elseif os.clock() - lastMove > 2 then
                hum.Jump = true
                lastMove = os.clock()
            end
            task.wait(0.1)
        end
        NC("care", false)
        return false
    end

    local function careOnce(id, feat)
        local okB, b = pcall(function()
            return Begin:InvokeServer({ itemKey = id, feature = feat })
        end)
        if not (okB and type(b) == "table" and b.ok and b.token) then return false, "begin" end
        local tc = os.clock()
        while active() and os.clock() - tc < CCfg.Wait do task.wait(0.1) end
        if not active() then
            pcall(function() Cancel:FireServer(b.token) end)
            return false, "stopped"
        end
        local okC, c = pcall(function()
            return Complete:InvokeServer({ itemKey = id, token = b.token, quiet = true, feature = feat })
        end)
        if okC and type(c) == "table" and c.ok then return true end
        pcall(function() Cancel:FireServer(b.token) end)
        return false, "complete"
    end

    -- returns: actions done, tanks served, actions failed
    local function runCare(list)
        local done, tanks, failed = 0, 0, 0
        for i, e in ipairs(list) do
            if not active() then break end
            if Auto.yieldTask() then
                cstatus("Interrupted, stepping aside")
                break
            end

            local verbs = {}
            for _, n in ipairs(e.need) do verbs[#verbs + 1] = CARE_VERB[n.feat] or n.feat end
            cstatus("Walking to tank " .. e.id)
            cnotify(("Tank %d/%d: heading there for %s"):format(i, #list, table.concat(verbs, ", ")))

            if walkNear(e.model, 2) then
                local did = 0
                for _, n in ipairs(e.need) do
                    if not active() or Auto.yieldTask() then break end
                    cstatus(("Care %s on %s (%d)"):format(n.feat, e.id, n.cond))
                    local okK, why = careOnce(e.id, n.feat)
                    if not okK and why == "begin" and walkNear(e.model, 0) then
                        okK, why = careOnce(e.id, n.feat)
                    end
                    if okK then
                        did += 1
                        done += 1
                        log("CARE", "ok", e.id, n.feat)
                    elseif why ~= "stopped" then
                        failed += 1
                        CBackoff[e.id .. ":" .. n.feat] = os.clock() + CCfg.Backoff
                        log("CARE", "fail", e.id, n.feat, why)
                    end
                    task.wait(0.4)
                end
                if did > 0 then tanks += 1 end
            elseif active() then
                for _, n in ipairs(e.need) do
                    failed += 1
                    CBackoff[e.id .. ":" .. n.feat] = os.clock() + CCfg.Backoff
                end
                log("CARE", "walk failed", e.id)
            end
        end
        return done, tanks, failed
    end

    task.spawn(function()
        local busy, lastRun = false, -1e9
        while alive do
            task.wait(CCfg.Interval)
            if Care.on and not busy then
                if next(CCfg.Feats) == nil then
                    cstatus("No care type selected")
                else
                    local list = tanksNeeding()
                    if #list == 0 then
                        cstatus("All tanks above threshold")
                    elseif deskHolds.restock or deskHolds.buy or deskHolds.thief or deskHolds.clean then
                        cstatus("Waiting for restock/buy to finish...")
                    elseif Auto.thiefNow() or (cashRunning and os.clock() - lastRun < CCfg.RunGap) then
                        cstatus(Auto.thiefNow() and "Thief on the plot, waiting..." or "Waiting between runs...")
                    else
                        busy = true
                        Auto.hold("care", true)
                        local tw = os.clock()
                        while Auto.cashierStarting and os.clock() - tw < 15 do task.wait(0.1) end
                        if Auto.pauseCashier then pcall(Auto.pauseCashier) end
                        local okR, done, tanks, failed = pcall(runCare, list)
                        if not okR then
                            log("ERR", "care", done)
                        elseif active() then
                            if done > 0 then
                                cnotify(("Done: %d action(s) on %d tank(s)"):format(done, tanks), icon("check", "info"))
                            end
                            if failed > 0 then
                                cnotify(("%d action(s) failed, retrying in %ds"):format(failed, CCfg.Backoff), icon("x", "info"))
                            end
                        end
                        Auto.hold("care", false)
                        NC("care", false)
                        lastRun = os.clock()
                        busy = false
                        if Care.on then cstatus("Waiting for tanks to need care...") end
                    end
                end
            end
        end
    end)

    -- GUI (tab Fish Tank): toggle first, then what / when, then the live status
    local CareBox = openSection(Tabs.Fish, "Auto Care", "heart")
    CareBox:Toggle({
        Title = "Auto Care",
        Desc = "Feeds, cleans and maintains your fish tanks for you. Don't open the tank panel while it runs.",
        Value = false,
        Callback = function(v)
            if v and not careReady then
                gameMissing("Care remotes not found, Auto Care can't run.")
                return
            end
            Care.on = v
            if v then CBackoff = {} end
            cstatus(v and "Running..." or "Stopped")
            if v then
                if next(CCfg.Feats) == nil then
                    cnotify("Pick at least one care type first.", icon("info"))
                else
                    cnotify("Enabled. Watching your tanks below " .. CCfg.Threshold .. ".", icon("check", "info"))
                end
            else
                cnotify("Disabled.", icon("x", "info"), 3)
            end
        end,
    })

    -- one dropdown instead of three toggles (all selected by default)
    local careValues, careDefault = {}, {}
    for _, t in ipairs(CARE_TYPES) do
        careValues[#careValues + 1] = t.label
        careDefault[#careDefault + 1] = t.label
    end
    CareBox:Dropdown({
        Title = "Care types",
        Desc = "Pick which care tasks Auto Care performs.",
        Flag = "CareTypes",
        Values = careValues,
        Value = careDefault,
        Multi = true,
        AllowNone = true,
        Callback = function(v)
            local list, feats = {}, {}
            if type(v) == "table" then
                for _, x in ipairs(v) do list[#list + 1] = pickValue(x) end
            elseif v ~= nil then
                list[1] = pickValue(v)
            end
            for _, label in ipairs(list) do
                local f = CARE_FEAT[label]
                if f then feats[f] = true end
            end
            CCfg.Feats = feats
            if Care.on and next(feats) == nil then cstatus("No care type selected") end
        end,
    })
    CareBox:Slider({
        Title = "Care threshold",
        Desc = "Care kicks in once a tank's bar drops below this percent.",
        Flag = "CareThreshold",
        Step = 5,
        Value = { Min = 10, Max = 100, Default = CCfg.Threshold },
        Callback = function(v) CCfg.Threshold = v end,
    })
    CareStatusP = CareBox:Paragraph({ Title = "Status", Desc = "Ready" })
end

-- =====================================================================
-- AUTO ANTI-THIEF (grab the bat, chase the shoplifter, swing)
-- From the game code: a thief is an NPC in Plot.NPCs with the attribute Shoplifter = true
-- (red Highlight + badge are just visuals of that attribute).
-- Bat remotes: Bat.Grab:FireServer() / Bat.Swing:FireServer(charge 0..1) / Bat.Drop:FireServer()
-- Player attribute HoldingBat = true while the bat is in hand.
-- =====================================================================
do
    local Thief = { on = false }
    local TCfg = {
        Range = 5.5,      -- swing when the thief is this close (studs)
        SwingGap = 0.9,   -- seconds between swings (the game itself blocks faster ones)
        Charge = 1,       -- swing power 0..1 (the game sends how long the windup was)
        GiveUp = 25,      -- seconds to chase one thief before leaving it
        GrabRange = 6,    -- stand this close to the bat to grab it
        Speed = 32,       -- WalkSpeed while handling a thief (restored afterwards)
    }
    local BatRem = remotesFolder:FindFirstChild("Bat")
    local GrabR = BatRem and BatRem:FindFirstChild("Grab")
    local DropR = BatRem and BatRem:FindFirstChild("Drop")
    local SwingR = BatRem and BatRem:FindFirstChild("Swing")
    local SwungR = BatRem and BatRem:FindFirstChild("Swung")
    local batReady = (GrabR and DropR and SwingR) and true or false

    local ThiefStatusP, lastS
    local function tstatus(t)
        if t ~= lastS then
            lastS = t
            pcall(function() ThiefStatusP:SetDesc(t) end)
        end
    end
    local function tnotify(text, iconName, dur)
        WindUI:Notify({ Title = "Anti-Thief", Content = text, Icon = iconName or icon("shield", "info"), Duration = dur or 4 })
    end

    local Thieves = {}
    local Gave = setmetatable({}, { __mode = "k" })

    local function liveThieves()
        local n = 0
        for m in pairs(Thieves) do
            if m.Parent and m:GetAttribute("Shoplifter") == true and not Gave[m] then
                n += 1
            else
                Thieves[m] = nil
            end
        end
        return n
    end

    -- thief on the plot = restock / care / cashier / buying all step aside
    local baseYield = Auto.yield
    Auto.yield = function() return baseYield() or (Thief.on and liveThieves() > 0) end
    Auto.yieldTask = function() return (Thief.on and liveThieves() > 0) and true or false end
    local baseLeave = Auto.canLeaveDesk
    Auto.canLeaveDesk = function()
        if Thief.on and (deskHolds.thief or liveThieves() > 0) then return false end
        return baseLeave()
    end

    local wakeEv = Instance.new("BindableEvent")
    local pending = false
    local function wake()
        if Thief.on then
            pending = true
            wakeEv:Fire()
        end
    end

    local function attrsOf(m)
        local t = {}
        for k, v in pairs(m:GetAttributes()) do t[#t + 1] = k .. "=" .. tostring(v) end
        table.sort(t)
        return table.concat(t, "|")
    end

    local function watch(m)
        if not m:IsA("Model") then return end
        local function check()
            if m:GetAttribute("Shoplifter") == true then
                if not Thieves[m] then
                    Thieves[m] = true
                    log("THIEF", "detected", m.Name, attrsOf(m))
                    wake()
                end
            else
                Thieves[m] = nil
            end
        end
        bind(m:GetAttributeChangedSignal("Shoplifter"), check)
        check()
    end

    local function plotNow()
        if Auto.getPlot then
            local p = Auto.getPlot()
            if p then return p end
        end
        local plots = workspace:FindFirstChild("Plots")
        for _, p in ipairs(plots and plots:GetChildren() or {}) do
            if p:GetAttribute("OwnerUserId") == lp.UserId then return p end
        end
    end

    -- NPCs folder can appear later (store closed = no folder), so keep looking
    local hookedNpcs
    local function hookNpcs()
        local plot = plotNow()
        local npcs = plot and plot:FindFirstChild("NPCs")
        if not npcs or npcs == hookedNpcs then return end
        hookedNpcs = npcs
        for _, m in ipairs(npcs:GetChildren()) do watch(m) end
        bind(npcs.ChildAdded, watch)
    end
    task.spawn(function()
        while alive do
            pcall(hookNpcs)
            task.wait(3)
        end
    end)

    local function hrpOf() return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end
    local function humOf() return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end
    local function holding() return lp:GetAttribute("HoldingBat") == true end

    -- fast walking: re-applied every frame because the game's own sprint code also sets WalkSpeed
    local speedConn, savedSpeed
    local function setSpeed(on)
        if on then
            if speedConn then return end
            local hu0 = humOf()
            savedSpeed = hu0 and hu0.WalkSpeed or nil
            speedConn = RunService.Heartbeat:Connect(function()
                local hu = humOf()
                if hu then hu.WalkSpeed = TCfg.Speed end
            end)
        else
            if speedConn then
                speedConn:Disconnect()
                speedConn = nil
            end
            local hu = humOf()
            if hu and savedSpeed then hu.WalkSpeed = savedSpeed end
            savedSpeed = nil
        end
    end

    -- a box in hand would block grabbing the bat
    local GoodsR = remotesFolder:FindFirstChild("Goods")
    local PetsR = remotesFolder:FindFirstChild("Pets")
    local function dropCarriedBox()
        local plot = plotNow()
        local boxes = plot and plot:FindFirstChild("Boxes")
        for _, b in ipairs(boxes and boxes:GetChildren() or {}) do
            if b:GetAttribute("Carrier") == lp.UserId then
                for _, folder in ipairs({ GoodsR, PetsR }) do
                    local r = folder and folder:FindFirstChild("DropBox")
                    if r then pcall(function() r:FireServer() end) end
                end
                log("THIEF", "dropped carried box", b.Name)
                task.wait(0.2)
                return
            end
        end
    end
    local function posOf(m)
        local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
        return r and r.Position or m:GetPivot().Position
    end

    local function ensureBat()
        if holding() then return true end
        local plot = plotNow()
        local tStart, lastFire = os.clock(), 0
        while Thief.on and alive and os.clock() - tStart < 12 do
            if holding() then return true end
            local bat = plot and plot:FindFirstChild("Bat")
            if not (bat and bat:IsA("BasePart")) then return false, "bat not found on your plot" end
            if bat:GetAttribute("HeldBy") ~= nil then return false, "someone else is holding the bat" end
            local h, hu = hrpOf(), humOf()
            if not (h and hu) then return false, "no character" end
            if (bat.Position - h.Position).Magnitude > TCfg.GrabRange then
                if Move.isTp() then Move.tp(bat.Position) else hu:MoveTo(bat.Position) end
            else
                hu:MoveTo(h.Position)
                if os.clock() - lastFire > 0.4 then
                    lastFire = os.clock()
                    GrabR:FireServer()
                end
            end
            task.wait(0.1)
        end
        return holding(), "couldn't grab the bat"
    end

    if SwungR then
        bind(SwungR.OnClientEvent, function(who, hits, charge, kind, n)
            if who == lp then
                log("THIEF", "swung", tostring(kind), tostring(charge), tostring(n), typeof(hits) == "table" and #hits or "-")
            end
        end)
    end

    -- returns: caught?, reason
    local function chase(m)
        local tStart, lastSwing, swings = os.clock(), 0, 0
        while Thief.on and alive and os.clock() - tStart < TCfg.GiveUp do
            if not m.Parent or m:GetAttribute("Shoplifter") ~= true then return true, "caught" end
            local h, hu = hrpOf(), humOf()
            if not (h and hu) then return false, "no character" end
            if not holding() then return false, "lost the bat" end
            -- leftovers of the cashier (register facing lock / anchor) must not hold us back
            if faceConn then pcall(setFacing, false) end
            if h.Anchored then h.Anchored = false end
            local tp = posOf(m)
            local flat = Vector3.new(tp.X - h.Position.X, 0, tp.Z - h.Position.Z)
            if flat.Magnitude > TCfg.Range then
                if Move.isTp() then Move.tp(tp - flat.Unit * 3, true) else hu:MoveTo(tp) end
                task.wait(0.1)
            else
                hu:MoveTo(h.Position)
                h.CFrame = CFrame.lookAt(h.Position, Vector3.new(tp.X, h.Position.Y, tp.Z))
                if os.clock() - lastSwing >= TCfg.SwingGap then
                    task.wait(0.08)
                    lastSwing = os.clock()
                    swings += 1
                    SwingR:FireServer(TCfg.Charge)
                    log("THIEF", "swing", swings, m.Name, attrsOf(m))
                end
                task.wait(0.05)
            end
        end
        return false, "timeout"
    end

    local function dropBat()
        if DropR and holding() then pcall(function() DropR:FireServer() end) end
    end

    local function handle()
        -- a thief beats everything: no waiting, the other features stop on their own (Auto.thiefNow)
        Auto.hold("thief", true)
        NC("thief", true)
        setSpeed(true)
        pcall(setFacing, false)   -- register facing lock
        pcall(unlockChar)         -- anchor / camera lock of a register tap in progress
        if shiftOn then pcall(endShift) end
        dropCarriedBox()
        tstatus("Thief spotted!")
        tnotify("Thief spotted! Grabbing the bat.", icon("shield", "info"))

        local okB, why = ensureBat()
        if not okB then
            tstatus("Can't get the bat: " .. tostring(why))
            log("THIEF", "no bat", tostring(why))
            for m in pairs(Thieves) do Gave[m] = true end
        else
            while Thief.on and alive and liveThieves() > 0 do
                local best, bd
                local h = hrpOf()
                for m in pairs(Thieves) do
                    if m.Parent and not Gave[m] and h then
                        local d = (posOf(m) - h.Position).Magnitude
                        if not bd or d < bd then best, bd = m, d end
                    end
                end
                if not best then break end
                tstatus("Chasing the thief...")
                local okC, r = chase(best)
                if okC then
                    tnotify("Thief caught!", icon("check", "info"))
                    log("THIEF", "caught", best.Name)
                else
                    Gave[best] = true
                    tstatus("Gave up: " .. tostring(r))
                    log("THIEF", "gave up", best.Name, tostring(r), attrsOf(best))
                end
                task.wait(0.2)
            end
            dropBat()
        end
        setSpeed(false)
        NC("thief", false)
        Auto.hold("thief", false)
        if Thief.on then tstatus("Watching for thieves...") end
    end

    task.spawn(function()
        while alive do
            wakeEv.Event:Wait()
            while alive and pending do
                task.wait(0.15)
                pending = false
                if Thief.on and liveThieves() > 0 then
                    local okH, e = pcall(handle)
                    if not okH then
                        log("ERR", "thief", e)
                        setSpeed(false)
                        NC("thief", false)
                        Auto.hold("thief", false)
                    end
                end
            end
        end
    end)

    -- slow safety net in case an attribute event was missed
    task.spawn(function()
        while alive do
            task.wait(10)
            wake()
        end
    end)

    Auto.thiefStop = function()
        Thief.on = false
        pcall(dropBat)
        Auto.hold("thief", false)
        setSpeed(false)
        NC("thief", false)
    end
    Auto.thiefNow = function()
        return (Thief.on and (deskHolds.thief or liveThieves() > 0)) and true or false
    end

    -- GUI (tab Security)
    local ThiefBox = openSection(Tabs.Security, "Auto Anti-Thief", "shield")
    ThiefBox:Toggle({
        Title = "Auto Anti-Thief",
        Desc = "Chases down shoplifters and deals with them automatically. Other features pause until it's done.",
        Value = false,
        Callback = function(v)
            if v and not batReady then
                gameMissing("Bat remotes not found, Auto Anti-Thief can't run.")
                return
            end
            Thief.on = v
            if v then
                for k in pairs(Gave) do Gave[k] = nil end
                tstatus("Watching for thieves...")
                wake()
            else
                task.spawn(dropBat)
                tstatus("Stopped")
            end
        end,
    })
    ThiefBox:Slider({
        Title = "Give up after (seconds)",
        Desc = "Stop chasing a thief after this long.",
        Flag = "ThiefGiveUp",
        Step = 5,
        Value = { Min = 10, Max = 60, Default = TCfg.GiveUp },
        Callback = function(v) TCfg.GiveUp = v end,
    })
    ThiefBox:Slider({
        Title = "Chase speed",
        Desc = "How fast you move while chasing a thief.",
        Flag = "ThiefSpeed",
        Step = 2,
        Value = { Min = 16, Max = 60, Default = TCfg.Speed },
        Callback = function(v) TCfg.Speed = v end,
    })
    ThiefStatusP = ThiefBox:Paragraph({ Title = "Status", Desc = "Ready" })
end

-- =====================================================================
-- AUTO CLEAN (sweep the mess customers leave behind)
-- Mess = Workspace.Plots.PlotN.Messes.<model>, attributes MessId / OwnerUserId / MessKind.
-- The server checks our position, so we WALK to each mess (noclip), then
-- Remotes.Mess.Clean:FireServer({ messId = id }).
-- Same rules as the other features: starts in a quiet moment (no customer waiting), takes a
-- "clean" hold so cashier / restock / care stay off the register, and finishes ALL the mess
-- before handing control back. Only a thief interrupts it.
-- =====================================================================
do
    local Clean = { on = false }
    local CLCfg = {
        Reach = 4,         -- stand this close (flat studs) before cleaning
        Delay = 0.4,       -- pause after arriving, before firing the remote
        WalkTimeout = 15,  -- seconds to reach one mess
        Retries = 3,       -- fire attempts per mess
        Backoff = 30,      -- seconds to leave a failed mess alone
        MaxLoops = 200,    -- safety cap per run
        Safety = 10,       -- seconds between quiet local re-checks (no remotes)
    }

    local CleanStatusP, lastS
    local function clstatus(t)
        if t ~= lastS then
            lastS = t
            pcall(function() CleanStatusP:SetDesc(t) end)
        end
    end

    -- looked up every time: right after joining the Mess remotes may not have replicated yet
    local function cleanRemote()
        local mf = remotesFolder:FindFirstChild("Mess")
        return mf and mf:FindFirstChild("Clean")
    end

    local function active() return alive and Clean.on and not Auto.thiefNow() end

    local Failed = {} -- messId -> time when it may be tried again

    -- only YOUR mess, on any plot (OwnerUserId is checked, never someone else's)
    local function myMesses()
        local list = {}
        local plots = workspace:FindFirstChild("Plots")
        for _, plot in ipairs(plots and plots:GetChildren() or {}) do
            local f = plot:FindFirstChild("Messes")
            for _, m in ipairs(f and f:GetChildren() or {}) do
                local id = m:GetAttribute("MessId")
                if id and m:GetAttribute("OwnerUserId") == lp.UserId and (Failed[id] or 0) < os.clock() then
                    list[#list + 1] = m
                end
            end
        end
        return list
    end

    local function nearestMess()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local best, bd
        for _, m in ipairs(myMesses()) do
            local okP, pos = pcall(function() return m:GetPivot().Position end)
            if okP then
                local d = hrp and (pos - hrp.Position).Magnitude or 0
                if not bd or d < bd then best, bd = m, d end
            end
        end
        return best
    end

    -- walk (noclip is held by the run) next to the mess; jumps if stuck
    local function walkTo(m)
        local ch = lp.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return false end
        if Move.isTp() then
            local okT, target = pcall(function() return m:GetPivot().Position end)
            return okT and m.Parent ~= nil and Move.tp(target)
        end
        local t0, lastPos, lastMove = os.clock(), hrp.Position, os.clock()
        while active() and m.Parent and os.clock() - t0 < CLCfg.WalkTimeout do
            local okP, target = pcall(function() return m:GetPivot().Position end)
            if not okP then return false end
            local p = hrp.Position
            if Vector3.new(p.X - target.X, 0, p.Z - target.Z).Magnitude <= CLCfg.Reach then
                hum:MoveTo(p)
                return true
            end
            hum:MoveTo(target)
            if (p - lastPos).Magnitude > 1 then
                lastPos, lastMove = p, os.clock()
            elseif os.clock() - lastMove > 2 then
                hum.Jump = true
                lastMove = os.clock()
            end
            task.wait(0.1)
        end
        return false
    end

    local function cleanOne(m)
        local id = m:GetAttribute("MessId")
        if not id then return false end
        local kind = tostring(m:GetAttribute("MessKind") or "mess")

        if not walkTo(m) then
            if m.Parent and active() then
                Failed[id] = os.clock() + CLCfg.Backoff
                log("CLEAN", "walk failed", id, kind)
            end
            return false
        end
        task.wait(CLCfg.Delay)

        for _ = 1, CLCfg.Retries do
            if not (active() and m.Parent) then break end
            local r = cleanRemote()
            if not r then return false end
            pcall(function() r:FireServer({ messId = id }) end)
            local tw = os.clock()
            while os.clock() - tw < 1.2 and m.Parent do task.wait(0.1) end
            if not m.Parent then
                log("CLEAN", "ok", id, kind)
                return true
            end
        end

        if m.Parent and active() then
            Failed[id] = os.clock() + CLCfg.Backoff
            log("CLEAN", "not cleaned", id, kind)
        end
        return not m.Parent
    end

    -- returns: cleaned, failed. Re-scans after every mess, so new mess is picked up in the same run.
    local function runClean()
        local done, failed = 0, 0
        for _ = 1, CLCfg.MaxLoops do
            if not active() then break end
            local m = nearestMess()
            if not m then break end
            clstatus(("Cleaning %s (%d done)"):format(tostring(m:GetAttribute("MessKind") or "mess"), done))
            if cleanOne(m) then done += 1 else failed += 1 end
            task.wait(0.2)
        end
        return done, failed
    end

    -- Auto Restock / Buy / Care wait while a clean run is going
    local baseLeave = Auto.canLeaveDesk
    Auto.canLeaveDesk = function()
        if deskHolds.clean then return false end
        return baseLeave()
    end

    -- ===== events (no polling) =====
    local wakeEv = Instance.new("BindableEvent")
    local pending = false
    local function wake()
        if Clean.on then
            pending = true
            wakeEv:Fire()
        end
    end

    local hooked = setmetatable({}, { __mode = "k" })
    local function hookPlots()
        local plots = workspace:FindFirstChild("Plots")
        for _, plot in ipairs(plots and plots:GetChildren() or {}) do
            local f = plot:FindFirstChild("Messes")
            if f and not hooked[f] then
                hooked[f] = true
                bind(f.ChildAdded, function() wake() end)
            end
        end
    end

    task.spawn(function()
        while alive do
            wakeEv.Event:Wait()
            while alive and pending do
                task.wait(0.6) -- let the mess attributes land / a burst settle into one check
                pending = false
                if Clean.on then
                    pcall(hookPlots)
                    if #myMesses() == 0 then
                        clstatus("No mess, waiting...")
                    elseif Auto.thiefNow() then
                        clstatus("Thief on the plot, waiting...")
                        task.delay(2, wake)
                    elseif deskHolds.restock or deskHolds.care or deskHolds.openclose then
                        clstatus("Waiting for restock/care to finish...")
                        task.delay(2, wake)
                    elseif not Auto.canLeaveDesk() then
                        clstatus(Auto.yield() and "Customer waiting, cleaning paused" or "Waiting for a quiet moment...")
                        task.delay(2, wake)
                    else
                        Auto.hold("clean", true) -- also stops the cashier from (re)starting a shift
                        -- a shift that is mid-start (lock + tap) must finish first
                        local tw = os.clock()
                        while Auto.cashierStarting and os.clock() - tw < 15 do task.wait(0.1) end
                        -- leave the register first: end the shift, release its facing / anchor lock
                        if Auto.pauseCashier then pcall(Auto.pauseCashier) end
                        pcall(setFacing, false)
                        pcall(unlockChar)
                        NC("clean", true)
                        local okR, done, failed = pcall(runClean)
                        NC("clean", false)
                        Auto.hold("clean", false)
                        if not okR then
                            log("ERR", "clean", done)
                        elseif Clean.on then
                            clstatus(("Last run: %d cleaned, %d failed"):format(done or 0, failed or 0))
                            -- anything left (e.g. a thief interrupted the run) gets another go shortly
                            if #myMesses() > 0 then task.delay(2, wake) end
                        end
                    end
                end
            end
        end
    end)

    -- slow safety net: reads local data only, in case a change had no event
    task.spawn(function()
        while alive do
            task.wait(CLCfg.Safety)
            pcall(hookPlots)
            wake()
        end
    end)

    Auto.cleanStop = function()
        Clean.on = false
        Auto.hold("clean", false)
        NC("clean", false)
    end

    -- GUI (tab Cashier): toggle first, then the live status
    local CleanBox = openSection(Tabs.Cashier, "Auto Clean", icon("sparkles", "brush", "trash-2"))
    CleanBox:Toggle({
        Title = "Auto Clean",
        Desc = "Sweeps up the mess customers leave behind.",
        Value = false,
        Flag = "AutoClean",
        Callback = function(v)
            if v and not cleanRemote() then
                gameMissing("Mess.Clean remote not found, Auto Clean can't run.")
                return
            end
            if v then
                Failed = {}
                Clean.on = true
                clstatus("Running...")
                wake()
            else
                Auto.cleanStop()
                clstatus("Stopped")
            end
        end,
    })
    CleanStatusP = CleanBox:Paragraph({ Title = "Status", Desc = "Ready" })
end

-- ===== MISC TAB =====
local MoveBox = openSection(Tabs.Misc, "Movement", "footprints")
MoveBox:Dropdown({
    Title = "Movement mode",
    Desc = "Walk (legit): moves naturally, safest. Teleport (fast): jumps straight to each spot. Applies to every feature.",
    Flag = "MoveMode",
    Values = { "Walk (legit)", "Teleport (fast)" },
    Value = "Walk (legit)",
    Callback = function(v)
        Move.teleport = pickValue(v):find("Teleport") ~= nil
    end,
})

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
    Desc = "Your settings save automatically and load back next time you join.",
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

-- =====================================================================
-- AUTO OPEN / CLOSE STORE (open in the morning, close at closing hour, then next day)
-- Plot attributes: StoreOpen, CustomersInside, CustomersPending, StoreDay
-- Game hour is read from the topbar "Time" label (e.g. "2:18 PM")
-- Opening = walk (noclip) to the OpenSign, then OpenStore:FireServer() (no args)
-- Closing = walk (noclip) to the OpenSign, hold, then ToggleDoors:FireServer() (no args)
-- =====================================================================
do
    local OC = { on = false, closeHour = 17 }
    local OStatusP, lastO

    local function ostatus(t)
        if t == lastO then return end
        lastO = t
        pcall(function() OStatusP:SetDesc(t) end)
    end

    local function plotNow2()
        local plots = workspace:FindFirstChild("Plots")
        for _, p in ipairs(plots and plots:GetChildren() or {}) do
            if p:GetAttribute("OwnerUserId") == lp.UserId then return p end
        end
    end

    local function badge()
        local top = lp.PlayerGui:FindFirstChild("TopbarStandard")
        if not top then return end
        for _, g in ipairs(top:GetDescendants()) do
            if g.Name == "StatusBadge" then return g end
        end
    end

    local function gameHour()
        local top = lp.PlayerGui:FindFirstChild("TopbarStandard")
        if not top then return end
        for _, g in ipairs(top:GetDescendants()) do
            if g:IsA("TextLabel") and g.Name == "Time" then
                local h, m, ap = g.Text:match("(%d+):(%d+)%s*(%a+)")
                if h then
                    h = tonumber(h) % 12
                    if ap:upper() == "PM" then h += 12 end
                    return h + tonumber(m) / 60
                end
            end
        end
    end

    local function pressBadge()
        local b = badge()
        if not b then return false end
        for _, g in ipairs(b:GetDescendants()) do
            if g:IsA("GuiButton") then
                for _, sig in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }) do
                    pcall(function() firesignal(g[sig]) end)
                end
                return true
            end
        end
        return false
    end

    -- looked up every time: right after joining the Plot remotes may not have replicated yet
    local function plotRemote(name)
        local pr = remotesFolder:FindFirstChild("Plot")
        return pr and pr:FindFirstChild(name)
    end

    local HOLD_TIME = 1.6 -- how long the game wants the close prompt held
    local REACH = 8
    pcall(function() REACH = require(RS.Modules.StoreDayConfig).SIGN_REACH_STUDS or REACH end)
    local STOP_DIST = math.max(2, REACH - 2)

    -- walk to the OpenSign (noclip only while walking), hold, fire ToggleDoors. No walking back.
    local function actAtSign(plot, mode) -- mode: "open" / "close"
        local sign = plot:FindFirstChild("OpenSign", true)
        local ch = lp.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        local OpenStoreR, ToggleDoorsR = plotRemote("OpenStore"), plotRemote("ToggleDoors")
        if not sign then ostatus("OpenSign not found, retrying...") return false end
        -- only the remote this action really needs (before: BOTH were required, so a missing ToggleDoors blocked opening too)
        local needR = (mode == "open") and OpenStoreR or ToggleDoorsR
        if not needR then
            ostatus((mode == "open" and "OpenStore" or "ToggleDoors") .. " remote not found, retrying...")
            log("OPENCLOSE", "remote missing", mode)
            return false
        end
        if not (hrp and hum) or hum.Health <= 0 then ostatus("Character not ready, retrying...") return false end

        Auto.hold("openclose", true) -- cashier / restock won't pull us back to the register
        if shiftOn then pcall(Auto.pauseCashier) end
        local tw = os.clock()
        while Auto.cashierStarting and os.clock() - tw < 15 do task.wait(0.1) end

        NC("openclose", true)
        -- opening needs to be 2 studs closer than closing, otherwise the server rejects OpenStore as too far
        local stopDist = (mode == "open") and math.max(2, STOP_DIST - 2) or STOP_DIST
        if Move.isTp() and (hrp.Position - sign:GetPivot().Position).Magnitude > stopDist then
            Move.tp(sign:GetPivot().Position)
        end
        local reached, t = false, os.clock()
        while alive and OC.on and os.clock() - t < 15 do
            if Auto.thiefNow() then break end
            local target = sign:GetPivot().Position
            if (hrp.Position - target).Magnitude <= stopDist then reached = true break end
            hum:MoveTo(target)
            task.wait(0.1)
        end

        local fired = false
        if not reached then
            ostatus("Couldn't reach the sign in 15s, retrying...")
            log("OPENCLOSE", "sign not reached", mode)
        end
        if reached then
            hum:MoveTo(hrp.Position)
            if mode == "open" then
                task.wait(0.2)
                if alive and OC.on and not Auto.thiefNow()
                    and plot:GetAttribute("StoreOpen") ~= true and plot:GetAttribute("DoorsLocked") ~= true then
                    OpenStoreR:FireServer()
                    fired = true
                end
            else
                task.wait(HOLD_TIME)
                -- ToggleDoors is a toggle: only fire if it still needs closing
                if alive and OC.on and not Auto.thiefNow()
                    and plot:GetAttribute("StoreOpen") == true and plot:GetAttribute("DoorsLocked") ~= true then
                    ToggleDoorsR:FireServer()
                    fired = true
                end
            end
            task.wait(0.3)
        end
        NC("openclose", false)
        Auto.hold("openclose", false)
        return fired
    end

    -- ===== DAY SUMMARY: press CONTINUE =====
    -- After closing, the "Day complete" screen has a CONTINUE (n) button that must be pressed.
    local contLabel, lastContScan = nil, 0
    local CONT_SIGS = { "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }

    local function isContinue(g)
        return (g:IsA("TextLabel") or g:IsA("TextButton"))
            and type(g.Text) == "string" and string.match(g.Text:lower(), "^%s*continue") ~= nil
    end

    local function uiShown(g)
        local cur = g
        while cur and cur ~= lp.PlayerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return g.AbsoluteSize.X > 0
    end

    -- remember the Continue label as soon as the game creates it (no heavy scan needed)
    table.insert(Connections, lp.PlayerGui.DescendantAdded:Connect(function(g)
        if g:IsA("TextLabel") or g:IsA("TextButton") then
            task.defer(function() if isContinue(g) then contLabel = g end end)
        end
    end))

    local function contUp()
        return contLabel ~= nil and contLabel:IsDescendantOf(game) and uiShown(contLabel)
    end

    local function findContinue(allowScan)
        if contLabel and not contLabel:IsDescendantOf(game) then contLabel = nil end
        if contLabel and uiShown(contLabel) then return contLabel end
        if not allowScan or os.clock() - lastContScan < 4 then return nil end
        lastContScan = os.clock()
        local n = 0
        for _, g in ipairs(lp.PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end -- yield so the phone doesn't freeze
            if isContinue(g) and uiShown(g) then contLabel = g return g end
        end
    end

    -- the label may sit inside the button, or next to it
    local function contButton(lbl)
        local cur = lbl
        for _ = 1, 4 do
            if not cur or cur == lp.PlayerGui then break end
            if cur:IsA("GuiButton") then return cur end
            for _, c in ipairs(cur:GetChildren()) do
                if c:IsA("GuiButton") then return c end
            end
            cur = cur.Parent
        end
    end

    task.spawn(function()
        local seenAt, tries = nil, 0
        while alive do
            if OC.on and not Auto.thiefNow() then
                local pl = plotNow2()
                local h = gameHour()
                local summaryTime = pl and (pl:GetAttribute("StoreOpen") ~= true
                    or pl:GetAttribute("DoorsLocked") == true
                    or (h ~= nil and h >= OC.closeHour))
                local lbl = findContinue(summaryTime and true or false)
                if lbl then
                    seenAt = seenAt or os.clock()
                    if os.clock() - seenAt >= 0.5 then
                        local btn = contButton(lbl)
                        if btn then
                            -- one signal per try (cycles), so the button is never double-fired
                            local sig = CONT_SIGS[(tries % #CONT_SIGS) + 1]
                            tries += 1
                            pcall(function() firesignal(btn[sig]) end)
                            ostatus("Day summary: pressed Continue")
                            if tries == 1 or tries == 5 then log("OPENCLOSE", "continue pressed", btn:GetFullName(), sig, tries) end
                        else
                            ostatus("Continue button not found, check the log")
                            if tries == 0 then log("OPENCLOSE", "continue label, no button", lbl:GetFullName()) end
                            tries += 1
                        end
                        task.wait(0.8)
                    end
                else
                    seenAt, tries = nil, 0
                end
            else
                seenAt, tries = nil, 0
            end
            task.wait(0.25)
        end
    end)

    task.spawn(function()
        local lastAct, closeSince = 0, nil
        local lastDay, dayTries = nil, 0
        while alive do
            if OC.on then
                local plot = plotNow2()
                local hour = gameHour()
                local clockMissing = (hour == nil)
                if clockMissing then hour = 0 end -- no clock yet: still allow opening a closed store
                if not plot then
                    ostatus("Waiting for the plot...")
                elseif Auto.thiefNow() then
                    ostatus("Thief on the plot, waiting...")
                elseif contUp() then
                    ostatus("Day summary, pressing Continue...")
                else
                    local isOpen = plot:GetAttribute("StoreOpen") == true
                    local inside = (plot:GetAttribute("CustomersInside") or 0) + (plot:GetAttribute("CustomersPending") or 0)
                    local late = (not clockMissing) and hour >= OC.closeHour
                    local doorsLocked = plot:GetAttribute("DoorsLocked") == true
                    local now = os.clock()

                    if isOpen then
                        if late then
                            closeSince = closeSince or now
                            -- wait for the store to empty, but never longer than 45s
                            if doorsLocked then
                                -- already closing (doors locked), never toggle again
                                ostatus("Closing, waiting for the store to finish...")
                            elseif (inside == 0 or now - closeSince > 45) and now - lastAct >= 15 then
                                lastAct = now
                                ostatus("Walking to the sign to close...")
                                local fired = actAtSign(plot, "close")
                                log("OPENCLOSE", "close", string.format("hour %.2f inside %d", hour, inside), tostring(fired))
                            elseif inside > 0 then
                                ostatus("Closing time, waiting for customers to leave (" .. inside .. ")")
                            end
                        else
                            closeSince = nil
                            ostatus(string.format("Store open, closing at %02d:00", OC.closeHour))
                        end
                    else
                        closeSince = nil
                        if late then
                            -- day is over: next day first, otherwise it would reopen and close in a loop
                            if now - lastAct >= 8 then
                                lastAct = now
                                local day = plot:GetAttribute("StoreDay")
                                if day ~= lastDay then lastDay, dayTries = day, 0 end
                                if dayTries >= 2 and not doorsLocked then
                                    -- next day did nothing twice (joined mid-evening?): just open like normal
                                    ostatus("Walking to the sign to open...")
                                    local fired = actAtSign(plot, "open")
                                    log("OPENCLOSE", "open (fallback)", string.format("hour %.2f", hour), tostring(fired))
                                else
                                    dayTries += 1
                                    ostatus("Day over, starting next day...")
                                    local NextDayR = plotRemote("StartNextDay")
                                    local ok, err = pcall(function() if NextDayR then NextDayR:FireServer() end end)
                                    log("OPENCLOSE", "next day", tostring(ok), tostring(err), "day", tostring(day))
                                end
                            end
                        elseif doorsLocked then
                            ostatus("Doors locked, waiting...")
                        elseif now - lastAct >= 8 then
                            lastAct = now
                            ostatus("Walking to the sign to open...")
                            local fired = actAtSign(plot, "open")
                            log("OPENCLOSE", "open", string.format("hour %.2f", hour), tostring(fired), clockMissing and "(clock not found)" or "")
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)

    local OCBox = openSection(Tabs.Cashier, "Auto Open / Close Store", "house")
    OCBox:Toggle({
        Title = "Auto Open / Close Store",
        Desc = "Opens and closes the store on schedule, then starts the next day.",
        Value = false,
        Callback = function(v)
            OC.on = v
            ostatus(v and "Watching the store..." or "Stopped")
        end,
    })
    OStatusP = OCBox:Paragraph({ Title = "Status", Desc = "Ready" })
end

-- =====================================================================
-- AUTO CONFIRM SET PRICE (restock gets stuck when the "Set price" window pops up)
-- Finds the "Set price" window in PlayerGui and presses its Confirm button (market price stays).
-- Only runs while Auto Restock is on, so it never touches prices you set by hand.
-- =====================================================================
do
    local PC = { on = true }
    local PStatusP, lastP
    local titleLabel          -- cached "Set price" TextLabel
    local lastScan = 0
    local confirmed = 0

    local function pstatus(t)
        if t == lastP then return end
        lastP = t
        pcall(function() PStatusP:SetDesc(t) end)
    end

    local function isTitle(g)
        return (g:IsA("TextLabel") or g:IsA("TextButton"))
            and type(g.Text) == "string" and g.Text:lower():gsub("%s+", " ") == "set price"
    end

    local function scanForTitle()
        lastScan = os.clock()
        local n = 0
        for _, g in ipairs(lp.PlayerGui:GetDescendants()) do
            n += 1
            if n % 800 == 0 then task.wait() end -- yield so the phone doesn't freeze
            if isTitle(g) then return g end
        end
    end

    -- the title and every parent up to the ScreenGui must be visible
    local function shown(g)
        local cur = g
        while cur and cur ~= lp.PlayerGui do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            if cur:IsA("ScreenGui") and not cur.Enabled then return false end
            cur = cur.Parent
        end
        return g.AbsoluteSize.X > 0
    end

    local function findConfirm(title)
        local root = title:FindFirstAncestorWhichIsA("ScreenGui") or lp.PlayerGui
        for _, g in ipairs(root:GetDescendants()) do
            if (g:IsA("TextLabel") or g:IsA("TextButton")) and g.Text == "Confirm" then
                if g:IsA("GuiButton") then return g end
                local up = g:FindFirstAncestorWhichIsA("GuiButton")
                if up then return up end
                return g
            end
        end
    end

    local function press(btn)
        if btn:IsA("GuiButton") then
            for _, sig in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }) do
                pcall(function() firesignal(btn[sig]) end)
            end
            return true
        end
        return false
    end

    -- remember the window as soon as the game creates it
    table.insert(Connections, lp.PlayerGui.DescendantAdded:Connect(function(g)
        if not titleLabel and (g:IsA("TextLabel") or g:IsA("TextButton")) then
            task.defer(function() if isTitle(g) then titleLabel = g end end)
        end
    end))

    task.spawn(function()
        local seenAt, tries = nil, 0
        while alive do
            if PC.on and Auto.restockOn then
                if titleLabel and not titleLabel:IsDescendantOf(game) then titleLabel = nil end
                if not titleLabel and os.clock() - lastScan > 5 then titleLabel = scanForTitle() end

                if titleLabel and shown(titleLabel) then
                    seenAt = seenAt or os.clock()
                    if os.clock() - seenAt >= 0.3 then
                        local btn = findConfirm(titleLabel)
                        if btn and press(btn) then
                            tries += 1
                            if tries == 1 then
                                confirmed += 1
                                log("PRICE", "confirm pressed", btn:GetFullName())
                                pstatus("Confirmed price window (" .. confirmed .. ")")
                            elseif tries == 4 then
                                log("PRICE", "window still open after 4 presses")
                                pstatus("Price window won't close, check the log")
                            end
                        else
                            pstatus("Price window open, Confirm button not found")
                        end
                        task.wait(0.6)
                    end
                else
                    seenAt, tries = nil, 0
                    if confirmed == 0 then pstatus("Watching for the price window...") end
                end
            else
                seenAt, tries = nil, 0
            end
            task.wait(0.25)
        end
    end)

    local PBox = openSection(Tabs.Stock, "Auto Confirm Price", "check")
    PBox:Toggle({
        Title = "Auto Confirm Price",
        Desc = "Auto-presses Confirm on the Set Price popup so restock doesn't get stuck.",
        Value = true,
        Flag = "AutoConfirmPrice",
        Callback = function(v)
            PC.on = v
            pstatus(v and "Watching for the price window..." or "Off")
        end,
    })
    PStatusP = PBox:Paragraph({ Title = "Status", Desc = "Ready" })
end

-- ===== UNLOAD =====
local function unload()
    if _G.PETSTORETYCOON_Unloaded == Window then return end
    _G.PETSTORETYCOON_Unloaded = Window
    if shiftOn then pcall(endShift) end
    pcall(setFacing, false)
    pcall(unlockChar)
    pcall(NC, "cashier", false)
    pcall(NC, "care", false)
    if Auto.thiefStop then pcall(Auto.thiefStop) end
    if Auto.cleanStop then pcall(Auto.cleanStop) end
    alive = false
    cashRunning = false
    Auto.restockOn = false
    Auto.buyOn = false
    Fish.on = false
    pcall(Auto.setNoclip, false)
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.PETSTORETYCOON_Unload = nil
end
_G.PETSTORETYCOON_Unload = unload

local DangerBox = section(Tabs.Misc, "Script", "power")
DangerBox:Button({
    Title = "Unload Script", Desc = "Removes the GUI and stops everything", Icon = "x",
    Callback = unload,
})

Tabs.Misc:Paragraph({ Title = HUB_NAME, Desc = "Made by Ransblox Scripts • " .. VERSION })

-- auto-save: register the Flag'd dropdowns + autoload last saved values
if Window.Folder and Window.ConfigManager then
    Window.ConfigManager:CreateConfig("default", true)
end
print("[Pet Store Tycoon] " .. VERSION .. " loaded OK")
