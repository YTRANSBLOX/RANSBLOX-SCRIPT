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

local ENABLE_HUMAN_AIM_MOTION = true

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

local function calibrateShot(geom, cueX, cueY, targetBall, candidate)
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

local function segmentClear(ax, ay, bx, by, balls, ignore)
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
        local bestId, bestDist, bestAngle = nil, math.huge, 0
        for id, ball in pairs(balls) do
            if id == 0 or ball.pocketed then continue end
            if requireOwn and not ShotJudge.legalTarget(balls, group, id) then continue end
            local dx, dy = ball.x - cue.x, ball.y - cue.y
            local d = math.sqrt(dx*dx + dy*dy)
            if d >= bestDist then continue end
            local ignore = { [0] = true, [id] = true }
            if not segmentClear(cue.x, cue.y, ball.x, ball.y, balls, ignore) then continue end
            bestDist = d
            bestId   = id
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
                    score = score - clusterCost * CLUSTER_WEIGHT * 0.001,
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
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c) then
            table.insert(calibrated, c)
            if #calibrated >= 3 then break end
        end
    end

    if #calibrated == 0 then
        warn("[c8bbot] calibrate gagal semua — fallback ke geometric candidates")
        return candidates
    end

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
                    score = score,
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
        if calibrateCombo(geometry, c.cueX, c.cueY, c.ballRef, c.ballBRef, c) then
            table.insert(calibrated, c)
            if #calibrated >= 2 then break end
        end
    end

    if #calibrated == 0 then return nil end
    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end

local BANK_SCORE_PENALTY = 0.75
local RAIL_EDGE_MARGIN = 2.0

local BALL_RAIL_LEN = geometry.halfLength - RADIUS
local BALL_RAIL_WID = geometry.halfWidth  - RADIUS
local CORNER_JAW_MARGIN = (Config.Table.CornerMouthInches / 1.4142135623730951) + RADIUS * 1.5
local SIDE_MOUTH_HALF   = (Config.Table.SideMouthInches / 2) + RADIUS * 1.5

local RAILS = {
    { axis = "y", value =  BALL_RAIL_WID, name = "top" },
    { axis = "y", value = -BALL_RAIL_WID, name = "bottom" },
    { axis = "x", value =  BALL_RAIL_LEN, name = "foot" },
    { axis = "x", value = -BALL_RAIL_LEN, name = "head" },
}

local function mirrorAcrossRail(x, y, rail)
    if rail.axis == "y" then
        return x, 2 * rail.value - y
    else
        return 2 * rail.value - x, y
    end
end

local function validRailPoint(rail, railX, railY)
    if rail.axis == "y" then
        local ax = math.abs(railX)
        if ax > (BALL_RAIL_LEN - CORNER_JAW_MARGIN) then return false end
        if ax < SIDE_MOUTH_HALF then return false end
        return true
    else
        local ay = math.abs(railY)
        if ay > (BALL_RAIL_WID - CORNER_JAW_MARGIN) then return false end
        return true
    end
end

local function angDiff(a, b)
    return (b - a + math.pi) % (2 * math.pi) - math.pi
end

local function simulateObjectBounce(geom, startX, startY, dirx, diry, speed)
    local objBall = PhysicsBall.new(99, startX, startY)
    local state = PhysicsSim.newState(geom, { objBall })
    objBall.vx = dirx * speed
    objBall.vy = diry * speed

    local events = {}
    local bounced = false
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        for _, ev in ipairs(events) do
            if ev.type == "pocket" then
                return bounced, true, nil, { x = objBall.x, y = objBall.y }, nil
            end
            if ev.type == "railHit" and not bounced then
                bounced = true
            end
        end

        if bounced and (objBall.vx ~= 0 or objBall.vy ~= 0) then
            local spd = math.sqrt(objBall.vx * objBall.vx + objBall.vy * objBall.vy)
            return true, false, math.atan2(objBall.vy, objBall.vx), { x = objBall.x, y = objBall.y }, spd
        end

        if not PhysicsBall.isMoving(objBall) then break end
        table.clear(events)
    end
    return bounced, false, nil, nil, nil
end

local function solveBounceSpeed(geom, ball, dirx, diry, pdist, guessSpeed)
    local neededPost = math.sqrt(ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * pdist) * 1.4

    local function postSpeedAt(spd)
        local bounced, pocketed, _, _, postSpd = simulateObjectBounce(geom, ball.x, ball.y, dirx, diry, spd)
        if not bounced then return nil end
        if pocketed then return neededPost end
        return postSpd
    end

    local s0 = guessSpeed
    local p0 = postSpeedAt(s0)
    if not p0 then return nil end

    local s1 = guessSpeed * 1.3
    local p1 = postSpeedAt(s1)
    if not p1 then return nil end

    for _ = 1, 6 do
        local err1 = p1 - neededPost
        if math.abs(err1) < 1 then break end
        local err0 = p0 - neededPost
        if math.abs(err1 - err0) < 1e-6 then break end
        local s2 = s1 - err1 * (s1 - s0) / (err1 - err0)
        if s2 <= 0 then s2 = s1 * 0.5 end
        local p2 = postSpeedAt(s2)
        if not p2 then break end
        s0, p0 = s1, p1
        s1, p1 = s2, p2
    end

    return s1
end

local function solveBankRailPoint(geom, ball, pocket, rail, mirrorC, nominalSpeed)
    local function coordToPoint(c)
        if rail.axis == "y" then return c, rail.value
        else return rail.value, c end
    end

    local function evalC(c)
        local rx, ry = coordToPoint(c)
        if not validRailPoint(rail, rx, ry) then return nil end
        local dx, dy = rx - ball.x, ry - ball.y
        local d = math.sqrt(dx * dx + dy * dy)
        if d < 1e-6 then return nil end
        local dirx, diry = dx / d, dy / d

        local bounced, pocketed, postAngle, pos = simulateObjectBounce(geom, ball.x, ball.y, dirx, diry, nominalSpeed)
        if not bounced or not pos then return nil end
        if pocketed then
            return { err = 0, rx = rx, ry = ry, angle = postAngle, pos = pos, pocketed = true }
        end
        if not postAngle then return nil end
        local desired = math.atan2(pocket.my - pos.y, pocket.mx - pos.x)
        return { err = angDiff(postAngle, desired), rx = rx, ry = ry, angle = postAngle, pos = pos, pocketed = false }
    end

    local c0 = mirrorC
    local r0 = evalC(c0)
    if not r0 then
        c0 = mirrorC - 1.0
        r0 = evalC(c0)
        if not r0 then return nil end
    end

    local c1 = mirrorC + 1.0
    local r1 = evalC(c1)
    if not r1 then
        c1 = c0 - 1.0
        r1 = evalC(c1)
        if not r1 then return nil end
    end

    local best = r1
    for _ = 1, 5 do
        if r1.pocketed or math.abs(r1.err) < math.rad(0.5) then
            best = r1
            break
        end
        if math.abs(r1.err - r0.err) < 1e-6 then break end
        local c2 = c1 - r1.err * (c1 - c0) / (r1.err - r0.err)
        local r2 = evalC(c2)
        if not r2 then break end
        c0, r0 = c1, r1
        c1, r1 = c2, r2
        best = r1
    end

    if not best.pocketed and math.abs(best.err) >= math.rad(3) then return nil end
    return best.rx, best.ry, best.angle, best.pos
end

local function bestBankShot(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for id, ball in pairs(balls) do
        if id ~= 0 and not ball.pocketed and isEligibleTarget(balls, group, id, onlyId) then
            local clusterCost = clusterPenalty(balls, id, ball)

            for _, pocket in ipairs(aimPockets) do
                if onlyPocketId and pocket.id ~= onlyPocketId then continue end
                for _, rail in ipairs(RAILS) do
                    local mx, my = mirrorAcrossRail(pocket.mx, pocket.my, rail)

                    local tdx, tdy = mx - ball.x, my - ball.y
                    local tdist = math.sqrt(tdx * tdx + tdy * tdy)
                    if tdist < 1e-6 then continue end

                    local guessX, guessY
                    if rail.axis == "y" then
                        if math.abs(tdy) < 1e-6 then continue end
                        local t = (rail.value - ball.y) / tdy
                        if t <= 0.05 or t >= 0.95 then continue end
                        guessX = ball.x + t * tdx
                        guessY = rail.value
                    else
                        if math.abs(tdx) < 1e-6 then continue end
                        local t = (rail.value - ball.x) / tdx
                        if t <= 0.05 or t >= 0.95 then continue end
                        guessX = rail.value
                        guessY = ball.y + t * tdy
                    end

                    if not validRailPoint(rail, guessX, guessY) then continue end

                    local gdx, gdy = guessX - ball.x, guessY - ball.y
                    local gpx, gpy = pocket.mx - guessX, pocket.my - guessY
                    local nominalPotDist = math.sqrt(gdx * gdx + gdy * gdy) + math.sqrt(gpx * gpx + gpy * gpy)
                    local nominalSpd = math.sqrt(ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * nominalPotDist) * 1.4

                    local railAxisGuess = (rail.axis == "y") and guessX or guessY
                    local railX, railY, simAngle = solveBankRailPoint(geometry, ball, pocket, rail, railAxisGuess, nominalSpd)
                    if not railX then continue end

                    local function solveNeeded(rx, ry, nomSpd)
                        local rdx_, rdy_ = rx - ball.x, ry - ball.y
                        local rdist_ = math.sqrt(rdx_ * rdx_ + rdy_ * rdy_)
                        if rdist_ < 1e-6 then return nil end
                        local pdx_, pdy_ = pocket.mx - rx, pocket.my - ry
                        local pdist_ = math.sqrt(pdx_ * pdx_ + pdy_ * pdy_)
                        return solveBounceSpeed(geometry, ball, rdx_ / rdist_, rdy_ / rdist_, pdist_, nomSpd)
                    end

                    local neededIncoming = solveNeeded(railX, railY, nominalSpd)
                    if not neededIncoming then continue end

                    local railX2, railY2, simAngle2 = solveBankRailPoint(
                        geometry, ball, pocket, rail,
                        (rail.axis == "y") and railX or railY, neededIncoming)
                    if railX2 then
                        railX, railY, simAngle = railX2, railY2, simAngle2
                        local neededIncoming2 = solveNeeded(railX, railY, neededIncoming)
                        if neededIncoming2 then neededIncoming = neededIncoming2 end
                    end

                    local targetObjSpeed = neededIncoming

                    local rdx, rdy = railX - ball.x, railY - ball.y
                    local rdist = math.sqrt(rdx * rdx + rdy * rdy)
                    if rdist < 1e-6 then continue end
                    local rdirx, rdiry = rdx / rdist, rdy / rdist

                    local pdirx, pdiry = math.cos(simAngle), math.sin(simAngle)
                    local pdx, pdy = pocket.mx - railX, pocket.my - railY
                    local pdist = math.sqrt(pdx * pdx + pdy * pdy)

                    local dotVal = math.clamp(pdirx * pocket.ax + pdiry * pocket.ay, -1, 1)
                    local appAngle = math.acos(dotVal)
                    local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
                    if appAngle > math.rad(approachLimitDeg) then continue end

                    local ghostX = ball.x - rdirx * DIAM
                    local ghostY = ball.y - rdiry * DIAM
                    if math.abs(ghostX) > geometry.halfLength - RADIUS
                    or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                        continue
                    end

                    local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                    local cueDist = math.sqrt(cdx * cdx + cdy * cdy)
                    if cueDist < 0.25 then continue end
                    local ux, uy = cdx / cueDist, cdy / cueDist

                    local cosCut = math.clamp(ux * rdirx + uy * rdiry, -1, 1)
                    local cutAngle = math.deg(math.acos(cosCut))
                    if cutAngle >= MAX_CUT_ANGLE then continue end

                    local ignore = { [0] = true, [id] = true }
                    if not segmentClear(cue.x, cue.y, ghostX, ghostY, balls, ignore) then continue end
                    if not segmentClear(ball.x, ball.y, railX, railY, balls, ignore) then continue end
                    if not segmentClear(railX, railY, pocket.mx, pocket.my, balls, ignore) then continue end

                    local effectivePotDist = rdist + pdist

                    local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutAngle))
                        / (math.max(cueDist, DIAM) * math.max(effectivePotDist, DIAM))
                    score = score * BANK_SCORE_PENALTY - clusterCost * CLUSTER_WEIGHT * 0.001

                    table.insert(candidates, {
                        angle = math.atan2(cdy, cdx),
                        cueDist = cueDist, potDist = effectivePotDist,
                        targetId = id, pocketId = pocket.id,
                        cutAngle = cutAngle,
                        cutAngleRad = math.rad(cutAngle),
                        appAngle = appAngle,
                        isSide = pocket.side,
                        phi = math.atan2(rdiry, rdirx),
                        ballRef = ball,
                        clusterCost = clusterCost,
                        score = score,
                        cueX = cue.x, cueY = cue.y,
                        isBank = true,
                        bankRail = rail.name,
                        bankRailValue = rail.value,
                        targetObjSpeed = targetObjSpeed,
                        bounceX = railX, bounceY = railY,
                    })
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b) return a.score > b.score end)

    local MAX_CALIBRATE = 8
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c) then
            table.insert(calibrated, c)
            if #calibrated >= 2 then break end
        end
    end

    if #calibrated == 0 then return nil end

    table.sort(calibrated, function(a, b) return a.score > b.score end)
    return calibrated
end

local function simulateObjectMultiBounce(geom, startX, startY, dirx, diry, speed, maxBounces)
    local objBall = PhysicsBall.new(99, startX, startY)
    local state = PhysicsSim.newState(geom, { objBall })
    objBall.vx = dirx * speed
    objBall.vy = diry * speed

    local events = {}
    local bouncePos = {}
    for _ = 1, SIM_STEPS do
        PhysicsSim.step(state, FIXED_STEP, events)

        for _, ev in ipairs(events) do
            if ev.type == "pocket" then
                return bouncePos, true, nil, { x = objBall.x, y = objBall.y }, nil
            end
            if ev.type == "railHit" then
                table.insert(bouncePos, { x = objBall.x, y = objBall.y })
            end
        end

        if #bouncePos >= maxBounces and (objBall.vx ~= 0 or objBall.vy ~= 0) then
            local spd = math.sqrt(objBall.vx * objBall.vx + objBall.vy * objBall.vy)
            return bouncePos, false, math.atan2(objBall.vy, objBall.vx), { x = objBall.x, y = objBall.y }, spd
        end

        if not PhysicsBall.isMoving(objBall) then break end
        table.clear(events)
    end
    return bouncePos, false, nil, nil, nil
end

local function solveBounceSpeedN(geom, ball, dirx, diry, pdistFromLastBounce, guessSpeed, maxBounces)
    local neededPost = math.sqrt(ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * pdistFromLastBounce) * 1.4

    local function postSpeedAt(spd)
        local bouncePos, pocketed, _, _, postSpd = simulateObjectMultiBounce(geom, ball.x, ball.y, dirx, diry, spd, maxBounces)
        if pocketed then return neededPost end
        if #bouncePos < maxBounces then return nil end
        return postSpd
    end

    local s0 = guessSpeed
    local p0 = postSpeedAt(s0)
    if not p0 then return nil end
    local s1 = guessSpeed * 1.3
    local p1 = postSpeedAt(s1)
    if not p1 then return nil end

    for _ = 1, 6 do
        local err1 = p1 - neededPost
        if math.abs(err1) < 1 then break end
        local err0 = p0 - neededPost
        if math.abs(err1 - err0) < 1e-6 then break end
        local s2 = s1 - err1 * (s1 - s0) / (err1 - err0)
        if s2 <= 0 then s2 = s1 * 0.5 end
        local p2 = postSpeedAt(s2)
        if not p2 then break end
        s0, p0 = s1, p1
        s1, p1 = s2, p2
    end

    return s1
end

local function solveMultiBankRailPoint(geom, ball, pocket, rail1, mirrorC1, nominalSpeed)
    local function coordToPoint(c)
        if rail1.axis == "y" then return c, rail1.value
        else return rail1.value, c end
    end

    local function evalC(c)
        local rx, ry = coordToPoint(c)
        if not validRailPoint(rail1, rx, ry) then return nil end
        local dx, dy = rx - ball.x, ry - ball.y
        local d = math.sqrt(dx * dx + dy * dy)
        if d < 1e-6 then return nil end
        local dirx, diry = dx / d, dy / d

        local bouncePos, pocketed, postAngle, finalPos = simulateObjectMultiBounce(geom, ball.x, ball.y, dirx, diry, nominalSpeed, 2)
        if pocketed then
            if #bouncePos < 2 then return nil end
            return { err = 0, bounce1 = bouncePos[1], bounce2 = bouncePos[2], pos = finalPos, pocketed = true }
        end
        if #bouncePos < 2 or not postAngle then return nil end
        local b2 = bouncePos[2]
        local desired = math.atan2(pocket.my - b2.y, pocket.mx - b2.x)
        return { err = angDiff(postAngle, desired), bounce1 = bouncePos[1], bounce2 = b2, pos = finalPos, pocketed = false }
    end

    local c0 = mirrorC1
    local r0 = evalC(c0)
    if not r0 then
        c0 = mirrorC1 - 1.0
        r0 = evalC(c0)
        if not r0 then return nil end
    end
    local c1 = mirrorC1 + 1.0
    local r1 = evalC(c1)
    if not r1 then
        c1 = c0 - 1.0
        r1 = evalC(c1)
        if not r1 then return nil end
    end

    local best = r1
    for _ = 1, 6 do
        if r1.pocketed or math.abs(r1.err) < math.rad(0.5) then
            best = r1
            break
        end
        if math.abs(r1.err - r0.err) < 1e-6 then break end
        local c2 = c1 - r1.err * (c1 - c0) / (r1.err - r0.err)
        local r2 = evalC(c2)
        if not r2 then break end
        c0, r0 = c1, r1
        c1, r1 = c2, r2
        best = r1
    end

    if not best.pocketed and math.abs(best.err) >= math.rad(3) then return nil end
    return best.bounce1, best.bounce2, best.pos
end

local function bestBankShot2(balls, group, onlyId, onlyPocketId)
    local cue = balls[0]
    if not cue or cue.pocketed then return nil end

    local candidates = {}

    for id, ball in pairs(balls) do
        if id ~= 0 and not ball.pocketed and isEligibleTarget(balls, group, id, onlyId) then
            local clusterCost = clusterPenalty(balls, id, ball)

            for _, pocket in ipairs(aimPockets) do
                if onlyPocketId and pocket.id ~= onlyPocketId then continue end
                for _, rail1 in ipairs(RAILS) do
                    for _, rail2 in ipairs(RAILS) do
                        if rail1 == rail2 then continue end

                        local m2x, m2y = mirrorAcrossRail(pocket.mx, pocket.my, rail2)
                        local m1x, m1y = mirrorAcrossRail(m2x, m2y, rail1)

                        local tdx, tdy = m1x - ball.x, m1y - ball.y
                        local tdist = math.sqrt(tdx * tdx + tdy * tdy)
                        if tdist < 1e-6 then continue end

                        local guessX, guessY
                        if rail1.axis == "y" then
                            if math.abs(tdy) < 1e-6 then continue end
                            local t = (rail1.value - ball.y) / tdy
                            if t <= 0.05 or t >= 0.95 then continue end
                            guessX = ball.x + t * tdx
                            guessY = rail1.value
                        else
                            if math.abs(tdx) < 1e-6 then continue end
                            local t = (rail1.value - ball.x) / tdx
                            if t <= 0.05 or t >= 0.95 then continue end
                            guessX = rail1.value
                            guessY = ball.y + t * tdy
                        end
                        if not validRailPoint(rail1, guessX, guessY) then continue end

                        local gdx, gdy = guessX - ball.x, guessY - ball.y
                        local nominalDist0 = math.sqrt(gdx * gdx + gdy * gdy)
                        local nominalPotDist = nominalDist0 * 2.2
                        local nominalSpd = math.sqrt(ARRIVE_SPEED ^ 2 + 2 * ROLLING_DECEL * nominalPotDist) * 1.4

                        local railAxisGuess = (rail1.axis == "y") and guessX or guessY
                        local bounce1, bounce2 = solveMultiBankRailPoint(geometry, ball, pocket, rail1, railAxisGuess, nominalSpd)
                        if not bounce1 then continue end

                        local rdx, rdy = bounce1.x - ball.x, bounce1.y - ball.y
                        local rdist = math.sqrt(rdx * rdx + rdy * rdy)
                        if rdist < 1e-6 then continue end
                        local rdirx, rdiry = rdx / rdist, rdy / rdist

                        local b2pdist0 = math.sqrt((pocket.mx - bounce2.x)^2 + (pocket.my - bounce2.y)^2)
                        local neededIncoming = solveBounceSpeedN(geometry, ball, rdirx, rdiry, b2pdist0, nominalSpd, 2)
                        if not neededIncoming then continue end

                        local bounce1b, bounce2b = solveMultiBankRailPoint(geometry, ball, pocket, rail1, railAxisGuess, neededIncoming)
                        if bounce1b then
                            bounce1, bounce2 = bounce1b, bounce2b
                            rdx, rdy = bounce1.x - ball.x, bounce1.y - ball.y
                            rdist = math.sqrt(rdx * rdx + rdy * rdy)
                            if rdist < 1e-6 then continue end
                            rdirx, rdiry = rdx / rdist, rdy / rdist
                            local b2pdist1 = math.sqrt((pocket.mx - bounce2.x)^2 + (pocket.my - bounce2.y)^2)
                            local neededIncoming2 = solveBounceSpeedN(geometry, ball, rdirx, rdiry, b2pdist1, neededIncoming, 2)
                            if neededIncoming2 then neededIncoming = neededIncoming2 end
                        end

                        local targetObjSpeed = neededIncoming

                        local finalDx, finalDy = pocket.mx - bounce2.x, pocket.my - bounce2.y
                        local finalDist = math.sqrt(finalDx * finalDx + finalDy * finalDy)
                        if finalDist < 1e-6 then continue end
                        local fdirx, fdiry = finalDx / finalDist, finalDy / finalDist

                        local dotVal = math.clamp(fdirx * pocket.ax + fdiry * pocket.ay, -1, 1)
                        local appAngle = math.acos(dotVal)
                        local approachLimitDeg = pocket.side and SIDE_APPROACH_DEG or CORNER_APPROACH_DEG
                        if appAngle > math.rad(approachLimitDeg) then continue end

                        local ghostX = ball.x - rdirx * DIAM
                        local ghostY = ball.y - rdiry * DIAM
                        if math.abs(ghostX) > geometry.halfLength - RADIUS
                        or math.abs(ghostY) > geometry.halfWidth  - RADIUS then
                            continue
                        end

                        local cdx, cdy = ghostX - cue.x, ghostY - cue.y
                        local cueDist = math.sqrt(cdx * cdx + cdy * cdy)
                        if cueDist < 0.25 then continue end
                        local ux, uy = cdx / cueDist, cdy / cueDist

                        local cosCut = math.clamp(ux * rdirx + uy * rdiry, -1, 1)
                        local cutAngle = math.deg(math.acos(cosCut))
                        if cutAngle >= MAX_CUT_ANGLE then continue end

                        local ignore = { [0] = true, [id] = true }
                        if not segmentClear(cue.x, cue.y, ghostX, ghostY, balls, ignore) then continue end
                        if not segmentClear(ball.x, ball.y, bounce1.x, bounce1.y, balls, ignore) then continue end
                        if not segmentClear(bounce1.x, bounce1.y, bounce2.x, bounce2.y, balls, ignore) then continue end
                        if not segmentClear(bounce2.x, bounce2.y, pocket.mx, pocket.my, balls, ignore) then continue end

                        local b1b2dist = math.sqrt((bounce2.x-bounce1.x)^2 + (bounce2.y-bounce1.y)^2)
                        local effectivePotDist = rdist + b1b2dist + finalDist

                        local score = pocket.window * math.cos(appAngle) * DIAM * math.cos(math.rad(cutAngle))
                            / (math.max(cueDist, DIAM) * math.max(effectivePotDist, DIAM))
                        score = score * (BANK_SCORE_PENALTY * 0.6) - clusterCost * CLUSTER_WEIGHT * 0.001

                        table.insert(candidates, {
                            angle = math.atan2(cdy, cdx),
                            cueDist = cueDist, potDist = effectivePotDist,
                            targetId = id, pocketId = pocket.id,
                            cutAngle = cutAngle,
                            cutAngleRad = math.rad(cutAngle),
                            appAngle = appAngle,
                            isSide = pocket.side,
                            phi = math.atan2(rdiry, rdirx),
                            ballRef = ball,
                            clusterCost = clusterCost,
                            score = score,
                            cueX = cue.x, cueY = cue.y,
                            isBank = true,
                            bankRail = rail1.name .. "+" .. rail2.name,
                            bankRailValue = rail1.value,
                            targetObjSpeed = targetObjSpeed,
                            bounceX = bounce1.x, bounceY = bounce1.y,
                            bounceX2 = bounce2.x, bounceY2 = bounce2.y,
                        })
                    end
                end
            end
        end
    end

    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b) return a.score > b.score end)

    local MAX_CALIBRATE = 5
    local calibrated = {}
    for i = 1, math.min(MAX_CALIBRATE, #candidates) do
        local c = candidates[i]
        if calibrateShot(geometry, c.cueX, c.cueY, c.ballRef, c) then
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

local function bestPocketFor8(balls, group)
    local cue = balls[0]
    local ball8 = balls[8]
    if not cue or not ball8 or ball8.pocketed then return nil end

    local all = {}
    local direct = bestShot(balls, group, 8)
    if direct then for _, c in ipairs(direct) do table.insert(all, c) end end
    local bank1 = bestBankShot(balls, group, 8)
    if bank1 then for _, c in ipairs(bank1) do table.insert(all, c) end end
    local bank2 = bestBankShot2(balls, group, 8)
    if bank2 then for _, c in ipairs(bank2) do table.insert(all, c) end end

    if #all > 0 then
        table.sort(all, function(a, b) return a.score > b.score end)
        return all[1]
    end

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

local function findPlacement(balls, isBreak)
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
        for _, x in ipairs({ 0, -10, 10, -20, 20, -hl * 0.7, hl * 0.7 }) do
            for _, y in ipairs({ 0, 5, -5, 10, -10 }) do
                if math.abs(x) <= hl and math.abs(y) <= hw and CuePlacement.valid(balls, geometry, x, y, false) then
                    return x, y
                end
            end
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
        if mySeat then
            local snap = snapshots[mySeat]
            if snap and snap.shooter == LP.UserId then
                local phaseOk = snap.phase == "Aiming" or snap.phase == "Intro" or snap.phase == "Placement"
                local balls = parseBalls(snap.balls)
                local group = snap.groups and snap.groups[snap.activeTeam]

                local mustCall = snap.calledPocket == nil and ShotJudge.eligible(balls, group)
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
                            cueX, cueY = findPlacement(balls, snap.breakShot == true)
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
                                local all8 = {}
                                local direct8 = bestShot(balls, group, 8, snap.calledPocket)
                                if direct8 then for _, c in ipairs(direct8) do table.insert(all8, c) end end
                                local bank8a = bestBankShot(balls, group, 8, snap.calledPocket)
                                if bank8a then for _, c in ipairs(bank8a) do table.insert(all8, c) end end
                                local bank8b = bestBankShot2(balls, group, 8, snap.calledPocket)
                                if bank8b then for _, c in ipairs(bank8b) do table.insert(all8, c) end end
                                if #all8 > 0 then
                                    table.sort(all8, function(a, b) return a.score > b.score end)
                                    shot = all8[1]
                                end
                            end
                            if not shot then
                                warn("[c8bbot] 8-ball: no bank shot into called pocket " .. tostring(snap.calledPocket) .. " — playing safety on the 8 (aim rail contact)")
                                shot = safeShot8(balls)
                            end
                        else
                            local all = {}
                            local direct = bestShot(balls, group)
                            if direct then for _, c in ipairs(direct) do table.insert(all, c) end end
                            local bank1 = bestBankShot(balls, group)
                            if bank1 then for _, c in ipairs(bank1) do table.insert(all, c) end end
                            local bank2 = bestBankShot2(balls, group)
                            if bank2 then for _, c in ipairs(bank2) do table.insert(all, c) end end
                            local combo = bestComboShot(balls, group)
                            if combo then for _, c in ipairs(combo) do table.insert(all, c) end end

                            if #all > 0 then
                                table.sort(all, function(a, b) return a.score > b.score end)
                                shot = all[1]
                                if shot.isCombo then
                                    warn(("[c8bbot] trick shot: combo (ball %d -> ball %d) chosen, score=%.4f"):format(shot.targetId, shot.comboTargetId, shot.score))
                                elseif shot.isBank then
                                    warn(("[c8bbot] trick shot: bank (%s rail) chosen, score=%.4f"):format(shot.bankRail or "?", shot.score))
                                else
                                    warn(("[c8bbot] direct pot chosen, score=%.4f"):format(shot.score))
                                end
                            else
                                warn("[c8bbot] no direct/bank/combo shot available (gak ada yang physics-verified) — safety fallback")
                                shot = safeShot(balls, group)
                            end
                        end

                        if shot then
                            local difficulty = math.clamp((shot.cutAngle or 0) / MAX_CUT_ANGLE, 0, 1)

                            setLocalCueEnabled(true)

                            if ENABLE_HUMAN_AIM_MOTION then
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
                                Net.get("ShotFired"):FireServer({
                                    epoch = snap.epoch,
                                    turnId = snap.turnId,
                                    cueX = cueX,
                                    cueY = cueY,
                                    tableId = mySeat,
                                    angle = shot.angle,
                                    power = power,
                                    spin = { x = 0, y = 0 },
                                    elevation = ELEVATION,
                                })
                                lastFired[mySeat] = key

                                local shotKind = snap.breakShot and "BREAK"
                                    or (shot.isCombo and ("COMBO/" .. tostring(shot.targetId) .. "->" .. tostring(shot.comboTargetId)))
                                    or (shot.isBank and ("BANK/" .. tostring(shot.bankRail)) or "pot")
                                warn(("[c8bbot] fired (%s%s) ball %s -> pocket %s | cutAngle=%.1f cueDist=%.1f potDist=%.1f power=%.3f angle=%.3f")
                                    :format(shotKind,
                                        snap.ballInHand and ", placed" or "",
                                        tostring(shot.targetId), tostring(shot.pocketId),
                                        shot.cutAngle or -1, shot.cueDist or -1, shot.potDist or -1,
                                        power, shot.angle))
                            end
                        end
                    end
                end
            end
        end
    end
end)

warn(("[c8bbot] auto-play v9.2 loaded | direct pot + bank(1-rail/2-rail) + combo/kiss, dipilih by highest confidence score | bank shot akurasi masih ada bug belum solved | aim: %s")
    :format(ENABLE_HUMAN_AIM_MOTION and "human" or "snap"))
