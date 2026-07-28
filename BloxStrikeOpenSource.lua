local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local cfg = {
    boxEnabled = true,
    clr = Color3.fromRGB(0, 255, 137),
    targetClr = Color3.fromRGB(255, 50, 50),
    thk = 1.5,
    trans = 0.8,
    syncRate = 3
}

local currentTarget = nil
local boxCache = {}

local function isEnemy(p)
    if p == lp then return false end
    local myAttr = lp:GetAttribute("Team")
    local pAttr = p:GetAttribute("Team")
    if myAttr ~= nil and pAttr ~= nil then
        return myAttr ~= pAttr
    end
    if lp.Team ~= nil and p.Team ~= nil then
        return lp.Team ~= p.Team
    end
    return true
end

local function getTarget()
    local maxDist = math.huge
    local selected = nil
    local myChar = lp.Character
    if not myChar or not myChar:FindFirstChild("Head") then return nil end

    for _, v in ipairs(Players:GetPlayers()) do
        if not isEnemy(v) then continue end
        local char = v.Character
        if not char or char:GetAttribute("Dead") == true then continue end
        
        local head = char:FindFirstChild("Head")
        if not head then continue end
        
        local pos, vis = cam:WorldToViewportPoint(head.Position)
        if not vis then continue end
        
        local mag = (Vector2.new(pos.X, pos.Y) - cam.ViewportSize / 2).Magnitude
        if mag < maxDist then
            maxDist = mag
            selected = head
        end
    end
    return selected
end

local function purgeBox(p)
    if boxCache[p] then
        for _, line in pairs(boxCache[p]) do
            pcall(function() line:Remove() end)
        end
        boxCache[p] = nil
    end
end

local function drawBox(p)
    if p == lp then return end
    purgeBox(p)

    local lines = {
        Top = Drawing.new("Line"),
        Bottom = Drawing.new("Line"),
        Left = Drawing.new("Line"),
        Right = Drawing.new("Line")
    }

    for _, line in pairs(lines) do
        line.Visible = false
        line.Color = cfg.clr
        line.Thickness = cfg.thk
        line.Transparency = cfg.trans
    end

    boxCache[p] = lines
end

for _, p in ipairs(Players:GetPlayers()) do drawBox(p) end
Players.PlayerAdded:Connect(drawBox)
Players.PlayerRemoving:Connect(purgeBox)

task.spawn(function()
    while true do
        task.wait(cfg.syncRate)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and not boxCache[p] then drawBox(p) end
        end
        for p, _ in pairs(boxCache) do
            if not Players:FindFirstChild(p.Name) then purgeBox(p) end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    currentTarget = getTarget()

    if not cfg.boxEnabled then
        for _, lines in pairs(boxCache) do
            for _, line in pairs(lines) do line.Visible = false end
        end
        return
    end

    for p, lines in pairs(boxCache) do
        local c = p.Character
        if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChild("Head") and isEnemy(p) and not c:GetAttribute("Dead") then
            local hrp = c.HumanoidRootPart
            local head = c.Head
            
            local topScreen, topVis = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
            local bottomScreen, botVis = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

            if topVis or botVis then
                local height = math.abs(topScreen.Y - bottomScreen.Y)
                local width = height / 1.5

                local x = topScreen.X - (width / 2)
                local y = topScreen.Y

                local isTarget = (currentTarget and head == currentTarget)
                local activeClr = isTarget and cfg.targetClr or cfg.clr

                lines.Top.From = Vector2.new(x, y)
                lines.Top.To = Vector2.new(x + width, y)

                lines.Bottom.From = Vector2.new(x, y + height)
                lines.Bottom.To = Vector2.new(x + width, y + height)

                lines.Left.From = Vector2.new(x, y)
                lines.Left.To = Vector2.new(x, y + height)

                lines.Right.From = Vector2.new(x + width, y)
                lines.Right.To = Vector2.new(x + width, y + height)

                for _, line in pairs(lines) do
                    line.Color = activeClr
                    line.Visible = true
                end
                continue
            end
        end
        
        for _, line in pairs(lines) do line.Visible = false end
    end
end)

local castMod
for _, v in ipairs(getgc(true)) do
    if type(v) == "table" and rawget(v, "cast") and rawget(v, "castThrough") and rawget(v, "isPartOfHumanoid") then
        castMod = v
        break
    end
end

if castMod then
    local rEnv = getfenv()
    local fEnv = setmetatable({}, {
        __index = function(_, k)
            if k == "debug" then
                return setmetatable({}, {
                    __index = function(_, dk)
                        if dk == "info" then
                            return function(a, b, ...)
                                if type(b) == "string" and b:match("f") then return nil end
                                return debug.info(a, b, ...)
                            end
                        end
                        return debug[dk]
                    end
                })
            elseif k == "getfenv" then
                return function(lvl)
                    local ok, env = pcall(getfenv, lvl)
                    if not ok or type(env) ~= "table" then return {} end
                    local c = {}
                    for x, y in pairs(env) do
                        if x ~= "hookfunction" and x ~= "getgenv" and x ~= "oth" and x ~= "hookfunc" and x ~= "replaceclosure" then
                            c[x] = y
                        end
                    end
                    return c
                end
            end
            return rEnv[k]
        end
    })

    pcall(setfenv, castMod.cast, fEnv)
    pcall(setfenv, castMod.castThrough, fEnv)

    local oCast
    oCast = hookfunction(castMod.cast, function(orig, dir, ...)
        if currentTarget and typeof(dir) == "Vector3" then
            local c = lp.Character
            if c and c:FindFirstChild("Head") then
                if (orig - c.Head.Position).Magnitude < 12 then
                    dir = (currentTarget.Position - orig)
                end
            end
        end
        return oCast(orig, dir, ...)
    end)
end
