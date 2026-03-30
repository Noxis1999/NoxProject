-- NOX TERMINATOR V174 - APEX GLOBAL EDITION
local UIS = game:GetService("UserInputService") 
local RunService = game:GetService("RunService") 
local Players = game:GetService("Players") 
local VirtualInputManager = game:GetService("VirtualInputManager") 

local player = Players.LocalPlayer 
local camera = workspace.CurrentCamera 

-- ⌨️ MAPPING DÉPLACEMENTS (AZERTY) ET SORTS
local KEY_Z, KEY_Q, KEY_S, KEY_D = Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D
local KEY_DASH, INTERACT_KEY = Enum.KeyCode.Q, Enum.KeyCode.E
local SPELL_1, SPELL_2 = Enum.KeyCode.One, Enum.KeyCode.Two
local SPELL_Z, SPELL_X = Enum.KeyCode.Z, Enum.KeyCode.X
local SPELL_C, SPELL_V = Enum.KeyCode.C, Enum.KeyCode.V 

local MASTER_KEY, PHASE_KEY, PREDATOR_KEY = Enum.KeyCode.LeftAlt, Enum.KeyCode.T, Enum.KeyCode.P
local TASK_KEY = Enum.KeyCode.CapsLock 

-- ⚙️ CONFIGURATION
local CFG = {
    AIM_OFFSET = Vector3.new(0, -1.5, 0), 
    PREDICTION_PVP = 0.065,
    PREDICTION_PVE = 0.04,
    PVE_ORBIT_MIN = 16, PVE_ORBIT_MAX = 23,   
    PVP_ORBIT_MIN = 22, PVP_ORBIT_MAX = 33,
    MAX_VIS_DIST = 200, GAP_CLOSE_DIST = 35,  
    PVP_HEAL_PCT = 80, PVE_HEAL_PCT = 80,     
    PANIC_BURST = 20, HEAL_COOLDOWN = 4.0,   
    PHASE_HEAL_DIST = 15, DASH_COOLDOWN = 2.5,   
    PREDATOR_SPEED = 0.45, PHASE_DISTANCE = 3,     
    AUTO_PHASE_STUCK = 12, NEMESYS_SCAN_RATE = 1.0,
    SPELL_COOLDOWN = 0.1, M1_COOLDOWN = 0.1,     
    LOOT_RADIUS = 200, SCAN_RATE = 0.15,      
    FOLLOW_DIST = 1.5, LOOT_SPEED_HACK = 1.5, 
    BARON_SPEED_HACK = 1.3, 
    NEON_CORE = Color3.fromRGB(0, 255, 255), 
    OFF_COLOR = Color3.fromRGB(255, 30, 60), 
    BG_HOLO = Color3.fromRGB(12, 12, 16), 
    PURPLE_PHASE = Color3.fromRGB(150, 0, 255)
}

-- 🌍 TRADUCTIONS (TITRE INCLUS)
local LANGUAGES = {
    FR = {
        title = "BOT TERMINATOR NOX", flag = "🇫🇷 FR", standby = "SYSTEM STANDBY...", taskCombat = "⚔️ CIBLE : COMBAT [CAPS]", taskLoot = "💰 CIBLE : LOOT ET COURONNE [CAPS]",
        predOn = "⚡ PREDATOR [ON] ⚡", predOff = "MOBILITÉ PREDATOR [OFF] (P)", vipNone = "", vipFound = "👑 DETECTÉE : ",
        info = "[ALT] POWER | [MOLETTE] PVP/PVE\n[CAPS] MODE | [P] PREDATOR | [J] MASQUER UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WALLHACK)...", searchEnemies = "🤖 RECHERCHE D'ENNEMIS...", killRedP = "⚠️ KILLING RED PLAYER !",
        searchLoot = "🤖 RECHERCHE LOOT ET COURONNE...", securingChest = "💰 SECURING CHEST..."
    },
    EN = {
        title = "NOX TERMINATOR BOT", flag = "🇬🇧 EN", standby = "SYSTEM STANDBY...", taskCombat = "⚔️ TARGET: COMBAT [CAPS]", taskLoot = "💰 TARGET: LOOT & CROWN [CAPS]",
        predOn = "⚡ PREDATOR [ON] ⚡", predOff = "PREDATOR MOBILITY [OFF] (P)", vipNone = "", vipFound = "👑 DETECTED: ",
        info = "[ALT] POWER | [WHEEL] PVP/PVE\n[CAPS] MODE | [P] PREDATOR | [J] HIDE UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WALLHACK)...", searchEnemies = "🤖 SEARCHING ENEMIES...", killRedP = "⚠️ KILLING RED PLAYER !",
        searchLoot = "🤖 SEARCHING LOOT & CROWN...", securingChest = "💰 SECURING CHEST..."
    },
    DE = {
        title = "NOX TERMINATOR BOT", flag = "🇩🇪 DE", standby = "SYSTEM BEREIT...", taskCombat = "⚔️ ZIEL: KAMPF [CAPS]", taskLoot = "💰 ZIEL: BEUTE & KRONE [CAPS]",
        predOn = "⚡ PREDATOR [AN] ⚡", predOff = "PREDATOR BEWEGUNG [AUS] (P)", vipNone = "", vipFound = "👑 KRONE DETEKTIERT: ",
        info = "[ALT] POWER | [MAUSRAD] PVP/PVE\n[CAPS] MODUS | [P] PREDATOR | [J] UI VERBERGEN", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WALLHACK)...", searchEnemies = "🤖 SUCHE FEINDE...", killRedP = "⚠️ TÖTE SPIELER !",
        searchLoot = "🤖 SUCHE BEUTE & KRONE...", securingChest = "💰 SICHERE TRUHE..."
    },
    ES = {
        title = "NOX TERMINATOR BOT", flag = "🇪🇸 ES", standby = "SISTEMA EN ESPERA...", taskCombat = "⚔️ OBJETIVO: COMBATE [CAPS]", taskLoot = "💰 OBJETIVO: BOTÍN Y CORONA [CAPS]",
        predOn = "⚡ DEPREDADOR [ON] ⚡", predOff = "MOVILIDAD [OFF] (P)", vipNone = "", vipFound = "👑 DETECTADA: ",
        info = "[ALT] PODER | [RUEDA] PVP/PVE\n[CAPS] MODO | [P] DEPREDADOR | [J] OCULTAR UI", statusOn = "EN LÍNEA", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (MURO)...", searchEnemies = "🤖 BUSCANDO ENEMIGOS...", killRedP = "⚠️ MATANDO JUGADOR!",
        searchLoot = "🤖 BUSCANDO BOTÍN Y CORONA...", securingChest = "💰 ASEGURANDO COFRE..."
    },
    IT = {
        title = "NOX TERMINATOR BOT", flag = "🇮🇹 IT", standby = "SISTEMA IN ATTESA...", taskCombat = "⚔️ BERSAGLIO: COMBAT [CAPS]", taskLoot = "💰 BERSAGLIO: BOTTINO E CORONA [CAPS]",
        predOn = "⚡ PREDATORE [ON] ⚡", predOff = "MOBILITÀ [OFF] (P)", vipNone = "", vipFound = "👑 RILEVATA: ",
        info = "[ALT] ACCENDI | [ROTELLA] PVP/PVE\n[CAPS] MODE | [P] PREDATORE | [J] HIDE UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (MURO)...", searchEnemies = "🤖 RICERCA NEMICI...", killRedP = "⚠️ UCCIDENDO GIOCATORE!",
        searchLoot = "🤖 RICERCA BOTTINO E CORONA...", securingChest = "💰 SICUREZZA CESTA..."
    }
}
local langOrder = {"FR", "EN", "DE", "ES", "IT"}
local currentLangIndex = 1
local L = LANGUAGES[langOrder[currentLangIndex]]

-- VARIABLES LOGIQUES
local botActive, currentMode, currentTask, running = false, "PVE", "COMBAT", true 
local predatorMode, isPanicking = false, false 
local lastSpell, lastHealth, lastM1 = 0, 100, 0
local lastPanic, lastStrafeSwitch, lastScan, lastOffensiveDash = 0, 0, 0, 0
local cachedTarget, cachedLoot, lockedTarget = nil, nil, nil
local lastNemesysScan, vipCheckTimer = 0, 0
local sideKey = KEY_Q
local nemesysPlayers = {}
local lastPosRecord, lastStuckCheck = Vector3.new(0,0,0), 0
local currentLootAttempt, lootAttemptTimer, isSecuringLoot = nil, 0, false
local currentLootTarget, lootTravelTimer = nil, 0
local lastPromptFire = 0
local blacklistedLoot = {} 
local currentSpellIndex = 1 

-- FONCTIONS UTILITAIRES
local KeysHeld = {}
local function SetKey(key, state)
    if not key then return end 
    if KeysHeld[key] ~= state then
        KeysHeld[key] = state; VirtualInputManager:SendKeyEvent(state, key, false, game)
    end
end
local function TapKey(key) if not key then return end SetKey(key, true); task.delay(0.05, function() SetKey(key, false) end) end
local function StopAllInputs() for k, isHeld in pairs(KeysHeld) do if isHeld then SetKey(k, false) end end end
local function StopMovementInputs() SetKey(KEY_Z, false); SetKey(KEY_Q, false); SetKey(KEY_S, false); SetKey(KEY_D, false) end

local function ForceCastHeal()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Four, false, game)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Quote, false, game)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game) 
    task.wait(0.35) 
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Four, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Quote, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
end

local function executeHitAndRun()
    if isPanicking then return end; isPanicking = true
    task.spawn(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        StopAllInputs()
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(180), 0); task.wait(0.05)
        if root then local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit; root.CFrame = root.CFrame + (flatLook * CFG.PHASE_HEAL_DIST) end
        SetKey(KEY_Z, true); TapKey(KEY_DASH); task.wait(0.3); StopAllInputs()
        camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(180), 0); task.wait(0.05)
        SetKey(KEY_Z, true); ForceCastHeal(); task.wait(0.4); isPanicking = false 
    end)
end

-- 🖥️ CONSTRUCTION UI
local sg = Instance.new("ScreenGui", player.PlayerGui); sg.Name = "NOX_TERMINATOR"; sg.ResetOnSpawn = false
local f = Instance.new("Frame", sg); f.Size = UDim2.new(0, 310, 0, 280); f.Position = UDim2.new(0.05, 0, 0.4, 0); f.BackgroundColor3 = CFG.BG_HOLO; f.Active = true; f.Draggable = true
local stroke = Instance.new("UIStroke", f); stroke.Name = "BotStroke"; stroke.Color = CFG.OFF_COLOR; stroke.Thickness = 2; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel", f); title.Size = UDim2.new(1, -100, 0, 40); title.Position = UDim2.new(0, 15, 0, 0); title.TextXAlignment = Enum.TextXAlignment.Left; title.Text = L.title; title.TextColor3 = CFG.OFF_COLOR; title.TextSize = 14; title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1
local status = Instance.new("TextLabel", f); status.Size = UDim2.new(1, -20, 0, 30); status.Position = UDim2.new(0, 15, 0, 35); status.TextXAlignment = Enum.TextXAlignment.Left; status.BackgroundTransparency = 1; status.Font = Enum.Font.Code; status.TextSize = 18; status.RichText = true 
local pBarBg = Instance.new("Frame", f); pBarBg.Size = UDim2.new(1, -40, 0, 6); pBarBg.Position = UDim2.new(0, 20, 0, 70); pBarBg.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05); pBarBg.BorderSizePixel = 0
local pBar = Instance.new("Frame", pBarBg); pBar.Size = UDim2.new(0, 0, 1, 0); pBar.BackgroundColor3 = CFG.OFF_COLOR; pBar.BorderSizePixel = 0
local pText = Instance.new("TextLabel", f); pText.Size = UDim2.new(1, -20, 0, 25); pText.Position = UDim2.new(0, 15, 0, 80); pText.TextXAlignment = Enum.TextXAlignment.Left; pText.Text = L.standby; pText.TextColor3 = CFG.OFF_COLOR; pText.TextSize = 13; pText.Font = Enum.Font.Code; pText.BackgroundTransparency = 1

local taskBtn = Instance.new("TextButton", f); taskBtn.Size = UDim2.new(1, -40, 0, 32); taskBtn.Position = UDim2.new(0, 20, 0, 110); taskBtn.Text = L.taskCombat; taskBtn.TextColor3 = Color3.new(1,1,1); taskBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); taskBtn.Font = Enum.Font.GothamBold; taskBtn.TextSize = 13; Instance.new("UICorner", taskBtn).CornerRadius = UDim.new(0, 4)
local predBtn = Instance.new("TextButton", f); predBtn.Size = UDim2.new(1, -40, 0, 32); predBtn.Position = UDim2.new(0, 20, 0, 150); predBtn.Text = L.predOff; predBtn.TextColor3 = Color3.new(1,1,1); predBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); predBtn.Font = Enum.Font.Code; predBtn.TextSize = 13; Instance.new("UICorner", predBtn).CornerRadius = UDim.new(0, 4)
local vipLabel = Instance.new("TextLabel", f); vipLabel.Size = UDim2.new(1, -20, 0, 25); vipLabel.Position = UDim2.new(0, 15, 0, 190); vipLabel.TextXAlignment = Enum.TextXAlignment.Left; vipLabel.BackgroundTransparency = 1; vipLabel.Font = Enum.Font.GothamBold; vipLabel.TextSize = 12; vipLabel.Text = L.vipNone; vipLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
local infoBox = Instance.new("TextLabel", f); infoBox.Size = UDim2.new(1, -20, 0, 45); infoBox.Position = UDim2.new(0, 10, 0, 220); infoBox.BackgroundTransparency = 1; infoBox.TextColor3 = Color3.fromRGB(180, 180, 180); infoBox.TextSize = 11; infoBox.Font = Enum.Font.Code; infoBox.Text = L.info; infoBox.TextWrapped = true

local closeBtn = Instance.new("TextButton", f); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 50); closeBtn.Font = Enum.Font.Code; closeBtn.TextSize = 18; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
local langBtn = Instance.new("TextButton", f); langBtn.Size = UDim2.new(0, 50, 0, 30); langBtn.Position = UDim2.new(1, -90, 0, 5); langBtn.Text = L.flag; langBtn.TextColor3 = Color3.new(1,1,1); langBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); langBtn.Font = Enum.Font.GothamBold; langBtn.TextSize = 12; Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 4)

-- 🔄 SYSTEME DE MISE A JOUR UI
local function refreshUITexts()
    title.Text = L.title
    langBtn.Text = L.flag
    infoBox.Text = L.info
    if not botActive then pText.Text = L.standby end
    taskBtn.Text = (currentTask == "COMBAT") and L.taskCombat or L.taskLoot
    predBtn.Text = predatorMode and L.predOn or L.predOff
end

local function updateStatusUI()
    local themeColor = botActive and CFG.NEON_CORE or CFG.OFF_COLOR
    stroke.Color = themeColor
    title.TextColor3 = themeColor; pText.TextColor3 = themeColor; pBar.BackgroundColor3 = themeColor
    local sCol = botActive and "rgb(0, 255, 255)" or "rgb(255, 30, 60)"
    local mCol = (currentMode == "PVP") and "rgb(255, 255, 0)" or "rgb(100, 255, 100)"
    status.Text = string.format("<b><font color='%s'>%s</font></b> | <b><font color='%s'>%s</font></b>", sCol, botActive and L.statusOn or L.statusOff, mCol, currentMode)
end

langBtn.MouseButton1Click:Connect(function()
    currentLangIndex = (currentLangIndex % #langOrder) + 1
    L = LANGUAGES[langOrder[currentLangIndex]]
    refreshUITexts(); updateStatusUI()
end)

-- 👑 SCANNER COURONNE
local function getCrownHolder()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local has = false
            if p:FindFirstChild("Backpack") then
                for _, item in ipairs(p.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (string.find(string.lower(item.Name), "baron") or string.find(string.lower(item.Name), "crown")) then has = true break end
                end
            end
            if not has then
                for _, item in ipairs(p.Character:GetChildren()) do
                    if item:IsA("Tool") and (string.find(string.lower(item.Name), "baron") or string.find(string.lower(item.Name), "crown")) then has = true break end
                end
            end
            if has then return p.Character.HumanoidRootPart end
        end
    end
    return nil
end

-- ⚔️ CIBLAGE
local function getTargets(t)
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local rootPos = char.HumanoidRootPart.Position
    if t - lastNemesysScan > CFG.NEMESYS_SCAN_RATE then
        nemesysPlayers = {} 
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Health > 0 and v.Parent ~= char then if isRedThreat(v.Parent) then table.insert(nemesysPlayers, v.Parent) end end
        end; lastNemesysScan = t
    end
    local nems_p, pvps, mobs = {}, {}, {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= char and v.Health > 0 then
            local hrp = v.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - rootPos).Magnitude
                if d <= CFG.MAX_VIS_DIST then
                    local isP = Players:GetPlayerFromCharacter(v.Parent)
                    if table.find(nemesysPlayers, v.Parent) then table.insert(nems_p, {hrp = hrp, dist = d})
                    elseif isP and currentMode == "PVP" then table.insert(pvps, {hrp = hrp, dist = d})
                    elseif not isP and currentMode == "PVE" then table.insert(mobs, {hrp = hrp, dist = d}) end
                end
            end
        end
    end
    local function sortT(tab) if #tab > 0 then table.sort(tab, function(a, b) return a.dist < b.dist end) return tab[1].hrp end return nil end
    return sortT(nems_p) or sortT(pvps) or sortT(mobs)
end

-- 🏃 BOUCLE PRINCIPALE
RunService.RenderStepped:Connect(function()
    if not botActive then return end
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then StopAllInputs(); return end
    local t = tick()

    -- VIP RADAR
    if t - vipCheckTimer > 1.0 then
        vipCheckTimer = t
        local vHrp = getCrownHolder()
        if vHrp then vipLabel.Text = L.vipFound .. string.upper(vHrp.Parent.Name); vipLabel.TextColor3 = Color3.new(1, 0.84, 0)
        else vipLabel.Text = L.vipNone; vipLabel.TextColor3 = Color3.fromRGB(100, 100, 100) end
    end

    -- SURVIE
    local hpPct = (hum.Health / hum.MaxHealth) * 100
    if hpPct <= ((currentMode == "PVP") and CFG.PVP_HEAL_PCT or CFG.PVE_HEAL_PCT) and (t - lastPanic > CFG.HEAL_COOLDOWN) then
        lastPanic = t; executeHitAndRun(); return
    end

    if currentTask == "COMBAT" then
        if (t - lastScan) > CFG.SCAN_RATE then cachedTarget = getTargets(t); lastScan = t end
        if cachedTarget then
            local targetDist = (cachedTarget.Position - root.Position).Magnitude
            pText.Text = L.killRedP
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, cachedTarget.Position + (cachedTarget.AssemblyLinearVelocity * CFG.PREDICTION_PVP) + CFG.AIM_OFFSET), 0.7)
            if targetDist > CFG.PVP_ORBIT_MAX then SetKey(KEY_Z, true) else SetKey(KEY_Z, false) end
            
            -- GATLING GUN SPAM
            if t - lastSpell > CFG.SPELL_COOLDOWN then
                local spellPool = {SPELL_1, SPELL_2, SPELL_Z, SPELL_C, SPELL_V, SPELL_X}
                currentSpellIndex = (currentSpellIndex % #spellPool) + 1
                TapKey(spellPool[currentSpellIndex]); lastSpell = t
            end
        else pText.Text = L.searchEnemies end
    elseif currentTask == "LOOT" then
        local vHrp = getCrownHolder()
        if vHrp then
            local d = (vHrp.Position - root.Position).Magnitude
            if d > CFG.FOLLOW_DIST then
                camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, vHrp.Position), 0.15)
                SetKey(KEY_Z, true)
                root.CFrame = root.CFrame + ((Vector3.new(vHrp.Position.X, root.Position.Y, vHrp.Position.Z) - root.Position).Unit * CFG.BARON_SPEED_HACK)
                pText.Text = "👑 VIP LEECH..."
            else StopMovementInputs(); pText.Text = "🛡️ PROTECTING VIP." end
        else pText.Text = L.searchLoot end
    end
end)

closeBtn.MouseButton1Click:Connect(function() sg:Destroy() running = false StopAllInputs() end)
taskBtn.MouseButton1Click:Connect(toggleTask)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == MASTER_KEY then botActive = not botActive; StopAllInputs(); updateStatusUI()
    elseif input.KeyCode == TASK_KEY then toggleTask() end
end)

updateStatusUI(); refreshUITexts()
