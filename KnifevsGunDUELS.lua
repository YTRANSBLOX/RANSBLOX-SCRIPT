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
    MagicDistance = 1
}

local currentTarget = nil
local cachedOrigin = Vector3.zero

local function sameDuel(plr)
    local myDuel = Services.LocalPlayer:GetAttribute("CurrentDuel")
    local theirDuel = plr:GetAttribute("CurrentDuel")
    if myDuel == nil or theirDuel == nil then
        return false
    end
    return myDuel == theirDuel
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

    -- Memastikan struktur tabel sesuai kebutuhan tanpa merusak tipe data bawaan
    local newData = typeof(oldData) == "table" and oldData or {}
    newData.humanoidShot = t.Humanoid
    newData.HitPosition = hitPos
    newData.Origin = origin

    return newData
end

Services.RunService.RenderStepped:Connect(function()
    updateOrigin()
    updateTarget()
end)

-- Metamethod Hooking yang Aman Tanpa getgc
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
