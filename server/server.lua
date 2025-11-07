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
--  VERSJONSKONTROLL (mrmoen_afterdark)
--====================================================--
local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
local resourceName = GetCurrentResourceName()
local githubVersionURL = "https://raw.githubusercontent.com/mrmoen7165/mrmoen_afterdark/main/fxmanifest.lua"

CreateThread(function()
    print("^3["..resourceName.."]^7 Laster versjonssjekk...")
    PerformHttpRequest(githubVersionURL, function(statusCode, response)
        if statusCode == 200 then
            local latestVersion = response:match("version ['\"]([0-9%.]+)['\"]")
            if latestVersion then
                if latestVersion ~= currentVersion then
                    print("^6["..resourceName.."]^7 En ny versjon er tilgjengelig!")
                    print("^2Din versjon:^7 " .. currentVersion .. "  ^3Nyeste versjon:^7 " .. latestVersion)
                    print("^5Oppdater fra GitHub:^7 https://github.com/mrmoen7165/mrmoen_afterdark")
                else
                    print("^2["..resourceName.."]^7 Du kjører siste versjon ("..currentVersion..")")
                end
            else
                print("^1["..resourceName.."]^7 Klarte ikke å lese versjon fra GitHub-responsen.")
            end
        else
            print("^1["..resourceName.."]^7 Kunne ikke sjekke versjon (GitHub-status: " .. statusCode .. ")")
        end
    end, "GET", "", {["User-Agent"] = "mrmoen_afterdark-version-check"})
end)
