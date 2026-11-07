-- =====================================================================
-- URBAN RELOAD — LOGIC MODULE
-- urban_reload_logic.lua
-- Expose ke _G.UrbanLogic setelah load
-- =====================================================================

if _G.UrbanLogic and _G.UrbanLogic.Unload then
    pcall(_G.UrbanLogic.Unload)
end

local Players                = game:GetService("Players")
local RunService             = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RS                     = game:GetService("ReplicatedStorage")
local lp                     = Players.LocalPlayer
local Camera                 = workspace.CurrentCamera

-- =====================================================================
-- CONFIG (exposed, bisa diubah dari GUI)
-- =====================================================================
local SAConfig = {
    Enabled      = true,
    AimParts     = { "Head", "UpperTorso", "LowerTorso" },
    TeamCheck    = true,
    FOVRadius    = 450,
    WallCheck    = true,
    VelSmoothing = 5,
}

local ESPConfig = {
    Enabled     = true,
    TeamCheck   = true,
    MaxDistance = 0,
    BorderColor = Color3.fromRGB(255, 140, 0),
    BgColor     = Color3.fromRGB(15, 15, 15),
    NameColor   = Color3.fromRGB(255, 255, 255),
    DistColor   = Color3.fromRGB(200, 200, 200),
    TextSize    = 13,
}

local AirdropConfig = {
    Enabled = false,
}

local GunConfigs = {
    ["M4"]       = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["M4A1"]     = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["AK"]       = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["M60"]      = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["MP5"]      = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["Uzi"]      = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["MK14"]     = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["G15"]      = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["M9"]       = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["Eagle"]    = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["SawedOff"] = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["SPAS12"]   = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["AWP"]      = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["DRAGON"]   = { BulletSpeed = math.huge, PredictStrength = 1.0 },
    ["RPG"]      = { BulletSpeed = math.huge, PredictStrength = 0.0 },
    ["Compact"]  = { BulletSpeed = math.huge, PredictStrength = 1.0 },
}
local DEFAULT_CFG = { BulletSpeed = math.huge, PredictStrength = 1.0 }

-- =====================================================================
-- INTERNALS
-- =====================================================================
local Connections  = {}
local velHistory   = {}
local saTargetCache = {}
local alive        = true

local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Connections, c)
    return c
end

-- =====================================================================
-- HELPERS
-- =====================================================================
local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isSameTeam(p)
    if not lp.Team then return false end
    return p.Team == lp.Team
end

local function getCenter()
    local vs = Camera.ViewportSize
    return Vector2.new(vs.X / 2, vs.Y / 2)
end

-- =====================================================================
-- SILENT AIM
-- =====================================================================
bind(Players.PlayerRemoving, function(p)
    velHistory[p.Name] = nil
    saTargetCache[p]   = nil
end)

local function getGunConfig()
    local char = lp.Character
    if not char then return DEFAULT_CFG end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return DEFAULT_CFG end
    local key = tool:GetAttribute("Weapon") or tool.Name
    return GunConfigs[key] or DEFAULT_CFG
end

local function getHitboxFolder(char)
    local ch = workspace:FindFirstChild("ClientHitboxes")
    if not ch then return nil end
    return ch:FindFirstChild(char.Name)
end

local ClientHitboxes = nil
pcall(function()
    ClientHitboxes = require(RS:WaitForChild("Weapons", 10):WaitForChild("ClientHitboxes", 10))
end)

local WallParams = RaycastParams.new()
WallParams.FilterType = Enum.RaycastFilterType.Exclude

local function getBestVisiblePos(char, rayOrigin)
    local folder = getHitboxFolder(char)
    local excl = {}
    if lp.Character then table.insert(excl, lp.Character) end
    local fx = workspace:FindFirstChild("FX")
    local ch = workspace:FindFirstChild("ClientHitboxes")
    if fx then table.insert(excl, fx) end

    for _, partName in ipairs(SAConfig.AimParts) do
        local wpos
        if folder then
            local hbox = folder:FindFirstChild(partName)
            if hbox and hbox.CFrame.Position.Y > -9000 then
                wpos = hbox.Position
            end
        end
        if not wpos then
            local part = char:FindFirstChild(partName)
            if part then wpos = part.Position end
        end
        if not wpos then continue end

        if SAConfig.WallCheck then
            local ex2 = table.clone(excl)
            table.insert(ex2, char)
            if ch then table.insert(ex2, ch) end
            WallParams.FilterDescendantsInstances = ex2
            local result = workspace:Raycast(rayOrigin, wpos - rayOrigin, WallParams)
            if result then continue end
        end
        return wpos, partName
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Position.Y > -9000 then
        if SAConfig.WallCheck then
            local ex2 = table.clone(excl)
            table.insert(ex2, char)
            if ch then table.insert(ex2, ch) end
            WallParams.FilterDescendantsInstances = ex2
            local result = workspace:Raycast(rayOrigin, hrp.Position - rayOrigin, WallParams)
            if not result then return hrp.Position, "HumanoidRootPart" end
        else
            return hrp.Position, "HumanoidRootPart"
        end
    end
    return nil, nil
end

local function getSmoothedVel(plrName, rawVel)
    if not velHistory[plrName] then velHistory[plrName] = {} end
    local hist = velHistory[plrName]
    table.insert(hist, rawVel)
    if #hist > SAConfig.VelSmoothing then table.remove(hist, 1) end
    local sum = Vector3.zero
    for _, v in hist do sum = sum + v end
    return sum / #hist
end

local function predictPos(plrName, char, targetPos, fromPos)
    local cfg = getGunConfig()
    if cfg.PredictStrength <= 0 then return targetPos end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return targetPos end
    local vel = getSmoothedVel(plrName, hrp.AssemblyLinearVelocity)
    if vel.Magnitude < 0.5 then return targetPos end
    local dist = (targetPos - fromPos).Magnitude
    local travelTime = dist / cfg.BulletSpeed
    return targetPos + vel * travelTime * cfg.PredictStrength
end

local function getTarget(rayOrigin)
    if ClientHitboxes and ClientHitboxes.Refresh then
        pcall(ClientHitboxes.Refresh)
    end
    local center = getCenter()
    local best, bestD = nil, math.huge

    for _, plr in Players:GetPlayers() do
        if plr == lp then continue end
        if SAConfig.TeamCheck and isSameTeam(plr) then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end

        local wpos = getBestVisiblePos(char, rayOrigin)
        saTargetCache[plr] = (wpos ~= nil)
        if not wpos then continue end

        wpos = predictPos(plr.Name, char, wpos, rayOrigin)
        local sp = Camera:WorldToViewportPoint(wpos)
        if sp.Z <= 0 then continue end
        local spos = Vector2.new(sp.X, sp.Y)
        local d2 = (spos - center).Magnitude
        if d2 > SAConfig.FOVRadius then continue end

        if d2 < bestD then
            bestD = d2
            best  = wpos
        end
    end
    return best
end

-- Hook namecall
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "ViewportPointToRay" and self == workspace.CurrentCamera then
        local args  = { ... }
        local x, y = args[1], args[2]
        local ray   = oldNamecall(self, ...)
        local center = getCenter()
        if SAConfig.Enabled and math.abs(x - center.X) < 3 and math.abs(y - center.Y) < 3 then
            local ok2, target = pcall(getTarget, ray.Origin)
            if ok2 and target then
                local dir = target - ray.Origin
                if dir.Magnitude > 0.1 then
                    return Ray.new(ray.Origin, dir.Unit)
                end
            end
        end
        return ray
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- =====================================================================
-- ESP
-- =====================================================================
local espFolder = Instance.new("Folder")
espFolder.Name   = "ESPFolder"
espFolder.Parent = Camera

local esps = {}

local function createESP(plr)
    if esps[plr] or plr == lp then return end

    local nameBB = Instance.new("BillboardGui")
    nameBB.AlwaysOnTop = true
    nameBB.Size        = UDim2.new(0, 120, 0, 20)
    nameBB.StudsOffset = Vector3.new(0, 3.2, 0)
    nameBB.Parent      = espFolder

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size                   = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3             = ESPConfig.NameColor
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize               = ESPConfig.TextSize
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.Text                   = plr.Name
    nameLabel.Parent                 = nameBB

    local cardBB = Instance.new("BillboardGui")
    cardBB.AlwaysOnTop = true
    cardBB.Size        = UDim2.new(0, 130, 0, 52)
    cardBB.StudsOffset = Vector3.new(0, 1, 0)
    cardBB.Parent      = espFolder

    local bg = Instance.new("Frame")
    bg.Size                   = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3       = ESPConfig.BgColor
    bg.BackgroundTransparency = 0.25
    bg.BorderSizePixel        = 0
    bg.Parent                 = cardBB
    local stroke = Instance.new("UIStroke")
    stroke.Color     = ESPConfig.BorderColor
    stroke.Thickness = 1.5
    stroke.Parent    = bg
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local hpBG = Instance.new("Frame")
    hpBG.Size             = UDim2.new(1, -8, 0, 5)
    hpBG.Position         = UDim2.new(0, 4, 0, 4)
    hpBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBG.BorderSizePixel  = 0
    hpBG.Parent           = bg
    Instance.new("UICorner", hpBG).CornerRadius = UDim.new(0, 2)

    local hpFG = Instance.new("Frame")
    hpFG.Size             = UDim2.new(1, 0, 1, 0)
    hpFG.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
    hpFG.BorderSizePixel  = 0
    hpFG.Parent           = hpBG
    Instance.new("UICorner", hpFG).CornerRadius = UDim.new(0, 2)

    local cardName = Instance.new("TextLabel")
    cardName.Size                   = UDim2.new(1, -8, 0, 18)
    cardName.Position               = UDim2.new(0, 4, 0, 11)
    cardName.BackgroundTransparency = 1
    cardName.TextColor3             = ESPConfig.NameColor
    cardName.TextStrokeTransparency = 0.4
    cardName.TextSize               = ESPConfig.TextSize
    cardName.Font                   = Enum.Font.GothamBold
    cardName.TextXAlignment         = Enum.TextXAlignment.Left
    cardName.Text                   = plr.Name
    cardName.Parent                 = bg

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size                   = UDim2.new(1, -8, 0, 16)
    infoLabel.Position               = UDim2.new(0, 4, 0, 31)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3             = ESPConfig.DistColor
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextSize               = ESPConfig.TextSize - 1
    infoLabel.Font                   = Enum.Font.Gotham
    infoLabel.TextXAlignment         = Enum.TextXAlignment.Left
    infoLabel.Text                   = ""
    infoLabel.Parent                 = bg

    esps[plr] = { nameBB = nameBB, nameLabel = nameLabel, cardBB = cardBB, hpFG = hpFG, cardName = cardName, infoLabel = infoLabel }
end

local function removeESP(plr)
    if esps[plr] then
        esps[plr].nameBB:Destroy()
        esps[plr].cardBB:Destroy()
        esps[plr] = nil
    end
end

local espVisRRList = {}
local espVisRRIdx  = 1

local espVisParams = RaycastParams.new()
espVisParams.FilterType = Enum.RaycastFilterType.Exclude

local function rebuildRRList()
    espVisRRList = {}
    for plr in pairs(esps) do
        table.insert(espVisRRList, plr)
    end
end

local function checkOnePlayerVis(myHRP)
    if #espVisRRList == 0 then rebuildRRList() return end
    if espVisRRIdx > #espVisRRList then
        rebuildRRList()
        espVisRRIdx = 1
    end
    local plr = espVisRRList[espVisRRIdx]
    espVisRRIdx = espVisRRIdx + 1
    if not plr or not esps[plr] then return end

    local char = plr.Character
    if not char or not isAlive(char) then
        saTargetCache[plr] = false
        return
    end
    if not myHRP then
        saTargetCache[plr] = false
        return
    end

    local excl = { lp.Character }
    local fx = workspace:FindFirstChild("FX")
    local ch = workspace:FindFirstChild("ClientHitboxes")
    if fx then table.insert(excl, fx) end
    if ch then table.insert(excl, ch) end
    table.insert(excl, char)

    local folder = getHitboxFolder(char)
    for _, partName in ipairs(SAConfig.AimParts) do
        local wpos
        if folder then
            local hbox = folder:FindFirstChild(partName)
            if hbox and hbox.CFrame.Position.Y > -9000 then
                wpos = hbox.Position
            end
        end
        if not wpos then
            local part = char:FindFirstChild(partName)
            if part then wpos = part.Position end
        end
        if not wpos then continue end

        espVisParams.FilterDescendantsInstances = excl
        local result = workspace:Raycast(myHRP.Position, wpos - myHRP.Position, espVisParams)
        if not result then
            saTargetCache[plr] = true
            return
        end
    end
    saTargetCache[plr] = false
end

bind(RunService.RenderStepped, function()
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")

    checkOnePlayerVis(myHRP)

    for plr, esp in pairs(esps) do
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")

        if not ESPConfig.Enabled or not char or not head or not isAlive(char)
            or (ESPConfig.TeamCheck and isSameTeam(plr)) then
            esp.nameBB.Enabled = false
            esp.cardBB.Enabled = false
            continue
        end

        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local dist = (myHRP and hrp) and math.floor((hrp.Position - myHRP.Position).Magnitude) or 0

        if ESPConfig.MaxDistance > 0 and dist > ESPConfig.MaxDistance then
            esp.nameBB.Enabled = false
            esp.cardBB.Enabled = false
            continue
        end

        local vis   = saTargetCache[plr] == true
        local hum   = char:FindFirstChildOfClass("Humanoid")
        local hp    = hum and hum.Health or 0
        local maxHp = hum and hum.MaxHealth or 100
        local hpPct = math.clamp(hp / maxHp, 0, 1)
        local hpColor = Color3.fromRGB(
            math.floor(255 * math.min(1, 2 * (1 - hpPct))),
            math.floor(255 * math.min(1, 2 * hpPct)), 0
        )

        if vis then
            esp.nameBB.Enabled        = false
            esp.cardBB.Enabled        = true
            esp.cardBB.Adornee        = head
            esp.hpFG.Size             = UDim2.new(hpPct, 0, 1, 0)
            esp.hpFG.BackgroundColor3 = hpColor
            esp.cardName.Text         = plr.Name
            esp.infoLabel.Text        = string.format("HP: %d%%  |  %dm", math.floor(hpPct * 100), dist)
        else
            esp.nameBB.Enabled = true
            esp.nameBB.Adornee = head
            esp.nameLabel.Text = plr.Name
            esp.cardBB.Enabled = false
        end
    end
end)

local function setupPlayer(plr)
    if plr == lp then return end
    createESP(plr)
    bind(plr.CharacterAdded, function()
        task.wait(0.5)
        if not esps[plr] then createESP(plr) end
        saTargetCache[plr] = false
        rebuildRRList()
    end)
end

for _, plr in Players:GetPlayers() do setupPlayer(plr) end
bind(Players.PlayerAdded, setupPlayer)
bind(Players.PlayerRemoving, function(p)
    removeESP(p)
    velHistory[p.Name] = nil
    saTargetCache[p]   = nil
end)

-- =====================================================================
-- AIRDROP
-- =====================================================================
local airdropActive = false
local airdropConn   = nil

local function getAirdropLandPos()
    local cf = RS:GetAttribute("AirdropFallLand")
    if typeof(cf) == "CFrame" then return cf.Position end
    return nil
end

local function findAirdropPrompt()
    local ad = workspace:FindFirstChild("Airdrop")
    if not ad then return nil end
    for _, v in ad:GetDescendants() do
        if v:IsA("ProximityPrompt") then return v end
    end
    return nil
end

local function teleportTo(pos)
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function tryCollectAirdrop()
    if not AirdropConfig.Enabled then return end
    local char = lp.Character
    if not char or not isAlive(char) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local savedCF = hrp.CFrame
    if RS:GetAttribute("AirdropLanded") ~= true then return end

    local ad = workspace:FindFirstChild("Airdrop")
    local pp = ad and ad:IsA("Model") and ad.PrimaryPart
    if pp then
        teleportTo(pp.Position)
    else
        local pos = getAirdropLandPos()
        if pos then teleportTo(pos) end
    end

    task.wait(0.3)

    local prompt = findAirdropPrompt()
    if prompt then
        local holdTime = tonumber(prompt:GetAttribute("HoldTime"))
            or tonumber(prompt:GetAttribute("GaugeHoldTime"))
            or prompt.HoldDuration or 3
        local ok2 = pcall(function() fireproximityprompt(prompt, holdTime) end)
        if not ok2 then
            pcall(function()
                ProximityPromptService:FirePromptButtonHoldBegan(prompt, lp)
                task.wait(holdTime)
                ProximityPromptService:FirePromptButtonHoldEnded(prompt, lp)
            end)
        end
        task.wait(0.5)
    end

    local c2 = lp.Character
    local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
    if h2 then h2.CFrame = savedCF end
end

local function startAirdropLoop()
    if airdropConn then return end
    airdropConn = bind(RunService.Heartbeat, function()
        if not AirdropConfig.Enabled then return end
        if RS:GetAttribute("AirdropLanded") == true then
            if not airdropActive then
                airdropActive = true
                task.spawn(tryCollectAirdrop)
            end
        else
            airdropActive = false
        end
    end)
end

-- =====================================================================
-- UNLOAD
-- =====================================================================
local function Unload()
    if _G.UrbanLogic and _G.UrbanLogic._unloaded then return end
    if _G.UrbanLogic then _G.UrbanLogic._unloaded = true end
    alive = false
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() espFolder:Destroy() end)
    pcall(function()
        local mt2 = getrawmetatable(game)
        setreadonly(mt2, false)
        mt2.__namecall = oldNamecall
        setreadonly(mt2, true)
    end)
    _G.UrbanLogic = nil
end

-- =====================================================================
-- EXPOSE
-- =====================================================================
_G.UrbanLogic = {
    SAConfig      = SAConfig,
    ESPConfig     = ESPConfig,
    AirdropConfig = AirdropConfig,
    Unload        = Unload,
    StartAirdrop  = startAirdropLoop,
    _unloaded     = false,
}
