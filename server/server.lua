local RSGCore = exports['rsg-core']:GetCoreObject()

--====================================================--
--  DEBUG FUNKSJON
--====================================================--
local function debugPrint(msg)
    if Config.Debug then
        print(('[^2AFTERDARK SERVER^7] %s'):format(msg))
    end
end

--====================================================--
--  LYDHÅNDTERING
--====================================================--
-- Standard event for å spille lyd i nærheten
RegisterNetEvent('mrmoen_afterdark:playSound', function(distance, soundFile, volume)
    local src = source
    debugPrint(("Spiller lyd '%s' for spillere innen %.1fm (vol %.1f)"):format(soundFile, distance, volume))
    TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, distance or 10.0, soundFile or "default", volume or 0.5)
end)

-- Bakoverkompatibilitet med gamle systemer (hvis noe fremdeles bruker dette navnet)
RegisterNetEvent('mrmoen_whispers:playSound', function(distance, soundFile, volume)
    local src = source
    debugPrint(("Legacy lydkall (whispers) '%s' fra %s"):format(soundFile, GetPlayerName(src)))
    TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, distance or 10.0, soundFile or "default", volume or 0.5)
end)

--====================================================--
--  FREMTIDIG PEST-SYNK (plassholder)
--====================================================--
-- Her kan du senere koble inn logikk for synkronisering av peststatus mellom spillere
-- For eksempel:
-- RegisterNetEvent('mrmoen_afterdark:syncInfection', function(isInfected)
--     local src = source
--     TriggerClientEvent('mrmoen_afterdark:updateInfection', -1, src, isInfected)
-- end)

--====================================================--
--  INIT MELDING
--====================================================--
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^3[MRMOEN_AFTERDARK]^7 Servermodul lastet ✅')
end)

--====================================================--
--  BRUK AV PESTMEDISIN (RSGCore usable item)
--====================================================--
local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateUseableItem("pest_medisin", function(source)
    TriggerClientEvent("rsg:client:usePestMedisin", source)
end)

--====================================================--
--  EVENT: Fjern pest-medisin etter bruk
--====================================================--
RegisterNetEvent("mrmoen_afterdark:removePestMedisin", function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local itemName = "pest_medisin"
    local item = Player.Functions.GetItemByName(itemName)

    if item and item.amount > 0 then
        Player.Functions.RemoveItem(itemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, item, "remove")
        debugPrint(("Fjernet 1 '%s' fra %s"):format(itemName, GetPlayerName(src)))
    else
        debugPrint(("Kunne ikke finne '%s' hos spiller %s"):format(itemName, GetPlayerName(src)))
    end
end)

--====================================================--
--  VERSJONSKONTROLL
--====================================================--
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

CreateThread(function()
    Wait(3000)
    PerformHttpRequest('https://api.github.com/repos/mrmoen7165/mrmoen_afterdark/releases/latest', function(status, body)
        if status ~= 200 then
            print(('^3[AFTERDARK]^7 Kunne ikke hente versjon fra GitHub (HTTP %s)'):format(status))
            return
        end

        local data = json.decode(body)
        if not data or not data.tag_name then
            print('^1[AFTERDARK]^7 Ugyldig respons fra GitHub API.')
            return
        end

        local latest = data.tag_name:gsub("v", "")
        if latest ~= currentVersion then
            print(('^3[AFTERDARK]^7 Ny versjon tilgjengelig! ^2v%s^7 (nåværende: ^1v%s^7)'):format(latest, currentVersion))
            print('^3[AFTERDARK]^7 Last ned nyeste versjon på: ^4https://github.com/mrmoen7165/mrmoen_afterdark/releases/latest^7')
        else
            print(('^2[AFTERDARK]^7 Du kjører siste versjon (^5v%s^7).'):format(currentVersion))
        end
    end, 'GET', '', {['User-Agent'] = 'MrMoen_Afterdark_VersionCheck'})
end)
