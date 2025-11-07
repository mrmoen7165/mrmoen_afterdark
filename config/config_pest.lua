Config = Config or {}

--====================================================--
--  LYDER I BRUK AV PEST-SYSTEMET
--====================================================--
Config.Sounds = Config.Sounds or {
    pest_cough = "hoste",        -- brukes ved symptomer og helbredelse
    heartbeat  = "heartbeat",    -- brukes i infeksjonsintro
    drink      = "drink"         -- brukes ved bruk av medisin
}

--====================================================--
--  PEST SYSTEM SETTINGS / SVARTEDAUEN-INNSTILLINGER
--====================================================--
Config.Pest = {
    Active = true,                    -- Slå av/på pest-systemet / Enable or disable pest system globally
    HealthTake = 1,                   -- Hvor mye helse som tappes per tick
    CureTime = 5000,                  -- Hvor lenge medisinen tar før den virker (ms)
    CureHealthRestore = 600,          -- Hvor mye helse som gjenopprettes etter kur
    DeathChance = 30,                 -- % sjanse for å dø etter sykdommen

    -- Filmatiske effekter ved infeksjon
    UseVisualInfectionEffects = true, -- Slå på filmatisk intro, kameraristing og fade
    Visual = {
        FadeOutTime = 1400,           -- hvor lenge skjermen fader ut
        FadeInDelay = 1200,           -- pause før fade-in starter
        FadeInTime  = 1500,           -- hvor lenge fade-in varer
        CamShakeIntro = { type = "DRUNK_SHAKE", intensity = 0.25 },
        HeartbeatSound = "heartbeat"  -- lydfil brukt under intro
    },

    -- Generelle sykdomsinnstillinger
    Model = "A_C_Rat_01",             -- Modell brukt for å spre sykdommen
    Radius = 4.5,                     -- Avstand før spilleren kan bli smittet
    SpreadChance = 5,                -- Sjanse (%) for smitte ved kontakt med rotte
    MinHealthLimit = 0,               -- Minimum helse (død)
    SickTickMin = 1200000,            -- Minimum tid sykdom varer (ms)
    SickTickMax = 1200000,            -- Maksimum tid sykdom varer (ms)
    HealthTickRate = 1500,            -- Hvor ofte helse tappes (ms)
    SpreadToPlayers = true,           -- Kan smitte andre spillere
    SpreadDistance = 5.0,             -- Avstand for smitte mellom spillere
    SpreadChancePlayer = 40,          -- % sjanse for å smitte annen spiller

    -- Svekkelsesinnstillinger (erstatter ragdoll)
    Weakness = {
        RunSpeedMultiplier = 0.6,   -- påvirker både gange og sprint
        MaxMoveBlend       = 0.5,   -- minimal effekt i RedM, men behold
        SwimSpeedMultiplier = 0.8,
        FeverEffect = "RespawnPulseMPIn",
        SickAnim = {
            Dict = "amb_wander@upperbody_idles@sick@both_arms@male_a@idle_a",
            Name = "idle_c"
        }
    },


    -- Notifikasjoner / Notifications
    Notify = {
        Infected = {
            title = _U("pest.title"),
            description = _U("pest.infected"),
            type = "error",
            duration = 8000
        },
        Progress = {
            title = _U("pest.title"),
            description = _U("pest.progress"),
            type = "warning",
            duration = 6000
        },
        Death = {
            title = _U("pest.title"),
            description = _U("pest.death"),
            type = "error",
            duration = 6000
        },
        Cured = {
            title = _U("pest.title"),
            description = _U("pest.cured"),
            sound = Config.Sounds.pest_cough,
            type = "success",
            duration = 6000
        }
    }
}

--====================================================--
--  PEST ZONES / SMITTESONER
--====================================================--
Config.PestZones = {
    {
        name = "Valentine Woods",
        coords = vector3(-613.36, 528.34, 94.62),
        radius = 4.0,
        rats = 2,
        notify = {
            title = _U("pest.title"),
            description = _U("pest.zone_warning"),
            type = "error",
            duration = 7000
        }
    },
    {
        name = "Blackwater Back Alleys",
        coords = vector3(-915.88, -1258.42, 46.23),
        radius = 6.0,
        rats = 3,
        notify = {
            title = _U("pest.title"),
            description = _U("pest.zone_dark"),
            type = "error",
            duration = 7000
        }
    }
}
