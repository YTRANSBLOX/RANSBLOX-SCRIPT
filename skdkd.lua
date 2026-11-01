local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Shared = RS:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local PhysicsTable = require(Shared.Physics:WaitForChild("Table"))
local PhysicsBall = require(Shared.Physics:WaitForChild("Ball"))
local PhysicsSim  = require(Shared.Physics:WaitForChild("Simulation"))
local Net = require(Shared:WaitForChild("Net"))
local ShotJudge = require(Shared.Rules:WaitForChild("ShotJudge"))
local CuePlacement = require(Shared.Rules:WaitForChild("CuePlacement"))

local RADIUS = Config.Balls.RadiusInches
local ELEVATION = Config.Cue.CueElevationDegrees
local MIN_POWER = Config.Input and Config.Input.MinPowerToShoot or 0.1
local BREAK_LINE_X = Config.Multiplayer.BreakLineX
local CLEAR = Config.Multiplayer.PlacementClearanceInches or 0

local MAX_CUT_ANGLE = 60

local POWER_ANCHORS = (Config.Cue.PowerAnchors) or {
    { 0.04, 15 }, { 0.1, 27 }, { 0.3, 60 },
    { 0.5, 100 }, { 0.75, 180 }, { 1, 440 }
}
local CUE_MIN_SPEED  = Config.Cue.MinSpeed  or 15
local CUE_MAX_SPEED  = Config.Cue.MaxSpeed  or 440
local ARRIVE_SPEED   = (Config.Bots and Config.Bots.Finder and Config.Bots.Finder.ArriveSpeed) or 8
local ROLLING_DECEL  = (Config.Physics.RollingFriction or 0.0125) * (Config.Physics.Gravity or 386.09)
local SIDE_APPROACH_DEG   = (Config.Bots and Config.Bots.Finder and Config.Bots.Finder.SideApproachDegrees)   or 50
local CORNER_APPROACH_DEG = (Config.Bots and Config.Bots.Finder and Config.Bots.Finder.CornerApproachDegrees) or 55
local DIAM = 2 * RADIUS

-- ── GUI HOOK ─────────────────────────────────────────────────────────────────
-- Shared live-settings table, read by the separate 8Ball Crazy GUI script.
-- Whichever script (this engine or the GUI loader) runs first creates the
-- table; the other reuses the SAME table via _G, so GUI toggles mutate it
-- in place and this engine's loop (which re-reads Settings.* every tick)
-- picks up changes live — no restart needed.
_G.C8B_Settings = _G.C8B_Settings or {
    Enabled        = true,  -- master on/off for auto aim+shoot
    HumanAim       = true,  -- eased/wobbled aim motion vs instant snap
    SpinEnabled    = true,  -- draw/follow spin for position play
    AutoCallPocket = true,  -- auto-call pocket for the 8-ball
    SafetyEnabled  = true,  -- safety fallback shot when no pot is found
    MaxPower       = 1.0,   -- hard cap on fired shot power (0..1)
}
local Settings = _G.C8B_Settings

-- Forward-declared: assigned later (lines ~636/673), but referenced by
-- bestCushionFirstShot/bestRailKissShot which are DEFINED earlier in the file.
-- Must be `local` here (not `local function` down below) or those earlier
-- closures capture the *global* segmentClear/segmentClearance instead of
-- this local — which is nil, causing "attempt to call a nil value" at runtime.
local segmentClear
local segmentClearance
local aimLineQualityDirect
local calibrateShot
local calibrateCushionShot

local geometry = PhysicsTable.build({ pocketsOpen = true })
local pockets = geometry.pockets
local segments = geometry.segments

local function buildAimPockets(geom)
    local halfLength = geom.halfLength
    local halfWidth  = geom.halfWidth
    local out = {}
    for _, p in ipairs(geom.pockets) do
        local sign = p.y > 0 and 1 or -1
        if p.x == 0 then
            table.insert(out, {
                id = p.id,
                mx = 0, my = sign * halfWidth,
                ax = 0, ay = sign,
                side = true,
                window = (Config.Table.SideMouthInches - DIAM) / 2,
            })
        else
            local signX = p.x > 0 and 1 or -1
            local cmh = Config.Table.CornerMouthInches / 1.4142135623730951 / 2
            table.insert(out, {
                id = p.id,
                mx = signX * (halfLength - cmh),
                my = sign  * (halfWidth  - cmh),
                ax = signX * 0.7071067811865475,
                ay = sign  * 0.7071067811865475,
                side = false,
                window = (Config.Table.CornerMouthInches - DIAM) / 2,
            })
        end
    end
    return out
end

local aimPockets = buildAimPockets(geometry)

local function findAimPocket(pocketId)
    for _, p in ipairs(aimPockets) do
        if p.id == pocketId then return p end
    end
    return nil
end

local function powerForSpeed(targetSpeed, maxPower)
    local speedFrac = math.clamp(
        math.max(targetSpeed - CUE_MIN_SPEED, 0) / (CUE_MAX_SPEED - CUE_MIN_SPEED), 0, 1)
    local actualSpeed = CUE_MIN_SPEED + speedFrac * (CUE_MAX_SPEED - CUE_MIN_SPEED)

    local anchors = POWER_ANCHORS
    local rawPower
    if actualSpeed <= anchors[1][2] then
        rawPower = anchors[1][1]
    else
        rawPower = anchors[#anchors][1]
        for i = 2, #anchors do
            local prev = anchors[i - 1]
            local curr = anchors[i]
            if actualSpeed > curr[2] then continue end
            local ratio = actualSpeed / prev[2]
            local speedRatio = curr[2] / prev[2]
            local t = math.log(ratio) / math.log(speedRatio)
            rawPower = prev[1] + t * (curr[1] - prev[1])
            break
        end
    end
    local cap = maxPower or 1.0
    return math.clamp(rawPower, MIN_POWER, cap)
end

local function shotPower(potDist, cueDist, cutAngleRad, maxPower)
    local arriveV2 = ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * potDist
    local objSpeed = math.sqrt(arriveV2) * 1.4
    local cosCut   = math.max(math.cos(cutAngleRad), 0.25)
    local cueSpeed = objSpeed / cosCut * 1.15 + 5
    return powerForSpeed(cueSpeed, maxPower)
end

local FIXED_STEP     = Config.Physics.FixedStep or (1/240)
local SIM_SECONDS    = 3
local SIM_STEPS      = math.floor(SIM_SECONDS / FIXED_STEP)

local function probe(geom, cueX, cueY, targetBall, angle, power)
    local cueBall    = PhysicsBall.new(0, cueX, cueY)
    local objBall    = PhysicsBall.new(targetBall.id, targetBall.x, targetBall.y)
    local state      = PhysicsSim.newState(geom, { cueBall, objBall })
    PhysicsSim.strike(state, { angle = angle, power = power })

    local events = {}
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        if objBall.vx ~= 0 or objBall.vy ~= 0 then
            local spd2 = objBall.vx^2 + objBall.vy^2
            return math.atan2(objBall.vy, objBall.vx), math.sqrt(spd2)
        end

        for _, ev in ipairs(events) do
            if ev.ball == 0 and (ev.type == "railHit" or ev.type == "pocket") then
                return nil, nil
            end
        end

        if cueBall.pocketed or not PhysicsBall.isMoving(cueBall) then
            return nil, nil
        end

        table.clear(events)
    end
    return nil, nil
end

-- Final sanity gate: simulasiin SEMUA bola yang masih di meja (bukan cuma
-- cue+target doang kayak probe()), jalanin sampai semua diam, terus cek
-- BENERAN ada event bola targetId masuk pocket. Ini beda sama probe()/
-- calibrateShot yang cuma ngecek sudut keberangkatan cocok sama target
-- geometris — itu nebak "harusnya masuk", ini beneran liat hasilnya.
-- Return: pocketed (bool), scratched (bool, cue ikut kepocket), cueX, cueY
-- (posisi akhir cue ball kalau nggak scratch — buat position play, lihat
-- evaluateLeaveQuality di bawah). Beda sama versi lama: dulu langsung
-- `return true` begitu event pocket target kedetek (early exit, hemat
-- compute) — sekarang sengaja TERUS disimulasiin sampe semua bola
-- berhenti, biar tau cue ball-nya mendarat di mana.
local function verifyPocketed(geom, balls, targetId, angle, power, spin)
    local simBalls = {}
    local cueBallSim, targetBallSim
    for id, b in pairs(balls) do
        if b and not b.pocketed then
            local nb = PhysicsBall.new(id, b.x, b.y)
            table.insert(simBalls, nb)
            if id == 0 then cueBallSim = nb end
            if id == targetId then targetBallSim = nb end
        end
    end
    if not cueBallSim or not targetBallSim then return false end

    local state = PhysicsSim.newState(geom, simBalls)
    PhysicsSim.strike(state, { angle = angle, power = power, spin = spin })

    local events = {}
    local targetPocketed = false
    local cueScratched = false
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        for _, ev in ipairs(events) do
            if ev.ball == targetId and ev.type == "pocket" then
                targetPocketed = true
            elseif ev.ball == 0 and ev.type == "pocket" then
                cueScratched = true
            end
        end
        table.clear(events)

        local anyMoving = false
        for _, nb in ipairs(simBalls) do
            if not nb.pocketed and PhysicsBall.isMoving(nb) then
                anyMoving = true
                break
            end
        end
        if not anyMoving then break end
    end

    if not targetPocketed then return false end
    if cueScratched or cueBallSim.pocketed then
        -- Target tetep masuk, tapi cue ikut kepocket (scratch/foul) —
        -- nggak ada posisi "leave" yang valid buat position play karena
        -- cue bakal di-replace/ball-in-hand.
        return true, true, nil, nil
    end
    return true, false, cueBallSim.x, cueBallSim.y
end

local POSITION_PLAY_WEIGHT = 0.5  -- seberapa gede pengaruh leave quality ke skor final
local SCRATCH_SCORE_PENALTY = 0.15  -- shot yang bikin cue scratch didenda berat (tetep valid, cuma didahulukan yang lain)

-- Nilai seberapa "enak" posisi cue ball abis shot buat giliran BERIKUTNYA —
-- bukan nyimulasiin shot beneran, cuma heuristik cepet (geometri + line-
-- of-sight) ngukur ada-nggaknya opsi pot yang bagus dari posisi segitu
-- buat sisa bola legal di meja. 0 = kayaknya bakal mati langkah abis ini,
-- makin gede makin banyak/gampang opsi lanjutannya.
local function evaluateLeaveQuality(balls, group, cueX, cueY, excludeId)
    if not cueX or not cueY then return 0 end

    local bestScore = 0
    for id, ball in pairs(balls) do
        if id == 0 or id == excludeId or ball.pocketed then continue end
        if group and not ShotJudge.legalTarget(balls, group, id) then continue end

        local dx, dy = ball.x - cueX, ball.y - cueY
        local d = math.sqrt(dx*dx + dy*dy)
        if d < 1e-6 then continue end
        local ignore = { [0] = true, [id] = true, [excludeId] = true }
        if not segmentClear(cueX, cueY, ball.x, ball.y, balls, ignore) then continue end

        for _, pocket in ipairs(aimPockets) do
            local pdx, pdy = pocket.mx - ball.x, pocket.my - ball.y
            local pd = math.sqrt(pdx*pdx + pdy*pdy)
            if pd < 1e-6 then continue end

            local dirx, diry = pdx/pd, pdy/pd
            local dotVal   = math.clamp(dirx*pocket.ax + diry*pocket.ay, -1, 1)
            local appAngle = math.acos(dotVal)
            local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
            if appAngle > math.rad(approachLimitDeg) then continue end

            -- Cut angle kasar: sudut antara arah cue->ball dan ball->pocket
            local cosCut   = math.clamp((dx/d)*dirx + (dy/d)*diry, -1, 1)
            local cutAngle = math.deg(math.acos(cosCut))
            if cutAngle >= MAX_CUT_ANGLE then continue end
            if not segmentClear(ball.x, ball.y, pocket.mx, pocket.my, balls, ignore) then continue end

            local s = pocket.window * math.cos(appAngle) * DIAM
                / (math.max(d, DIAM) * math.max(pd, DIAM))
            if s > bestScore then bestScore = s end
        end
    end
    return bestScore
end

-- ── SPIN / POSITION PLAY ─────────────────────────────────────────────────────
-- Dari dump Physics.Cue: spin = {x=side, y=top(+)/draw(-)}, clamp circular ke
-- Config.Cue.MaxSpinOffset (0.5 di game ini). Config.Cue.SideSpinBendsPath =
-- false, artinya side spin TIDAK membelokkan arah awal cue ball (no squirt)
-- DAN tidak menghasilkan wz di strike() kalau spin.x = 0 — jadi draw/follow
-- (spin.y doang) murni ngubah behavior cue ball SETELAH nabrak object ball,
-- tanpa throw/deviasi ke object ball. Makanya aman dipakai tanpa re-kalibrasi
-- sudut. Side spin (x) baru masuk fase 2 karena dia ngasih wz -> throw ke
-- object ball, butuh kompensasi sudut terpisah.
local SPIN_PRESETS = {
    { x = 0, y =  0.00, name = "center" },
    { x = 0, y = -0.20, name = "draw-light" },
    { x = 0, y = -0.42, name = "draw-heavy" },
    { x = 0, y =  0.20, name = "follow-light" },
    { x = 0, y =  0.42, name = "follow-heavy" },
}
-- Off-center hit ngurangin energi yang nyalur ke translasi cue ball (lihat
-- v66/v69 di strike()) -- makin gede |spin|, makin lemah cue ball keluar
-- buat power yang sama. Kompensasi kasar: naikin power proporsional ke
-- magnitude spin. Angka ini empiris, bukan hasil re-derive rumus exact-nya
-- strike() (itu butuh StickMassOunces/TipRestitution dkk yang nilainya udah
-- kita tau dari Config, tapi kompensasi approx ini jauh lebih murah compute-
-- nya dan verifyPocketed tetap jadi gerbang akhir yang nge-reject kalau
-- power-nya ternyata salah/gak masuk).
local SPIN_POWER_COMPENSATION = 0.22
local SPIN_TRY_TOP_N = 2  -- cuma shot paling top yang dicobain variasi spin (hemat compute)

-- Buat satu candidate shot yang UDAH kebukti masuk pakai center spin (pot
-- geometrinya valid), coba beberapa preset draw/follow dan pilih yang
-- ninggalin cue ball di posisi paling enak buat shot berikutnya. Kalau gak
-- ada preset spin yang menang/tetep masuk, balik ke center (behavior lama,
-- gak ada regresi).
local function chooseSpinForPosition(geom, balls, group, candidate)
    local basePower = candidate._power
    if not basePower then return end

    local bestSpin, bestPower, bestLeave = nil, basePower, nil
    local _, baseScratch, baseX, baseY = verifyPocketed(
        geom, balls, candidate.targetId, candidate.angle, basePower, nil)
    if not baseScratch then
        bestLeave = evaluateLeaveQuality(balls, group, baseX, baseY, candidate.targetId)
    else
        bestLeave = -1  -- center shot scratch -> spin manapun yang nggak scratch otomatis menang
    end

    for _, preset in ipairs(SPIN_PRESETS) do
        if preset.x ~= 0 or preset.y ~= 0 then
            local spinMag = math.sqrt(preset.x * preset.x + preset.y * preset.y)
            local testPower = math.clamp(
                basePower * (1 + SPIN_POWER_COMPENSATION * spinMag), MIN_POWER, 1.0)

            local pocketed, scratched, leaveX, leaveY = verifyPocketed(
                geom, balls, candidate.targetId, candidate.angle, testPower, preset)

            if pocketed and not scratched then
                local leaveQ = evaluateLeaveQuality(balls, group, leaveX, leaveY, candidate.targetId)
                if leaveQ > bestLeave then
                    bestLeave  = leaveQ
                    bestSpin   = preset
                    bestPower  = testPower
                end
            end
        end
    end

    if bestSpin then
        candidate.spin        = { x = bestSpin.x, y = bestSpin.y }
        candidate._power      = bestPower
        candidate.leaveQuality = bestLeave
        candidate.spinName    = bestSpin.name
    else
        candidate.leaveQuality = (bestLeave >= 0) and bestLeave or 0
    end
end

-- ── TRICK SHOT ENGINE ─────────────────────────────────────────────────────────

-- Probe cushion-first: cue ball BOLEH pantul rail dulu sebelum kena target.
-- Beda dari probe biasa: railHit di cue tidak langsung cancel, tapi dicatat.
-- Kalau cue kena rail lebih dari maxBounce kali → cancel (jangan infinite bounce).
local function probeCushionFirst(geom, cueX, cueY, targetBall, angle, power, maxBounce)
    if not targetBall or not targetBall.id or not targetBall.x or not targetBall.y then return nil, nil, 0 end
    maxBounce = maxBounce or 1
    local cueBall = PhysicsBall.new(0, cueX, cueY)
    local objBall = PhysicsBall.new(targetBall.id, targetBall.x, targetBall.y)
    local state   = PhysicsSim.newState(geom, { cueBall, objBall })
    PhysicsSim.strike(state, { angle = angle, power = power })

    local events   = {}
    local bounces  = 0
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        if objBall.vx ~= 0 or objBall.vy ~= 0 then
            local spd2 = objBall.vx^2 + objBall.vy^2
            return math.atan2(objBall.vy, objBall.vx), math.sqrt(spd2), bounces
        end

        for _, ev in ipairs(events) do
            if ev.ball == 0 then
                if ev.type == "pocket" then return nil, nil, bounces end
                if ev.type == "railHit" then
                    bounces += 1
                    if bounces > maxBounce then return nil, nil, bounces end
                end
            end
        end

        if cueBall.pocketed or not PhysicsBall.isMoving(cueBall) then
            return nil, nil, bounces
        end

        table.clear(events)
    end
    return nil, nil, bounces
end

-- Hitung titik pantulan ideal di rail untuk cushion-first shot.
-- Rail yang tersedia: top (y=+hw), bottom (y=-hw), left (x=-hl), right (x=+hl)
local function railBouncePoints(geom, cueX, cueY, targetX, targetY)
    local hl = geom.halfLength
    local hw = geom.halfWidth
    local points = {}

    -- Pantul atas (y = +hw): mirror target terhadap rail atas
    do
        local rty = 2 * hw - targetY
        local denom = (rty - cueY)
        if math.abs(denom) > 1e-6 then
            local bx2 = cueX + (hw - cueY) / denom * (targetX - cueX)
            if math.abs(bx2) < hl - RADIUS then
                table.insert(points, { bx = bx2, by = hw, rail = "top" })
            end
        end
    end

    -- Pantul bawah (y = -hw): mirror target terhadap rail bawah
    do
        local rty = -2 * hw - targetY
        local denom = (rty - cueY)
        if math.abs(denom) > 1e-6 then
            local bx2 = cueX + (-hw - cueY) / denom * (targetX - cueX)
            if math.abs(bx2) < hl - RADIUS then
                table.insert(points, { bx = bx2, by = -hw, rail = "bottom" })
            end
        end
    end

    -- Pantul kanan (x = +hl): mirror target terhadap rail kanan
    do
        local rtx = 2 * hl - targetX
        local denom = (rtx - cueX)
        if math.abs(denom) > 1e-6 then
            local by2 = cueY + (hl - cueX) / denom * (targetY - cueY)
            if math.abs(by2) < hw - RADIUS then
                table.insert(points, { bx = hl, by = by2, rail = "right" })
            end
        end
    end

    -- Pantul kiri (x = -hl): mirror target terhadap rail kiri
    do
        local rtx = -2 * hl - targetX
        local denom = (rtx - cueX)
        if math.abs(denom) > 1e-6 then
            local by2 = cueY + (-hl - cueX) / denom * (targetY - cueY)
            if math.abs(by2) < hw - RADIUS then
                table.insert(points, { bx = -hl, by = by2, rail = "left" })
            end
        end
    end

    return points
end

-- Sama kayak railBouncePoints, tapi buat DUA kali pantul berturut-turut
-- (lewat salah satu dari 4 pojok meja) — dipake buat double-rail/corner
-- bank shot. Teknik cermin dirantai: reflect target lewat rail KEDUA
-- dulu, baru hasilnya di-reflect lagi lewat rail PERTAMA. Garis lurus
-- dari start ke titik hasil reflect ganda itu motong rail pertama di
-- bounce point 1 — otomatis bener secara hukum pemantulan di rail itu.
-- Dari bounce point 1, garis ke titik hasil reflect TUNGGAL (lewat rail
-- kedua doang) motong rail kedua di bounce point 2.
local function reflectOverRail(x, y, rail)
    if rail.type == "h" then
        return x, 2 * rail.coord - y
    else
        return 2 * rail.coord - x, y
    end
end

local function railLineIntersect(x1, y1, x2, y2, rail)
    if rail.type == "h" then
        local denom = y2 - y1
        if math.abs(denom) < 1e-6 then return nil end
        local tt = (rail.coord - y1) / denom
        return x1 + tt * (x2 - x1), rail.coord
    else
        local denom = x2 - x1
        if math.abs(denom) < 1e-6 then return nil end
        local tt = (rail.coord - x1) / denom
        return rail.coord, y1 + tt * (y2 - y1)
    end
end

local function railBouncePointsDouble(geom, startX, startY, endX, endY)
    local hl = geom.halfLength
    local hw = geom.halfWidth
    local RAILS = {
        { type = "h", coord = hw,  name = "top" },
        { type = "h", coord = -hw, name = "bottom" },
        { type = "v", coord = hl,  name = "right" },
        { type = "v", coord = -hl, name = "left" },
    }
    local points = {}

    -- Cuma kombinasi rail HORIZONTAL + VERTIKAL yang bener-bener nunjuk
    -- ke pojok meja (h+h atau v+v itu dua rail sejajar, bukan pojok).
    -- Loop railA x railB dengan type beda otomatis ngasih 4 pojok x 2
    -- urutan mantul (misal top-dulu-baru-left, atau left-dulu-baru-top).
    for _, rail1 in ipairs(RAILS) do
        for _, rail2 in ipairs(RAILS) do
            if rail1.type ~= rail2.type then
                local e1x, e1y = reflectOverRail(endX, endY, rail2)
                local e2x, e2y = reflectOverRail(e1x, e1y, rail1)

                local bx1, by1 = railLineIntersect(startX, startY, e2x, e2y, rail1)
                if bx1 then
                    local within1 = (rail1.type == "h" and math.abs(bx1) < hl - RADIUS)
                        or (rail1.type == "v" and math.abs(by1) < hw - RADIUS)
                    if within1 then
                        local bx2, by2 = railLineIntersect(bx1, by1, e1x, e1y, rail2)
                        if bx2 then
                            local within2 = (rail2.type == "h" and math.abs(bx2) < hl - RADIUS)
                                or (rail2.type == "v" and math.abs(by2) < hw - RADIUS)
                            if within2 then
                                table.insert(points, {
                                    bx1 = bx1, by1 = by1, rail1 = rail1.name,
                                    bx2 = bx2, by2 = by2, rail2 = rail2.name,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    return points
end

-- TRICK SHOT 1: Cushion-first — cue pantul rail dulu baru kena target
local TRICK_CUSHION_SCORE_MULT = 0.72  -- sedikit lebih rendah dari direct
local function bestCushionFirstShot(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for id, ball in pairs(balls) do
        if id == 0 or ball.pocketed then continue end
        if not ball or not ball.x or not ball.y then continue end
        local isTarget = onlyId and (id == onlyId)
            or (not onlyId and group and ShotJudge.legalTarget(balls, group, id))
            or (not onlyId and not group)
        if not isTarget then continue end

        -- Cari semua bounce point dari 4 rail menuju ghost point target
        for _, pocket in ipairs(aimPockets) do
            if onlyPocketId and pocket.id ~= onlyPocketId then continue end

            local dx0 = pocket.mx - ball.x
            local dy0 = pocket.my - ball.y
            local dist0 = math.sqrt(dx0*dx0 + dy0*dy0)
            if dist0 < 1e-6 then continue end
            local dirx0, diry0 = dx0/dist0, dy0/dist0

            local dotVal = math.clamp(dirx0*pocket.ax + diry0*pocket.ay, -1, 1)
            local appAngle = math.acos(dotVal)
            local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
            if appAngle > math.rad(approachLimitDeg) then continue end

            local ghostX = ball.x - dirx0 * DIAM
            local ghostY = ball.y - diry0 * DIAM
            if math.abs(ghostX) > geometry.halfLength - RADIUS
            or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                continue
            end

            -- Cari semua rail bounce point menuju ghost point
            local bouncePoints = railBouncePoints(geometry, cue.x, cue.y, ghostX, ghostY)
            for _, bp in ipairs(bouncePoints) do
                -- Angle dari cue ke bounce point
                local bdx, bdy = bp.bx - cue.x, bp.by - cue.y
                local blen = math.sqrt(bdx*bdx + bdy*bdy)
                if blen < 1 then continue end
                local angle = math.atan2(bdy, bdx)

                -- Jarak total: cue→rail + rail→ghost + ball→pocket
                local rdx, rdy = ghostX - bp.bx, ghostY - bp.by
                local railToGhost = math.sqrt(rdx*rdx + rdy*rdy)
                local totalDist   = blen + railToGhost + dist0

                -- Cut angle dari ghost ke pocket
                local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                local cueDist   = math.sqrt(cdx*cdx + cdy*cdy)
                if cueDist < 0.25 then continue end
                local ux, uy    = (ghostX - ball.x) / DIAM, (ghostY - ball.y) / DIAM
                local cosCut    = math.clamp(ux * dirx0 + uy * diry0, -1, 1)
                local cutAngle  = math.deg(math.acos(cosCut))
                if cutAngle >= MAX_CUT_ANGLE then continue end

                -- Validasi jalur dari rail ke ghost (ball lain tidak block)
                local ignore = { [0] = true, [id] = true }
                if not segmentClear(bp.bx, bp.by, ghostX, ghostY, balls, ignore) then continue end
                if not segmentClear(ball.x, ball.y, pocket.mx, pocket.my, balls, ignore) then continue end

                local cutForScore = cutAngle
                if not pocket.side then
                    cutForScore = math.max(0, math.deg(math.rad(cutAngle) - 0.349))
                end

                local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutForScore))
                    / (math.max(totalDist, DIAM) * math.max(dist0, DIAM))
                score = score * TRICK_CUSHION_SCORE_MULT

                -- Physics verify pakai probeCushionFirst
                local pw = shotPower(dist0, blen, math.rad(cutAngle), 1.0)
                -- boost power buat cushion first (energy loss di rail)
                pw = math.min(pw * 1.25, 1.0)
                local actualPhi, actualSpd, bounceCount = probeCushionFirst(
                    geometry, cue.x, cue.y, ball, angle, pw, 1)
                if not actualPhi or not actualSpd or bounceCount == 0 then continue end

                -- Line quality buat cushion first
                local lineQ = aimLineQualityDirect(
                    balls, bp.bx, bp.by, ball, ghostX, ghostY, pocket.mx, pocket.my)
                local lineMultiplier = 0.75 + lineQ * 0.40

                table.insert(candidates, {
                    angle       = angle,
                    cueDist     = blen,
                    potDist     = dist0,
                    targetId    = id,
                    pocketId    = pocket.id,
                    cutAngle    = cutAngle,
                    cutAngleRad = math.rad(cutAngle),
                    appAngle    = appAngle,
                    isSide      = pocket.side,
                    phi         = math.atan2(diry0, dirx0),
                    ballRef     = ball,
                    lineQuality = lineQ,
                    _power      = pw,
                    score       = score * lineMultiplier,
                    cueX        = cue.x, cueY = cue.y,
                    isCushionFirst = true,
                    railName    = bp.rail,
                    calibrated  = true,  -- udah physics-verified via probeCushionFirst
                })
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    local MAX_CALIBRATE = 6
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateCushionShot(geometry, c.cueX, c.cueY, c.ballRef, c, 1) then
            local pocketed, scratched, leaveX, leaveY = verifyPocketed(geometry, balls, c.targetId, c.angle, c._power)
            if pocketed then
                if scratched then
                    c.scratch = true
                    c.score = c.score * SCRATCH_SCORE_PENALTY
                else
                    c.leaveQuality = evaluateLeaveQuality(balls, group, leaveX, leaveY, c.targetId)
                    c.score = c.score * (1 + POSITION_PLAY_WEIGHT * c.leaveQuality)
                end
                table.insert(calibrated, c)
                if #calibrated >= 3 then break end
            end
        end
    end

    if #calibrated == 0 then return nil end

    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end

-- TRICK SHOT 2: Rail-kiss / bank shot — target ball kena rail dulu sebelum
-- masuk pocket. Pake mirror-math yang SAMA kayak railBouncePoints (dipake
-- cushion-first buat cue), tapi sekarang dari sudut pandang TARGET BALL:
-- cermin posisi pocket di tiap rail, baru cari titik pantul yang bener
-- secara geometris — bukan nebak satu arah terus gedein power & berharap.
local TRICK_RAILKISS_SCORE_MULT = 0.65
local function bestRailKissShot(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for id, ball in pairs(balls) do
        if id == 0 or ball.pocketed then continue end
        if not ball or not ball.x or not ball.y then continue end
        local isTarget = onlyId and (id == onlyId)
            or (not onlyId and group and ShotJudge.legalTarget(balls, group, id))
            or (not onlyId and not group)
        if not isTarget then continue end

        for _, pocket in ipairs(aimPockets) do
            if onlyPocketId and pocket.id ~= onlyPocketId then continue end

            -- Titik pantul yang bener secara geometris buat ball -> rail -> pocket
            local bouncePoints = railBouncePoints(geometry, ball.x, ball.y, pocket.mx, pocket.my)
            for _, bp in ipairs(bouncePoints) do
                local bdx, bdy = bp.bx - ball.x, bp.by - ball.y
                local blen = math.sqrt(bdx*bdx + bdy*bdy)
                if blen < 1 then continue end
                local dirx0, diry0 = bdx/blen, bdy/blen

                -- Ghost point: cue ngarahin ball ke TITIK PANTUL, bukan ke pocket langsung
                local ghostX = ball.x - dirx0 * DIAM
                local ghostY = ball.y - diry0 * DIAM
                if math.abs(ghostX) > geometry.halfLength - RADIUS
                or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                    continue
                end

                local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                local cueDist   = math.sqrt(cdx*cdx + cdy*cdy)
                if cueDist < 0.25 then continue end

                local cosCut    = math.clamp(
                    (cdx/cueDist)*dirx0 + (cdy/cueDist)*diry0, -1, 1)
                local cutAngle  = math.deg(math.acos(cosCut))
                if cutAngle >= MAX_CUT_ANGLE then continue end

                local ignore = { [0] = true, [id] = true }
                if not segmentClear(cue.x, cue.y, ghostX, ghostY, balls, ignore) then continue end
                if not segmentClear(ball.x, ball.y, bp.bx, bp.by, balls, ignore) then continue end
                if not segmentClear(bp.bx, bp.by, pocket.mx, pocket.my, balls, ignore) then continue end

                local rdx, rdy = pocket.mx - bp.bx, pocket.my - bp.by
                local railToPocket = math.sqrt(rdx*rdx + rdy*rdy)
                if railToPocket < 1e-6 then continue end
                local totalDist = blen + railToPocket

                local angle = math.atan2(cdy, cdx)
                -- power dihitung dari jarak TOTAL beneran (ball->rail->pocket),
                -- bukan jarak lurus ball->pocket — makanya dulu butuh fudge 1.3x
                local pw = math.min(shotPower(totalDist, cueDist, math.rad(cutAngle), 1.0) * 1.15, 1.0)

                -- Approach angle ke pocket itu arah SEGMEN TERAKHIR (rail->pocket),
                -- bukan ball->pocket langsung, karena itu arah bola pas masuk lubang
                local rnx, rny = rdx/railToPocket, rdy/railToPocket
                local dotVal   = math.clamp(rnx*pocket.ax + rny*pocket.ay, -1, 1)
                local appAngle = math.acos(dotVal)

                local cutForScore = cutAngle
                if not pocket.side then
                    cutForScore = math.max(0, math.deg(math.rad(cutAngle) - 0.349))
                end
                local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutForScore))
                    / (math.max(totalDist, DIAM) * math.max(railToPocket, DIAM))
                score = score * TRICK_RAILKISS_SCORE_MULT

                local lineQ         = aimLineQualityDirect(balls, cue.x, cue.y, ball, ghostX, ghostY, bp.bx, bp.by)
                local lineMultiplier = 0.75 + lineQ * 0.40

                table.insert(candidates, {
                    angle       = angle,
                    cueDist     = cueDist,
                    potDist     = totalDist,
                    targetId    = id,
                    pocketId    = pocket.id,
                    cutAngle    = cutAngle,
                    cutAngleRad = math.rad(cutAngle),
                    appAngle    = appAngle,
                    isSide      = pocket.side,
                    phi         = math.atan2(diry0, dirx0),
                    ballRef     = ball,
                    lineQuality = lineQ,
                    _power      = pw,
                    score       = score * lineMultiplier,
                    cueX        = cue.x, cueY = cue.y,
                    isRailKiss  = true,
                    railName    = bp.rail,
                })
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    -- Cue jalan lurus ke ghost (nggak mantul rail di rail-kiss — yang mantul
    -- target ball-nya), jadi calibrateShot biasa cocok buat presisi-in
    -- angle/power cue->ghost. verifyPocketed yang jadi gerbang akhir:
    -- simulasi penuh SEMUA bola di meja, otomatis nyakup fisika rail
    -- bounce-nya karena itu bagian dari simulasinya sendiri.
    local MAX_CALIBRATE = 8
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c) then
            local pocketed, scratched, leaveX, leaveY = verifyPocketed(geometry, balls, c.targetId, c.angle, c._power)
            if pocketed then
                if scratched then
                    c.scratch = true
                    c.score = c.score * SCRATCH_SCORE_PENALTY
                else
                    c.leaveQuality = evaluateLeaveQuality(balls, group, leaveX, leaveY, c.targetId)
                    c.score = c.score * (1 + POSITION_PLAY_WEIGHT * c.leaveQuality)
                end
                table.insert(calibrated, c)
                if #calibrated >= 3 then break end
            end
        end
    end

    if #calibrated == 0 then return nil end

    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end

-- TRICK SHOT 3: Double-rail / corner bank — target ball mantul DUA rail
-- berurutan (lewat salah satu pojok meja) sebelum masuk pocket. Dipake
-- pas direct, cushion-first, dan rail-kiss (1 mantul) semua kehalang —
-- misal bola ketutup total sama bola lawan dari segala sudut 1-rail.
local TRICK_DOUBLERAIL_SCORE_MULT = 0.45  -- lebih rendah dari rail-kiss (makin banyak mantul, makin gampang meleset)
local function bestDoubleRailShot(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for id, ball in pairs(balls) do
        if id == 0 or ball.pocketed then continue end
        if not ball or not ball.x or not ball.y then continue end
        local isTarget = onlyId and (id == onlyId)
            or (not onlyId and group and ShotJudge.legalTarget(balls, group, id))
            or (not onlyId and not group)
        if not isTarget then continue end

        for _, pocket in ipairs(aimPockets) do
            if onlyPocketId and pocket.id ~= onlyPocketId then continue end

            local bouncePairs = railBouncePointsDouble(geometry, ball.x, ball.y, pocket.mx, pocket.my)
            for _, bp in ipairs(bouncePairs) do
                local bdx, bdy = bp.bx1 - ball.x, bp.by1 - ball.y
                local blen = math.sqrt(bdx*bdx + bdy*bdy)
                if blen < 1 then continue end
                local dirx0, diry0 = bdx/blen, bdy/blen

                -- Ghost point: cue ngarahin ball ke BOUNCE POINT PERTAMA
                local ghostX = ball.x - dirx0 * DIAM
                local ghostY = ball.y - diry0 * DIAM
                if math.abs(ghostX) > geometry.halfLength - RADIUS
                or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                    continue
                end

                local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                local cueDist = math.sqrt(cdx*cdx + cdy*cdy)
                if cueDist < 0.25 then continue end

                local cosCut = math.clamp(
                    (cdx/cueDist)*dirx0 + (cdy/cueDist)*diry0, -1, 1)
                local cutAngle = math.deg(math.acos(cosCut))
                if cutAngle >= MAX_CUT_ANGLE then continue end

                -- Validasi SEMUA segmen: cue->ghost, ball->bounce1,
                -- bounce1->bounce2, bounce2->pocket — nggak boleh keblok
                local ignore = { [0] = true, [id] = true }
                if not segmentClear(cue.x, cue.y, ghostX, ghostY, balls, ignore) then continue end
                if not segmentClear(ball.x, ball.y, bp.bx1, bp.by1, balls, ignore) then continue end
                if not segmentClear(bp.bx1, bp.by1, bp.bx2, bp.by2, balls, ignore) then continue end
                if not segmentClear(bp.bx2, bp.by2, pocket.mx, pocket.my, balls, ignore) then continue end

                local r1dx, r1dy = bp.bx2 - bp.bx1, bp.by2 - bp.by1
                local railToRail = math.sqrt(r1dx*r1dx + r1dy*r1dy)
                if railToRail < 1e-6 then continue end

                local r2dx, r2dy = pocket.mx - bp.bx2, pocket.my - bp.by2
                local railToPocket = math.sqrt(r2dx*r2dx + r2dy*r2dy)
                if railToPocket < 1e-6 then continue end

                local totalDist = blen + railToRail + railToPocket
                local angle = math.atan2(cdy, cdx)
                -- power dari jarak total beneran (ball->rail1->rail2->pocket),
                -- fudge lebih gede dari rail-kiss biasa karena 2x energy loss di rail
                local pw = math.min(shotPower(totalDist, cueDist, math.rad(cutAngle), 1.0) * 1.2, 1.0)

                -- Approach angle ke pocket = arah segmen TERAKHIR (rail2->pocket)
                local rnx, rny = r2dx/railToPocket, r2dy/railToPocket
                local dotVal   = math.clamp(rnx*pocket.ax + rny*pocket.ay, -1, 1)
                local appAngle = math.acos(dotVal)

                local cutForScore = cutAngle
                if not pocket.side then
                    cutForScore = math.max(0, math.deg(math.rad(cutAngle) - 0.349))
                end
                local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutForScore))
                    / (math.max(totalDist, DIAM) * math.max(railToPocket, DIAM))
                score = score * TRICK_DOUBLERAIL_SCORE_MULT

                local lineQ          = aimLineQualityDirect(balls, cue.x, cue.y, ball, ghostX, ghostY, bp.bx1, bp.by1)
                local lineMultiplier = 0.75 + lineQ * 0.40

                table.insert(candidates, {
                    angle        = angle,
                    cueDist      = cueDist,
                    potDist      = totalDist,
                    targetId     = id,
                    pocketId     = pocket.id,
                    cutAngle     = cutAngle,
                    cutAngleRad  = math.rad(cutAngle),
                    appAngle     = appAngle,
                    isSide       = pocket.side,
                    phi          = math.atan2(diry0, dirx0),
                    ballRef      = ball,
                    lineQuality  = lineQ,
                    _power       = pw,
                    score        = score * lineMultiplier,
                    cueX         = cue.x, cueY = cue.y,
                    isDoubleRail = true,
                    railName     = bp.rail1 .. "->" .. bp.rail2,
                })
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    -- Sama kayak rail-kiss: cue jalan lurus ke ghost, verifyPocketed
    -- (simulasi fisika penuh) yang jadi gerbang akhir buat nyakup
    -- fisika DUA kali bounce-nya.
    local MAX_CALIBRATE = 10
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c)
            and verifyPocketed(geometry, balls, c.targetId, c.angle, c._power) then
            table.insert(calibrated, c)
            if #calibrated >= 3 then break end
        end
    end

    if #calibrated == 0 then return nil end

    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end
-- ─────────────────────────────────────────────────────────────────────────────

calibrateShot = function(geom, cueX, cueY, targetBall, candidate)
    local phi       = candidate.phi
    local potDist   = candidate.potDist
    local cut       = candidate.cutAngleRad or math.rad(candidate.cutAngle or 0)

    local arriveV2  = ARRIVE_SPEED^2 + 2 * ROLLING_DECEL * potDist
    local targetSpd = candidate.targetObjSpeed or (math.sqrt(arriveV2) * 1.4)
    local cosCut    = math.max(math.cos(cut), 0.25)
    local cueSpeed  = targetSpd / cosCut * 1.15 + 5

    local angle     = candidate.angle
    local converged = false
    local dAngleDPhi = nil

    for _ = 1, 5 do
        local pw = powerForSpeed(cueSpeed)
        local actualPhi, actualSpd = probe(geom, cueX, cueY, targetBall, angle, pw)
        if not actualPhi or not actualSpd or actualSpd <= 0 then
            return false
        end

        local dPhi = actualPhi - phi
        while dPhi >  math.pi do dPhi = dPhi - 2*math.pi end
        while dPhi < -math.pi do dPhi = dPhi + 2*math.pi end

        local speedRatio = targetSpd / actualSpd

        if math.abs(dPhi) < math.rad(0.02) then
            if math.abs(speedRatio - 1) < 0.03 then
                converged = true
                break
            end
        end

        if not dAngleDPhi then
            local pw2 = powerForSpeed(cueSpeed)
            local phi2 = probe(geom, cueX, cueY, targetBall, angle + 0.002, pw2)
            if not phi2 then return false end
            local dphi2 = phi2 - actualPhi
            while dphi2 >  math.pi do dphi2 = dphi2 - 2*math.pi end
            while dphi2 < -math.pi do dphi2 = dphi2 + 2*math.pi end
            dAngleDPhi = dphi2 / 0.002
            if math.abs(dAngleDPhi) < 0.1 then return false end
        end

        angle    = angle - dPhi / dAngleDPhi
        cueSpeed = math.min(cueSpeed * speedRatio, CUE_MAX_SPEED)

        if math.abs(dPhi) < math.rad(0.1) then
            converged = true
        end
    end

    if not converged then return false end

    candidate.angle        = angle
    candidate._power       = powerForSpeed(cueSpeed)
    candidate.calibrated   = true
    return true
end

-- Sama persis kayak calibrateShot, tapi pakai probeCushionFirst (cue boleh
-- mantul rail N kali dulu) buat ngukur actualPhi/actualSpd. Tanpa ini,
-- cushion-first cuma pakai angle/power hasil rumus geometris mentah —
-- nggak pernah dikoreksi terhadap fisika beneran, makanya gampang miss
-- begitu ada bounce.
calibrateCushionShot = function(geom, cueX, cueY, targetBall, candidate, maxBounce)
    maxBounce = maxBounce or 1
    local phi       = candidate.phi
    local potDist   = candidate.potDist
    local cut       = candidate.cutAngleRad or math.rad(candidate.cutAngle or 0)

    local arriveV2  = ARRIVE_SPEED^2 + 2 * ROLLING_DECEL * potDist
    local targetSpd = candidate.targetObjSpeed or (math.sqrt(arriveV2) * 1.4)
    local cosCut    = math.max(math.cos(cut), 0.25)
    local cueSpeed  = targetSpd / cosCut * 1.15 + 5

    local angle     = candidate.angle
    local converged = false
    local dAngleDPhi = nil

    for _ = 1, 5 do
        local pw = powerForSpeed(cueSpeed)
        local actualPhi, actualSpd = probeCushionFirst(geom, cueX, cueY, targetBall, angle, pw, maxBounce)
        if not actualPhi or not actualSpd or actualSpd <= 0 then
            return false
        end

        local dPhi = actualPhi - phi
        while dPhi >  math.pi do dPhi = dPhi - 2*math.pi end
        while dPhi < -math.pi do dPhi = dPhi + 2*math.pi end

        local speedRatio = targetSpd / actualSpd

        if math.abs(dPhi) < math.rad(0.02) then
            if math.abs(speedRatio - 1) < 0.03 then
                converged = true
                break
            end
        end

        if not dAngleDPhi then
            local pw2 = powerForSpeed(cueSpeed)
            local phi2 = probeCushionFirst(geom, cueX, cueY, targetBall, angle + 0.002, pw2, maxBounce)
            if not phi2 then return false end
            local dphi2 = phi2 - actualPhi
            while dphi2 >  math.pi do dphi2 = dphi2 - 2*math.pi end
            while dphi2 < -math.pi do dphi2 = dphi2 + 2*math.pi end
            dAngleDPhi = dphi2 / 0.002
            if math.abs(dAngleDPhi) < 0.1 then return false end
        end

        angle    = angle - dPhi / dAngleDPhi
        cueSpeed = math.min(cueSpeed * speedRatio, CUE_MAX_SPEED)

        if math.abs(dPhi) < math.rad(0.1) then
            converged = true
        end
    end

    if not converged then return false end

    candidate.angle        = angle
    candidate._power       = powerForSpeed(cueSpeed)
    candidate.calibrated   = true
    return true
end

local snapshots = {}
local mySeat = nil
local lastFired = {}
local lastCalled = {}
local currentAngle = {}
local cached8Shot = {}

local cueInput = nil

local function findCueInput()
    local ok, list = pcall(getgc, true)
    if not ok then return nil end
    for _, obj in ipairs(list) do
        if type(obj) == "table"
            and type(rawget(obj, "angle")) == "number"
            and type(rawget(obj, "aimListeners")) == "table"
            and type(rawget(obj, "spinListeners")) == "table"
            and type(rawget(obj, "elevationListeners")) == "table"
        then
            return obj
        end
    end
    return nil
end

local function setLocalCueAngle(angle)
    if not cueInput then
        cueInput = findCueInput()
    end
    if cueInput then
        pcall(function() cueInput:setAngle(angle) end)
    end
end

local function setLocalCueEnabled(enabled)
    if not cueInput then
        cueInput = findCueInput()
    end
    if cueInput then
        pcall(function() cueInput:setEnabled(enabled) end)
    end
end

local MIN_AIM_UPDATE_INTERVAL = 0.12
local lastAimSent = {}

local function sendAimUpdate(tableId, angle, snap, force)
    local now = os.clock()
    if not force and lastAimSent[tableId] and (now - lastAimSent[tableId]) < MIN_AIM_UPDATE_INTERVAL then
        return true
    end
    lastAimSent[tableId] = now
    return pcall(function()
        Net.get("AimUpdate"):FireServer(
            tableId, angle, snap.epoch, snap.turnId,
            0, nil, nil, nil, ELEVATION
        )
    end)
end

function parseBalls(flat)
    local balls = {}
    if not flat then return balls end
    local n = math.floor(#flat / 4)
    for id = 0, n - 1 do
        local base = id * 4
        balls[id] = {
            id = id,
            x = flat[base + 1],
            y = flat[base + 2],
            z = flat[base + 3],
            pocketed = flat[base + 4] == 1,
        }
    end
    return balls
end

segmentClear = function(ax, ay, bx, by, balls, ignore)
    local dx, dy = bx - ax, by - ay
    local len2 = dx * dx + dy * dy
    if len2 < 1e-9 then return true end
    local minGap2 = (2 * RADIUS) * (2 * RADIUS) * 0.92
    for id, b in pairs(balls) do
        if not b.pocketed and not ignore[id] then
            local t = ((b.x - ax) * dx + (b.y - ay) * dy) / len2
            t = math.clamp(t, 0, 1)
            local px, py = ax + t * dx, ay + t * dy
            local ddx, ddy = b.x - px, b.y - py
            if ddx * ddx + ddy * ddy < minGap2 then
                return false
            end
        end
    end
    return true
end

-- ── INTERNAL AIM LINE VALIDATOR ─────────────────────────────────────────────
-- Ngitung "kualitas garis" dari sebuah shot tanpa rendering apapun.
-- Makin tinggi nilainya (0..1), makin lurus dan bersih jalurnya.
-- Dipake sebagai multiplier di scoring semua jenis shot.
--
-- Segments yang dicek:
--   direct : cue→ghost, ball→pocket
--   combo  : cue→ghostA, ballA→ghostB, ballB→pocket
--   safety : cue→target
--
-- Faktor yang dinilai per segment:
--   1. Clearance margin  — seberapa jauh bola lain dari garis (makin lebar makin bagus)
--   2. Alignment score   — seberapa lurus segmen-segmen itu satu sama lain
--   3. Length penalty    — garis panjang dikurangi sedikit (lebih susah akurat)

local AIM_LINE_CLEAR_MULTIPLIER = 1.6  -- margin yang dianggap "nyaman" = DIAM * ini
local AIM_LINE_LENGTH_PENALTY   = 0.0008  -- per inch panjang total

segmentClearance = function(ax, ay, bx, by, balls, ignore)
    -- Return: minimum clearance ratio dari semua bola ke garis ini (0..inf)
    -- 1.0 = persis mepet DIAM (garis aman tapi pas-pasan), >1 = lega, <1 = mepet banget
    local dx, dy = bx - ax, by - ay
    local len2 = dx * dx + dy * dy
    if len2 < 1e-9 then return math.huge end
    local minClear = math.huge
    for id, b in pairs(balls) do
        if not b.pocketed and not ignore[id] then
            local t = math.clamp(((b.x - ax) * dx + (b.y - ay) * dy) / len2, 0, 1)
            local px, py = ax + t * dx, ay + t * dy
            local ddx, ddy = b.x - px, b.y - py
            local dist = math.sqrt(ddx * ddx + ddy * ddy)
            local ratio = dist / DIAM
            if ratio < minClear then minClear = ratio end
        end
    end
    return minClear
end

local function segmentAlignment(ax, ay, bx, by, cx, cy)
    -- Seberapa lurus titik A→B→C (dot product arah AB dan BC)
    -- 1.0 = lurus sempurna, 0 = belok 90°, -1 = balik arah
    local abx, aby = bx - ax, by - ay
    local bcx, bcy = cx - bx, cy - by
    local lenAB = math.sqrt(abx * abx + aby * aby)
    local lenBC = math.sqrt(bcx * bcx + bcy * bcy)
    if lenAB < 1e-6 or lenBC < 1e-6 then return 1 end
    return (abx / lenAB) * (bcx / lenBC) + (aby / lenAB) * (bcy / lenBC)
end

-- Direct shot: cue→ghost→ball→pocket
aimLineQualityDirect = function(balls, cueX, cueY, ball, ghostX, ghostY, pocketMX, pocketMY)
    local ignore = { [0] = true, [ball.id] = true }

    local clearCue   = segmentClearance(cueX, cueY, ghostX, ghostY, balls, ignore)
    local clearPot   = segmentClearance(ball.x, ball.y, pocketMX, pocketMY, balls, ignore)
    local minClear   = math.min(clearCue, clearPot)

    -- Clearance score: 0 jika mepet banget, 1 jika lega (>= AIM_LINE_CLEAR_MULTIPLIER)
    local clearScore = math.clamp(
        (minClear - 1.0) / (AIM_LINE_CLEAR_MULTIPLIER - 1.0), 0, 1)

    -- Alignment: cue→ghost→pocket (idealnya relatif lurus setelah tumbukan)
    local alignScore = math.clamp(
        (segmentAlignment(cueX, cueY, ghostX, ghostY, pocketMX, pocketMY) + 1) / 2, 0, 1)

    -- Length penalty
    local lenCue = math.sqrt((ghostX-cueX)^2 + (ghostY-cueY)^2)
    local lenPot = math.sqrt((pocketMX-ball.x)^2 + (pocketMY-ball.y)^2)
    local lengthFactor = math.max(0, 1 - (lenCue + lenPot) * AIM_LINE_LENGTH_PENALTY)

    local quality = (clearScore * 0.55 + alignScore * 0.25 + lengthFactor * 0.20)
    return quality
end

-- Combo shot: cue→ghostA, ballA→ghostB, ballB→pocket
local function aimLineQualityCombo(balls, cueX, cueY, ballA, ghostAX, ghostAY, ballB, ghostBX, ghostBY, pocketMX, pocketMY)
    local ignore = { [0] = true, [ballA.id] = true, [ballB.id] = true }

    local clearCue  = segmentClearance(cueX, cueY, ghostAX, ghostAY, balls, ignore)
    local clearMid  = segmentClearance(ballA.x, ballA.y, ghostBX, ghostBY, balls, ignore)
    local clearPot  = segmentClearance(ballB.x, ballB.y, pocketMX, pocketMY, balls, ignore)
    local minClear  = math.min(clearCue, clearMid, clearPot)

    local clearScore = math.clamp(
        (minClear - 1.0) / (AIM_LINE_CLEAR_MULTIPLIER - 1.0), 0, 1)

    -- Alignment: cue→ghostA→ghostB dan ghostA→ghostB→pocket
    local align1 = (segmentAlignment(cueX, cueY, ghostAX, ghostAY, ghostBX, ghostBY) + 1) / 2
    local align2 = (segmentAlignment(ghostAX, ghostAY, ghostBX, ghostBY, pocketMX, pocketMY) + 1) / 2
    local alignScore = math.clamp((align1 + align2) / 2, 0, 1)

    local lenTotal = math.sqrt((ghostAX-cueX)^2+(ghostAY-cueY)^2)
        + math.sqrt((ghostBX-ballA.x)^2+(ghostBY-ballA.y)^2)
        + math.sqrt((pocketMX-ballB.x)^2+(pocketMY-ballB.y)^2)
    local lengthFactor = math.max(0, 1 - lenTotal * AIM_LINE_LENGTH_PENALTY * 1.3)

    local quality = (clearScore * 0.50 + alignScore * 0.30 + lengthFactor * 0.20)
    return quality
end

-- Safety shot: cue→target (satu segment, yang penting clear dan pendek)
local function aimLineQualitySafety(balls, cueX, cueY, targetBall)
    local ignore = { [0] = true, [targetBall.id] = true }
    local clear = segmentClearance(cueX, cueY, targetBall.x, targetBall.y, balls, ignore)
    local clearScore = math.clamp((clear - 1.0) / (AIM_LINE_CLEAR_MULTIPLIER - 1.0), 0, 1)
    local lenFactor  = math.max(0, 1 - math.sqrt(
        (targetBall.x-cueX)^2 + (targetBall.y-cueY)^2) * AIM_LINE_LENGTH_PENALTY)
    return clearScore * 0.70 + lenFactor * 0.30
end
-- ─────────────────────────────────────────────────────────────────────────────

local CLUSTER_RADIUS = RADIUS * 6
local CLUSTER_WEIGHT = 2.5

local function clusterPenalty(balls, targetId, ball)
    local penalty = 0
    for otherId, other in pairs(balls) do
        if otherId ~= 0 and otherId ~= targetId and not other.pocketed then
            local dx, dy = other.x - ball.x, other.y - ball.y
            local d = math.sqrt(dx * dx + dy * dy)
            if d < CLUSTER_RADIUS then
                penalty += (CLUSTER_RADIUS - d)
            end
        end
    end
    return penalty
end

local function safeShot(balls, group)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local function pick(requireOwn)
        -- Pilih safety target terbaik berdasarkan jarak + aim line quality
        local bestId, bestScore, bestDist, bestAngle = nil, -math.huge, math.huge, 0
        for id, ball in pairs(balls) do
            if id == 0 or ball.pocketed then continue end
            if requireOwn and not ShotJudge.legalTarget(balls, group, id) then continue end
            local dx, dy = ball.x - cue.x, ball.y - cue.y
            local d = math.sqrt(dx*dx + dy*dy)
            local ignore = { [0] = true, [id] = true }
            if not segmentClear(cue.x, cue.y, ball.x, ball.y, balls, ignore) then continue end
            -- Internal aim line: lebih pendek dan clear = lebih baik
            local lineQ  = aimLineQualitySafety(balls, cue.x, cue.y, ball)
            local pickScore = lineQ / math.max(d, DIAM)
            if pickScore <= bestScore then continue end
            bestScore = pickScore
            bestDist  = d
            bestId    = id
            bestAngle = math.atan2(dy, dx)
        end
        return bestId, bestDist, bestAngle
    end

    local bestId, bestDist, bestAngle = pick(true)
    local forcedFoul = false
    if not bestId then
        bestId, bestDist, bestAngle = pick(false)
        forcedFoul = bestId ~= nil
    end

    if not bestId then return nil end
    local safePower = math.clamp(
        powerForSpeed(ARRIVE_SPEED + ROLLING_DECEL * bestDist * 0.5 / math.max(ARRIVE_SPEED, 1)),
        MIN_POWER, 0.35
    )
    if forcedFoul then
        warn(("[c8bbot] SEMUA bola sendiri ketutup total (gak ada garis lurus yang clear) — gak ada shot legal yang mungkin. Forced foul: pukul pelan ball %d (line-of-sight clear, bukan asal tebak) power=%.2f"):format(bestId, safePower))
    else
        warn(("[c8bbot] no feasible pot — safe fallback: hit ball %d (line-of-sight clear) power=%.2f"):format(bestId, safePower))
    end
    return {
        angle       = bestAngle,
        targetId    = bestId,
        pocketId    = nil,
        cutAngle    = 0,
        cutAngleRad = 0,
        cueDist     = bestDist,
        potDist     = 0,
        _power      = safePower,
        forcedFoul  = forcedFoul,
    }
end

local function isEligibleTarget(balls, group, id, onlyId)
    if onlyId then return id == onlyId end
    return ShotJudge.legalTarget(balls, group, id)
end

local function bestShot(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}
    local closestReject = nil

    for id, ball in pairs(balls) do
        if id ~= 0 and not ball.pocketed and isEligibleTarget(balls, group, id, onlyId) then
            local clusterCost = clusterPenalty(balls, id, ball)

            for _, pocket in ipairs(aimPockets) do
                if onlyPocketId and pocket.id ~= onlyPocketId then continue end
                local dx0 = pocket.mx - ball.x
                local dy0 = pocket.my - ball.y
                local dist0 = math.sqrt(dx0 * dx0 + dy0 * dy0)
                if dist0 < 1e-6 then continue end
                local dirx0, diry0 = dx0 / dist0, dy0 / dist0

                local dotVal = math.clamp(dirx0 * pocket.ax + diry0 * pocket.ay, -1, 1)
                local appAngle = math.acos(dotVal)
                local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
                if appAngle > math.rad(approachLimitDeg) then continue end

                local ghostX = ball.x - dirx0 * DIAM
                local ghostY = ball.y - diry0 * DIAM
                if math.abs(ghostX) > geometry.halfLength - RADIUS
                or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                    continue
                end

                local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                local cueDist = math.sqrt(cdx * cdx + cdy * cdy)
                if cueDist < 0.25 then continue end
                local ux, uy = cdx / cueDist, cdy / cueDist

                local cosCut = math.clamp(ux * dirx0 + uy * diry0, -1, 1)
                local cutAngle = math.deg(math.acos(cosCut))

                local ignore = { [0] = true, [id] = true }
                local blocked = (cutAngle >= MAX_CUT_ANGLE)
                    or not segmentClear(cue.x, cue.y, ghostX, ghostY, balls, ignore)
                    or not segmentClear(ball.x, ball.y, pocket.mx, pocket.my, balls, ignore)

                if not closestReject or cutAngle < closestReject.cutAngle then
                    closestReject = { cutAngle = cutAngle, targetId = id, pocketId = pocket.id }
                end

                if blocked then continue end

                local cutForScore = cutAngle
                if not pocket.side then
                    cutForScore = math.max(0, math.deg(math.rad(cutAngle) - 0.3490658503988659))
                end

                local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutForScore))
                    / (math.max(cueDist, DIAM) * math.max(dist0, DIAM))

                -- Internal aim line: validasi kualitas jalur cue→ghost→pocket
                local lineQ = aimLineQualityDirect(
                    balls, cue.x, cue.y, ball,
                    ghostX, ghostY, pocket.mx, pocket.my)
                -- lineQ 0..1, scale ke 0.75..1.15 agar gak terlalu dominan tp berpengaruh nyata
                local lineMultiplier = 0.75 + lineQ * 0.40

                table.insert(candidates, {
                    angle = math.atan2(cdy, cdx),
                    cueDist = cueDist, potDist = dist0,
                    targetId = id, pocketId = pocket.id,
                    cutAngle = cutAngle,
                    cutAngleRad = math.rad(cutAngle),
                    appAngle = appAngle,
                    isSide = pocket.side,
                    phi = math.atan2(diry0, dirx0),
                    ballRef = ball,
                    clusterCost = clusterCost,
                    lineQuality = lineQ,
                    score = (score - clusterCost * CLUSTER_WEIGHT * 0.001) * lineMultiplier,
                    cueX = cue.x, cueY = cue.y,
                })
            end
        end
    end

    if #candidates == 0 then
        if closestReject then
            warn(("[c8bbot][debug] no clean shot, closest: ball %d -> pocket %s | cutAngle=%.1f")
                :format(closestReject.targetId, tostring(closestReject.pocketId), closestReject.cutAngle))
        end
        return nil
    end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local MAX_CALIBRATE = 6
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c)
            and verifyPocketed(geometry, balls, c.targetId, c.angle, c._power) then
            table.insert(calibrated, c)
            if #calibrated >= 3 then break end
        end
    end

    if #calibrated == 0 then
        warn("[c8bbot] calibrate+verify gagal semua — nggak ada direct shot yang beneran kebukti masuk")
        return nil
    end

    table.sort(calibrated, function(a, b) return a.score > b.score end)

    -- Posisi-main: cuma shot paling top yang dicobain variasi draw/follow,
    -- biar cue ball-nya mendarat enak buat shot berikutnya, bukan asal pot.
    -- Gated by Settings.SpinEnabled (GUI toggle "Spin / Position Play").
    if Settings.SpinEnabled then
        for i = 1, math.min(SPIN_TRY_TOP_N, #calibrated) do
            local c = calibrated[i]
            chooseSpinForPosition(geometry, balls, group, c)
            if c.leaveQuality then
                c.score = c.score * (1 + POSITION_PLAY_WEIGHT * c.leaveQuality)
            end
            if c.spinName then
                warn(("[c8bbot] position-play: ball %d -> pocket %s pakai spin [%s] (y=%.2f) | leaveQ=%.3f")
                    :format(c.targetId, tostring(c.pocketId), c.spinName, c.spin.y, c.leaveQuality or -1))
            end
        end
    end

    -- Re-sort: skor bisa berubah urutan abis leaveQuality dilipetin masuk.
    table.sort(calibrated, function(a, b) return a.score > b.score end)

    return calibrated
end

local function comboProbe(geom, cueX, cueY, ballA, ballB, angle, power)
    local cueBall = PhysicsBall.new(0, cueX, cueY)
    local aBall   = PhysicsBall.new(ballA.id, ballA.x, ballA.y)
    local bBall   = PhysicsBall.new(ballB.id, ballB.x, ballB.y)
    local state   = PhysicsSim.newState(geom, { cueBall, aBall, bBall })
    PhysicsSim.strike(state, { angle = angle, power = power })

    local events = {}
    local aHit = false
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        if not aHit and (aBall.vx ~= 0 or aBall.vy ~= 0) then
            aHit = true
        end

        if bBall.vx ~= 0 or bBall.vy ~= 0 then
            local spd2 = bBall.vx * bBall.vx + bBall.vy * bBall.vy
            return math.atan2(bBall.vy, bBall.vx), math.sqrt(spd2), aHit
        end

        for _, ev in ipairs(events) do
            if ev.ball == 0 and (ev.type == "railHit" or ev.type == "pocket") then
                return nil, nil, aHit
            end
            if ev.ball == ballA.id and (ev.type == "railHit" or ev.type == "pocket") then
                return nil, nil, aHit
            end
        end

        if not aHit and (cueBall.pocketed or not PhysicsBall.isMoving(cueBall)) then
            return nil, nil, false
        end

        table.clear(events)
    end
    return nil, nil, aHit
end

local function calibrateCombo(geom, cueX, cueY, ballA, ballB, candidate)
    local phi     = candidate.phi
    local potDist = candidate.potDist
    local cut     = candidate.cutAngleRad or math.rad(candidate.cutAngle or 0)

    local arriveV2  = ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * potDist
    local targetSpd = math.sqrt(arriveV2) * 1.4
    local cosCut    = math.max(math.cos(cut), 0.25)
    local cueSpeed = targetSpd / cosCut * 1.15 * 1.35 + 8

    local angle      = candidate.angle
    local converged  = false
    local dAngleDPhi = nil

    for _ = 1, 7 do
        local pw = powerForSpeed(cueSpeed)
        local actualPhi, actualSpd = comboProbe(geom, cueX, cueY, ballA, ballB, angle, pw)
        if not actualPhi or not actualSpd or actualSpd <= 0 then
            return false
        end

        local dPhi = actualPhi - phi
        while dPhi >  math.pi do dPhi = dPhi - 2*math.pi end
        while dPhi < -math.pi do dPhi = dPhi + 2*math.pi end

        local speedRatio = targetSpd / actualSpd

        if math.abs(dPhi) < math.rad(0.05) then
            if math.abs(speedRatio - 1) < 0.04 then
                converged = true
                break
            end
        end

        if not dAngleDPhi then
            local pw2 = powerForSpeed(cueSpeed)
            local phi2 = comboProbe(geom, cueX, cueY, ballA, ballB, angle + 0.002, pw2)
            if not phi2 then return false end
            local dphi2 = phi2 - actualPhi
            while dphi2 >  math.pi do dphi2 = dphi2 - 2*math.pi end
            while dphi2 < -math.pi do dphi2 = dphi2 + 2*math.pi end
            dAngleDPhi = dphi2 / 0.002
            if math.abs(dAngleDPhi) < 0.05 then return false end
        end

        angle    = angle - dPhi / dAngleDPhi
        cueSpeed = math.min(cueSpeed * speedRatio, CUE_MAX_SPEED)

        if math.abs(dPhi) < math.rad(0.15) then
            converged = true
        end
    end

    if not converged then return false end

    candidate.angle      = angle
    candidate._power     = powerForSpeed(cueSpeed)
    candidate.calibrated = true
    return true
end

local COMBO_SCORE_PENALTY = 0.55

local function bestComboShot(balls, group, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for bId, ballB in pairs(balls) do
        if bId == 0 or bId == 8 or ballB.pocketed then continue end
        if not ShotJudge.legalTarget(balls, group, bId) then continue end

        for _, pocket in ipairs(aimPockets) do
            if onlyPocketId and pocket.id ~= onlyPocketId then continue end

            local dx0 = pocket.mx - ballB.x
            local dy0 = pocket.my - ballB.y
            local dist0 = math.sqrt(dx0 * dx0 + dy0 * dy0)
            if dist0 < 1e-6 then continue end
            local dirx0, diry0 = dx0 / dist0, dy0 / dist0

            local dotVal = math.clamp(dirx0 * pocket.ax + diry0 * pocket.ay, -1, 1)
            local appAngle = math.acos(dotVal)
            local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
            if appAngle > math.rad(approachLimitDeg) then continue end

            local ghostBX = ballB.x - dirx0 * DIAM
            local ghostBY = ballB.y - diry0 * DIAM
            if math.abs(ghostBX) > geometry.halfLength - RADIUS
            or math.abs(ghostBY) > geometry.halfWidth  - RADIUS then
                continue
            end

            for aId, ballA in pairs(balls) do
                if aId == 0 or aId == bId or aId == 8 or ballA.pocketed then continue end
                if not ShotJudge.legalTarget(balls, group, aId) then continue end

                local adx0 = ghostBX - ballA.x
                local ady0 = ghostBY - ballA.y
                local adist0 = math.sqrt(adx0 * adx0 + ady0 * ady0)
                if adist0 < 1e-6 then continue end
                local adirx0, adiry0 = adx0 / adist0, ady0 / adist0

                local ghostAX = ballA.x - adirx0 * DIAM
                local ghostAY = ballA.y - adiry0 * DIAM
                if math.abs(ghostAX) > geometry.halfLength - RADIUS
                or math.abs(ghostAY) > geometry.halfWidth  - RADIUS then
                    continue
                end

                local cdx, cdy = ghostAX - cue.x, ghostAY - cue.y
                local cueDist = math.sqrt(cdx * cdx + cdy * cdy)
                if cueDist < 0.25 then continue end
                local ux, uy = cdx / cueDist, cdy / cueDist

                local cosCutA = math.clamp(ux * adirx0 + uy * adiry0, -1, 1)
                local cutAngleA = math.deg(math.acos(cosCutA))
                if cutAngleA >= MAX_CUT_ANGLE then continue end

                local ignore = { [0] = true, [aId] = true, [bId] = true }
                if not segmentClear(cue.x, cue.y, ghostAX, ghostAY, balls, ignore) then continue end
                if not segmentClear(ballA.x, ballA.y, ghostBX, ghostBY, balls, ignore) then continue end
                if not segmentClear(ballB.x, ballB.y, pocket.mx, pocket.my, balls, ignore) then continue end

                local cutForScore = cutAngleA
                if not pocket.side then
                    cutForScore = math.max(0, math.deg(math.rad(cutAngleA) - 0.3490658503988659))
                end

                local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutForScore))
                    / (math.max(cueDist, DIAM) * math.max(dist0 + adist0, DIAM))
                score = score * COMBO_SCORE_PENALTY

                -- Internal aim line: validasi jalur combo cue→ghostA→ghostB→pocket
                local lineQ = aimLineQualityCombo(
                    balls, cue.x, cue.y,
                    ballA, ghostAX, ghostAY,
                    ballB, ghostBX, ghostBY,
                    pocket.mx, pocket.my)
                local lineMultiplier = 0.75 + lineQ * 0.40

                table.insert(candidates, {
                    angle = math.atan2(cdy, cdx),
                    cueDist = cueDist, potDist = dist0,
                    targetId = aId, comboTargetId = bId, pocketId = pocket.id,
                    cutAngle = cutAngleA,
                    cutAngleRad = math.rad(cutAngleA),
                    appAngle = appAngle,
                    isSide = pocket.side,
                    phi = math.atan2(diry0, dirx0),
                    ballRef = ballA, ballBRef = ballB,
                    lineQuality = lineQ,
                    score = score * lineMultiplier,
                    cueX = cue.x, cueY = cue.y,
                    isCombo = true,
                })
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    local MAX_CALIBRATE = 8
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        -- Yang masuk pocket di combo itu ballB (comboTargetId), bukan
        -- ballA — jadi verifyPocketed dicek ke comboTargetId.
        if calibrateCombo(geometry, c.cueX, c.cueY, c.ballRef, c.ballBRef, c)
            and verifyPocketed(geometry, balls, c.comboTargetId, c.angle, c._power) then
            table.insert(calibrated, c)
            if #calibrated >= 2 then break end
        end
    end

    if #calibrated == 0 then return nil end
    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end


local function breakShotAim(balls)
    local cue = balls[0]
    local apex = balls[1]
    if not cue or not apex then return nil end
    local dx, dy = apex.x - cue.x, apex.y - cue.y
    if math.sqrt(dx * dx + dy * dy) < 1e-6 then return nil end
    return { angle = math.atan2(dy, dx), power = 0.95 }
end

local function safeShot8(balls)
    local cue = balls[0]
    local ball8 = balls[8]
    if not cue or cue.pocketed or not ball8 or ball8.pocketed then return nil end

    local dx, dy = ball8.x - cue.x, ball8.y - cue.y
    local cueDist = math.sqrt(dx * dx + dy * dy)
    if cueDist < 1e-6 then return nil end
    local angle = math.atan2(dy, dx)

    local ignore8 = { [0] = true, [8] = true }
    local clear = segmentClear(cue.x, cue.y, ball8.x, ball8.y, balls, ignore8)

    if clear then
        local VIRTUAL_RAIL_DIST = 35
        local power = shotPower(VIRTUAL_RAIL_DIST, cueDist, 0, 0.65)
        return {
            angle       = angle,
            targetId    = 8,
            pocketId    = nil,
            cutAngle    = 0,
            cutAngleRad = 0,
            cueDist     = cueDist,
            potDist     = 0,
            _power      = power,
            isSafety    = true,
        }
    end

    local blockerId, blockerDist, blockerAngle = nil, math.huge, angle
    for id, b in pairs(balls) do
        if id == 0 or id == 8 or b.pocketed then continue end
        local bdx, bdy = b.x - cue.x, b.y - cue.y
        local bd = math.sqrt(bdx*bdx + bdy*bdy)
        if bd >= blockerDist then continue end
        local ig = { [0] = true, [id] = true }
        if segmentClear(cue.x, cue.y, b.x, b.y, balls, ig) then
            blockerId, blockerDist, blockerAngle = id, bd, math.atan2(bdy, bdx)
        end
    end
    if not blockerId then return nil end

    local power = math.clamp(
        powerForSpeed(ARRIVE_SPEED + ROLLING_DECEL * blockerDist * 0.5 / math.max(ARRIVE_SPEED, 1)),
        MIN_POWER, 0.35
    )
    warn(("[c8bbot] bola 8 ketutup total (gak ada garis lurus clear ke bola 8 sama sekali) — gak ada shot legal yang mungkin. Forced foul: pukul pelan ball %d (line-of-sight clear) power=%.2f"):format(blockerId, power))
    return {
        angle       = blockerAngle,
        targetId    = blockerId,
        pocketId    = nil,
        cutAngle    = 0,
        cutAngleRad = 0,
        cueDist     = blockerDist,
        potDist     = 0,
        _power      = power,
        isSafety    = true,
        forcedFoul  = true,
    }
end

-- Pilih pocket buat bola 8 yang BENERAN bisa dijangkau — bukan cuma yang
-- paling deket garis lurus ke bola 8. Dulu: kalau direct shot gagal nemu
-- jalan, langsung jatuh ke pocket ter-dekat tanpa cek reachability sama
-- sekali (gak ngecek line-of-sight, cushion-first, rail-kiss, double-rail).
-- Akibatnya bot manggil pocket yang gak ada shot valid ke situ, terus pas
-- nembak beneran (snap.calledPocket) logic-nya udah bener cek ke-4 metode
-- itu tapi nggak nemu apa-apa karena pocket-nya emang nggak reachable ->
-- jatuh ke safeShot8 (foul paksa) -> kalah. Sekarang: evaluasi SEMUA
-- metode (direct + cushion-first + rail-kiss + double-rail) ke SEMUA
-- pocket sekaligus -- persis sama kayak yang dipake pas eksekusi nembak
-- (lihat snap.calledPocket ~= nil di bawah) -- baru pilih skor tertinggi.
-- Jarak garis lurus cuma dipake last-resort kalau BENERAN nggak ada satu
-- pun shot yang physics-verified ke pocket manapun (harus tetep manggil
-- sesuatu, aturannya begitu).
local function bestPocketFor8(balls, group)
    local cue = balls[0]
    local ball8 = balls[8]
    if not cue or not ball8 or ball8.pocketed then return nil end

    local all8 = {}
    local direct   = bestShot(balls, group, 8)
    if direct   then for _, c in ipairs(direct)   do table.insert(all8, c) end end
    local cushion  = bestCushionFirstShot(balls, group, 8)
    if cushion  then for _, c in ipairs(cushion)  do table.insert(all8, c) end end
    local railkiss = bestRailKissShot(balls, group, 8)
    if railkiss then for _, c in ipairs(railkiss) do table.insert(all8, c) end end
    local dblrail  = bestDoubleRailShot(balls, group, 8)
    if dblrail  then for _, c in ipairs(dblrail)  do table.insert(all8, c) end end

    if #all8 > 0 then
        table.sort(all8, function(a, b) return a.score > b.score end)
        return all8[1]
    end

    warn("[c8bbot] bola 8: nggak ada shot physics-verified ke pocket manapun — call pocket ter-dekat sebagai last resort (kemungkinan bakal foul)")
    local best, bestDist = nil, math.huge
    for _, pocket in ipairs(pockets) do
        local dx, dy = ball8.x - pocket.x, ball8.y - pocket.y
        local d = dx * dx + dy * dy
        if d < bestDist then
            bestDist = d
            best = pocket.id
        end
    end
    if not best then return nil end
    return { pocketId = best }
end

-- Ball-in-hand (bukan break): dulu cuma nyisir grid kasar dan ambil posisi
-- LEGAL PERTAMA yang ketemu (asal gak nabrak bola lain) -- nggak mikirin
-- enak-nggaknya buat shot berikutnya sama sekali. Sekarang nyisir grid
-- lebih rapat dan nilai tiap posisi legal pake evaluateLeaveQuality (yang
-- sama persis dipake buat position-play abis shot) -- ambil posisi dengan
-- opsi pot terbaik, bukan yang pertama ketemu.
local PLACEMENT_GRID_STEP = 3  -- inci; makin kecil makin teliti tapi makin berat compute

local function findPlacement(balls, group, isBreak)
    if isBreak then
        for _, y in ipairs({ 0, 5, -5, 10, -10, 15, -15, 20, -20 }) do
            if CuePlacement.valid(balls, geometry, BREAK_LINE_X, y, true) then
                return BREAK_LINE_X, y
            end
        end
        return BREAK_LINE_X, 0
    else
        local hl = (geometry.halfLength or 44) - RADIUS - CLEAR - 1
        local hw = (geometry.halfWidth or 22) - RADIUS - CLEAR - 1

        local bestX, bestY, bestScore = nil, nil, -1
        local fallbackX, fallbackY = nil, nil  -- posisi legal pertama, jaga-jaga kalau semua skor 0

        local x = -hl
        while x <= hl do
            local y = -hw
            while y <= hw do
                if CuePlacement.valid(balls, geometry, x, y, false) then
                    if not fallbackX then fallbackX, fallbackY = x, y end
                    local q = evaluateLeaveQuality(balls, group, x, y, nil)
                    if q > bestScore then
                        bestScore, bestX, bestY = q, x, y
                    end
                end
                y = y + PLACEMENT_GRID_STEP
            end
            x = x + PLACEMENT_GRID_STEP
        end

        if bestX then
            return bestX, bestY
        elseif fallbackX then
            return fallbackX, fallbackY
        end
        return 0, 0
    end
end

local function angleDiff(a, b)
    return (b - a + math.pi) % (2 * math.pi) - math.pi
end

local function easeTo(tableId, snap, angle, duration)
    local startAngle = currentAngle[tableId]
    if not startAngle then startAngle = angle end
    local totalDelta = angleDiff(startAngle, angle)
    local steps = math.max(5, math.floor(duration / 0.04))
    local elapsed = 0

    for i = 1, steps do
        task.wait(duration / steps)
        elapsed += duration / steps
        local t = math.clamp(elapsed / duration, 0, 1)
        local eased = t < 0.5
            and 4 * t * t * t
            or 1 - ((-2 * t + 2) ^ 3) / 2
        local a = startAngle + totalDelta * eased
        currentAngle[tableId] = a

        setLocalCueAngle(a)

        local ok = sendAimUpdate(tableId, a, snap, i == steps)
        if not ok then return false end
    end

    currentAngle[tableId] = angle
    return true
end

local function humanAim(tableId, snap, targetAngle, difficulty)
    difficulty = difficulty or 0
    local startAngle = currentAngle[tableId]
    if not startAngle then
        startAngle = targetAngle + (math.random() - 0.5) * 0.6
        currentAngle[tableId] = startAngle
    end

    local hops = 1
    for _ = 1, hops do
        local wobble = (math.random() - 0.5) * math.rad(4 + 6 * difficulty)
        local waypoint = targetAngle + wobble
        local hopDuration = 0.18 + math.random() * 0.12
        if not easeTo(tableId, snap, waypoint, hopDuration) then return end
        task.wait(0.02 + math.random() * 0.04)
    end

    local finalDuration = (0.35 + math.random() * 0.45) * (1 + difficulty * 0.8)
    easeTo(tableId, snap, targetAngle, finalDuration)
end

local function updateSeat(state)
    local found = nil
    for seatTableId, seatList in pairs(state) do
        for _, seat in ipairs(seatList) do
            if seat.userId == LP.UserId and seat.connected then
                found = seatTableId
            end
        end
    end
    mySeat = found
end

Net.get("TableState").OnClientEvent:Connect(function(payload)
    if typeof(payload) ~= "table" or type(payload.id) ~= "number" then return end
    local prev = snapshots[payload.id]
    if not prev or payload.epoch >= prev.epoch then
        snapshots[payload.id] = payload
        local allSeats = {}
        for id, snap in pairs(snapshots) do
            allSeats[id] = snap.seats or {}
        end
        updateSeat(allSeats)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        if mySeat and Settings.Enabled then
            local snap = snapshots[mySeat]
            if snap and snap.shooter == LP.UserId then
                local phaseOk = snap.phase == "Aiming" or snap.phase == "Intro" or snap.phase == "Placement"
                local balls = parseBalls(snap.balls)
                local group = snap.groups and snap.groups[snap.activeTeam]

                local mustCall = snap.calledPocket == nil and ShotJudge.eligible(balls, group) and Settings.AutoCallPocket
                local callPhaseOk = phaseOk or snap.phase == "PocketChoice"

                if mustCall and callPhaseOk then
                    local callKey = tostring(snap.epoch) .. ":" .. tostring(snap.turnId)
                    if lastCalled[mySeat] ~= callKey then
                        local shot8 = bestPocketFor8(balls, group)
                        if shot8 and shot8.pocketId then
                            Net.get("MatchAction"):FireServer({
                                kind = "Pocket",
                                tableId = mySeat,
                                epoch = snap.epoch,
                                turnId = snap.turnId,
                                pocket = shot8.pocketId,
                            })
                            lastCalled[mySeat] = callKey
                            cached8Shot[mySeat] = {
                                turnId = snap.turnId,
                                pocketId = shot8.pocketId,
                                shot = shot8.angle and shot8 or nil,
                            }
                            warn("[c8bbot] called pocket " .. tostring(shot8.pocketId) .. " for the 8")
                        end
                    end
                elseif phaseOk then
                    local key = tostring(snap.epoch) .. ":" .. tostring(snap.turnId)
                    if lastFired[mySeat] ~= key then
                        cueInput = findCueInput()
                        if not cueInput then
                            warn("[c8bbot][debug] cueInput not found at turn start, will retry on next aim call")
                        end

                        task.wait(0.4 + math.random() * 1.1)

                        local cueX, cueY = nil, nil

                        if snap.ballInHand then
                            cueX, cueY = findPlacement(balls, group, snap.breakShot == true)
                            balls[0] = { id = 0, x = cueX, y = cueY, z = 0, pocketed = false }
                        end

                        local shot
                        if snap.breakShot then
                            local b = breakShotAim(balls)
                            if b then
                                shot = { angle = b.angle, targetId = -1, pocketId = -1, _power = b.power }
                            end
                        elseif snap.calledPocket ~= nil and balls[8] and not balls[8].pocketed then
                            local cached = cached8Shot[mySeat]
                            if cached and cached.turnId == snap.turnId
                                and cached.pocketId == snap.calledPocket and cached.shot then
                                shot = cached.shot
                            else
                                -- Evaluasi direct + trick shot BARENGAN, skor tertinggi yang menang
                                -- (sama kayak bola biasa) — bukan trick cuma fallback pas direct gagal.
                                local all8 = {}
                                local direct8 = bestShot(balls, group, 8, snap.calledPocket)
                                if direct8 then for _, c in ipairs(direct8) do table.insert(all8, c) end end
                                local cushion8 = bestCushionFirstShot(balls, group, 8, snap.calledPocket)
                                if cushion8 then for _, c in ipairs(cushion8) do table.insert(all8, c) end end
                                local railkiss8 = bestRailKissShot(balls, group, 8, snap.calledPocket)
                                if railkiss8 then for _, c in ipairs(railkiss8) do table.insert(all8, c) end end
                                local doublerail8 = bestDoubleRailShot(balls, group, 8, snap.calledPocket)
                                if doublerail8 then for _, c in ipairs(doublerail8) do table.insert(all8, c) end end

                                if #all8 > 0 then
                                    table.sort(all8, function(a, b) return a.score > b.score end)
                                    shot = all8[1]
                                    local shotLabel = "direct"
                                    if shot.isCushionFirst then shotLabel = ("cushion-first/rail:%s"):format(shot.railName or "?")
                                    elseif shot.isRailKiss then shotLabel = "rail-kiss"
                                    elseif shot.isDoubleRail then shotLabel = ("double-rail/%s"):format(shot.railName or "?")
                                    end
                                    warn(("[c8bbot] 8-ball shot chosen [%s] into called pocket %s | score=%.4f")
                                        :format(shotLabel, tostring(snap.calledPocket), shot.score))
                                end
                            end
                            if not shot and Settings.SafetyEnabled then
                                warn("[c8bbot] 8-ball: no direct/trick shot into called pocket " .. tostring(snap.calledPocket) .. " — safety fallback")
                                shot = safeShot8(balls)
                            end
                        else
                            local all = {}
                            local direct = bestShot(balls, group)
                            if direct then for _, c in ipairs(direct) do table.insert(all, c) end end
                            local combo = bestComboShot(balls, group)
                            if combo then for _, c in ipairs(combo) do table.insert(all, c) end end
                            local cushion = bestCushionFirstShot(balls, group)
                            if cushion then for _, c in ipairs(cushion) do table.insert(all, c) end end
                            local railkiss = bestRailKissShot(balls, group)
                            if railkiss then for _, c in ipairs(railkiss) do table.insert(all, c) end end
                            local doublerail = bestDoubleRailShot(balls, group)
                            if doublerail then for _, c in ipairs(doublerail) do table.insert(all, c) end end

                            if #all > 0 then
                                table.sort(all, function(a, b) return a.score > b.score end)
                                shot = all[1]
                                local shotLabel = "direct"
                                if shot.isCombo        then shotLabel = ("combo/%d->%d"):format(shot.targetId, shot.comboTargetId)
                                elseif shot.isCushionFirst then shotLabel = ("cushion-first/rail:%s"):format(shot.railName or "?")
                                elseif shot.isRailKiss then shotLabel = "rail-kiss"
                                elseif shot.isDoubleRail then shotLabel = ("double-rail/%s"):format(shot.railName or "?")
                                end
                                warn(("[c8bbot] shot chosen [%s] ball %s -> pocket %s | score=%.4f lineQ=%.3f")
                                    :format(shotLabel, tostring(shot.targetId), tostring(shot.pocketId),
                                        shot.score, shot.lineQuality or -1))
                            elseif Settings.SafetyEnabled then
                                warn("[c8bbot] no direct/combo/trick shot physics-verified — safety fallback")
                                shot = safeShot(balls, group)
                            else
                                warn("[c8bbot] no pot found, Safety Play off — staying idle this turn")
                            end
                        end

                        if shot then
                            local difficulty = math.clamp((shot.cutAngle or 0) / MAX_CUT_ANGLE, 0, 1)

                            setLocalCueEnabled(true)

                            if Settings.HumanAim then
                                humanAim(mySeat, snap, shot.angle, difficulty)
                            else
                                currentAngle[mySeat] = shot.angle
                                setLocalCueAngle(shot.angle)
                                sendAimUpdate(mySeat, shot.angle, snap, true)
                            end
                            task.wait(0.15 + math.random() * 0.25)

                            local fresh = snapshots[mySeat]
                            local stillValid = fresh
                                and fresh.epoch == snap.epoch
                                and fresh.turnId == snap.turnId
                                and fresh.shooter == LP.UserId

                            if not stillValid then
                                warn("[c8bbot] state berubah selama aim, shot dibatalkan")
                            else
                                setLocalCueAngle(shot.angle)
                                sendAimUpdate(mySeat, shot.angle, snap, true)
                                task.wait(0.05)

                                local power
                                if shot._power then
                                    power = shot._power
                                else
                                    power = shotPower(
                                        shot.potDist,
                                        shot.cueDist,
                                        shot.cutAngleRad or math.rad(shot.cutAngle or 0)
                                    )
                                end
                                -- Settings.MaxPower (GUI slider) hard-caps whatever power the
                                -- shot finder computed; only clamped here at the final fire
                                -- point so the internal physics search/verification upstream
                                -- is untouched.
                                power = math.clamp(power, MIN_POWER, Settings.MaxPower)
                                Net.get("ShotFired"):FireServer({
                                    epoch = snap.epoch,
                                    turnId = snap.turnId,
                                    cueX = cueX,
                                    cueY = cueY,
                                    tableId = mySeat,
                                    angle = shot.angle,
                                    power = power,
                                    spin = shot.spin or { x = 0, y = 0 },
                                    elevation = ELEVATION,
                                })
                                lastFired[mySeat] = key

                                local shotKind = snap.breakShot and "BREAK"
                                    or (shot.isCombo and ("COMBO/" .. tostring(shot.targetId) .. "->" .. tostring(shot.comboTargetId)))
                                    or "pot"
                                local spinUsed = shot.spin
                                warn(("[c8bbot] fired (%s%s) ball %s -> pocket %s | cutAngle=%.1f cueDist=%.1f potDist=%.1f power=%.3f angle=%.3f lineQ=%.3f spin=%s")
                                    :format(shotKind,
                                        snap.ballInHand and ", placed" or "",
                                        tostring(shot.targetId), tostring(shot.pocketId),
                                        shot.cutAngle or -1, shot.cueDist or -1, shot.potDist or -1,
                                        power, shot.angle,
                                        shot.lineQuality or -1,
                                        spinUsed and ("x=%.2f,y=%.2f"):format(spinUsed.x, spinUsed.y) or "none"))
                            end
                        end
                    end
                end
            end
        end
    end
end)

warn(("[c8bbot] auto-play v9.6-gui loaded | direct + combo + cushion-first + rail-kiss + double-rail trick shots | internal aim line validator semua shot | draw/follow spin position-play (direct shot) | safety hanya kalau semua gagal | GUI hooks: Enabled/HumanAim/SpinEnabled/AutoCallPocket/SafetyEnabled/MaxPower via _G.C8B_Settings | aim: %s")
    :format(Settings.HumanAim and "human" or "snap"))
