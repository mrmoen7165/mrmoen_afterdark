Config = {}

--====================================================--
--  GENERELT
--====================================================--
Config.Locale = "no"           -- Språk ("no" eller "en")
Config.Debug = false            -- Aktiver/Deaktiver debug-print
Config.FadeIn = true           -- Fade-effekt på prest/spøkelse
Config.CheckInterval = 1000    -- Hvor ofte scriptet sjekker spillerposisjon (ms)

--====================================================--
--  TID (NATT / DAG)
--====================================================--
Config.NightStart = 22         -- Klokkeslett natt starter
Config.NightEnd = 4            -- Klokkeslett natt slutter

--====================================================--
--  LYD
--====================================================--
Config.SoundRange = 25.0       -- Rekkevidde for lyd (meter)
Config.SoundVolume = 0.4       -- Volum (0.0–1.0)

--====================================================--
--  GHOST-INNSTILLINGER
--====================================================--
Config.GhostLifetime = 10000   -- Hvor lenge et spøkelse varer (ms)
Config.GhostChance = 100       -- Sjanse (1–100) for at spøkelse spawner

--====================================================--
--  PEST (BLACK DEATH) – AKTIVERES I EGEN CONFIG
--====================================================--
Config.Pest = {
    Active = true,                     -- Om pest-systemet er aktivt
    InfectionChance = 10,              -- Sjanse for infeksjon (prosent)
    InfectionInterval = 60 * 1000,     -- Hvor ofte man kan bli smittet (ms)
    RecoveryChance = 10,               -- Sjanse for å bli frisk naturlig
    Visual = true,                     -- Aktiver visuelle effekter
    UseVisualInfectionEffects = true,  -- Om fade, camera-effekter brukes
    DeathEnabled = true,               -- Død ved alvorlig infeksjon
}
