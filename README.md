# 💀 MRMOEN_AFTERDARK
### Et originalt RedM-script utviklet og eid av **MrMoen**

---

## 🧩 Om scriptet

**MRMOEN_AFTERDARK** er et stemningsfullt og realistisk RedM-script laget for **RSGCore**, som bringer mørketid, sykdom og overnaturlige hendelser inn i spillet.

Scriptet kombinerer fire systemer i én komplett pakke:

- ☣️ **Svartedauen (Pest-system)** realistisk sykdom, hoste, feber, rotter og smitte  
- 🔔 **Prester** NPC-prester som advarer spillere etter mørkets frembrudd  
- 👻 **Spøkelser** filmatiske åndevesener som dukker opp ved gravplasser  
- 🌫️ **Hjemsøkte områder** mystiske steder med lyder, stemning og visuelle effekter  

Optimalisert for RedM med `ox_lib` og `rsg-core`.

## ⚙️ Installasjon

1. Pakk ut mappen **`mrmoen_afterdark`** til din server:
resources/mrmoen_afterdark

2. Legg til i `server.cfg`:
```cfg
ensure mrmoen_afterdark
Sørg for at følgende ressurser er installert:

rsg-core

ox_lib

interact-sound

🔊 Lydfiler
Plasser disse .ogg-filene i:
interact-sound/client/html/sounds/
Lyd	Filnavn	Brukes til
hoste.ogg	pest_cough	Spilles ved hoste og helbredelse
heartbeat.ogg	heartbeat	Spilles ved infeksjonsstart
drink.ogg	drink	Spilles når medisinen brukes
priest.ogg	priest	Prest advarselslyd
ghost_whisper1.ogg	ghost	Spilles når spøkelser vises
woman_cry.ogg	haunted	Brukes ved hjemsøkte områder

☣️ Pest-system (Svartedauen)
Spillere kan bli smittet i bestemte soner eller av andre spillere

Symptomer inkluderer hoste, feberfilter, nedsatt bevegelse og kameraristing

Spilleren kan dø eller overleve etter infeksjonsperioden

Medisin (pest_medisin) kan brukes for å kureres

Medisin fjernes automatisk fra inventory etter bruk

Debug-melding i konsollen:
[^3AFTERDARK DEBUG^7] [Pest] Spilleren er kurert for pest.

🔔 Prester
Vises kun mellom 22:00 – 04:00 (in-game)

Advarer spillere som nærmer seg kirken om natten

Forsvinner automatisk ved daggry

Støtter fade-in/out og avspillingslyd (priest.ogg)

👻 Spøkelser
Aktiveres kun om natten

Spawner ved gravplasser

Har filmatisk fade-effekt og beveger seg mot spilleren

Forlater området etter noen sekunder

🌫️ Hjemsøkte områder
Aktiveres kun om natten

Spiller stemningslyder (woman_cry.ogg) og sender ox_lib-varsler

Kan brukes til rollespill eller eventer

💬 Kommandoer
Kommando	Beskrivelse
/curepest	Kurer pesten manuelt (debug/test)

🌍 Språk
Scriptet støtter både norsk (no) og engelsk (en).
Språket settes i config/config_general.lua:

lua
Kopier kode
Config.Locale = "no"
🧩 Konfigurasjon
Fil	Beskrivelse
config/config_general.lua	Språk, debug, tid og grunninnstillinger
config/config_haunt.lua	Prester, spøkelser og hjemsøkte områder
config/config_pest.lua	Pest-system, soner og medisindefinisjon
locales/no.lua	Norsk språkfil
locales/en.lua	Engelsk språkfil

🧠 Funksjoner
System	Beskrivelse
Pest	Infeksjon, hoste, svekkelse, feberfilter og dødssjanse
Medisin	pest_medisin fjerner infeksjon med animasjon og lyd
Prester	NPC-prester som vises og forsvinner dynamisk
Spøkelser	Spawner filmatisk, følger spilleren og forsvinner igjen
Hjemsøkt	Lyder og varsler i bestemte områder
Språk	Støtter NO/EN via _U()-systemet
Effekter	Fading, risting, og post-FX for stemning

💬 Debug
Slå på debugmeldinger i config/config_general.lua:

lua
Kopier kode
Config.Debug = true
Gir detaljerte meldinger i konsollen som viser når prester, spøkelser og pest blir aktivert.

✨ Utvikler
👤 MrMoen
Utvikler og eier av MRMOEN_AFTERDARK
Optimalisert for RSGCore & RedM
Lisensiert til bruk under MIT-lisens med krav om kreditering.
https://discord.gg/6PPXgFpssr

❤️ Støtt prosjektet
Dersom du bruker scriptet på din server — gi gjerne ⭐ på GitHub!