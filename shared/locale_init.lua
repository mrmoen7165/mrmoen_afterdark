Locales = Locales or {}

--====================================================--
--  DEBUG PRINT
--====================================================--
function debugPrint(msg)
    if Config and Config.Debug then
        print(("[^3AFTERDARK DEBUG^7] %s"):format(msg))
    end
end

--====================================================--
--  _U(key)
--  Henter oversettelser basert på valgt språk
--  Støtter nested keys som "pest.infected"
--====================================================--
function _U(key)
    if type(Config) ~= "table" then Config = {} end
    local locale = (Config and Config.Locale) or 'no'
    local langData = Locales[locale] or Locales['en'] or {}
    local text = langData

    for part in string.gmatch(key, "([^.]+)") do
        if type(text) == "table" then
            text = text[part]
        else
            text = nil
            break
        end
    end

    -- Fallback til engelsk hvis ikke funnet
    if not text then
        local fallback = Locales['en'] or {}
        local fbText = fallback
        for part in string.gmatch(key, "([^.]+)") do
            if type(fbText) == "table" then
                fbText = fbText[part]
            else
                fbText = nil
                break
            end
        end
        text = fbText
    end

    return text or ("[" .. key .. "]")
end

--====================================================--
--  playNotify(data)
--  Viser varsler og spiller lyd (globalt tilgjengelig)
--====================================================--
function playNotify(data)
    if not data then return end

    -- Spill lyd hvis definert
    if data.sound then
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance",
            Config.SoundRange or 25.0,
            data.sound,
            Config.SoundVolume or 0.5)
    end

    -- Vis notifikasjon (ox_lib først)
    if exports['ox_lib'] and exports['ox_lib'].notify then
        exports['ox_lib']:notify({
            title = data.title or _U("general.warning"),
            description = data.description or "",
            type = data.type or "inform",
            duration = data.duration or 5000
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 150, 0},
            args = {'AfterDark', data.description or data.title or ""}
        })
    end
end

--====================================================--
--  LAST SPRÅK SYNKRONT (KORRIGERT)
--====================================================--
local resource = GetCurrentResourceName()
local lang = (Config and Config.Locale) or "en"
local path = string.format("locales/%s.lua", lang)
local fallback = "locales/en.lua"

local file = LoadResourceFile(resource, path)
if file then
    local fn, err = load(file)
    if fn then
        local result = fn()  -- kjør filen for å hente tabellen
        if type(result) == "table" then
            Locales[lang] = result
            debugPrint(("Språk lastet: %s"):format(lang))
        else
            print(("^1[AFTERDARK]^7 Feil: '%s.lua' returnerte ingen tabell!"):format(lang))
        end
    else
        print(("^1[AFTERDARK]^7 Feil ved lasting av språkfil: %s (%s)"):format(lang, err))
    end
else
    local fbFile = LoadResourceFile(resource, fallback)
    if fbFile then
        local fn = load(fbFile)
        if fn then
            Locales["en"] = fn()
            print(("^3[AFTERDARK]^7 Finner ikke '%s.lua', bruker engelsk fallback."):format(lang))
        end
    end
end

--====================================================--
--  INFO
--====================================================--
-- Denne filen fungerer som felles base for alle systemene i MRMOEN_AFTERDARK.
-- Her kan du utvide med flere globale hjelpefunksjoner (for eksempel effekter,
-- tilfeldige lyder, synk-funksjoner eller universelle eventhåndterere).
