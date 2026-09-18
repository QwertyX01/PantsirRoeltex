-- ============================================
--   Rooeltex — Obsidian v20
--   Фиолетовая тема + все функции
-- ============================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local HAS_DRAWING = (Drawing ~= nil)

-- ============================================
--   ЗАГРУЗКА OBSIDIAN
-- ============================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- ============================================
--   ОКНО
-- ============================================

local Window = Library:CreateWindow({
    Title = "Rooeltex",
    Footer = "premium edition • v20.0",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = true,
    AnimationSpeed = 1.3,
})

local Tabs = {
    Visuals = Window:AddTab("Visuals", "eye"),
    Names = Window:AddTab("Names", "tag"),
    Aim = Window:AddTab("Aim", "crosshair"),
    Misc = Window:AddTab("Misc", "settings"),
    ["UI Settings"] = Window:AddTab("UI & Settings", "sliders"),
}

-- ============================================
--   СОСТОЯНИЕ
-- ============================================

local STATE = {
    espPlayer   = true,
    espBot      = true,
    espDefender = false,
    fullbright  = false,
    fov         = 70,
    fogEnabled  = false,
    spinEnabled = false,
    spinSpeed   = 15,
    flyEnabled  = false,
    flySpeed    = 60,
    killAll     = false,
    killDelay   = 0.25,
    killRockets = false,
    highlight   = false,
    tracers     = false,
    timeMode    = "off",
    showDroneName    = true,
    showDroneType    = true,
    showDroneDist    = true,
    showDroneDroneId = false,
    nameFontSize     = 14,
    nameColorMode    = "team",
    speedEnabled     = false,
    speedValue       = 32,
    jumpEnabled      = false,
    jumpValue        = 75,
    infJumpEnabled   = false,
    noclipEnabled    = false,
    antiAfkEnabled   = false,
    hitboxEnabled    = false,
    hitboxSize       = 15,
    hitboxVisible    = true,
    -- NEW FUNC
    autoFarmEnabled  = false,
    autoFarmRadius   = 500,
    spinBotEnabled   = false,
    spinBotSpeed     = 20,
    fullAutoEnabled  = false,
    fullAutoDelay    = 0.1,
    aimbotEnabled    = false,
    aimbotFov        = 300,
    aimbotSmooth     = 0.2,
    flightEnabled    = false,
    flightSpeed      = 100,
    rocketCounter    = 0,
    droneCounter     = 0,
}

-- ============================================
--   РАКЕТЫ
-- ============================================

local ROCKET_NAMES = {
    ["X101"]     = true,
    ["Flamingo"] = true,
    ["Neptun"]   = true,
    ["Kalibr"]   = true,
    ["Tomahawk"] = true,
    ["Shadow"]   = true,
    ["Ten"]      = true,
    ["Tень"]     = true,
}

local ROCKET_CFG = {
    KILL_DELAY  = 0.15,
    WAIT_DEATH  = 1.5,
    CHECK_EMPTY = 0.6,
    TP_COOLDOWN = 0.1,
    DEATH_POLL  = 0.1,
}

-- ============================================
--   НАЗВАНИЯ ДРОНОВ
-- ============================================

local function getDroneDisplayName(drone)
    local droneName = drone:GetAttribute("DroneName")
    if not droneName then return "Unknown" end
    local displayNames = {
        ["FPV"]        = "FPV Drone",
        ["FPVOld"]     = "FPV Old",
        ["Shahed136"]  = "Shahed-136",
        ["Shahed107"]  = "Shahed-107",
        ["Shahed238"]  = "Shahed-238",
        ["Gerbera"]    = "Gerbera",
        ["Delta"]      = "Delta",
        ["Lisica"]     = "Lisica",
        ["Lancet"]     = "Lancet",
        ["Molniva"]    = "Molniya",
        ["Neptun"]     = "Neptun",
        ["Kalibr"]     = "Kalibr",
        ["BM35"]       = "BM-35",
        ["Geran5"]     = "Geran-5",
        ["X101"]       = "X-101",
        ["Flamingo"]   = "Flamingo",
        ["Tomahawk"]   = "Tomahawk",
        ["Shadow"]     = "Shadow",
        ["Ten"]        = "Тень",
    }
    return displayNames[droneName] or droneName
end

local function getDroneType(drone)
    local isPD = drone:GetAttribute("IsPlayerDrone")
    if isPD == true then return "Player" end
    if isPD == false then return "Bot" end
    local oid = drone:GetAttribute("OwnerUserId")
    if oid and oid ~= 0 then return "Player" end
    return "Bot"
end

local function getNameColor(drone)
    local t = getDroneType(drone)
    if STATE.nameColorMode == "team" then
        return t == "Player" and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 60, 60)
    elseif STATE.nameColorMode == "white" then
        return Color3.fromRGB(255, 255, 255)
    elseif STATE.nameColorMode == "cyan" then
        return Color3.fromRGB(80, 200, 255)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ============================================
--   FULLBRIGHT / FOG
-- ============================================

local originalLighting = nil
local originalFog = nil

local function applyFullbright()
    if originalLighting then return end
    originalLighting = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows,
    }
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    Lighting.Brightness = 3
    Lighting.ClockTime = 12
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
end

local function restoreFullbright()
    if not originalLighting then return end
    Lighting.Ambient = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.FogStart = originalLighting.FogStart
    Lighting.GlobalShadows = originalLighting.GlobalShadows
    originalLighting = nil
end

local function applyFog()
    if originalFog then return end
    originalFog = { FogColor = Lighting.FogColor, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
    Lighting.FogColor = Color3.fromRGB(140, 130, 115)
    Lighting.FogStart = 40
    Lighting.FogEnd = 400
end

local function restoreFog()
    if not originalFog then return end
    Lighting.FogColor = originalFog.FogColor
    Lighting.FogStart = originalFog.FogStart
    Lighting.FogEnd = originalFog.FogEnd
    originalFog = nil
end

-- ============================================
--   ВРЕМЯ СУТОК
-- ============================================

local originalTime = nil
local timeConnection = nil

local function removeSky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
end

local function makeSky(name, sunSize, moonSize, stars)
    removeSky()
    local sky = Instance.new("Sky")
    sky.Name = name
    sky.SkyboxBk = "rbxassetid://6444884337"
    sky.SkyboxDn = "rbxassetid://6444884337"
    sky.SkyboxFt = "rbxassetid://6444884337"
    sky.SkyboxLf = "rbxassetid://6444884337"
    sky.SkyboxRt = "rbxassetid://6444884337"
    sky.SkyboxUp = "rbxassetid://6444884337"
    if sunSize then sky.SunAngularSize = sunSize end
    if moonSize then sky.MoonAngularSize = moonSize end
    sky.StarCount = stars
    sky.Parent = Lighting
end

local function setupSunset()
    makeSky("SunsetSky", 28, 11, 3000)
    Lighting.Brightness = 1.5
    Lighting.ClockTime = 18.5
    Lighting.GeographicLatitude = 20
    Lighting.Ambient = Color3.fromRGB(120, 80, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(160, 100, 80)
    Lighting.EnvironmentDiffuseScale = 0.6
    Lighting.EnvironmentSpecularScale = 0.4
    Lighting.GlobalShadows = true
    Lighting.FogColor = Color3.fromRGB(200, 140, 100)
    Lighting.FogStart = 200
    Lighting.FogEnd = 4000
end

local function setupDay()
    makeSky("DaySky", 21, nil, 0)
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
    Lighting.GeographicLatitude = 0
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.GlobalShadows = true
    Lighting.FogColor = Color3.fromRGB(200, 200, 220)
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
end

local function setupNight()
    makeSky("NightSky", nil, 11, 5000)
    Lighting.Brightness = 1
    Lighting.ClockTime = 0
    Lighting.Ambient = Color3.fromRGB(20, 20, 40)
    Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 60)
    Lighting.EnvironmentDiffuseScale = 0.3
    Lighting.EnvironmentSpecularScale = 0.3
    Lighting.GlobalShadows = true
    Lighting.FogColor = Color3.fromRGB(15, 15, 30)
    Lighting.FogStart = 100
    Lighting.FogEnd = 5000
end

local function startTimeLoop(mode)
    if timeConnection then
        timeConnection:Disconnect()
        timeConnection = nil
    end
    if not originalTime then
        originalTime = {
            ClockTime = Lighting.ClockTime,
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogColor = Lighting.FogColor,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
            GeographicLatitude = Lighting.GeographicLatitude,
        }
    end
    STATE.timeMode = mode
    if mode == "day" then setupDay()
    elseif mode == "night" then setupNight()
    elseif mode == "sunset" then setupSunset() end
    timeConnection = RunService.Heartbeat:Connect(function()
        if STATE.timeMode == "day" then
            Lighting.ClockTime = 14
        elseif STATE.timeMode == "night" then
            Lighting.ClockTime = 0
        elseif STATE.timeMode == "sunset" then
            Lighting.ClockTime = 18.5
        end
    end)
end

local function restoreTime()
    if timeConnection then
        timeConnection:Disconnect()
        timeConnection = nil
    end
    removeSky()
    if originalTime then
        Lighting.ClockTime = originalTime.ClockTime
        Lighting.Brightness = originalTime.Brightness
        Lighting.Ambient = originalTime.Ambient
        Lighting.OutdoorAmbient = originalTime.OutdoorAmbient
        Lighting.FogColor = originalTime.FogColor
        Lighting.FogStart = originalTime.FogStart
        Lighting.FogEnd = originalTime.FogEnd
        Lighting.GlobalShadows = originalTime.GlobalShadows
        Lighting.EnvironmentDiffuseScale = originalTime.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = originalTime.EnvironmentSpecularScale
        Lighting.GeographicLatitude = originalTime.GeographicLatitude
    end
    STATE.timeMode = "off"
end

-- ============================================
--   SPIN
-- ============================================

local spinConnection = nil

local function startSpin()
    if spinConnection then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bav = Instance.new("BodyAngularVelocity")
    bav.Name = "SpinBAV"
    bav.MaxTorque = Vector3.new(0, 1e5, 0)
    bav.AngularVelocity = Vector3.new(0, STATE.spinSpeed, 0)
    bav.P = 500
    bav.Parent = hrp
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = false end
    spinConnection = RunService.Heartbeat:Connect(function()
        if not STATE.spinEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local b = h:FindFirstChild("SpinBAV")
        if b then b.AngularVelocity = Vector3.new(0, STATE.spinSpeed, 0) end
    end)
end

local function stopSpin()
    if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bav = hrp:FindFirstChild("SpinBAV")
            if bav then bav:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

-- ============================================
--   FLY
-- ============================================

local flyConnection = nil

local function startFly()
    if flyConnection then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyBG"
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 3000
    bg.D = 50
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    flyConnection = RunService.RenderStepped:Connect(function()
        if not STATE.flyEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if not bv or not bv.Parent then return end
        if not bg or not bg.Parent then return end
        local hm = c:FindFirstChildOfClass("Humanoid")
        if not hm then return end
        local moveDir = hm.MoveDirection
        local velocity = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0.05 then
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude > 0.01 then
                velocity = velocity + flatDir.Unit * STATE.flySpeed
            end
        end
        local lookY = camera.CFrame.LookVector.Y
        if math.abs(moveDir.Z) > 0.3 and math.abs(lookY) > 0.15 then
            velocity = velocity + Vector3.new(0, lookY * STATE.flySpeed, 0)
        end
        bv.Velocity = velocity
        bg.CFrame = camera.CFrame
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("FlyBV")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("FlyBG")
            if bg then bg:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ============================================
--   KILL ALL
-- ============================================

local killing = false

local function checkIsPlayer(drone)
    local isPD = drone:GetAttribute("IsPlayerDrone")
    if isPD == true then return true end
    if isPD == false then return false end
    local oid = drone:GetAttribute("OwnerUserId")
    if oid and oid ~= 0 then return true end
    return false
end

local function findDroneRoot(drone)
    if drone.PrimaryPart and drone.PrimaryPart:IsA("BasePart") then
        return drone.PrimaryPart
    end
    local body = drone:FindFirstChild("Body")
    if body and body:IsA("BasePart") then return body end
    for _, obj in ipairs(drone:GetDescendants()) do
        if obj:IsA("BasePart") then return obj end
    end
    return nil
end

local function getAllDrones()
    local list = {}
    local spawned = Workspace:FindFirstChild("Drones")
        and Workspace.Drones:FindFirstChild("SpawnedDrones")
    if not spawned then return list end
    for _, d in ipairs(spawned:GetChildren()) do
        if d:IsA("Model")
        and d:GetAttribute("Destroyed") ~= true
        and d:GetAttribute("DroneName") ~= nil then
            local root = findDroneRoot(d)
            if root then table.insert(list, { drone = d, root = root }) end
        end
    end
    return list
end

local function waitForDeath(drone, timeout)
    local start = tick()
    while tick() - start < timeout do
        if not drone.Parent then return true end
        if drone:GetAttribute("Destroyed") == true then return true end
        if not STATE.killAll then return false end
        task.wait(0.05)
    end
    return false
end

local function startKillAll()
    if killing then return end
    killing = true
    if STATE.flyEnabled then STATE.flyEnabled = false; stopFly() end
    if STATE.spinEnabled then STATE.spinEnabled = false; stopSpin() end
    task.wait(0.2)
    while STATE.killAll do
        local drones = getAllDrones()
        if #drones == 0 then
            task.wait(0.5)
        else
            local target = drones[1]
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.PlatformStand = true end
                    hrp.CFrame = CFrame.new(target.root.Position)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    waitForDeath(target.drone, 1.5)
                    task.wait(STATE.killDelay)
                else
                    task.wait(0.1)
                end
            else
                task.wait(0.1)
            end
        end
    end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    killing = false
end

-- ============================================
--   KILL ROCKETS
-- ============================================

local killingRockets = false
local rocketStartCFrame = nil

local function isRocket(drone)
    local name = drone:GetAttribute("DroneName")
    if not name then return false end
    return ROCKET_NAMES[name] == true
end

local function getRocketDrones()
    local list = {}
    local spawned = Workspace:FindFirstChild("Drones")
        and Workspace.Drones:FindFirstChild("SpawnedDrones")
    if not spawned then return list end
    for _, d in ipairs(spawned:GetChildren()) do
        if d:IsA("Model")
        and d:GetAttribute("Destroyed") ~= true
        and d:GetAttribute("DroneName") ~= nil
        and isRocket(d) then
            local root = findDroneRoot(d)
            if root then
                table.insert(list, {
                    drone = d,
                    root  = root,
                    name  = d:GetAttribute("DroneName"),
                })
            end
        end
    end
    return list
end

local function rocketTeleport(cf)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    hrp.CFrame = cf
end

local function clearBodyMovers()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(hrp:GetChildren()) do
        if obj:IsA("BodyPosition") or obj:IsA("BodyVelocity")
        or obj:IsA("BodyGyro") or obj:IsA("AlignPosition")
        or obj:IsA("AlignOrientation") then
            obj:Destroy()
        end
    end
end

local function startKillRockets()
    if killingRockets then return end
    killingRockets = true

    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then rocketStartCFrame = hrp.CFrame end
    end

    clearBodyMovers()
    if STATE.flyEnabled then STATE.flyEnabled = false; stopFly() end
    if STATE.spinEnabled then STATE.spinEnabled = false; stopSpin() end
    task.wait(0.1)

    local rockets = getRocketDrones()

    if #rockets == 0 then
        Library:Notify({ Title = "Kill Rockets", Content = "No rockets", Duration = 3 })
        print("[Kill Rockets] ❌ No rockets")
        killingRockets = false
        rocketStartCFrame = nil
        return
    end

    Library:Notify({ Title = "Kill Rockets", Content = "Найдено: " .. #rockets, Duration = 3 })
    print("[Kill Rockets] ▶ Старт. Найдено:", #rockets)

    local emptyTimer = 0

    while STATE.killRockets do
        rockets = getRocketDrones()

        if #rockets == 0 then
            emptyTimer = emptyTimer + ROCKET_CFG.KILL_DELAY
            if emptyTimer >= ROCKET_CFG.CHECK_EMPTY then
                print("[Kill Rockets] ✅ Всё сбито. Возврат.")
                break
            end
            task.wait(ROCKET_CFG.KILL_DELAY)
        else
            emptyTimer = 0
            local target = rockets[1]
            print(string.format("[Kill Rockets] 🎯 %s | %d шт.",
                tostring(target.name), #rockets))

            rocketTeleport(CFrame.new(target.root.Position))

            local t0 = tick()
            while tick() - t0 < ROCKET_CFG.WAIT_DEATH do
                if not target.drone.Parent then break end
                if target.drone:GetAttribute("Destroyed") == true then break end
                if not STATE.killRockets then break end
                task.wait(ROCKET_CFG.DEATH_POLL)
            end

            task.wait(ROCKET_CFG.TP_COOLDOWN)
        end
    end

    if rocketStartCFrame then
        rocketTeleport(rocketStartCFrame)
        print("[Kill Rockets] 🏠 Возврат выполнен")
        rocketStartCFrame = nil
    end

    local char2 = player.Character
    if char2 then
        local hum2 = char2:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2.PlatformStand = false end
    end

    killingRockets = false
end

local function stopKillRockets()
    STATE.killRockets = false
end

-- ============================================
--   HITBOX EXPANDER (отдельный парт!)
-- ============================================

local hitboxParts = {}
local hitboxHighlights = {}

local function createHitboxPart(drone)
    local root = findDroneRoot(drone)
    if not root then return end

    local existing = hitboxParts[drone]
    if existing and existing.Parent then
        existing.Size = Vector3.new(STATE.hitboxSize, STATE.hitboxSize, STATE.hitboxSize)
        existing.CFrame = root.CFrame
        return
    end

    local hb = Instance.new("Part")
    hb.Name = "Rooeltex_Hitbox"
    hb.Size = Vector3.new(STATE.hitboxSize, STATE.hitboxSize, STATE.hitboxSize)
    hb.CFrame = root.CFrame
    hb.Anchored = true
    hb.CanCollide = false
    hb.CanQuery = true
    hb.CanTouch = true
    hb.Massless = true
    hb.Material = Enum.Material.ForceField
    hb.Color = Color3.fromRGB(255, 0, 0)
    hb.Transparency = 0.7
    hb.Parent = drone
    hitboxParts[drone] = hb

    if STATE.hitboxVisible then
        local hl = Instance.new("Highlight")
        hl.Name = "RooeltexHitboxVisual"
        hl.Adornee = hb
        hl.FillColor = Color3.fromRGB(255, 30, 30)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = CoreGui
        hitboxHighlights[drone] = hl
    end
end

local function removeHitboxPart(drone)
    local hb = hitboxParts[drone]
    if hb then hb:Destroy(); hitboxParts[drone] = nil end
    local hl = hitboxHighlights[drone]
    if hl then hl:Destroy(); hitboxHighlights[drone] = nil end
end

local function applyHitbox()
    local list = getAllDrones()
    for _, entry in ipairs(list) do
        createHitboxPart(entry.drone)
    end
end

local function stopHitbox()
    for drone, _ in pairs(hitboxParts) do
        removeHitboxPart(drone)
    end
    hitboxParts = {}
    hitboxHighlights = {}
end

task.spawn(function()
    while task.wait(0.1) do
        if STATE.hitboxEnabled then
            applyHitbox()
        end
    end
end)

-- ============================================
--   MISC FUNCTIONS
-- ============================================

-- SPEED
local speedConnection = nil
local originalWalkSpeed = 16

local function applySpeed()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if STATE.speedEnabled then hum.WalkSpeed = STATE.speedValue end
end

local function startSpeed()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    originalWalkSpeed = hum.WalkSpeed
    applySpeed()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(function()
        if not STATE.speedEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = STATE.speedValue end
    end)
end

local function stopSpeed()
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = originalWalkSpeed end
    end
end

-- JUMP
local jumpConnection = nil
local originalJumpPower = 50

local function applyJump()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if STATE.jumpEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = STATE.jumpValue
    end
end

local function startJump()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    originalJumpPower = hum.JumpPower
    applyJump()
    if jumpConnection then jumpConnection:Disconnect() end
    jumpConnection = RunService.Heartbeat:Connect(function()
        if not STATE.jumpEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.UseJumpPower = true
            h.JumpPower = STATE.jumpValue
        end
    end)
end

local function stopJump()
    if jumpConnection then jumpConnection:Disconnect(); jumpConnection = nil end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = originalJumpPower end
    end
end

-- INFINITE JUMP
local infJumpConnection = nil

local function startInfJump()
    if infJumpConnection then return end
    infJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not STATE.infJumpEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function stopInfJump()
    if infJumpConnection then infJumpConnection:Disconnect(); infJumpConnection = nil end
end

-- NOCLIP
local noclipConnection = nil

local function startNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if not STATE.noclipEnabled then return end
        local char = player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    local char = player.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ANTI-AFK
local antiAfkConnection = nil

local function startAntiAfk()
    if antiAfkConnection then return end
    antiAfkConnection = player.Idled:Connect(function()
        if not STATE.antiAfkEnabled then return end
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end

local function stopAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect(); antiAfkConnection = nil end
end

-- 🆕 SPIN BOT (быстрое вращение персонажа)
local spinBotConnection = nil

local function startSpinBot()
    if spinBotConnection then return end
    spinBotConnection = RunService.Heartbeat:Connect(function()
        if not STATE.spinBotEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(STATE.spinBotSpeed), 0)
    end)
end

local function stopSpinBot()
    if spinBotConnection then spinBotConnection:Disconnect(); spinBotConnection = nil end
end

-- 🆕 AUTO FARM (телепорт к ближайшему дрону и убийство)
local autoFarmRunning = false

local function startAutoFarm()
    if autoFarmRunning then return end
    autoFarmRunning = true

    while STATE.autoFarmEnabled do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local drones = getAllDrones()
                local closest = nil
                local minDist = STATE.autoFarmRadius

                for _, d in ipairs(drones) do
                    local dist = (d.root.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = d
                    end
                end

                if closest then
                    hrp.CFrame = CFrame.new(closest.root.Position + Vector3.new(0, 5, 0))
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
        task.wait(0.5)
    end
    autoFarmRunning = false
end

local function stopAutoFarm()
    STATE.autoFarmEnabled = false
end

-- 🆕 AIMBOT (поворот камеры к ближайшему дрону)
local aimbotConnection = nil

local function startAimbot()
    if aimbotConnection then return end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not STATE.aimbotEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local drones = getAllDrones()
        local closest = nil
        local minAngle = STATE.aimbotFov

        for _, d in ipairs(drones) do
            local dir = (d.root.Position - camera.CFrame.Position).Unit
            local look = camera.CFrame.LookVector
            local dot = dir:Dot(look)
            if dot > 0 then
                local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
                if angle < minAngle then
                    minAngle = angle
                    closest = d
                end
            end
        end

        if closest then
            local targetCF = CFrame.new(camera.CFrame.Position, closest.root.Position)
            camera.CFrame = camera.CFrame:Lerp(targetCF, STATE.aimbotSmooth)
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
end

-- 🆕 FLIGHT (плавный полёт с WASD и пробелом)
local flightConnection = nil

local function startFlight()
    if flightConnection then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bg = Instance.new("BodyGyro")
    bg.Name = "FlightBG"
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 1000
    bg.D = 50
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlightBV"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.P = 1250
    bv.Parent = hrp

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    flightConnection = RunService.RenderStepped:Connect(function()
        if not STATE.flightEnabled then return end
        local c = player.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if not bg.Parent or not bv.Parent then return end

        local hm = c:FindFirstChildOfClass("Humanoid")
        if not hm then return end

        local moveDir = hm.MoveDirection
        local velocity = moveDir * STATE.flightSpeed

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, STATE.flightSpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            velocity = velocity - Vector3.new(0, STATE.flightSpeed, 0)
        end

        bv.Velocity = velocity
        bg.CFrame = camera.CFrame
    end)
end

local function stopFlight()
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bg = hrp:FindFirstChild("FlightBG")
            if bg then bg:Destroy() end
            local bv = hrp:FindFirstChild("FlightBV")
            if bv then bv:Destroy() end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

-- ============================================
--   ESP ДЛЯ ДРОНОВ
-- ============================================

local COLORS = { PLAYER = Color3.fromRGB(0, 255, 100), BOT = Color3.fromRGB(255, 60, 60) }
local SETTINGS = {
    SCAN_RATE    = 0.2,
    BOX_THICK    = 1,
    BOX_PADDING  = 35,
    STREAM_RADIUS = 4,
}

local droneCache = {}
local espData = {}
local hlData = {}
local tracerData = {}

local function createHighlightFor(drone, isPlayer)
    if hlData[drone] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "RooeltexHL"
    hl.Adornee = drone
    hl.FillTransparency = 1
    hl.OutlineColor = isPlayer and COLORS.PLAYER or COLORS.BOT
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = CoreGui
    hlData[drone] = hl
end

local function createTracerFor(drone, isPlayer)
    if tracerData[drone] then return end
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = isPlayer and COLORS.PLAYER or COLORS.BOT
    line.Transparency = 0.8
    line.Visible = false
    tracerData[drone] = line
end

local function createESPFor(drone, isPlayer)
    if espData[drone] then return end
    local color = isPlayer and COLORS.PLAYER or COLORS.BOT
    local lineT = Drawing.new("Line")
    local lineB = Drawing.new("Line")
    local lineL = Drawing.new("Line")
    local lineR = Drawing.new("Line")
    for _, l in ipairs({lineT, lineB, lineL, lineR}) do
        l.Thickness = SETTINGS.BOX_THICK
        l.Color = color
        l.Transparency = 1
        l.Visible = false
    end
    local nameText = Drawing.new("Text")
    nameText.Size = STATE.nameFontSize
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.new(0, 0, 0)
    nameText.Color = color
    nameText.Font = 2
    nameText.Text = getDroneDisplayName(drone)
    nameText.Visible = false
    local typeText = Drawing.new("Text")
    typeText.Size = 12
    typeText.Center = true
    typeText.Outline = true
    typeText.OutlineColor = Color3.new(0, 0, 0)
    typeText.Color = color
    typeText.Font = 2
    typeText.Text = getDroneType(drone)
    typeText.Visible = false
    local distText = Drawing.new("Text")
    distText.Size = 11
    distText.Center = true
    distText.Outline = true
    distText.OutlineColor = Color3.new(0, 0, 0)
    distText.Color = Color3.fromRGB(235, 235, 235)
    distText.Font = 3
    distText.Text = "--"
    distText.Visible = false
    espData[drone] = {
        lineT = lineT, lineB = lineB, lineL = lineL, lineR = lineR,
        nameText = nameText, typeText = typeText, distText = distText,
    }
end

local function hideESPElements(drone)
    local data = espData[drone]
    if data then
        data.lineT.Visible = false
        data.lineB.Visible = false
        data.lineL.Visible = false
        data.lineR.Visible = false
        data.nameText.Visible = false
        data.typeText.Visible = false
        data.distText.Visible = false
    end
    local line = tracerData[drone]
    if line then line.Visible = false end
    local hl = hlData[drone]
    if hl then hl.Enabled = false end
end

local function removeAllFor(drone)
    local data = espData[drone]
    if data then
        for _, key in ipairs({"lineT","lineB","lineL","lineR","nameText","typeText","distText"}) do
            if data[key] then data[key]:Remove() end
        end
        espData[drone] = nil
    end
    local line = tracerData[drone]
    if line then line:Remove(); tracerData[drone] = nil end
    local hl = hlData[drone]
    if hl then hl:Destroy(); hlData[drone] = nil end
    removeHitboxPart(drone)
end

task.spawn(function()
    while task.wait(SETTINGS.SCAN_RATE) do
        local list = {}
        local spawned = Workspace:FindFirstChild("Drones")
            and Workspace.Drones:FindFirstChild("SpawnedDrones")
        if spawned then
            for _, d in ipairs(spawned:GetChildren()) do
                if d:IsA("Model")
                and d:GetAttribute("Destroyed") ~= true
                and d:GetAttribute("DroneName") ~= nil then
                    local root = findDroneRoot(d)
                    if root then
                        table.insert(list, {
                            drone = d, root = root,
                            isPlayer = checkIsPlayer(d),
                        })
                    end
                end
            end
        end
        droneCache = list
        STATE.droneCounter = #list
        local currentSet = {}
        for _, entry in ipairs(list) do
            currentSet[entry.drone] = true
            if STATE.highlight then createHighlightFor(entry.drone, entry.isPlayer) end
            if STATE.tracers then createTracerFor(entry.drone, entry.isPlayer) end
        end
        for drone, _ in pairs(hlData) do
            if not currentSet[drone] or not drone.Parent
            or drone:GetAttribute("Destroyed") == true then
                removeAllFor(drone)
            end
        end
        for drone, _ in pairs(tracerData) do
            if not currentSet[drone] or not drone.Parent
            or drone:GetAttribute("Destroyed") == true then
                removeAllFor(drone)
            end
        end
        for drone, _ in pairs(espData) do
            if not currentSet[drone] or not drone.Parent
            or drone:GetAttribute("Destroyed") == true then
                removeAllFor(drone)
            end
        end
        for drone, _ in pairs(hitboxParts) do
            if not drone.Parent or drone:GetAttribute("Destroyed") == true then
                removeHitboxPart(drone)
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local myPos
    if player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then myPos = hrp.Position end
    end
    if not myPos then myPos = camera.CFrame.Position end
    local screenSize = camera.ViewportSize
    local tracerStartX = screenSize.X / 2
    local tracerStartY = screenSize.Y

    for _, entry in ipairs(droneCache) do
        local drone = entry.drone
        local isPlayer = entry.isPlayer

        if not drone.Parent
        or drone:GetAttribute("Destroyed") == true then
            hideESPElements(drone)
        else
            local root = findDroneRoot(drone)
            if not root then
                hideESPElements(drone)
            else
                local shouldShow = (isPlayer and STATE.espPlayer) or (not isPlayer and STATE.espBot)
                if HAS_DRAWING and shouldShow then
                    createESPFor(drone, isPlayer)
                    local data = espData[drone]
                    local pos = camera:WorldToViewportPoint(root.Position)
                    if pos.Z > 0 then
                        local scale = SETTINGS.BOX_PADDING * (100 / pos.Z)
                        local sx = math.clamp(scale, 5, 200)
                        local sy = math.clamp(scale, 5, 200)
                        local minX, minY = pos.X - sx, pos.Y - sy
                        local maxX, maxY = pos.X + sx, pos.Y + sy
                        data.lineT.From = Vector2.new(minX, minY); data.lineT.To = Vector2.new(maxX, minY); data.lineT.Visible = true
                        data.lineB.From = Vector2.new(minX, maxY); data.lineB.To = Vector2.new(maxX, maxY); data.lineB.Visible = true
                        data.lineL.From = Vector2.new(minX, minY); data.lineL.To = Vector2.new(minX, maxY); data.lineL.Visible = true
                        data.lineR.From = Vector2.new(maxX, minY); data.lineR.To = Vector2.new(maxX, maxY); data.lineR.Visible = true
                        local centerX = (minX + maxX) / 2
                        local lineHeight = 15
                        local currentY = minY - 20
                        if STATE.showDroneName then
                            data.nameText.Text = getDroneDisplayName(drone)
                            data.nameText.Color = getNameColor(drone)
                            data.nameText.Position = Vector2.new(centerX, currentY)
                            data.nameText.Visible = true
                            currentY = currentY - lineHeight
                        else
                            data.nameText.Visible = false
                        end
                        if STATE.showDroneType then
                            data.typeText.Text = getDroneType(drone)
                            data.typeText.Color = getNameColor(drone)
                            data.typeText.Position = Vector2.new(centerX, currentY)
                            data.typeText.Visible = true
                            currentY = currentY - lineHeight
                        else
                            data.typeText.Visible = false
                        end
                        if STATE.showDroneDist then
                            local d = math.floor((root.Position - myPos).Magnitude)
                            data.distText.Text = d .. "m"
                            data.distText.Position = Vector2.new(centerX, currentY)
                            data.distText.Visible = true
                        else
                            data.distText.Visible = false
                        end
                    else
                        hideESPElements(drone)
                    end
                else
                    local data = espData[drone]
                    if data then
                        data.lineT.Visible = false
                        data.lineB.Visible = false
                        data.lineL.Visible = false
                        data.lineR.Visible = false
                        data.nameText.Visible = false
                        data.typeText.Visible = false
                        data.distText.Visible = false
                    end
                end
                if STATE.tracers and HAS_DRAWING then
                    local line = tracerData[drone]
                    if line then
                        local screenPos = camera:WorldToViewportPoint(root.Position)
                        if screenPos.Z > 0 then
                            line.From = Vector2.new(tracerStartX, tracerStartY)
                            line.To = Vector2.new(screenPos.X, screenPos.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                else
                    local line = tracerData[drone]
                    if line then line.Visible = false end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    Workspace:RequestStreamAroundAsync(hrp.Position, SETTINGS.STREAM_RADIUS)
                end)
            end
        end
    end
end)

-- ============================================
--   UI: VISUALS TAB
-- ============================================

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP")
ESPGroup:AddToggle("espPlayer", {
    Text = "ESP Player", Default = true,
    Callback = function(v) STATE.espPlayer = v end,
})
ESPGroup:AddToggle("espBot", {
    Text = "ESP Bot", Default = true,
    Callback = function(v) STATE.espBot = v end,
})
ESPGroup:AddToggle("espDefender", {
    Text = "ESP Defenders", Default = false,
    Tooltip = "Синяя обводка на защитниках",
    Callback = function(v) STATE.espDefender = v end,
})
ESPGroup:AddToggle("highlight", {
    Text = "Highlight", Default = false,
    Callback = function(v)
        STATE.highlight = v
        if v then
            for _, entry in ipairs(droneCache) do
                createHighlightFor(entry.drone, entry.isPlayer)
            end
        else
            for drone, hl in pairs(hlData) do hl:Destroy() end
            hlData = {}
        end
    end,
})
ESPGroup:AddToggle("tracers", {
    Text = "Tracers", Default = false,
    Callback = function(v)
        STATE.tracers = v
        if v then
            for _, entry in ipairs(droneCache) do
                createTracerFor(entry.drone, entry.isPlayer)
            end
        else
            for drone, line in pairs(tracerData) do line:Remove() end
            tracerData = {}
        end
    end,
})

local CameraGroup = Tabs.Visuals:AddRightGroupbox("Camera")
CameraGroup:AddToggle("fullbright", {
    Text = "Fullbright", Default = false,
    Callback = function(v)
        STATE.fullbright = v
        if v then applyFullbright() else restoreFullbright() end
    end,
})
CameraGroup:AddSlider("fov", {
    Text = "Camera FOV", Default = 70,
    Min = 70, Max = 120, Rounding = 1,
    Callback = function(v)
        camera.FieldOfView = v
        STATE.fov = v
    end,
})

local TimeGroup = Tabs.Visuals:AddLeftGroupbox("Time of Day")
TimeGroup:AddButton({
    Text = "☀️ День",
    Func = function()
        startTimeLoop("day")
        Library:Notify({ Title = "Time", Content = "День ☀️", Duration = 3 })
    end,
})
TimeGroup:AddButton({
    Text = "🌙 Ночь",
    Func = function()
        startTimeLoop("night")
        Library:Notify({ Title = "Time", Content = "Ночь 🌙", Duration = 3 })
    end,
})
TimeGroup:AddButton({
    Text = "🌅 Закат",
    Func = function()
        startTimeLoop("sunset")
        Library:Notify({ Title = "Time", Content = "Закат 🌅", Duration = 3 })
    end,
})
TimeGroup:AddButton({
    Text = "❌ Выключить",
    Func = function()
        restoreTime()
        Library:Notify({ Title = "Time", Content = "Время восстановлено", Duration = 3 })
    end,
})

local AtmoGroup = Tabs.Visuals:AddRightGroupbox("Atmosphere")
AtmoGroup:AddToggle("fog", {
    Text = "Fog", Default = false,
    Callback = function(v)
        STATE.fogEnabled = v
        if v then applyFog() else restoreFog() end
    end,
})
AtmoGroup:AddToggle("spin", {
    Text = "Spin", Default = false,
    Callback = function(v)
        STATE.spinEnabled = v
        if v then startSpin() else stopSpin() end
    end,
})
AtmoGroup:AddSlider("spinSpeed", {
    Text = "Spin Speed", Default = 15,
    Min = 5, Max = 40, Rounding = 1,
    Callback = function(v) STATE.spinSpeed = v end,
})

-- ============================================
--   UI: NAMES TAB
-- ============================================

local NamesGroup = Tabs.Names:AddLeftGroupbox("Drone Names")
NamesGroup:AddToggle("showDroneName", {
    Text = "Show Drone Name", Default = true,
    Callback = function(v) STATE.showDroneName = v end,
})
NamesGroup:AddToggle("showDroneType", {
    Text = "Show Drone Type", Default = true,
    Callback = function(v) STATE.showDroneType = v end,
})
NamesGroup:AddToggle("showDroneDist", {
    Text = "Show Distance", Default = true,
    Callback = function(v) STATE.showDroneDist = v end,
})

local NamesStyleGroup = Tabs.Names:AddRightGroupbox("Style")
NamesStyleGroup:AddSlider("nameFontSize", {
    Text = "Font Size", Default = 14,
    Min = 8, Max = 24, Rounding = 1,
    Callback = function(v) STATE.nameFontSize = v end,
})
NamesStyleGroup:AddDropdown("nameColorMode", {
    Text = "Color Mode",
    Values = { "team", "white", "cyan" },
    Default = "team",
    Callback = function(v) STATE.nameColorMode = v end,
})

-- ============================================
--   UI: AIM TAB
-- ============================================

local AimGroup = Tabs.Aim:AddLeftGroupbox("Combat")
AimGroup:AddToggle("killAll", {
    Text = "Kill All", Default = false,
    Callback = function(v)
        STATE.killAll = v
        if v then task.spawn(startKillAll) end
    end,
})
AimGroup:AddToggle("killRockets", {
    Text = "Kill Rockets", Default = false,
    Tooltip = "Сбивает только ракеты (X101, Flamingo, Neptun, Kalibr, Tomahawk, Shadow, Ten)",
    Callback = function(v)
        STATE.killRockets = v
        if v then
            task.spawn(startKillRockets)
        else
            stopKillRockets()
        end
    end,
})
AimGroup:AddToggle("aimbot", {
    Text = "Aimbot (Camera)", Default = false,
    Callback = function(v)
        STATE.aimbotEnabled = v
        if v then startAimbot() else stopAimbot() end
    end,
})
AimGroup:AddSlider("aimbotFov", {
    Text = "Aimbot FOV", Default = 300,
    Min = 30, Max = 1000, Rounding = 1,
    Callback = function(v) STATE.aimbotFov = v end,
})
AimGroup:AddSlider("aimbotSmooth", {
    Text = "Aimbot Smooth", Default = 20,
    Min = 1, Max = 100, Rounding = 1,
    Callback = function(v) STATE.aimbotSmooth = v / 100 end,
})
AimGroup:AddSlider("killDelay", {
    Text = "Kill Delay", Default = 25,
    Min = 10, Max = 100, Rounding = 1,
    Callback = function(v) STATE.killDelay = v / 100 end,
})

local HitboxGroup = Tabs.Aim:AddRightGroupbox("Hitbox Expander")
HitboxGroup:AddToggle("hitbox", {
    Text = "Enable Hitbox", Default = false,
    Callback = function(v)
        STATE.hitboxEnabled = v
        if not v then stopHitbox() end
    end,
})
HitboxGroup:AddSlider("hitboxSize", {
    Text = "Hitbox Size", Default = 15,
    Min = 2, Max = 60, Rounding = 1,
    Callback = function(v) STATE.hitboxSize = v end,
})
HitboxGroup:AddToggle("hitboxVisible", {
    Text = "Show Hitbox (Red)", Default = true,
    Callback = function(v)
        STATE.hitboxVisible = v
        if not v then
            for drone, _ in pairs(hitboxHighlights) do
                local hl = hitboxHighlights[drone]
                if hl then hl:Destroy(); hitboxHighlights[drone] = nil end
            end
        end
    end,
})

-- ============================================
--   UI: MISC TAB
-- ============================================

local MiscGroup = Tabs.Misc:AddLeftGroupbox("Movement")
MiscGroup:AddToggle("fly", {
    Text = "Fly (Old)", Default = false,
    Callback = function(v)
        STATE.flyEnabled = v
        if v then startFly() else stopFly() end
    end,
})
MiscGroup:AddToggle("flight", {
    Text = "Flight (New, WASD+Space+Shift)", Default = false,
    Tooltip = "Space — вверх, LeftShift — вниз, WASD — движение",
    Callback = function(v)
        STATE.flightEnabled = v
        if v then startFlight() else stopFlight() end
    end,
})
MiscGroup:AddSlider("flightSpeed", {
    Text = "Flight Speed", Default = 100,
    Min = 20, Max = 300, Rounding = 1,
    Callback = function(v) STATE.flightSpeed = v end,
})
MiscGroup:AddSlider("flySpeed", {
    Text = "Fly Speed (Old)", Default = 60,
    Min = 20, Max = 200, Rounding = 1,
    Callback = function(v) STATE.flySpeed = v end,
})
MiscGroup:AddToggle("speed", {
    Text = "Speed Hack", Default = false,
    Callback = function(v)
        STATE.speedEnabled = v
        if v then startSpeed() else stopSpeed() end
    end,
})
MiscGroup:AddSlider("speedValue", {
    Text = "Speed Value", Default = 32,
    Min = 16, Max = 200, Rounding = 1,
    Callback = function(v)
        STATE.speedValue = v
        applySpeed()
    end,
})
MiscGroup:AddToggle("jump", {
    Text = "Jump Power", Default = false,
    Callback = function(v)
        STATE.jumpEnabled = v
        if v then startJump() else stopJump() end
    end,
})
MiscGroup:AddSlider("jumpValue", {
    Text = "Jump Value", Default = 75,
    Min = 50, Max = 300, Rounding = 1,
    Callback = function(v)
        STATE.jumpValue = v
        applyJump()
    end,
})
MiscGroup:AddToggle("infJump", {
    Text = "Infinite Jump", Default = false,
    Callback = function(v)
        STATE.infJumpEnabled = v
        if v then startInfJump() else stopInfJump() end
    end,
})
MiscGroup:AddToggle("noclip", {
    Text = "Noclip", Default = false,
    Callback = function(v)
        STATE.noclipEnabled = v
        if v then startNoclip() else stopNoclip() end
    end,
})

local MiscGroup2 = Tabs.Misc:AddRightGroupbox("Utility")
MiscGroup2:AddToggle("antiAfk", {
    Text = "Anti-AFK", Default = false,
    Callback = function(v)
        STATE.antiAfkEnabled = v
        if v then startAntiAfk() else stopAntiAfk() end
    end,
})
MiscGroup2:AddToggle("spinBot", {
    Text = "Spin Bot 🌀", Default = false,
    Tooltip = "Крутит персонажа очень быстро",
    Callback = function(v)
        STATE.spinBotEnabled = v
        if v then startSpinBot() else stopSpinBot() end
    end,
})
MiscGroup2:AddSlider("spinBotSpeed", {
    Text = "Spin Bot Speed", Default = 20,
    Min = 1, Max = 180, Rounding = 1,
    Callback = function(v) STATE.spinBotSpeed = v end,
})
MiscGroup2:AddToggle("autoFarm", {
    Text = "Auto Farm 🎯", Default = false,
    Tooltip = "Автоматически телепортируется к ближайшему дрону",
    Callback = function(v)
        STATE.autoFarmEnabled = v
        if v then task.spawn(startAutoFarm) else stopAutoFarm() end
    end,
})
MiscGroup2:AddSlider("autoFarmRadius", {
    Text = "Auto Farm Radius", Default = 500,
    Min = 50, Max = 5000, Rounding = 10,
    Callback = function(v) STATE.autoFarmRadius = v end,
})
MiscGroup2:AddButton({
    Text = "🔄 Reset Character",
    Func = function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end,
})
MiscGroup2:AddButton({
    Text = "🧹 Clear Drones Cache",
    Func = function()
        for drone, _ in pairs(espData) do removeAllFor(drone) end
        espData, hlData, tracerData = {}, {}, {}
        droneCache = {}
        Library:Notify({ Title = "Misc", Content = "Кэш дронов очищен", Duration = 3 })
    end,
})

-- Инфо-бокс с счётчиками
local InfoGroup = Tabs.Misc:AddLeftGroupbox("Info")
InfoGroup:AddLabel("Drones: " .. tostring(STATE.droneCounter))

-- ============================================
--   ESP DEFENDERS
-- ============================================

local DEFENDER_COLOR = Color3.fromRGB(50, 150, 255)
local defHL = {}
local defBox = {}
local defTracer = {}
local defName = {}
local defVertical = {}
local DEFENDERS = {}

local function isDefender(plr)
    if plr == player then return false end
    if not plr.Team then return false end
    return plr.Team.Name == "Defenders"
end

local function createDefHL(plr)
    if not plr.Character then return end
    if defHL[plr] then
        defHL[plr].Adornee = plr.Character
        return
    end
    local hl = Instance.new("Highlight")
    hl.Name = "DefenderHL"
    hl.Adornee = plr.Character
    hl.FillTransparency = 1
    hl.OutlineColor = DEFENDER_COLOR
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = CoreGui
    defHL[plr] = hl
end

local function createDefBox(plr)
    if defBox[plr] then return end
    local t = Drawing.new("Line")
    local b = Drawing.new("Line")
    local l = Drawing.new("Line")
    local r = Drawing.new("Line")
    for _, ln in ipairs({t, b, l, r}) do
        ln.Thickness = 1.5
        ln.Color = DEFENDER_COLOR
        ln.Transparency = 0.9
        ln.Visible = false
    end
    defBox[plr] = { T = t, B = b, L = l, R = r }
end

local function createDefTracer(plr)
    if defTracer[plr] then return end
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = DEFENDER_COLOR
    line.Transparency = 0.7
    line.Visible = false
    defTracer[plr] = line
end

local function createDefName(plr)
    if defName[plr] then return end
    local txt = Drawing.new("Text")
    txt.Size = 14
    txt.Center = true
    txt.Outline = true
    txt.OutlineColor = Color3.new(0, 0, 0)
    txt.Color = Color3.fromRGB(200, 220, 255)
    txt.Font = 2
    txt.Text = plr.Name
    txt.Visible = false
    defName[plr] = txt
end

local function createDefVertical(plr)
    if defVertical[plr] then return end
    local txt = Drawing.new("Text")
    txt.Size = 11
    txt.Center = false
    txt.Outline = true
    txt.OutlineColor = Color3.new(0, 0, 0)
    txt.Color = Color3.fromRGB(100, 180, 255)
    txt.Font = 3
    txt.Text = "DEFENDERS"
    txt.Visible = false
    defVertical[plr] = txt
end

local function removeDefAll(plr)
    if defHL[plr] then defHL[plr]:Destroy(); defHL[plr] = nil end
    if defBox[plr] then
        for _, l in pairs(defBox[plr]) do l:Remove() end
        defBox[plr] = nil
    end
    if defTracer[plr] then defTracer[plr]:Remove(); defTracer[plr] = nil end
    if defName[plr] then defName[plr]:Remove(); defName[plr] = nil end
    if defVertical[plr] then defVertical[plr]:Remove(); defVertical[plr] = nil end
end

task.spawn(function()
    while task.wait(0.3) do
        if not STATE.espDefender then
            for plr, _ in pairs(DEFENDERS) do
                removeDefAll(plr)
            end
            DEFENDERS = {}
        else
            local current = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if isDefender(plr) and plr.Character then
                    current[plr] = true
                    DEFENDERS[plr] = true
                    createDefHL(plr)
                    createDefBox(plr)
                    createDefTracer(plr)
                    createDefName(plr)
                    createDefVertical(plr)
                end
            end
            for plr, _ in pairs(DEFENDERS) do
                if not current[plr] then
                    removeDefAll(plr)
                    DEFENDERS[plr] = nil
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not STATE.espDefender then return end
    local screenSize = camera.ViewportSize
    local startX = screenSize.X / 2
    local startY = screenSize.Y

    for plr, _ in pairs(DEFENDERS) do
        if plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = camera:WorldToViewportPoint(root.Position)
                if pos.Z <= 0 then
                    local box = defBox[plr]
                    if box then for _, l in pairs(box) do l.Visible = false end end
                    local n = defName[plr]
                    if n then n.Visible = false end
                    local v = defVertical[plr]
                    if v then v.Visible = false end
                else
                    local box = defBox[plr]
                    if box then
                        local studToPixel = 100 / pos.Z
                        local halfW = 2.2 * studToPixel
                        local halfH = 3.2 * studToPixel
                        halfW = math.max(halfW, 10)
                        halfH = math.max(halfH, 16)
                        halfW = math.min(halfW, 45)
                        halfH = math.min(halfH, 70)
                        local minX = pos.X - halfW
                        local maxX = pos.X + halfW
                        local minY = pos.Y - halfH
                        local maxY = pos.Y + halfH
                        box.T.From = Vector2.new(minX, minY)
                        box.T.To   = Vector2.new(maxX, minY)
                        box.B.From = Vector2.new(minX, maxY)
                        box.B.To   = Vector2.new(maxX, maxY)
                        box.L.From = Vector2.new(minX, minY)
                        box.L.To   = Vector2.new(minX, maxY)
                        box.R.From = Vector2.new(maxX, minY)
                        box.R.To   = Vector2.new(maxX, maxY)
                        for _, l in pairs(box) do l.Visible = true end
                        local name = defName[plr]
                        if name then
                            name.Text = plr.Name
                            name.Position = Vector2.new(pos.X, minY - 14)
                            name.Visible = true
                        end
                        local vert = defVertical[plr]
                        if vert then
                            vert.Text = "D\nE\nF\nE\nN\nD\nE\nR\nS"
                            vert.Position = Vector2.new(minX - 12, minY)
                            vert.Visible = true
                        end
                    end
                    local tracer = defTracer[plr]
                    if tracer then
                        tracer.From = Vector2.new(startX, startY)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    end
                end
            end
        end
    end
end)

-- ============================================
--   SAVE MANAGER + THEME
-- ============================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
ThemeManager:SetFolder("Rooeltex")
SaveManager:SetFolder("Rooeltex/Pantsir")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

task.spawn(function()
    task.wait(0.1)
    pcall(function()
        ThemeManager:SetLibrary(Library)
        Library:SetTheme("Amethyst")
    end)
end)

-- ============================================
--   СТАРТ
-- ============================================

Window:SelectTab(1)
Library:Notify({
    Title = "Rooeltex",
    Content = "v20 • Фиолетовая тема + все функции",
    Duration = 5,
})
print("═══════════════════════════════")
print("✅ Rooeltex v20 загружен")
print("🟣 Тема: Amethyst (фиолетовая)")
print("═══════════════════════════════")
