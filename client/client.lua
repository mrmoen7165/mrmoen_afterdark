local RSGCore = exports['rsg-core']:GetCoreObject()
Config = Config or {}
Config.NightStart    = tonumber(Config.NightStart) or 22
Config.NightEnd      = tonumber(Config.NightEnd)   or 4
Config.CheckInterval = tonumber(Config.CheckInterval) or 1000
Config.SoundRange    = tonumber(Config.SoundRange) or 25.0
Config.SoundVolume   = tonumber(Config.SoundVolume) or 0.4

local locale = Locales and Locales[Config.Locale] or {}

--------------------------------------------------------
--  HJELPEFUNKSJONER
--------------------------------------------------------
local function debugPrint(msg)
    if Config.Debug then
        print(('[^3AFTERDARK DEBUG^7] %s'):format(msg))
    end
end

local function isNightTime()
    local h = GetClockHours()
    local hour = (type(h) == "number" and h or 12)
    local ns = tonumber(Config.NightStart) or 22
    local ne = tonumber(Config.NightEnd) or 4
    return (hour >= ns or hour < ne)
end

local function notify(data)
    if exports['ox_lib'] and exports['ox_lib'].notify then
        exports['ox_lib']:notify(data)
    else
        local msg = type(data) == "table" and (data.description or data.title) or tostring(data)
        TriggerEvent('chat:addMessage', { color = {255, 200, 0}, args = {'Afterdark', msg} })
    end
end

local function playSound(sound)
    if not sound or sound == "" then return end
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance",
        Config.SoundRange, sound, Config.SoundVolume)
end

--------------------------------------------------------
--  GHOST / FADE-IN / FADE-OUT
--------------------------------------------------------
local function spawnGhost(model, coords)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local ped = CreatePed(hash, coords.x, coords.y, coords.z - 1.0, 0.0, false, false, 0, 0)
    if not DoesEntityExist(ped) then
        ped = Citizen.InvokeNative(0xD49F9B0955C367DE, hash,
            coords.x, coords.y, coords.z - 1.0, math.random(0, 360),
            true, false, 0, 0, 0)
    end
    if not DoesEntityExist(ped) then
        debugPrint("FEIL: kunne ikke lage ghost-ped"); return
    end

    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
    PlaceEntityOnGroundProperly(ped, true)
    SetPedRandomComponentVariation(ped, 0)
    SetEntityVisible(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, false)
    SetPedCanRagdoll(ped, false)
    SetEntityAlpha(ped, 0, false)

    for a = 0, 160, 20 do
        SetEntityAlpha(ped, a, false)
        Wait(100)
    end
    TaskGoToEntity(ped, PlayerPedId(), -1, 1.5, 0.3, 0, 0)
    Wait(Config.GhostLifetime or 10000)
    for a = 160, 0, -20 do
        SetEntityAlpha(ped, a, false)
        Wait(100)
    end
    DeleteEntity(ped)
end

--------------------------------------------------------
--  PRESTER
--------------------------------------------------------
CreateThread(function()
    local priestData, shown = {}, {}
    for i,_ in ipairs(Config.Priests or {}) do
        priestData[i] = { ped=nil, active=false }
        shown[i] = false
    end

    while true do
        Wait(1000)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local night  = isNightTime()
        local day    = not night

        for i,priest in ipairs(Config.Priests or {}) do
            local d = priestData[i]
            local c = priest.coords
            local dist = #(coords - vector3(c.x,c.y,c.z))

            -- spawn prest ved natt
            if night and not d.active then
                local m = GetHashKey(priest.model)
                RequestModel(m)
                while not HasModelLoaded(m) do Wait(10) end
                local ped = CreatePed(m, c.x, c.y, c.z - 1.0, c.w, false,false,0,0)
                Citizen.InvokeNative(0x283978A15512B2FE,ped,true)
                PlaceEntityOnGroundProperly(ped,true)
                SetPedRandomComponentVariation(ped,0)
                SetEntityInvincible(ped,true)
                SetBlockingOfNonTemporaryEvents(ped,true)
                SetPedCanBeTargetted(ped,false)
                FreezeEntityPosition(ped,true)
                SetEntityVisible(ped,true)
                if Config.FadeIn then
                    for a=0,255,51 do SetEntityAlpha(ped,a,false) Wait(50) end
                else SetEntityAlpha(ped,255,false) end
                d.ped = ped; d.active = true
                debugPrint(("Prest spawn: %s"):format(priest.name))
            end

            -- fjern prest ved dag
            if day and d.active then
                if DoesEntityExist(d.ped) then
                    if Config.FadeIn then
                        for a=255,0,-51 do SetEntityAlpha(d.ped,a,false) Wait(50) end
                    end
                    DeleteEntity(d.ped)
                end
                d.active=false; shown[i]=false
                debugPrint(("Prest fjernet (dag): %s"):format(priest.name))
            end

            -- interaksjon
            if night and d.active and dist < priest.radius then
                if not shown[i] then
                    shown[i]=true
                    notify(priest.notify)
                    playSound(priest.sound)
                end
            else shown[i]=false end
        end
    end
end)

--------------------------------------------------------
--  SPØKELSER
--------------------------------------------------------
CreateThread(function()
    local triggered = {}
    while true do
        Wait(Config.CheckInterval)
        local coords = GetEntityCoords(PlayerPedId())
        local night  = isNightTime()
        for i,ghost in ipairs(Config.Ghosts or {}) do
            triggered[i] = triggered[i] or false
            local dist = #(coords - ghost.coords)
            if night and dist < ghost.radius then
                if not triggered[i] then
                    triggered[i]=true
                    notify(ghost.notify)
                    playSound(ghost.sound)
                    spawnGhost(ghost.model, ghost.coords)
                end
            else
                if not night then triggered[i]=false end
            end
        end
    end
end)

--------------------------------------------------------
--  HAUNTED
--------------------------------------------------------
CreateThread(function()
    local triggered = {}
    while true do
        Wait(Config.CheckInterval)
        local coords = GetEntityCoords(PlayerPedId())
        local night  = isNightTime()
        for i,spot in ipairs(Config.Haunted or {}) do
            triggered[i] = triggered[i] or false
            local dist = #(coords - spot.coords)
            if night and dist < spot.radius then
                if not triggered[i] then
                    triggered[i]=true
                    notify(spot.notify)
                    playSound(spot.sound)
                end
            else
                if not night then triggered[i]=false end
            end
        end
    end
end)

--------------------------------------------------------
--  PEST-SYSTEM (urørt fra afterdark)
--------------------------------------------------------
if Config.Pest and Config.Pest.Active then
    local infected = false
    local function infectPlayer()
        if infected then return end
        infected = true
        debugPrint("Spilleren er nå smittet av pesten!")
        if Config.Pest.Visual then
            DoScreenFadeOut(1400); Wait(1400); DoScreenFadeIn(2000)
        end
        playSound("cough")
        notify({
            title = _U("pest.title"),
            description = _U("pest.infected"),
            type = "error",
            duration = 8000
        })
    end

    CreateThread(function()
        while true do
            Wait(Config.Pest.InfectionInterval or 30000)
            if not infected and math.random(1,100) <= (Config.Pest.InfectionChance or 15) then
                infectPlayer()
            elseif infected then
                if math.random(1,100) <= (Config.Pest.RecoveryChance or 20) then
                    infected=false
                    notify({
                        title=_U("pest.title"),
                        description=_U("pest.cured"),
                        type="success",
                        duration=6000
                    })
                elseif Config.Pest.DeathEnabled then
                    ApplyDamageToPed(PlayerPedId(),50,false)
                    debugPrint("Pest: skade påført.")
                end
            end
        end
    end)
end
