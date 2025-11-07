Config = Config or {}

--====================================================--
--  PRESTER / PRIESTS
--====================================================--
Config.Priests = {
    {
        name = "Valentine Church",
        model = "U_M_M_ValDoctor_01",
        coords = vector4(-231.85, 796.23, 124.63, 75.85),
        radius = 3.0,
        sound = "priest",
        notify = {
            title = _U("priest.title"),
            description = _U("priest.warning"),
            type = "warning",
            duration = 7000
        }
    },
    {
        name = "Blackwater Church",
        model = "U_M_M_RhdGenStoreOwner_01",
        coords = vector4(-971.34, -1199.66, 59.18, 199.06),
        radius = 3.0,
        sound = "priest",
        notify = {
            title = _U("priest.title"),
            description = _U("priest.closed"),
            type = "warning",
            duration = 7000
        }
    }
}

--====================================================--
--  SPØKELSER / GHOSTS
--====================================================--
Config.Ghosts = {
    {
        name = "Valentine Graveyard",
        coords = vector3(-228.09, 824.71, 124.43),
        model = "A_M_M_Rancher_01",
        radius = 8.0,
        sound = "ghost_whisper1",
        notify = {
            title = _U("ghost.title"),
            description = _U("ghost.whisper"),
            type = "inform",
            duration = 8000
        }
    },
    {
        name = "Blackwater Graveyard",
        coords = vector3(-1014.05, -1194.79, 59.45),
        model = "A_M_M_Rancher_01",
        radius = 8.0,
        sound = "ghost_whisper1",
        notify = {
            title = _U("ghost.title"),
            description = _U("ghost.grave"),
            type = "inform",
            duration = 8000
        }
    }
}

--====================================================--
--  HAUNTED / HJEMSØKTE OMRÅDER
--====================================================--
Config.Haunted = {
    {
        name = "Valentine Woods",
        coords = vector3(-613.36, 528.34, 94.62),
        radius = 4.0,
        sound = "woman_cry",
        notify = {
            title = _U("haunted.title"),
            description = _U("haunted.cry"),
            type = "error",
            duration = 9000
        }
    },
    {
        name = "Blackwater Monument Area",
        coords = vector3(-892.07, -1152.32, 46.88),
        radius = 10.0,
        sound = "woman_cry",
        notify = {
            title = _U("haunted.title"),
            description = _U("haunted.echo"),
            type = "error",
            duration = 9000
        }
    }
}
