local cloneref = cloneref or function(...) return ... end
local GetService = setmetatable({}, {
    __index = function(self, key)
        return cloneref(game:GetService(key))
    end
})

getgenv().Services = {
    RunService = GetService.RunService,
    Players = GetService.Players,
    WorkSpace = GetService.Workspace,
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
    ESPBox = true
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
    outline.Thickness = 2
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.ZIndex = 1
    outline.Visible = false

    local box = Drawing.new("Square")
    box.Filled = false
    box.Thickness = 1
    box.ZIndex = 2
    box.Visible = false

    return {Box = box, Outline = outline}
end

local function hideBox(data)
    data.Box.Visible = false
    data.Outline.Visible = false
end

local function updateESP()
    if not getgenv().SilentAim.ESPBox then
        for _, data in pairs(EspBoxes) do
            hideBox(data)
        end
        return
    end

    local cam = Services.CurrentCamera or Services.WorkSpace.CurrentCamera
    if not cam then return end

    local seen = {}

    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and sameDuel(plr) then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and hrp then
                seen[plr] = true

                if not EspBoxes[plr] then
                    EspBoxes[plr] = createBox()
                end

                local hrpPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen and hrpPos.Z > 0 then
                    local head = char:FindFirstChild("Head")
                    local headPos = head and cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local legPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))

                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.65

                    local isTarget = currentTarget and currentTarget.Part and currentTarget.Part:IsDescendantOf(char)
                    local color = isTarget and COLOR_TARGET or COLOR_NORMAL
                    local data = EspBoxes[plr]

                    local boxPos = Vector2.new(hrpPos.X - width / 2, headPos.Y)
                    local boxSize = Vector2.new(width, height)

                    data.Outline.Position = boxPos
                    data.Outline.Size = boxSize
                    data.Outline.Visible = true

                    data.Box.Position = boxPos
                    data.Box.Size = boxSize
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
    if not getgenv().SilentAim.Enabled then return end

    local cam = Services.CurrentCamera or Services.WorkSpace.CurrentCamera
    if not cam then return end

    local best, bestDist = nil, getgenv().SilentAim.FOV
    local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    local hitName = getgenv().SilentAim.HitPart or "Head"

    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= Services.LocalPlayer and plr.Character and sameDuel(plr) then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(hitName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and part then
                local screen, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and screen.Z > 0 then
                    local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = { Part = part, Humanoid = hum }
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
    if not t or not t.Part or not t.Part.Parent then return oldData end
    if not t.Humanoid or not t.Humanoid.Parent or t.Humanoid.Health <= 0 then return oldData end

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

    local newData = typeof(oldData) == "table" and oldData or {}
    newData.humanoidShot = t.Humanoid
    newData.HitPosition = hitPos
    newData.Origin = origin

    return newData
end

Services.RunService.RenderStepped:Connect(function()
    updateOrigin()
    updateTarget()
    updateESP()
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and method == "FireServer" and typeof(self) == "Instance" and self.Name == "ShootGun" then
        if getgenv().SilentAim.Enabled and currentTarget then
            for i = 1, #args do
                if typeof(args[i]) == "table" then
                    args[i] = buildShotData(args[i])
                    break
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end))
