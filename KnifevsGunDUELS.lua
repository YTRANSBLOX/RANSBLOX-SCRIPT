local cloneref = cloneref or function(...) return ... end
local GetService = setmetatable({}, {
    __index = function(self, key)
        return cloneref(game:GetService(key))
    end
})

getgenv().Services = {
    RunService = GetService.RunService,
    Players = GetService.Players,
    UserInputService = GetService.UserInputService,
    CoreGui = GetService.CoreGui,
    TweenService = GetService.TweenService,
    ReplicatedStorage = GetService.ReplicatedStorage,
    HttpService = GetService.HttpService,
    Lighting = GetService.Lighting,
    WorkSpace = GetService.Workspace,
    Debris = GetService.Debris,
}

Services.CurrentCamera = Services.WorkSpace.CurrentCamera
Services.LocalPlayer = Services.Players.LocalPlayer

getgenv().SilentAim = {
    Enabled = true,
    TeamCheck = false,
    FOV = 300,
    HitPart = "Head",
    MagicBullet = true,
    MagicDistance = 1,
    ESP = true
}

local currentTarget = nil
local cachedOrigin = Vector3.zero
local EspBoxes = {}

local COLOR_NORMAL = Color3.fromRGB(255, 255, 255)
local COLOR_TARGET = Color3.fromRGB(255, 170, 220)

local function sameDuel(plr)
    local myDuel = Services.LocalPlayer:GetAttribute("CurrentDuel")
    local theirDuel = plr:GetAttribute("CurrentDuel")
    if myDuel == nil or theirDuel == nil then
        return false
    end
    return myDuel == theirDuel
end

local function createBox()
    local outline = Drawing.new("Square")
    outline.Filled = false
    outline.Thickness = 1
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.ZIndex = 1
    outline.Visible = false

    local box = Drawing.new("Square")
    box.Filled = false
    box.Thickness = 0.8
    box.ZIndex = 2
    box.Visible = false

    return {Box = box, Outline = outline}
end

local function hideBox(data)
    data.Box.Visible = false
    data.Outline.Visible = false
end

local function getBoxData(character)
    local cam = Services.CurrentCamera or Services.WorkSpace.CurrentCamera
    if not cam then return nil end

    local parts = {}
    for _, name in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot", "LeftUpperArm", "RightUpperArm"}) do
        local p = character:FindFirstChild(name)
        if p then
            table.insert(parts, p)
        end
    end

    if #parts == 0 then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if hrp then table.insert(parts, hrp) end
        if head then table.insert(parts, head) end
    end

    if #parts == 0 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyVisible = false

    for _, part in ipairs(parts) do
        local pos, onScreen = cam:WorldToViewportPoint(part.Position)
        if onScreen and pos.Z > 0 then
            anyVisible = true
            local size = part.Size
            local cf = part.CFrame
            local corners = {
                cf * Vector3.new( size.X/2,  size.Y/2,  size.Z/2),
                cf * Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
                cf * Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
                cf * Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
                cf * Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
                cf * Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
                cf * Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
                cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
            }
            for _, corner in ipairs(corners) do
                local screen = cam:WorldToViewportPoint(corner)
                if screen.Z > 0 then
                    minX = math.min(minX, screen.X)
                    minY = math.min(minY, screen.Y)
                    maxX = math.max(maxX, screen.X)
                    maxY = math.max(maxY, screen.Y)
                end
            end
        end
    end

    if not anyVisible or minX == math.huge then return nil end

    local height = maxY - minY
    local extra = height * 0.18

    minY = minY - extra
    maxY = maxY + extra

    local width = maxX - minX
    local pos = Vector2.new(minX, minY)
    local size = Vector2.new(width, maxY - minY)

    if size.X < 4 or size.Y < 4 then return nil end

    return pos, size
end

local function updateESP()
    if not getgenv().SilentAim.ESP then
        for _, data in pairs(EspBoxes) do
            hideBox(data)
        end
        return
    end

    local seen = {}

    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and sameDuel(plr) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                seen[plr] = true

                if not EspBoxes[plr] then
                    EspBoxes[plr] = createBox()
                end

                local pos, size = getBoxData(plr.Character)
                if pos and size then
                    local isTarget = currentTarget and currentTarget.Part and currentTarget.Part:IsDescendantOf(plr.Character)
                    local color = isTarget and COLOR_TARGET or COLOR_NORMAL

                    local data = EspBoxes[plr]

                    data.Outline.Position = Vector2.new(pos.X - 1, pos.Y - 1)
                    data.Outline.Size = Vector2.new(size.X + 2, size.Y + 2)
                    data.Outline.Visible = true

                    data.Box.Position = pos
                    data.Box.Size = size
                    data.Box.Color = color
                    data.Box.Visible = true
                else
                    hideBox(EspBoxes[plr])
                end
            end
        end
    end

    for plr, data in pairs(EspBoxes) do
        if not seen[plr] then
            hideBox(data)
            data.Box:Remove()
            data.Outline:Remove()
            EspBoxes[plr] = nil
        end
    end
end

local function updateTarget()
    currentTarget = nil
    if not getgenv().SilentAim.Enabled then
        return
    end
    local cam = Services.CurrentCamera or Services.WorkSpace.CurrentCamera
    if not cam then
        return
    end

    local best, bestDist = nil, getgenv().SilentAim.FOV
    local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    local hitName = getgenv().SilentAim.HitPart or "Head"
    local wtvp = cam.WorldToViewportPoint

    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and sameDuel(plr) then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(hitName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and part then
                local screen, onScreen = wtvp(cam, part.Position)
                if onScreen and screen.Z > 0 then
                    local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = {
                            Part = part,
                            Humanoid = hum
                        }
                    end
                end
            end
        end
    end

    currentTarget = best
end

local function updateOrigin()
    local char = Services.LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                cachedOrigin = handle.Position
                return
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            cachedOrigin = hrp.Position
            return
        end
    end
    local cam = Services.CurrentCamera or Services.WorkSpace.CurrentCamera
    if cam then
        cachedOrigin = cam.CFrame.Position
    end
end

local function buildShotData(oldData)
    local t = currentTarget
    if not t or not t.Part or not t.Part.Parent then
        return oldData
    end
    if not t.Humanoid or not t.Humanoid.Parent or t.Humanoid.Health <= 0 then
        return oldData
    end

    local hitPos = t.Part.Position
    local from = cachedOrigin
    if typeof(oldData) == "table" and typeof(oldData.Origin) == "Vector3" then
        from = oldData.Origin
    end

    local origin = from
    if getgenv().SilentAim.MagicBullet then
        local dist = getgenv().SilentAim.MagicDistance or 1
        local dir = (hitPos - from)
        if dir.Magnitude > 0.05 then
            origin = hitPos - dir.Unit * dist
        else
            origin = hitPos + Vector3.new(0, 0, dist)
        end
    end

    return {
        humanoidShot = t.Humanoid,
        HitPosition = hitPos,
        Origin = origin
    }
end

Services.RunService.RenderStepped:Connect(function()
    updateOrigin()
    updateTarget()
    updateESP()
end)

for _, fn in ipairs(getgc(false)) do
    if typeof(fn) == "function" and islclosure(fn) then
        local ok, consts = pcall(debug.getconstants, fn)
        if ok and consts then
            local hit, origin, hum = false, false, false
            for i = 1, #consts do
                local c = consts[i]
                if c == "HitPosition" then
                    hit = true
                elseif c == "Origin" then
                    origin = true
                elseif c == "humanoidShot" then
                    hum = true
                end
            end
            if hit and origin and hum then
                local old
                old = hookfunction(fn, newcclosure(function(...)
                    local result = old(...)
                    if getgenv().SilentAim.Enabled and currentTarget then
                        return buildShotData(result)
                    end
                    return result
                end))
            end
        end
    end
end

for _, fn in ipairs(getgc(false)) do
    if typeof(fn) == "function" and islclosure(fn) then
        local ok, consts = pcall(debug.getconstants, fn)
        if ok and consts then
            local hasShootGun = false
            for i = 1, #consts do
                if consts[i] == "ShootGun" then
                    hasShootGun = true
                    break
                end
            end
            if hasShootGun then
                local old
                old = hookfunction(fn, newcclosure(function(self, aimPos, ...)
                    if getgenv().SilentAim.Enabled and currentTarget and currentTarget.Part and currentTarget.Part.Parent then
                        aimPos = currentTarget.Part.Position
                    end
                    return old(self, aimPos, ...)
                end))
            end
        end
    end
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and typeof(self) == "Instance" and self.Name == "ShootGun" then
        if getgenv().SilentAim.Enabled and currentTarget then
            local n = #args
            if n >= 3 and typeof(args[3]) == "table" then
                args[3] = buildShotData(args[3])
                return oldNamecall(self, unpack(args))
            elseif n >= 2 and typeof(args[2]) == "table" then
                args[2] = buildShotData(args[2])
                return oldNamecall(self, unpack(args))
            end
        end
    end

    return oldNamecall(self, ...)
end))
