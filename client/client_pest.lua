local RSGCore = exports['rsg-core']:GetCoreObject()
local infected, infectionTimer = false, 0
local zoneCooldown, lastCough = {}, 0

--====================================================--
--  FUNKSJON: infectPlayer (med realistisk treghet)
--====================================================--
local function infectPlayer()
    if infected or not Config.Pest.Active then return end
    infected = true
    debugPrint(_U("debug.pest_active"))
    local ped = PlayerPedId()

    -- Filmisk intro
    if Config.Pest.UseVisualInfectionEffects and Config.Pest.Visual then
        local v = Config.Pest.Visual
        DoScreenFadeOut(v.FadeOutTime or 1400)
        Wait(v.FadeInDelay or 1200)

        if v.HeartbeatSound then
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, v.HeartbeatSound, 0.7)
            Wait(2800)
        end

        DoScreenFadeIn(v.FadeInTime or 1500)
        ShakeGameplayCam(v.CamShakeIntro.type or "DRUNK_SHAKE", v.CamShakeIntro.intensity or 0.25)
        Wait(1600)
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 6, Config.Sounds.pest_cough, 0.3)
    end

    -- Hindrer øyeblikkelig død ved lav helse
    SetEntityHealth(ped, math.max(GetEntityHealth(ped), 150))

    local weak = Config.Pest.Weakness or {}

    -- Redusert bevegelse
    if weak.RunSpeedMultiplier then
        Citizen.InvokeNative(0x085BF80FA50A39D1, ped, weak.RunSpeedMultiplier)
        debugPrint("[Pest] Gange-hastighet redusert til " .. weak.RunSpeedMultiplier)
    end

    if weak.MaxMoveBlend then
        SetPedMaxMoveBlendRatio(ped, weak.MaxMoveBlend)
        debugPrint("[Pest] Maks bevegelsesblend satt til " .. weak.MaxMoveBlend)
    end

    if weak.SwimSpeedMultiplier then
        Citizen.InvokeNative(0xBF9B4D6267E8C26D, ped, weak.SwimSpeedMultiplier)
    end

    if weak.FeverEffect then
        local fx = weak.FeverEffect or "RespawnPulseMPIn"
        Citizen.InvokeNative(0xCAB4DD2D5B2B7246, fx)
        Citizen.InvokeNative(0x5199405EABFBD7F0, fx, 0, true)
        debugPrint("[Pest] Feberfilter aktivert: " .. tostring(fx))
    end

    infectionTimer = GetGameTimer() + math.random(Config.Pest.SickTickMin, Config.Pest.SickTickMax)
    playNotify(Config.Pest.Notify.Infected)

    CreateThread(function()
        while infected do
            Wait(Config.Pest.HealthTickRate)
            local health = GetEntityHealth(ped)

            -- Gradvis helsetap
            if health > Config.Pest.MinHealthLimit then
                SetEntityHealth(ped, health - Config.Pest.HealthTake)
            end

            -- Tilfeldige symptomer
            if Config.Pest.UseVisualInfectionEffects and GetGameTimer() - lastCough > 6000 then
                local rnd = math.random(1, 100)

                if rnd <= 5 then
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 6, Config.Sounds.pest_cough, 0.2)
                    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)
                    lastCough = GetGameTimer()

                elseif rnd <= 13 then
                    ShakeGameplayCam("DRUNK_SHAKE", 0.2)
                    Wait(1500)

                elseif rnd <= 16 and weak.SickAnim then
                    RequestAnimDict(weak.SickAnim.Dict)
                    while not HasAnimDictLoaded(weak.SickAnim.Dict) do Wait(10) end
                    TaskPlayAnim(ped, weak.SickAnim.Dict, weak.SickAnim.Name or "idle_c",
                        4.0, -4.0, 5000, 1, 0, false, false, false)
                    Wait(5000)
                    ClearPedTasks(ped)
                end
            end

            -- Ferdig
            if GetGameTimer() > infectionTimer then
                infected = false
                local roll = math.random(1, 100)
                if roll <= (Config.Pest.DeathChance or 30) then
                    playNotify(Config.Pest.Notify.Death)
                    SetEntityHealth(ped, 0)
                else
                    local current = GetEntityHealth(ped)
                    local weakHealth = math.max(current * 0.25, 30)
                    SetEntityHealth(ped, weakHealth)
                    playNotify({
                        title = _U("pest.title"),
                        description = _U("pest.progress") .. " " .. _U("pest.zone_warning"),
                        type = "warning",
                        duration = 8000
                    })
                    ShakeGameplayCam("DRUNK_SHAKE", 0.35)
                end
                debugPrint(_U("debug.pest_inactive"))
                break
            end
        end

        -- Tilbakestill etter sykdom
        Citizen.InvokeNative(0x085BF80FA50A39D1, ped, 1.0)
        Citizen.InvokeNative(0xBF9B4D6267E8C26D, ped, 1.0)
        SetPedMaxMoveBlendRatio(ped, 1.0)

        -- Fade ut feberfilter
        if weak.FeverEffect then
            local fx = weak.FeverEffect or "RespawnPulseMPIn"
            local fadeTime = 3000
            local step = 0
            while step < fadeTime do
                Wait(100)
                step = step + 100
                ShakeGameplayCam("DRUNK_SHAKE", 0.05 - (step / fadeTime) * 0.05)
            end
            Citizen.InvokeNative(0xB4FD7446BAB2F394, fx)
            Citizen.InvokeNative(0xD2209BE128B5418C, fx)
        end
    end)
end


--====================================================--
--  FUNKSJON: curePlayer
--====================================================--
local function curePlayer()
    if not infected then return end
    debugPrint(_U("debug.pest_inactive"))
    local ped = PlayerPedId()

    local duration = (Config.Pest.CureTime or 4000) + 2000
    local halfTime = duration / 2

    if exports['ox_lib'] and exports['ox_lib'].progressCircle then
        CreateThread(function()
            exports['ox_lib']:progressCircle({
                duration = duration,
                label = _U("pest.cured"),
                position = 'bottom',
                useWhileDead = false,
                canCancel = false
            })
        end)
    else
        Wait(duration)
    end

    Wait(halfTime - 800)
    local animDict = "amb_rest_drunk@world_human_drinking@male_a@idle_a"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    local model = GetHashKey("p_bottlebeer01a")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local bottle = CreateObject(model, GetEntityCoords(ped), true, true, false)
    AttachEntityToEntity(bottle, ped, GetPedBoneIndex(ped, 57005),
        0.10, 0.02, 0.0, -90.0, 0.0, 0.0, true, true, false, true, 1, true)

    TaskPlayAnim(ped, animDict, "idle_a", 2.0, -2.0, -1, 49, 0, false, false, false)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, Config.Sounds.drink or "drink", 0.6)

    Wait(3000)
    ClearPedTasksImmediately(ped)
    if DoesEntityExist(bottle) then DeleteObject(bottle) end

    Wait(1000)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 6, Config.Sounds.pest_cough, 0.5)
    Wait(1500)
    playNotify(Config.Pest.Notify.Cured)

    SetEntityHealth(ped, GetEntityHealth(ped) + Config.Pest.CureHealthRestore)
    infected = false
    TriggerServerEvent("mrmoen_afterdark:removePestMedisin")
end


--====================================================--
--  FUNKSJON: spawnRats
--====================================================--
local function spawnRats(zone)
    local model = GetHashKey(Config.Pest.Model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    for i = 1, zone.rats or 1 do
        local offset = vector3(
            zone.coords.x + math.random(-2, 2),
            zone.coords.y + math.random(-2, 2),
            zone.coords.z
        )
        local rat = CreatePed(model, offset.x, offset.y, offset.z, 0.0, true, false, 0, 0)
        SetEntityInvincible(rat, true)
        TaskWanderStandard(rat, 10.0, 10)
    end
end


--====================================================--
--  TRÅD: Overvåker pestsoner
--====================================================--
CreateThread(function()
    while true do
        Wait(Config.CheckInterval)
        if Config.Pest.Active then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for _, zone in pairs(Config.PestZones) do
                if not zoneCooldown[zone.name] and #(coords - zone.coords) <= zone.radius then
                    playNotify(zone.notify)
                    spawnRats(zone)
                    zoneCooldown[zone.name] = true
                    if math.random(1, 100) <= Config.Pest.SpreadChance then
                        infectPlayer()
                    end
                    Wait(20000)
                    zoneCooldown[zone.name] = false
                end
            end
        end
    end
end)


--====================================================--
--  TRÅD: Spillere smitter hverandre
--====================================================--
CreateThread(function()
    while true do
        Wait(3000)
        if infected and Config.Pest.SpreadToPlayers then
            local ped = PlayerPedId()
            local myCoords = GetEntityCoords(ped)

            for _, playerId in ipairs(GetActivePlayers()) do
                if playerId ~= PlayerId() then
                    local targetPed = GetPlayerPed(playerId)
                    if DoesEntityExist(targetPed) then
                        local dist = #(myCoords - GetEntityCoords(targetPed))
                        if dist <= (Config.Pest.SpreadDistance or 5.0) then
                            if math.random(1, 100) <= (Config.Pest.SpreadChancePlayer or 25) then
                                TriggerServerEvent("mrmoen_afterdark:infectPlayer", GetPlayerServerId(playerId))
                                debugPrint("[Pest] Du smittet en annen spiller!")
                            end
                        end
                    end
                end
            end
        end
    end
end)


--====================================================--
--  EVENTS OG KOMMANDOER
--====================================================--
RegisterCommand('curepest', function()
    if infected then curePlayer() else debugPrint("No infection to cure.") end
end, false)

RegisterNetEvent('rsg:client:usePestMedisin', function()
    if infected then
        curePlayer()
    else
        playNotify({
            title = _U("pest.title"),
            description = _U("pest.cured"),
            type = "success",
            duration = 4000
        })
    end
end)

RegisterNetEvent("mrmoen_afterdark:curePlague", function()
    if not infected then
        playNotify({
            title = _U("pest.title"),
            description = "Du er allerede frisk.",
            type = "inform",
            duration = 4000
        })
        return
    end
    curePlayer()
end)

RegisterNetEvent("mrmoen_afterdark:forceInfection", function()
    if not infected and Config.Pest.Active then
        debugPrint("[Pest] Du ble smittet av en annen spiller!")
        infectPlayer()
    end
end)
