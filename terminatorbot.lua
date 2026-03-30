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

-- ⚙️ CONFIGURATION NOX TERMINATOR V176 (BASE V170)
local CFG = {
    AIM_OFFSET = Vector3.new(0, -1.5, 0), 
    
    PREDICTION_PVP = 0.065,
    PREDICTION_PVE = 0.04,
    
    PVE_ORBIT_MIN = 16,    
    PVE_ORBIT_MAX = 23,   
    PVP_ORBIT_MIN = 22,   
    PVP_ORBIT_MAX = 33,
    
    MAX_VIS_DIST = 200,   -- Gardé à 200 pour la stabilité du combat
    GAP_CLOSE_DIST = 35,  
    
    PVP_HEAL_PCT = 80,     
    PVE_HEAL_PCT = 80,     
    PANIC_BURST = 20,      
    HEAL_COOLDOWN = 4.0,   
    PHASE_HEAL_DIST = 15,  
    
    DASH_COOLDOWN = 2.5,   
    PREDATOR_SPEED = 0.45, 
    PHASE_DISTANCE = 3,     
    AUTO_PHASE_STUCK = 12,  
    
    NEMESYS_SCAN_RATE = 1.0,
    SPELL_COOLDOWN = 0.1, 
    M1_COOLDOWN = 0.1,     
    
    LOOT_RADIUS = 350,     -- Monté à 350 pour voir les coffres de loin
    SCAN_RATE = 0.15,      
    FOLLOW_DIST = 1.5, 
    LOOT_SPEED_HACK = 1.5, 
    BARON_SPEED_HACK = 1.3, 
    
    NEON_CORE = Color3.fromRGB(0, 255, 255), 
    OFF_COLOR = Color3.fromRGB(255, 30, 60), 
    BG_HOLO = Color3.fromRGB(12, 12, 16), 
    PURPLE_PHASE = Color3.fromRGB(150, 0, 255)
}

-- 🌍 DICTIONNAIRE MULTILINGUE
local LANGUAGES = {
    FR = {
        title = "BOT TERMINATOR NOX", flag = "🇫🇷 FR", standby = "EN ATTENTE...", taskCombat = "⚔️ CIBLE : COMBAT [CAPS]", taskLoot = "💰 CIBLE : LOOT ET COURONNE [CAPS]",
        predOn = "⚡ PREDATOR [ON] ⚡", predOff = "MOBILITÉ PREDATOR [OFF] (P)", vipNone = "👑 COURONNE : NON DÉTECTÉE", vipFound = "👑 DÉTECTÉE : ",
        info = "[ALT] POWER | [MOLETTE] PVP/PVE\n[CAPS] MODE | [P] PREDATOR | [J] MASQUER UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WALLHACK)...", searchEnemies = "🤖 RECHERCHE D'ENNEMIS...", killRedP = "⚠️ KILLING RED PLAYER !",
        killRedM = "⚠️ KILLING RED MOB !", killTarget = "⚔️ EXTERMINATION EN COURS...", vipLeech = "👑 VIP LEECH ACTIVE...", protectVip = "🛡️ PROTECTION VIP.",
        searchLoot = "🤖 RECHERCHE LOOT ET COURONNE...", securingChest = "💰 OUVERTURE DU COFFRE..."
    },
    EN = {
        title = "NOX TERMINATOR BOT", flag = "🇬🇧 EN", standby = "SYSTEM STANDBY...", taskCombat = "⚔️ TARGET: COMBAT [CAPS]", taskLoot = "💰 TARGET: LOOT & CROWN [CAPS]",
        predOn = "⚡ PREDATOR [ON] ⚡", predOff = "PREDATOR MOBILITY [OFF] (P)", vipNone = "👑 CROWN: NOT DETECTED", vipFound = "👑 DETECTED: ",
        info = "[ALT] POWER | [WHEEL] PVP/PVE\n[CAPS] MODE | [P] PREDATOR | [J] HIDE UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WALLHACK)...", searchEnemies = "🤖 SEARCHING ENEMIES...", killRedP = "⚠️ KILLING RED PLAYER !",
        killRedM = "⚠️ KILLING RED MOB !", killTarget = "⚔️ FOCUSED EXTERMINATION...", vipLeech = "👑 VIP LEECH ACTIVE...", protectVip = "🛡️ PROTECTING VIP.",
        searchLoot = "🤖 SEARCHING LOOT & CROWN...", securingChest = "💰 SECURING CHEST..."
    },
    DE = {
        title = "NOX TERMINATOR BOT", flag = "🇩🇪 DE", standby = "SYSTEM BEREIT...", taskCombat = "⚔️ ZIEL: KAMPF [CAPS]", taskLoot = "💰 ZIEL: BEUTE & KRONE [CAPS]",
        predOn = "⚡ PREDATOR [AN] ⚡", predOff = "PREDATOR BEWEGUNG [AUS] (P)", vipNone = "👑 KRONE: NICHT GEFUNDEN", vipFound = "👑 GEFUNDEN: ",
        info = "[ALT] POWER | [MAUSRAD] PVP/PVE\n[CAPS] MODUS | [P] PREDATOR | [J] UI VERBERGEN", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (WAND)...", searchEnemies = "🤖 SUCHE FEINDE...", killRedP = "⚠️ TÖTE ROTEN SPIELER !",
        killRedM = "⚠️ TÖTE ROTEN MOB !", killTarget = "⚔️ FOKUSSIERTE VERNICHTUNG...", vipLeech = "👑 VIP VERFOLGUNG AKTIV...", protectVip = "🛡️ BESCHÜTZE VIP.",
        searchLoot = "🤖 SUCHE BEUTE & KRONE...", securingChest = "💰 SICHERE TRUHE..."
    },
    ES = {
        title = "BOT TERMINATOR NOX", flag = "🇪🇸 ES", standby = "SISTEMA EN ESPERA...", taskCombat = "⚔️ OBJETIVO: COMBATE [CAPS]", taskLoot = "💰 OBJETIVO: BOTÍN Y CORONA [CAPS]",
        predOn = "⚡ DEPREDADOR [ON] ⚡", predOff = "MOVILIDAD DEPREDADOR [OFF] (P)", vipNone = "👑 CORONA: NO DETECTADA", vipFound = "👑 DETECTADA: ",
        info = "[ALT] PODER | [RUEDA] PVP/PVE\n[CAPS] MODO | [P] DEPREDADOR | [J] OCULTAR UI", statusOn = "EN LÍNEA", statusOff = "DESCONECTADO",
        ghostPhase = "⚠️ GHOST-PHASE (MURO)...", searchEnemies = "🤖 BUSCANDO ENEMIGOS...", killRedP = "⚠️ ¡MATANDO JUGADOR ROJO!",
        killRedM = "⚠️ ¡MATANDO MOB ROJO!", killTarget = "⚔️ EXTERMINACIÓN ENFOCADA...", vipLeech = "👑 SEGUIMIENTO VIP ACTIVO...", protectVip = "🛡️ PROTEGIENDO VIP.",
        searchLoot = "🤖 BUSCANDO BOTÍN Y CORONA...", securingChest = "💰 ASEGURANDO COFRE..."
    },
    IT = {
        title = "BOT TERMINATOR NOX", flag = "🇮🇹 IT", standby = "SISTEMA IN ATTESA...", taskCombat = "⚔️ BERSAGLIO: COMBAT [CAPS]", taskLoot = "💰 BERSAGLIO: BOTTINO E CORONA [CAPS]",
        predOn = "⚡ PREDATORE [ON] ⚡", predOff = "MOBILITÀ PREDATORE [OFF] (P)", vipNone = "👑 CORONA: NON RILEVATA", vipFound = "👑 RILEVATA: ",
        info = "[ALT] ACCENDI | [ROTELLA] PVP/PVE\n[CAPS] MODALITÀ | [P] PREDATORE | [J] NASCONDI UI", statusOn = "ONLINE", statusOff = "OFFLINE",
        ghostPhase = "⚠️ GHOST-PHASE (MURO)...", searchEnemies = "🤖 RICERCA NEMICI...", killRedP = "⚠️ UCCIDENDO GIOCATORE ROSSO!",
        killRedM = "⚠️ UCCIDENDO MOB ROSSO!", killTarget = "⚔️ STERMINIO MIRATO...", vipLeech = "👑 INSEGUIMENTO VIP ATTIVO...", protectVip = "🛡️ PROTEGGENDO VIP.",
        searchLoot = "🤖 RICERCA BOTTINO E CORONA...", securingChest = "💰 METTENDO AL SICURO CESTA..."
    }
}
local langOrder = {"FR", "EN", "DE", "ES", "IT"}
local currentLangIndex = 1
local L = LANGUAGES[langOrder[currentLangIndex]]

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

local function executePhaseStep(distance)
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = root.CFrame + (root.CFrame.LookVector * (distance or CFG.PHASE_DISTANCE)) end
end

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

-- 🖥️ UI REDESIGN
local sg = Instance.new("ScreenGui", player.PlayerGui); sg.Name = "NOX_TERMINATOR"; sg.ResetOnSpawn = false
local f = Instance.new("Frame", sg); f.Size = UDim2.new(0, 310, 0, 280); f.Position = UDim2.new(0.05, 0, 0.4, 0); f.BackgroundColor3 = CFG.BG_HOLO; f.Active = true; f.Draggable = true
local stroke = Instance.new("UIStroke", f); stroke.Name = "BotStroke"; stroke.Color = CFG.OFF_COLOR; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

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
    if f:FindFirstChild("BotStroke") then f.BotStroke.Color = themeColor end
    title.TextColor3 = themeColor; pText.TextColor3 = themeColor; pBar.BackgroundColor3 = themeColor
    local sCol = botActive and "rgb(0, 255, 255)" or "rgb(255, 30, 60)"
    local mCol = (currentMode == "PVP") and "rgb(255, 255, 0)" or "rgb(100, 255, 100)"
    status.Text = string.format("<b><font color='%s'>%s</font></b> | <b><font color='%s'>%s</font></b>", sCol, botActive and L.statusOn or L.statusOff, mCol, currentMode)
end
updateStatusUI()

langBtn.MouseButton1Click:Connect(function()
    currentLangIndex = (currentLangIndex % #langOrder) + 1
    L = LANGUAGES[langOrder[currentLangIndex]]
    refreshUITexts()
    updateStatusUI()
end)

local function toggleTask()
    StopAllInputs(); currentLootAttempt = nil; currentLootTarget = nil; isSecuringLoot = false; lockedTarget = nil
    currentTask = (currentTask == "COMBAT") and "LOOT" or "COMBAT"
    taskBtn.Text = currentTask == "COMBAT" and L.taskCombat or L.taskLoot
    taskBtn.BackgroundColor3 = currentTask == "COMBAT" and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
end
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() running = false StopAllInputs() end)
taskBtn.MouseButton1Click:Connect(toggleTask)

local uiVisible = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.J then uiVisible = not uiVisible; f.Visible = uiVisible
    elseif input.KeyCode == MASTER_KEY then botActive = not botActive; StopAllInputs(); if not botActive then pText.Text = L.standby; pBar.BackgroundColor3 = CFG.OFF_COLOR end; updateStatusUI()
    elseif input.KeyCode == TASK_KEY then toggleTask() 
    elseif input.KeyCode == PHASE_KEY then executePhaseStep(CFG.PHASE_DISTANCE)
    elseif input.KeyCode == PREDATOR_KEY then predatorMode = not predatorMode; predBtn.Text = predatorMode and L.predOn or L.predOff; predBtn.BackgroundColor3 = predatorMode and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(30, 30, 30)
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then currentMode = (currentMode == "PVP") and "PVE" or "PVP"; lockedTarget = nil; updateStatusUI() end
end)

local function isRedThreat(character)
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("BillboardGui") then
            for _, sub in ipairs(desc:GetDescendants()) do
                if sub:IsA("ImageLabel") and sub.Visible then local c = sub.ImageColor3; if c.R > c.G + 0.3 and c.R > c.B + 0.3 then return true end
                elseif sub:IsA("TextLabel") and sub.Visible then local c = sub.TextColor3; if c.R > c.G + 0.3 and c.R > c.B + 0.3 then return true end end
            end
        end
    end
    return false
end

local function getCrownHolder()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hasBaron = false
            if p:FindFirstChild("Backpack") then
                for _, item in ipairs(p.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        local iName = string.lower(item.Name)
                        if string.find(iName, "baron") or string.find(iName, "crown") or string.find(iName, "couronne") then hasBaron = true; break end
                    end
                end
            end
            if not hasBaron then
                for _, item in ipairs(p.Character:GetChildren()) do
                    if item:IsA("Tool") then
                        local iName = string.lower(item.Name)
                        if string.find(iName, "baron") or string.find(iName, "crown") or string.find(iName, "couronne") then hasBaron = true; break end
                    end
                end
            end
            if not hasBaron then
                for _, desc in ipairs(p.Character:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text then
                        local txt = string.lower(desc.Text)
                        if string.match(txt, "baron") or string.find(txt, "crown") or string.find(txt, "couronne") then hasBaron = true; break end
                    end
                end
            end
            if hasBaron then return p.Character.HumanoidRootPart end
        end
    end
    return nil
end

local function getTargets(t)
    local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local rootPos = char.HumanoidRootPart.Position
    
    if t - lastNemesysScan > CFG.NEMESYS_SCAN_RATE then
        nemesysPlayers = {} 
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Humanoid") and v.Health > 0 and v.Parent ~= char then if isRedThreat(v.Parent) then table.insert(nemesysPlayers, v.Parent) end end
        end; lastNemesysScan = t
    end
    
    local currentLockValid = false; local currentLockTier = 4
    if lockedTarget and typeof(lockedTarget) == "Instance" and lockedTarget:IsDescendantOf(workspace) and lockedTarget.Parent and lockedTarget.Parent:FindFirstChild("Humanoid") and lockedTarget.Parent.Humanoid.Health > 0 then
        if (lockedTarget.Position - rootPos).Magnitude <= CFG.MAX_VIS_DIST then
            currentLockValid = true
            local p = lockedTarget.Parent
            if table.find(nemesysPlayers, p) then if Players:GetPlayerFromCharacter(p) then currentLockTier = 1 else currentLockTier = 2 end else currentLockTier = 3 end
        end
    end
    
    local nems_p, nems_m, pvps, mobs = {}, {}, {}, {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= char and v.Health > 0 then
            local hrp = v.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                local isForbidden = false
                local pName = string.lower(v.Parent.Name)
                
                local bannedNames = {"rylock", "edwin", "james", "shaman", "merchant_wizard", "pnj", "npc", "merchant", "marchand", "shop", "boutique", "shamen", "guild", "sorcier", "collectionneur"}
                for _, bN in ipairs(bannedNames) do if string.find(pName, bN) then isForbidden = true; break end end

                if not isForbidden then for _, desc in ipairs(v.Parent:GetDescendants()) do if desc:IsA("ProximityPrompt") then isForbidden = true; break end end end
                if not isForbidden then
                    local currentObj = v.Parent
                    while currentObj and currentObj ~= workspace do 
                        local objN = string.lower(currentObj.Name)
                        if string.find(objN, "capturedai") or string.find(objN, "banditwagon") then isForbidden = true; break end
                        currentObj = currentObj.Parent 
                    end
                end
                
                if not isForbidden then
                    local d = (hrp.Position - rootPos).Magnitude
                    if d <= CFG.MAX_VIS_DIST then
                        local isP = Players:GetPlayerFromCharacter(v.Parent)
                        local isRed = table.find(nemesysPlayers, v.Parent)
                        
                        if isRed and isP then table.insert(nems_p, {hrp = hrp, dist = d})
                        elseif isRed and not isP then table.insert(nems_m, {hrp = hrp, dist = d})
                        elseif isP and currentMode == "PVP" then table.insert(pvps, {hrp = hrp, dist = d})
                        elseif not isP and currentMode == "PVE" then table.insert(mobs, {hrp = hrp, dist = d})
                        end
                    end
                end
            end
        end
    end
    
    local function sortT(tab) if #tab > 0 then table.sort(tab, function(a, b) return a.dist < b.dist end) return tab[1].hrp end return nil end
    local closestRedPlayer = sortT(nems_p)
    local closestRedMob = sortT(nems_m)
    
    if closestRedPlayer and currentLockTier > 1 then lockedTarget = closestRedPlayer; return lockedTarget end
    if closestRedMob and currentLockTier > 2 then lockedTarget = closestRedMob; return lockedTarget end
    
    if currentLockValid then return lockedTarget end
    lockedTarget = closestRedPlayer or closestRedMob or sortT(pvps) or sortT(mobs)
    return lockedTarget
end

local function getLoot(t)
    if typeof(currentLootAttempt) == "Instance" and currentLootAttempt:IsDescendantOf(workspace) and currentLootAttempt.Enabled then
        if not blacklistedLoot[currentLootAttempt] or t > blacklistedLoot[currentLootAttempt] then return currentLootAttempt end
    end
    
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local closest, dist = nil, CFG.LOOT_RADIUS
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            if not blacklistedLoot[v] or t > blacklistedLoot[v] then
                local isBad = false
                local currentObj = v.Parent
                
                while currentObj and currentObj ~= workspace do
                    local objN = string.lower(currentObj.Name)
                    if currentObj:FindFirstChildOfClass("Humanoid") or string.find(objN, "banditwagon") then isBad = true; break end
                    currentObj = currentObj.Parent
                end
                
                if not isBad then
                    local pos = nil
                    pcall(function() pos = v.Parent:IsA("Attachment") and v.Parent.WorldPosition or v.Parent:GetPivot().Position end)
                    
                    if pos then
                        local pName = string.lower(v.Parent.Name)
                        local penalty = 0
                        if string.find(pName, "wagon") or string.find(pName, "cart") then penalty = 150 end
                        
                        local d = (pos - root.Position).Magnitude + penalty
                        if d < dist then dist = d; closest = v end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not botActive then return end
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    
    if not root or not hum or hum.Health <= 0 then StopAllInputs(); isPanicking, isSecuringLoot, lockedTarget, currentLootAttempt = false, false, nil, nil; return end
    local t = tick()
    
    if t - vipCheckTimer > 1.0 then
        vipCheckTimer = t
        local vipHrp = getCrownHolder()
        if vipHrp and vipHrp.Parent then
            local pName = vipHrp.Parent.Name
            vipLabel.Text = L.vipFound .. string.upper(pName)
            vipLabel.TextColor3 = Color3.new(1, 0.84, 0)
        else
            vipLabel.Text = L.vipNone
            vipLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        end
    end

    if isPanicking then return end
    
    local canPhase = false
    if currentTask == "LOOT" then 
        canPhase = true 
    elseif currentTask == "COMBAT" and lockedTarget then
        if (lockedTarget.Position - root.Position).Magnitude > 20 then canPhase = true end
    end
    
    if canPhase and (t - lastStuckCheck) > 0.75 then
        if (KeysHeld[KEY_Z] or KeysHeld[KEY_S] or KeysHeld[KEY_Q] or KeysHeld[KEY_D]) then 
            if (root.Position - lastPosRecord).Magnitude < 2.5 then 
                hum.Jump = true
                local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
                root.CFrame = root.CFrame + (flatLook * CFG.AUTO_PHASE_STUCK)
                pText.Text = L.ghostPhase; pBar.BackgroundColor3 = CFG.PURPLE_PHASE
            end
        end; lastPosRecord = root.Position; lastStuckCheck = t
    end

    local curHP = hum.Health; local hpPct = (curHP / hum.MaxHealth) * 100
    
    if ((curHP - lastHealth) < -CFG.PANIC_BURST or hpPct <= ((currentMode == "PVP") and CFG.PVP_HEAL_PCT or CFG.PVE_HEAL_PCT)) and (t - lastPanic > CFG.HEAL_COOLDOWN) then
        lastPanic = t; currentLootAttempt, cachedLoot, lockedTarget, isSecuringLoot = nil, nil, nil, false
        executeHitAndRun(); lastHealth = curHP; return
    end; lastHealth = curHP

    if currentTask == "COMBAT" then
        if (t - lastScan) > CFG.SCAN_RATE then cachedTarget = getTargets(t); lastScan = t end
        local target = cachedTarget; local targetDist = target and (target.Position - root.Position).Magnitude or math.huge

        if not target then StopMovementInputs(); pText.Text = L.searchEnemies; pBar.BackgroundColor3 = CFG.NEON_CORE
        else
            local isRed = table.find(nemesysPlayers, target.Parent)
            local isP = Players:GetPlayerFromCharacter(target.Parent)
            
            if isRed and isP then pText.Text = L.killRedP; pBar.BackgroundColor3 = CFG.PURPLE_PHASE
            elseif isRed then pText.Text = L.killRedM; pBar.BackgroundColor3 = Color3.new(1, 0.5, 0)
            else pText.Text = L.killTarget; pBar.BackgroundColor3 = Color3.new(1, 0, 0) end
            
            local cMin = (currentMode == "PVP" or isRed) and CFG.PVP_ORBIT_MIN or CFG.PVE_ORBIT_MIN
            local cMax = (currentMode == "PVP" or isRed) and CFG.PVP_ORBIT_MAX or CFG.PVE_ORBIT_MAX
            
            local curPred = (isP or isRed) and CFG.PREDICTION_PVP or CFG.PREDICTION_PVE
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position + (target.AssemblyLinearVelocity * curPred) + CFG.AIM_OFFSET), 0.7) 
            
            hum.WalkSpeed = 24
            if predatorMode and hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + (hum.MoveDirection * CFG.PREDATOR_SPEED) end
            
            if targetDist > cMax then SetKey(KEY_S, false); SetKey(KEY_Z, true) 
                if hpPct > 50 and targetDist > CFG.GAP_CLOSE_DIST and t - lastOffensiveDash > CFG.DASH_COOLDOWN then SetKey(KEY_Z, true); TapKey(KEY_DASH); lastOffensiveDash = t end
            elseif targetDist < cMin then SetKey(KEY_Z, false); SetKey(KEY_S, true) 
            else SetKey(KEY_Z, false); SetKey(KEY_S, false) end
            
            SetKey(sideKey, true); if t - lastStrafeSwitch > 1.2 then SetKey(sideKey, false); sideKey = (sideKey == KEY_Q) and KEY_D or KEY_Q; lastStrafeSwitch = t end
            if math.random(1, 100) <= 12 then hum.Jump = true end
            
            local attackRange = (isP or isRed) and 150 or 60
            
            if targetDist <= attackRange then
                if t - lastM1 > CFG.M1_COOLDOWN then lastM1 = t; VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1); task.delay(0.05, function() VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1) end) end
                
                if t - lastSpell > CFG.SPELL_COOLDOWN then 
                    local spellPool = {SPELL_1, SPELL_2, SPELL_Z, SPELL_C, SPELL_V} 
                    if currentMode == "PVP" or isRed or isP then 
                        table.insert(spellPool, SPELL_X) 
                    end
                    
                    currentSpellIndex = currentSpellIndex + 1
                    if currentSpellIndex > #spellPool then currentSpellIndex = 1 end
                    
                    TapKey(spellPool[currentSpellIndex])
                    lastSpell = t 
                end
            end
        end

    elseif currentTask == "LOOT" then
        if cachedLoot then
            local isInvalid = typeof(cachedLoot) ~= "Instance" or not cachedLoot:IsDescendantOf(workspace) or not cachedLoot.Enabled
            local isBlacklisted = blacklistedLoot[cachedLoot] and t < blacklistedLoot[cachedLoot]
            if isInvalid or isBlacklisted then cachedLoot, isSecuringLoot = nil, false; SetKey(INTERACT_KEY, false) end
        end

        if (t - lastScan) > CFG.SCAN_RATE then if not cachedLoot then cachedLoot = getLoot(t) end; lastScan = t end
        local loot = cachedLoot
        
        if not loot then 
            local crownHolder = getCrownHolder()
            if crownHolder then
                isSecuringLoot = false; SetKey(INTERACT_KEY, false)
                local hPos = crownHolder.Position
                local dH = (hPos - root.Position).Magnitude
                
                if dH > CFG.FOLLOW_DIST then
                    hum.WalkSpeed = 24
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, hPos), 0.15)
                    SetKey(KEY_Z, true)
                    
                    -- 🛡️ ANTI-ROLLBACK COURONNE (Si < 120m, on speedhack)
                    if dH < 120 then
                        local flatDir = (Vector3.new(hPos.X, root.Position.Y, hPos.Z) - root.Position).Unit
                        root.CFrame = root.CFrame + (flatDir * CFG.BARON_SPEED_HACK)
                    end
                    
                    pText.Text = L.vipLeech; pBar.BackgroundColor3 = Color3.new(1, 0.84, 0)
                    if math.random(1, 25) == 1 then hum.Jump = true end
                else
                    StopMovementInputs()
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, hPos), 0.15)
                    pText.Text = L.protectVip; pBar.BackgroundColor3 = Color3.new(1, 0.84, 0)
                end
            else
                isSecuringLoot = false; SetKey(INTERACT_KEY, false); StopMovementInputs(); pText.Text = L.searchLoot; pBar.BackgroundColor3 = Color3.new(0, 0.8, 0)
            end
        else
            pcall(function() loot.RequiresLineOfSight = false end)
            if loot ~= currentLootTarget then currentLootTarget = loot; lootTravelTimer = t end
            
            local lootPos = nil
            pcall(function() lootPos = loot.Parent:IsA("Attachment") and loot.Parent.WorldPosition or loot.Parent:GetPivot().Position end)
            
            if not lootPos then cachedLoot = nil; return end
            
            local actDist = math.max((loot.MaxActivationDistance or 5) * 0.85, 3.5)
            local dL = (lootPos - root.Position).Magnitude
            
            if dL > actDist then 
                if t - lootTravelTimer > 25.0 then
                    blacklistedLoot[loot] = t + 300.0; currentLootAttempt, cachedLoot, currentLootTarget, isSecuringLoot = nil, nil, nil, false
                    SetKey(INTERACT_KEY, false); return
                end
                
                isSecuringLoot = false; hum.WalkSpeed = 24; camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, lootPos), 0.15); SetKey(KEY_Z, true); SetKey(INTERACT_KEY, false) 
                
                if dL > 8 then 
                    local flatDir = (Vector3.new(lootPos.X, root.Position.Y, lootPos.Z) - root.Position).Unit
                    root.CFrame = root.CFrame + (flatDir * CFG.LOOT_SPEED_HACK)
                end
                
                if math.random(1, 25) == 1 then hum.Jump = true end
            else
                if not isSecuringLoot then 
                    isSecuringLoot = true; currentLootAttempt = loot; lootAttemptTimer = t; StopMovementInputs(); hum.WalkSpeed = 0; root.AssemblyLinearVelocity = Vector3.zero; 
                    task.spawn(function() task.wait(0.2); if isSecuringLoot then SetKey(INTERACT_KEY, true) end end)
                elseif t - lootAttemptTimer > 15.0 then 
                    blacklistedLoot[loot] = t + 300.0; currentLootAttempt, cachedLoot, currentLootTarget, isSecuringLoot = nil, nil, nil, false; SetKey(INTERACT_KEY, false); return 
                end
                
                StopMovementInputs(); hum.WalkSpeed = 0; camera.CFrame = CFrame.lookAt(camera.CFrame.Position, lootPos); pText.Text = L.securingChest; pBar.BackgroundColor3 = Color3.new(1, 0.8, 0)
                if fireproximityprompt and (t - lastPromptFire > 0.4) then pcall(function() fireproximityprompt(loot) end); lastPromptFire = t end
            end
        end
    end
end)
