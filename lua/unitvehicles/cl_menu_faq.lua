UV = UV or {}
UV.FAQ = UV.FAQ or {}

function UVGetFAQText(key)
	local cvar = GetConVar("gmod_language")
	local lang = cvar and string.lower(cvar:GetString()) or "en"

	-- Try exact match (sv-se)
	if UV.FAQ[lang] and UV.FAQ[lang][key] then
		return UV.FAQ[lang][key]
	end

	-- Try base language fallback (sv)
	local base = string.match(lang, "^(%a+)")
	if base and UV.FAQ[base] and UV.FAQ[base][key] then
		return UV.FAQ[base][key]
	end
	
	-- English fallback
	if UV.FAQ.en and UV.FAQ.en[key] then
		return UV.FAQ.en[key]
	end

	return "Missing FAQ text: " .. key
end

-- English
UV.FAQ["en"] = {
-- Introduction
["Intro"] = [[
# -- What is this addon?

Unit Vehicles is a Sandbox-oriented addon that allows players, in both Multiplayer with others or Singleplayer with AI, to engage in high-speed pursuits as or against police (Units) and thrilling races on any map.

**Here are the currently supported vehicle bases:**
 |-- prop_vehicle_jeep (default vehicle base)
 |-- simfphys
 |-- Glide (required and highly recommended)
]],
["Requirements"] = [[
# -- Do I have to install other addon(s) for this?

Yes. *Decent Vehicle - Basic AI* and *Glide // Styled's Vehicle Base* is REQUIRED for Unit Vehicles to function properly.
 |-- Decent Vehicle provides waypoints for AIs to spawn and roam around in.
 |-- Glide provides the vehicles needed to use with the Default preset.
]],
["Github"] = [[
# -- Does this addon have a GitHub repository?

Yes. It is currently private at the moment until official release.
]],
["Roadmap"] = [[
# -- How can I keep up to date with the latest updates? Is there a road map?

You can follow us on our Trello page, or our Discord server, both of which you can find on our Workshop page.
]],
["ConVars"] = [[
# -- What console commands are there I can use?

 |-- uv_spawnvehicles - Spawns patrolling AI Units
 |-- uv_setheat [x] - Sets the Heat Level
 |-- uv_despawnvehicles - Despawns Patrolling AI Units
 |-- uv_resetallsettings - Resets all server settings to their default values
 |-- uv_startpursuit - Starts a countdown before beginning a pursuit
 |-- uv_stoppursuit - Stops a pursuit with AI Units assuming you've escaped
 |-- uv_wantedtable - Prints a list of wanted suspects to the console
 |-- uv_clearbounty - Sets the bounty value to 0
 |-- uv_setbounty [x] - Sets the bounty value
 |-- uv_spawn_as_unit - Allows you to join as the Unit
]],

-- Racing
["Racing.Joining"] = [[
# -- How do I join races?

If someone has prepared a race, and they send an invite, you'll receive an on-screen notification inviting you to it, assuming that you are in a vehicle and no pursuit is ongoing.
]],

["Racing.SpawnAI"] = [[
# -- How do I race with AI?

There are two ways of doing that:

**Option 1**
 |-- 1. Spawn any Glide, Simfphys or HL2 Jeep vehicle.
 |-- 2. Pull out the [string:tool.uvracermanager.name] tool.
 |-- 3. Press [+attack2] on the vehicle.
 |-- 4. Tweak the settings to your liking, then click [string:uv.tool.create].
 |-- 5. Repeat for every vehicle you want the AI to use.
 
**Option 2 (Recommended)**
 |-- 1. Open the [string:uv.airacer] tab.
 |-- 2. Enable [string:uv.airacer.override].
 |-- 3. In the list below the option, open the menus containing cars and press [+attack2] to add the vehicles to an AI vehicle list

**Notes**
 |-- Ensure the [string:uv.tool.base.title] variable matches your desired base.
]],

["Racing.Resetting"] = [[
# -- I'm stuck! How do I reset?

 |-- Press [key:unitvehicle_keybind_resetposition] to reset your car
 |-- Wait 3 seconds
 |-- You're back at the last checkpoint you passed!
 
**Notes**
 |-- You cannot reset when being busted
 |-- You cannot reset while already moving
]],

["Racing.Starting"] = [[
# -- How do I start racing?

Begin a race by going to [string:uv.rm] in the UV Menu:
 |-- Click [string:uv.rm.loadrace]
 |-- Select any race from the list
 |-- Invite other racers, or hit [string:uv.rm.startrace]
 |-- You can immediately start the race, or automatically spawn AI to join your race


*Notes*
 |-- There must be at least 1 Grid Slot to start the race!
 |-- You can invite friends/AI Racers by clicking [string:uv.rm.sendinvite] before clicking [string:uv.rm.startrace] as long as a race is loaded
 |-- If there are no existing races, you'll have to make your own
 |-- Alternatively, find some on the Workshop!
]],

["Racing.Create"] = [[
# -- How do I create races?
Use the [string:tool.uvracemanager.name] tool:


*-- Step 1: Create Checkpoints*
 |-- Press [+attack] in one corner to start placing a checkpoint
 |-- Press [+attack] in another to finish placing it
 |-- Tip: Hold [+use] to increase checkpoint height automatically
 

*-- Step 2: Set the Checkpoints in order*
 |-- Press [+attack2] on the checkpoint.
 |-- Type in the Checkpoint ID
 |-- Make sure the ID is in sequentual order
 |-- Branching checkpoints use a matching ID
 |-- AI will always use the last placed checkpoint ID
 

*-- Step 3: Create Grid Slots*
 |-- Press [+reload] to place Grid Slots
 |-- The numbers on the slots represent starting order
 |-- Want more racers? Place more slots!
 

*-- Step 4: Export Race*
 |-- Done with the race? Open the Spawnmenu and hit [string:tool.uvracemanager.settings.saverace]
 |-- Give it a name
 |-- It will now appear as a race you can import and race on!
]],
["Racing.Create.Speedlimit"] = [[
# -- The AI Racers are going too fast around the track!

When placing checkpoints, you'll have to define the speed in which the AI will take it.
If the AI is going too fast, you'll have to alter the speedlimit value found in the [string:tool.uvracemanager.name] settings.
If you have a race already loaded, you can press [+attack2] on the Checkpoint to edit it and apply the updated speedlimit.
Alternatively, you can edit the last number in the race data file.
]],

-- Pursuits
["Pursuit.Starting"] = [[
# -- How do I start a pursuit?

 |-- Go to [string:uv.pm]
 |-- Click [string:uv.pm.pursuit.start]
 |-- Alternatively, drive into or drive recklessly near a Unit
 |-- Away you go!
]],

["Pursuit.JoinAsUnit"] = [[
# -- Can I join the Pursuit as a Unit?

Yes you can! And it's simple:
 |-- Go to [string:uv.pm] or [string:uv.menu.welcome]
 |-- Click [string:uv.pm.spawnas]
 |-- Pick the vehicle you want to drive
 |-- Away you go!
]],
["Pursuit.Respawn"] = [[
# -- I'm stuck or too far from the suspect(s)! How do I reset?

 |-- Press [key:unitvehicle_keybind_resetposition] to open the [string:uv.pm.spawnas] menu
 |-- Pick the vehicle you want to reset as
 |-- Away you go!
 
**Notes**
 |-- If you reset once, you'll have to wait a moment before doing so again
]],
["Pursuit.CreateUnits"] = [[
# -- I want to create Units. What do I do?

Here's what you do:
 |-- 1. Pull out the [string:tool.uvunitmanager.name] tool
 |-- 2. Spawn any vehicle
 |-- 3. Press [+attack2] on the vehicle
 |-- 4. Give the Unit a unique name
 |-- 5. (Optional) Select the Heat Level the Unit appears in
 |-- 6. (Optional) Tweak other values as you see fit
 |-- 7. Click [string:uv.tool.create]
 
Now apply the Unit via the [string:tool.uvunitmanager.name] tool, and you'll either face the Unit you made, or be allowed to play as the Unit against the fleeing suspects.
]],
["Pursuit.Roadblocks"] = [[
# -- I want to create Roadblocks. What do I do?

You use the [string:tool.uvroadblock.name] tool:
 |-- 1. Using the tool, create the props and pieces necessary for the roadblock
 |-- 2. Using the [string:tool.weld.name] tool (or any alternative), weld all the pieces together
 |-- 3. Once welded, press [+attack2] on any piece of the roadblock
 |-- 4. Tweak the settings to your liking, then click [string:uv.tool.create]
 
The roadblock will now appear randomly when a Pursuit is active.
]],
["Pursuit.Pursuitbreaker"] = [[
# -- I want to create Pursuit Breakers. What do I do?

You use the [string:tool.uvpursuitbreaker.name] tool:
 |-- 1. Create the props and pieces necessary for the Pursuit Breaker
 |-- 2. Using the [string:tool.weld.name] tool (or any alternative), weld all the pieces together
 |-- 3. Once welded, press [+attack2] on any piece of the Pursuit Breaker
 |-- 4. Tweak the settings to your liking, then click [string:uv.tool.create]
]],

["Other.CreateTraffic"] = [[
# -- How do I spawn traffic?

Here's what you do:
 |-- 1. Pull out the [string:tool.uvtrafficmanager.name] tool
 |-- 2. Spawn any vehicle
 |-- 3. Press [+attack2] on the vehicle
 |-- 4. Give the vehicle a unique name
 |-- 5. (Optional) Tweak the values as you see fit
 |-- 6. Click [string:uv.tool.create]
 
You can then tweak general settings in the [string:uv.tm] tab in the UV Menu.
]],
["Other.PursuitTech"] = [[
# -- What are Pursuit Tech?

Pursuit Tech are a series of weapons and support devices utilized by both Racers and Units.
You can apply up to 2 Pursuit Techs to your vehicle to either fight the opponents or defend yourself.

Here's how to apply and use them:
 |-- 1. Pull out the [string:tool.uvpursuittech.name] tool
 |-- 2. Select the Pursuit Tech you want to use as a Racer or Unit
 |-- 3. Press [+attack] on your vehicle or Unit
 
You can now press [key:unitvehicle_pursuittech_keybindslot_1] and [key:unitvehicle_pursuittech_keybindslot_2] to activate your Pursuit Tech while driving!
]],
["Other.RenameAI"] = [[
# -- Can I rename AI Racers and Units?

Yes you can. And it's simple:
 |-- 1. Pull out the [string:tool.uvnamechanger.name] tool
 |-- 2. Type out the name you want the AI to have
 |-- 3. Press [+attack] on the AI Racer or Unit
]],
["Other.DataFolder"] = [[
# -- Where is my UV data stored?

You can find your UV-related data stored in your game's *data/unitvehicles* directory.
]],
}

-- Svenska (Swedish) sv-se
UV.FAQ["sv-se"] = {
-- Introduction
["Intro"] = [[
# -- Vad är det här för tillägg?

Unit Vehicles är ett Sandbox-fokuserat tillägg som tillåter spelare, antingen flera spelare via nätet eller ensam med AI, att gå med i jakter i hög hastighet som eller emot polisen (Enheter) och spännande lopp på vilken karta som helst.

**Här är dem nuvarande stödjande fordonsbaserna:**
 |-- prop_vehicle_jeep (standard fordonsbas)
 |-- simfphys
 |-- Glide (krävs och starkt rekommenderad)
]],
["Requirements"] = [[
# -- Behöver jag installera andra tillägg för detta?

Ja. *Decent Vehicle - Basic AI* och *Glide // Styled's Vehicle Base* KRÄVS för att Unit Vehicles ska fungera korrekt.
 |-- Decent Vehicles ger waypoints till AI:n att spawna och köra runt på.
 |-- Glide erbjuder fordonen som krävs för standard förinställningen.
]],
["Github"] = [[
# -- Har tillägget en GitHub-sida?

Ja. Den är privat för tillfället tills officiella lanseringen.
]],
["Roadmap"] = [[
# -- Hur håller jag mig uppdaterad på senaste uppdateringarna? Finns det en vägkarta?

Du kan följa oss på vår Trello-sida, eller på vår Discord-server. Du hittar båda på Workshop-sidan.
]],
["ConVars"] = [[
# -- Vilka konsolkommandon kan jag använda?

 |-- uv_spawnvehicles - Spawnar patrullerande AI-enheter
 |-- uv_setheat [x] - Sätter spaningsnivån
 |-- uv_despawnvehicles - Tar bort patrullerande AI-enheter
 |-- uv_resetallsettings - Återställer alla serverinställningar
 |-- uv_startpursuit - Påbörjar en nedräkning innan en jakt startas
 |-- uv_stoppursuit - Stoppar jakten där AI-enheter tror att du kommit undan
 |-- uv_wantedtable - Skriver ut en lista på efterlysta misstänka i konsolen
 |-- uv_clearbounty - Sätter belöningsvärdet till 0
 |-- uv_setbounty [x] - Sätter belöningsvärdet
 |-- uv_spawn_as_unit - Tillåter dig att gå med som en enhet
]],

-- Racing
["Racing.Joining"] = [[
# -- Hur går jag med ett race?

Om något har förberett ett race och skickat en inbjudan så får du en notifikation på skärmen som bjuder in dig till den, förutsatt att du är i ett fordon och ingen jakt pågår.
]],

["Racing.SpawnAI"] = [[
# -- Hur tävlar jag med AI?

Det finns två sätt att göra det:

**Alternativ 1**
 |-- 1. Spawna ett Glide-, Simfphys- eller HL2 Jeep-fordon.
 |-- 2. Ta fram verktyget [string:tool.uvracermanager.name].
 |-- 3. Tryck på [+attack2] på fordonet.
 |-- 4. Ändra inställningarna som du vill, och tryck därefter på [string:uv.tool.create]
 |-- 5. Upprepa med alla fordon du vill att AI:n ska använda.
 
**Alternativ 2 (Rekommenderat)**
 |-- 1. Öppna [string:uv.airacer]-fliken.
 |-- 2. Aktivera [string:uv.airacer.override].
 |-- 3. I listan under alternativet, öppna menyerna som innehåller bilar och tryck på [+attack2] för att lägga till bilarna i AI:ns fordonslista

**Notera**
 |-- Kolla så att [string:uv.tool.base.title]-variabeln matchar din valda bas.
]],

["Racing.Resetting"] = [[
# -- Jag har fastnat! Hur återställer jag?

 |-- Tryck på [key:unitvehicle_keybind_resetposition] för att återställa din bil
 |-- Vänta 3 sekunder
 |-- Du är tillbaks till kontrollpunkten du kört igenom!
 
**Notera**
 |-- Du kan inte återställa när du arresteras
 |-- Du kan inte återställa när du är i rörelse
]],

["Racing.Starting"] = [[
# -- Hur börjar jag ett race?

Påbörja ett race genom att gå till [string:uv.rm] i UV-menyn:
 |-- Tryck på [string:uv.rm.loadrace]
 |-- Välj ett race i listan
 |-- Bjud in andra tävlande, eller tryck på [string:uv.rm.startrace]
 |-- Du kan omedelbart påbörja racet, eller automatiskt spawna AI för att gå med racet


*Notera*
 |-- Det måste finnas minst 1 Startplats för att påbörja racet!
 |-- Du kan bjuda in vänner/AI-racers genom att trycka på [string:uv.rm.sendinvite] innan du trycker på [string:uv.rm.startrace], förutsatt att ett race är laddat.
 |-- Om det inte finns något race så behöver du skapa ditt eget
 |-- Alternativt så hittar du några på Workshop!
]],

["Racing.Create"] = [[
# -- Hur skapar jag ett race?
Använd verktyget [string:tool.uvracemanager.name]:


*-- Steg 1: Skapa kontrollpunkter*
 |-- Tryck på [+attack] i ett hörn för att börja placera en kontrollpunkt.
 |-- Tryck på [+attack] i ett annat hörn för att slutföra placeringen.
 |-- Tips: Håll inne [+use] för att öka höjden på kontrollpunkten automatiskt.
 

*-- Steg 2: Sätt kontrollpunkternas ordning*
 |-- Tryck på [+attack2] på kontrollpunkten
 |-- Skriv in Kontrollpunktens ID
 |-- Var säker på att ID:n är i sekventiell ordning
 |-- Förgrenade punkter använder matchande ID
 |-- AI:n kommer alltid använda den sist utplacerade kontrollpunkten
 

*-- Steg 3: Skapa spawnpunkter*
 |-- Tryck på [+reload] för att placera ut Spawnpunkter
 |-- Punkternas nummer representerar startordning
 |-- Vill du ha fler tävlande? Placera ut fler punkter!
 

*-- Steg 4: Exportera racet*
 |-- Färdig med racet? Öppna Spawnmenyn och tryck på [string:tool.uvracemanager.settings.saverace]
 |-- Ge den ett namn
 |-- Den kommer nu visas som ett race du kan importera och tävla på!
]],
["Racing.Create.Speedlimit"] = [[
# -- AI-racers kör för fort runt banan!

När du placerar ut kontrollpunkter så måste du specifiera hastigheten som AI:n kommer ta den i.
Om AI:n kör för fort så behöver du redigera hastighetsbegränsningsvärdet som du hittar i inställningarna på verktyget [string:tool.uvracemanager.name].
Om ett race redan är laddat så kan du trycka på [+attack2] på Kontrollpunkten för att redigera den och tillämpa den uppdaterade gränsen.
Alternativt så kan du redigera det sista värdet i racets datafil.
]],

-- Pursuits
["Pursuit.Starting"] = [[
# -- Hur påbörjar jag en jakt?

 |-- Gå till [string:uv.pm]
 |-- Tryck på [string:uv.pm.pursuit.start]
 |-- Alternativt så krockar du med, eller köra galet nära en Enhet
 |-- Iväg med dig!
]],

["Pursuit.JoinAsUnit"] = [[
# -- Kan jag gå med jakten som en Enhet?

Ja, det kan du! Och simpelt är det:
 |-- Gå till [string:uv.pm] eller [string:uv.menu.welcome]
 |-- Tryck på [string:uv.pm.spawnas]
 |-- Välj fordonet du vill köra
 |-- Iväg med dig!
]],
["Pursuit.Respawn"] = [[
# -- Jag har fastnat eller är för långt bort från dem misstänkta! Hur återställer jag?

 |-- Tryck på [key:unitvehicle_keybind_resetposition] för att öppna menyn [string:uv.pm.spawnas]
 |-- Välj ett fordon du vill återställas som
 |-- Iväg med dig!
 
**Notera**
 |-- Om du återstället en gång så behöver du vänta ett ögonblick innan du kan göra det igen
]],
["Pursuit.CreateUnits"] = [[
# -- Jag vill skapa Enheter. Hur gör jag det?

Du gör såhär:
 |-- 1. Ta fram verktyget [string:tool.uvunitmanager.name]
 |-- 2. Spawna ett fordon
 |-- 3. Tryck på [+attack2] på fordonet
 |-- 4. Ge Enheten ett unikt namn
 |-- 5. (Valfritt) Välj Spaningsnivån som Enheten ska finnas i
 |-- 6. (Valfritt) Ändra andra värden som du vill
 |-- 7. Tryck på [string:uv.tool.create]
 
Du kan nu tillämpa Enheten via verktyget [string:tool.uvunitmanager.name] och antingen möta Enheten du precis skapat, eller tillåtas att spela som Enheten mot flyende misstänkta.
]],
["Pursuit.Roadblocks"] = [[
# -- Jag vill skapa vägspärrar. Hur gör jag det?

Du använder verktyget [string:tool.uvroadblock.name]:
 |-- 1. Skapa föremål och delar som krävs till vägspärren med verktyget
 |-- 2. Med verktyget [string:tool.weld.name] (eller alternativ), svetsa alla delar tillsammans
 |-- 3. När dem är svetsade, tryck på [+attack2] på vilken del som helst i vägspärren
 |-- 4. Ändra inställningarna som du vill, och tryck därefter på [string:uv.tool.create]
 
Vägspärren kommer nu placeras ut slumpmässigt när en jakt pågår.
]],
["Pursuit.Pursuitbreaker"] = [[
# -- Jag vill skapa Pursuit Breakers. Hur gör jag?

Du använder verktyget [string:tool.uvpursuitbreaker.name]:
 |-- 1. Skapa föremål och delar som krävs till Pursuit Breakern
 |-- 2. Med verktyget [string:tool.weld.name] (eller alternativ), svetsa alla delar tillsammans
 |-- 3. När dem är svetsade, tryck på [+attack2] på vilken del som helst i vägspärren
 |-- 4. Ändra inställningarna som du vill, och tryck därefter på [string:uv.tool.create]
]],

["Other.CreateTraffic"] = [[
# -- Hur spawnar jag trafik?

Du gör såhär:
 |-- 1. Ta fram verktyget [string:tool.uvtrafficmanager.name]
 |-- 2. Spawna ett fordon
 |-- 3. Tryck på [+attack2] på fordonet
 |-- 4. Ge fordonet ett unikt namn
 |-- 5. (Valfritt) Ändra värden som du själv vill
 |-- 6. Tryck på [string:uv.tool.create]
 
Du kan ändra generella inställningar i [string:uv.tm]-fliken i UV-menyn.
]],
["Other.PursuitTech"] = [[
# -- Vad är Jakt Teknologi?

Jakt Teknologi är en samling vapen och stödanordning som används av både Racers och Enheter.
Du kan tillämpa upp till 2 Jakt Teknologin på ditt fordon för att antingen strida mot moståndare, eller försvara dig själv.

Såhär tillämpar du och använder dem:
 |-- 1. Ta fram verktyget [string:tool.uvpursuittech.name]
 |-- 2. Välj Teknologin du vill använda som en Racer eller Enhet
 |-- 3. Tryck på [+attack] på ditt fordon eller din Enhet
 
Du kan nu trycka på [key:unitvehicle_pursuittech_keybindslot_1] och [key:unitvehicle_pursuittech_keybindslot_2] för att aktivera din Jakt Teknologi när du kör!
]],
["Other.RenameAI"] = [[
# -- Kan jag döpa om AI-racers och Enheter?

Ja, det kan du. Och simpelt är det:
 |-- 1. Ta fram verktyget [string:tool.uvnamechanger.name]
 |-- 2. Skriv namnet du vill att AI:n ska ha
 |-- 3. Tryck på [+attack] på AI-racern eller Enheten
]],
["Other.DataFolder"] = [[
# -- Vart finns min UV-data?

Du kan hitta all din UV-data i spelets *data/unitvehicles*-mapp.
]],
}

-- Español (Spanish) es-es
UV.FAQ["es-es"] = {
-- Introducción
["Intro"] = [[
# -- ¿De qué trata esta extensión?

Unit Vehicles es una extensión orientada al mundo abierto que permite, en ambos multijugador con demás personas o un solo jugador con la IA, sumergirte en persecuciones de alta velocidad como o en contra de la policía (Unidades) y carreras emocionantes en cualquier mapa.

**Estas son las bases de vehículos soportadas actualmente**
 |-- prop_vehicle_jeep (base por defecto)
 |-- simfphys
 |-- Glide (requerida y altamente recomendada)
]],
["Requirements"] = [[
# -- ¿Necesito instalar otras extensión(es) para esto?

Sí. *Decent Vehicle - Basic AI* y *Glide // Styled's Vehicle Base* son REQUERIDAS para que Unit Vehicles funcione adecuadamente.
 |-- Decent Vehicle provee nodos para que la IA pueda aparecer y moverse en ellos.
 |-- Glide provee los vehículos necesarios para usar con el preajuste por defecto.
]],
["Github"] = [[
# -- ¿Tiene esta extensión un repositorio en Github?

Sí. Por el momento se encuentra privado hasta el lanzamiento oficial.
]],
["Roadmap"] = [[
# -- ¿Cómo puedo mantenerme al tanto con las últimas actualizaciones? ¿Hay alguna hoja de ruta?

Puedes seguirnos en nuestra página de Trello, o en nuestro servidor de Discord, ambos los puedes encontrar en nuestra página de la Workshop.
]],
["ConVars"] = [[
# -- ¿Qué comandos de consola hay para usar?

 |-- uv_spawnvehicles - Aparece unidades IA que patrullan.
 |-- uv_setheat [x] - Establece el nivel de persecución.
 |-- uv_despawnvehicles - Desaparece unidades IA que patrullan.
 |-- uv_resetallsettings - Reestablece todos ajustes del servidor a sus valores por defecto.
 |-- uv_startpursuit - Comienza un conteo antes de comenzar una persecución.
 |-- uv_stoppursuit - Detiene la persecución con unidades IA las cuales asumen que escapaste.
 |-- uv_wantedtable - Muestra una lista de sospechosos buscados en la consola.
 |-- uv_clearbounty - Establece el valor de la bolsa a 0.
 |-- uv_setbounty [x] - Establece el valor de la bolsa.
 |-- uv_spawn_as_unit - Te permite unirte como unidad policial.
]],

-- Carreras
["Racing.Joining"] = [[
# -- ¿Cómo me uno a las carreras?

Si alguien ya preparó una carrera, y te envian una invitación, recibirás una notificación en pantalla en la que te invitan a ella, asumiendo que estás en un vehículo y no hay ninguna persecución en curso.
]],

["Racing.SpawnAI"] = [[
# -- ¿Cómo corro con la IA?

Hay 2 maneras de hacerlo:

**Opción 1**
 |-- 1. Aparece cualquier vehículo Glide, Simfphys o HL2 Jeep.
 |-- 2. Saca la herramienta [string:tool.uvracermanager.name].
 |-- 3. Presiona [+attack2] sobre el vehículo.
 |-- 4. Cambia los ajustes a como más te gusten, y después haz click en [string:uv.tool.create].
 |-- 5. Ahora repitelo para cualquier vehículo que quieres que la IA use.
 
**Opción 2 (Recomendada)**
 |-- 1. Abre la tabla [string:uv.airacer].
 |-- 2. Activa [string:uv.airacer.override].
 |-- 3. En la lista de debajo de la opción, abre los menús que contienen coches y presiona [+attack2] para añadir los vehículos  a una lista de vehículos para la IA

**Notas**
 |-- Asegúrate que la variable [string:uv.tool.base.title] es la misma a la de tu base de vehículos asignada.
]],

["Racing.Resetting"] = [[
# -- ¡Me atasqué! ¿Cómo reaparezco?

 |-- Presiona [key:unitvehicle_keybind_resetposition] para restablecer el vehículo
 |-- Espera 3 segundos
 |-- ¡Estás de vuelta en el último punto de control por el que pasaste!
 
**A tener en cuenta**
 |-- No puedes restablecer mientras estás siendo arrestado.
 |-- No puedes restablecer cuando ya te estás moviendo.
]],

["Racing.Starting"] = [[
# -- ¿Cómo comienzo a correr?

Comienza una carrera yendo a [string:uv.rm] en el menú de UV:
 |-- Haz click en [string:uv.rm.loadrace]
 |-- Elige una carrera de la lista
 |-- Invita a otros corredores, o presiona [string:uv.rm.startrace]
 Puedes comenzar la carrera inmediatamente, o automáticamente aparecer IA para que se unan a tu carrera.


*A tener en cuenta*
 |-- ¡Tiene que haber por lo menos 1 espacio en la grilla para comenzar la carrera!
 |-- Puedes invitar amigos/corredores IA haciendo click en [string:uv.rm.sendinvite] antes de hacer click en [string:uv.rm.startrace] siempre y cuando la carrera esté cargada.
 |-- Si no hay carreras existentes, tendrás que crear una.
 |-- ¡Como alternativa, busca si hay en la workshop!
]],

["Racing.Create"] = [[
# -- ¿Cómo creo carreras?
Usa la herramienta [string:tool.uvracemanager.name]:


*-- Paso 1: Crea puntos de control*
 |-- Presiona [+attack] en una esquina para empezar a colocar un punto de control
 |-- Presiona  [+attack] en otra esquina para terminar de colocarlo
 |-- Consejo: Mantén [+use] para incrementar la altura del punto de control automáticamente
 

*-- Paso 2: pon los puntos de control en orden*
 |-- Presiona [+attack2] en el punto de control.
 |-- Escribe la ID del punto de control
 |-- Asegúrate de que la ID esté en orden secuencial
 |-- Los puntos de control unidos usan la misma ID
 |-- La IA siempre pasará por el último punto de control puesto 
 

*-- Paso 3: Crea espacios en la grilla*
 |-- Presiona [+reload] para poner espacios en la grilla
 |-- Los números en los espacios representan el orden de las posiciones
 |-- ¿Quieres más corredores? ¡Pon más espacios!
 

*-- Paso 4: Exportar la carrera*
 |-- ¿Terminaste de crear tu carrera? Abre el menú de objetos y dale a [string:tool.uvracemanager.settings.saverace]
 |-- Ponle un nombre
 |-- ¡Ahora aparecerá como una carrera que puedes importar y usar!
]],
["Racing.Create.Speedlimit"] = [[
# -- ¡Los corredores IA van a ir rápido por la pista!

Al poner puntos de control, tendrás que definir la velocidad que la IA tomará.
Si la IA va muy rápido, tendrás que cambiar el límite de velocidad que encontrarás en los ajustes de [string:tool.uvracemanager.name].
Si tienes una carrera ya cargada, puedes presionar [+attack2] en el punto de control para editarlo y aplicar el límite de velocidad actualizado.
Alternativamente, puedes editar el ultimo numero en el archivo "race data".
]],

-- Persecuciones
["Pursuit.Starting"] = [[
# -- ¿Cómo empiezo una persecución?

 |-- Ve a [string:uv.pm]
 |-- Haz click en [string:uv.pm.pursuit.start]
 |-- Alternativamente, conduce agresivamente o colisiona con una unidad policial
 |-- ¡Y allí vas!
]],

["Pursuit.JoinAsUnit"] = [[
# -- ¿Puedo unirme a la persecución como unidad policial?

¡Sí que puedes! y es simple:
 |-- Ve a [string:uv.pm] o a [string:uv.menu.welcome]
 |-- Haz click en [string:uv.pm.spawnas]
 |-- Elige el vehículo que quieras conducir
 |-- ¡Y allí vas!
]],
["Pursuit.Respawn"] = [[
# -- ¡Estoy atascado o muy lejos de el/los sospechoso(s)! ¿Cómo reaparezco?

 |-- Presiona [key:unitvehicle_keybind_resetposition] para abrir el menú [string:uv.pm.spawnas]
 |-- Elige el vehículo con el que quieras reaparecer
 |-- ¡Y allí vas!
 
**A tener en cuenta**
 |-- Si reapareces una vez, tendrás que esperar un momento antes de que lo vuelvas a hacer.
]],
["Pursuit.CreateUnits"] = [[
# -- Quiero crear unidades ¿Qué hago?

Esto es lo que harás:
 |-- 1. Saca la herramienta [string:tool.uvunitmanager.name]
 |-- 2. Aparece cualquier vehículo
 |-- 3. Presiona [+attack2] en el vehículo
 |-- 4. Dale un nombre único a la unidad
 |-- 5. (Opcional) selecciona el nivel de persecución en el cual la unidad aparecerá
 |-- 6. (Opcional) ajusta otros valores como creas que encajen mejor
 |-- 7. Haz click en [string:uv.tool.create]
 
Ahora aplica la unidad a través de la herramienta [string:tool.uvunitmanager.name]. Ahora podrás enfrentar a esa unidad o usarla para atrapar sospechosos.
]],
["Pursuit.Roadblocks"] = [[
# -- Quiero crear bloqueos. ¿Qué hago?

Tienes que usar la herramienta [string:tool.uvroadblock.name]:
 |-- 1. Usando la herramienta, crea los objetos y piezas necesarias para el bloqueo.
 |-- 2. Usando la herramienta [string:tool.weld.name] (o cualquier alternativa), suelda todos los objetos y piezas juntos.
 |-- 3. Una vez soldados, presiona [+attack2] en cualquier objeto del bloqueo.
 |-- 4. Cambia los ajustes a cómo te parezcan mejor, después haz click en [string:uv.tool.create]
 
El bloqueo ahora aparecerá aleatoriamente cuando una persecución se encuentre activa.
]],
["Pursuit.Pursuitbreaker"] = [[
# -- Quiero crear pausas de persecución. ¿Qué hago?

Usa la herramienta [string:tool.uvpursuitbreaker.name]:
 |-- 1. Crea los objetos y piezas necesarias para la pausa de persecución.
 |-- 2. Usando la herramienta [string:tool.weld.name] (o cualquier alternativa), suelda todos los objetos y piezas juntos.
 |-- 3. Una vez soldados, presiona [+attack2] en cualquier objeto de la pausa de persecución.
 |-- 4. Cambia los ajustes a cómo te parezcan mejor, después haz click en [string:uv.tool.create]
]],

["Other.CreateTraffic"] = [[
# -- ¿Cómo aparezco tráfico?

Esto es lo que harás:
 |-- 1. Saca la herramienta [string:tool.uvtrafficmanager.name] 
 |-- 2. Aparece cualquier vehículo
 |-- 3. Presiona [+attack2] en el vehículo
 |-- 4. Dale un nombre único al vehículo
 |-- 5. (Opcional) ajusta otros valores como creas que encajen mejor
 |-- 6. Haz click en [string:uv.tool.create]
 
Puedes cambiar los ajustes generales en la tabla [string:uv.tm] en el menú de UV.
]],
["Other.PursuitTech"] = [[
# -- ¿Que son las tecnologías de persecución?

Las tecnologías de persecución son una serie de armas y dispositivos de apoyo utilizados por corredores y las unidades policiales.
Puedes aplicar hasta 2 tecnologías de persecución a tu vehículo para luchar contra tus oponentes o defenderte de ellos.

Así es como se aplican y usan:
 |-- 1. Saca la herramienta [string:tool.uvpursuittech.name]
 |-- 2. Elige la tecnología de persecución que quieres usar como corredor o como unidad policial.
 |-- 3. Presiona [+attack] en tu vehículo o unidad
 
Ahora puedes presionar [key:unitvehicle_pursuittech_keybindslot_1] y [key:unitvehicle_pursuittech_keybindslot_2] para activar tus tecnologías de persecución mientras manejas!
]],
["Other.RenameAI"] = [[
# -- ¿Puedo renombrar los corredores IA y las unidades?

Si puedes. Y es simple:
 |-- 1. Saca la herramienta [string:tool.uvnamechanger.name]
 |-- 2. Escribe el nombre que quieres que la IA tenga
 |-- 3. Presiona [+attack] en el corredor IA o unidad
]],
["Other.DataFolder"] = [[
# -- ¿Donde se guardan mis datos de UV?

Puedes encontrar tus datos relacionados con UV guardados en el directorio *data/unitvehicles* de tu juego.
]],
}

-- Русский (Russian) ru
UV.FAQ["ru"] = {
-- Introduction
["Intro"] = [[
# -- О чём этот аддон?

Unit Vehicles - это аддон, ориентированный на песочницу, который позволяет игрокам в Мультиплеере с другими или Синглплеере с ИИ учавствовать в высокоскоростных погонях за или против полиции (Юнитов), а также в захватывающих гонках на любой карте. 

**Поддерживаемые базы машин на данный момент:**
 |-- prop_vehicle_jeep (стандартная база машин)
 |-- simfphys
 |-- Glide (требуется и настоятельно рекомендуется)
]],
["Requirements"] = [[
# -- Требуется ли мне устанавливать другие аддоны?

Да. *Decent Vehicle - Basic AI* и *Glide // Styled's Vehicle Base* требуется для Unit Vehicles для правильного функционирования.
 |-- Decent Vehicle предоставляет точки для ИИ для их размещения и езды по карте.
 |-- Glide предоставляет машины, нужные для использования стандартного пресета.
]],
["Github"] = [[
# -- Есть ли у этого аддона репозиторий на GitHub?

Да. В данный момент он приватный до официального релиза. 
]],
["Roadmap"] = [[
# -- Как я могу быть в курсе последних обновлений? Есть ли дорожная карта?

Ты можешь отслеживать нас на нашей странице в Trello или на нашем Discord сервере, которые можно найти на нашей странице в Мастерской.
]],
["ConVars"] = [[
# -- Какие есть консольные команды, которые я могу использовать?

 |-- uv_spawnvehicles - Размещает патрулирующих ИИ Юнитов
 |-- uv_setheat [x] - Устанавливает Уровень Жары
 |-- uv_despawnvehicles - Удаляет патрулирующих ИИ Юнитов
 |-- uv_resetallsettings - Сбрасивает все серверные настройки до их изначальных значений
 |-- uv_startpursuit - Начинает отсчёт до начала погони
 |-- uv_stoppursuit - Останавливает погоню с ИИ Юнитами, предполагая ваш побег
 |-- uv_wantedtable - Выводит список разыскиваемых подозреваемых в консоль
 |-- uv_clearbounty - Устанавливает значение награды на 0
 |-- uv_setbounty [x] - Устанавливает значение награды
 |-- uv_spawn_as_unit - Позволяет вам присоединиться в качестве Юнита
]],

-- Racing
["Racing.Joining"] = [[
# -- Как мне присоединяться к гонкам?

Если кто-то приготовил гонку, а затем отправил приглашение, у тебя появится уведомление на экране, предполагая, что ты в машине и не в погоне.
]],

["Racing.SpawnAI"] = [[
# -- Как мне устроить гонку с ИИ?

Есть два способа сделать это:

**Вариант 1**
 |-- 1. Разместить любую машину Glide, Simfphys или HL2 Jeep.
 |-- 2. Использовать инструмент [string:tool.uvracermanager.name].
 |-- 3. Нажать [+attack2] по машине.
 |-- 4. Изменить настройки на свой вкус, а затем нажать [string:uv.tool.create].
 |-- 5. Повторить для каждой машины, которую ты хочешь, чтобы её использовала ИИ.
 
**Вариант 2 (Рекомендуется)**
 |-- 1. Открыть вкладку [string:uv.airacer].
 |-- 2. Включить [string:uv.airacer.override].
 |-- 3. В списке ниже, открой меню, содержащее машины и нажми [+attack2] чтобы добавить машины для списка ИИ машин

**Примечания**
 |-- Убедись, что значение [string:uv.tool.base.title] соответсвует твоей желаемой базе.
]],

["Racing.Resetting"] = [[
# -- Я застрял! Как мне вернуться?

 |-- Нажми [key:unitvehicle_keybind_resetposition] чтобы вернуть свою машину
 |-- Подожди 3 секунды
 |-- Ты вернулся на последнюю пройденную контрольную точку!
 
**Примечания**
 |-- Ты не сможешь вернуться во время ареста
 |-- Ты не сможешь вернуться во время движения
]],

["Racing.Starting"] = [[
# -- Как мне начать гонку?

Начать гонку, переходя в [string:uv.rm] в UV Меню:
 |-- Нажми [string:uv.rm.loadrace]
 |-- Выбери любую гонку из списка
 |-- Пригласи других гонщиков или нажми [string:uv.rm.startrace]
 |-- Ты можешь сразу начать гонку или автоматически разместить ИИ, чтобы они присоединились к гонке


*Примечания*
 |-- Должно быть хотя бы 1 Место Старта, чтобы начать гонку!
 |-- Ты можешь пригласить друзей/ИИ Гонщиков нажатием [string:uv.rm.sendinvite] до нажатия [string:uv.rm.startrace] до тех пор, пока гонка загружена
 |-- Если нет имеющихся гонок, ты можешь создать свою
 |-- Или же ты можешь найти некоторые в Мастерской!
]],

["Racing.Create"] = [[
# -- Как мне создавать гонки?
Use the [string:tool.uvracemanager.name] tool:


*-- Шаг 1: Создай Контрольные Точки*
 |-- Нажми [+attack] в одном месте, чтобы начать установку контрольной точки
 |-- Нажми [+attack] по другому месту, чтобы закончить установку
 |-- Совет: Нажми [+use] чтобы повысить высоту контрольной точки автоматически
 

*-- Шаг 2: Размести Контрольные Точки по порядку*
 |-- Нажми [+attack2] по контрольной точке.
 |-- Введи ID для Контрольной Точки
 |-- Убедись, что ID в правильной последовательности
 |-- Для разветвляющихся контрольных точек используй совпадающие ID
 |-- ИИ всегда будет использовать последний установленный ID контрольной точки
 

*-- Шаг 3: Создай Места Старта*
 |-- Нажми [+reload] чтобы разместить Места Старта
 |-- Номера на местах отображают порядок старта
 |-- Хочешь больше гонщиков? Размести больше мест!
 

*-- Шаг 4: Экспортируй Гонку*
 |-- Закончил с гонкой? Открой Спавнменю и нажми [string:tool.uvracemanager.settings.saverace]
 |-- Назови её
 |-- Она отобразится как гонка, которую ты можешь импортировать, а затем начать гонку!
]],
["Racing.Create.Speedlimit"] = [[
# -- ИИ Гонщики слишком быстро ездят по трассе!

Во время размещения контрольных точек, тебе нужно решить, с какой скоростью ИИ будет ездить.
Если ИИ ездит слишком быстро, тебе нужно изменить значение ограничения скорости, найденное в [string:tool.uvracemanager.name] настройках.
Если у тебя есть уже загруженная гонка, ты можешь нажать [+attack2] по Контрольной Точке, чтобы изменить её и принять обновлённое ограничение скорости.
Или же ты можешь изменить последний номер в файле данных гонки.
]],

-- Pursuits
["Pursuit.Starting"] = [[
# -- Как мне начать погоню?

 |-- Отправляйся в [string:uv.pm]
 |-- Нажми [string:uv.pm.pursuit.start]
 |-- Или же превышай скорость или врежься в Юнита
 |-- Уходи скорей!
]],

["Pursuit.JoinAsUnit"] = [[
# -- Могу ли я присоединиться к Погоне в качестве Юнита?

Да, ты можешь! И это просто:
 |-- Отправляйся в [string:uv.pm] или [string:uv.menu.welcome]
 |-- Нажми [string:uv.pm.spawnas]
 |-- Выбери машину, на которой хочешь ехать
 |-- Поезжай!
]],
["Pursuit.Respawn"] = [[
# -- Я застрял или слишком далеко от подозреваемого(мых)! Как мне вернуться?

 |-- Нажми [key:unitvehicle_keybind_resetposition] чтобы открыть меню [string:uv.pm.spawnas]
 |-- Выбери машину, на которой ты хочешь вернуться
 |-- Поезжай!
 
**Примечания**
 |-- Если ты вернулся один раз, тебе нужно подождать немного времени, чтобы сделать это снова
]],
["Pursuit.CreateUnits"] = [[
# -- Я хочу создать Юнитво. Что мне нужно сделать?

Вот что тебе нужно сделать:
 |-- 1. Используй инструмент [string:tool.uvunitmanager.name]
 |-- 2. Поставь любую машину
 |-- 3. Нажми [+attack2] по машине
 |-- 4. Выбери уникальное имя Юниту
 |-- 5. (Необязательно) Выбери Уровень Жары, на котором Юнит появляется
 |-- 6. (Необязательно) Сделай изменения, которые могут быть уместны
 |-- 7. Нажми [string:uv.tool.create]
 
Теперь прими Юнита с помощью инструмента [string:tool.uvunitmanager.name] и либо ты встретишься с Юнитом, которого ты создал, либо тебе позволят играть за Юнита против сбегающих подозреваемых.
]],
["Pursuit.Roadblocks"] = [[
# -- Я хочу создать Заграждения. Что мне нужно сделать?

Ты используешь инструмент [string:tool.uvroadblock.name]:
 |-- 1. Используя его, размести пропы и части, нужные для Заграждения
 |-- 2. Используя инструмент [string:tool.weld.name] (или любую другую альтернативу), свари все части вместе
 |-- 3. Как только всё сварено, нажми [+attack2] по любой части Заграждения
 |-- 4. Измени настройки на свой вкус, затем нажми [string:uv.tool.create]
 
Заграждения будет появляться случайно во время погони.
]],
["Pursuit.Pursuitbreaker"] = [[
# -- Я хочу создать Погонеломы. Что мне нужно сделать?

You use the [string:tool.uvpursuitbreaker.name] tool:
 |-- 1. Размести пропы и части, нужные для Погонелома
 |-- 2. Используя инструмент [string:tool.weld.name] (или любую другую альтернативу), свари все части вместе
 |-- 3. Как только всё сварено, нажми [+attack2] по любой части Погонелома
 |-- 4. Измени настройки на свой вкус, затем нажми [string:uv.tool.create]
]],

["Other.CreateTraffic"] = [[
# -- Как мне разместить трафик?

Вот что тебе нужно сделать?:
 |-- 1. Используй инструмент [string:tool.uvtrafficmanager.name]
 |-- 2. Поставь любую машину
 |-- 3. Нажми [+attack2] по машине
 |-- 4. Выбери уникальное имя
 |-- 5. (Необязательно) Сделай изменения, которые могут быть уместны
 |-- 6. Нажми [string:uv.tool.create]
 
Ты можешь изменить общие настройки во вкладке [string:uv.tm] UV Меню.
]],
["Other.PursuitTech"] = [[
# -- Что такое Технология Погони?
Технология погони - это серия оружий и устройств поддержки, исползуемые как Гонщиками, так и Юнитами.
Ты можешь применить только 2 Технологии Погони на свой автомобиль, чтобы сражаться с соперниками или защитить себя.

Вот как можно применить и использовать их:
 |-- 1. Используй инструмент [string:tool.uvpursuittech.name]
 |-- 2. Выбери Технологию Погони, которую ты хочешь использовать за Гонщика или Юнита
 |-- 3. Нажми [+attack] по своей машине или Юниту
 
Теперь ты можешь нажать [key:unitvehicle_pursuittech_keybindslot_1] и [key:unitvehicle_pursuittech_keybindslot_2] чтобы активировать Технологию Погони во время вождения!
]],
["Other.RenameAI"] = [[
# -- Могу ли я переименовать ИИ Гонщиков и Юнитов?

Да, ты можешь. И это просто:
 |-- 1. Используй инструмент [string:tool.uvnamechanger.name]
 |-- 2. Введи имя, которые ты хочешь применить для ИИ
 |-- 3. Нажми [+attack] по ИИ Гонщику или Юниту
]],
["Other.DataFolder"] = [[
# -- Где храняться данные UV?

Ты можешь найти данные, связанные с UV, хранящиеся в директории *data/unitvehicles* игры.
]],
}

-- Polska (Polish) pl
UV.FAQ["pl"] = {
-- Introduction
["Intro"] = [[
# -- Czym jest ten dodatek?

Unit Vehicles to dodatek stworzony z myślą o trybie Piaskownicy, który pozwala graczom ścigać się z Policją (Jednostkami) niezależnie od ilości osób. Gracze mogą wcielić się zarówno w Poszukiwanego lub Jednostkę, oraz tworzyć i uczestniczyć w wyścigach na określonej trasie.

**Lista wspieranych baz pojazdów:**
 |-- prop_vehicle_jeep (podstawowy Jeep z HL2)
 |-- simfphys
 |-- Glide (wymagane i zalecane)
]],
["Requirements"] = [[
# -- Czy potrzebuję innych dodatków aby ten działał?

Tak. *Decent Vehicle - Basic AI* i *Glide // Styled's Vehicle Base* są WYMAGANE do poprawnego działania Unit Vehicles.
 |-- Decent Vehicle odpowiedzialne jest za punkty nawigacyjne dla pojazdów kontrolowanych przez SI.
 |-- Glide dodaje pojazdy używane w domyślnych ustawieniach.
]],
["Github"] = [[
# -- Czy ten dodatek posiada Repozytorium na Githubie?

Tak, aczkolwiek do momentu oficjalnego wydania dodatku będzie ono prywatne.
]],
["Roadmap"] = [[
# -- Gdzie mogę przeczytać najnowsze zmiany? Jest jakiś plan działania?

Możesz obserwować naszą stronę na Trello lub dołączyć na Discorda. Oba linki znajdziesz na stronie dodatku na Warsztacie Steam.
]],
["ConVars"] = [[
# -- Jakich komend mogę użyć?

 |-- uv_spawnvehicles - Pojawia patrolujące jednostki SI
 |-- uv_setheat [x] - Ustawia Poziom Obławy
 |-- uv_despawnvehicles - Usuwa patrolujące Jednostki SI
 |-- uv_resetallsettings - Resetuje wszystkie ustawienia do domyślnych wartości
 |-- uv_startpursuit - Rozpoczyna pościg po odliczeniu
 |-- uv_stoppursuit - Zatrzymuje pościg zakładając że zakończył się ucieczką
 |-- uv_wantedtable - Drukuje listę poszukiwanych w konsoli
 |-- uv_clearbounty - Ustawia notowania na 0
 |-- uv_setbounty [x] - Ustawia notowania na wpisaną liczbę
 |-- uv_spawn_as_unit - Pojawia Cię jako Jednostka
]],

-- Racing
["Racing.Joining"] = [[
# -- Jak dołączyć do Wyścigu?

Jak gracz przygotuje Wyścig i Cię zaprosi, dostaniesz powiadomienie na ekranie pod warunkiem że znajdujesz się w pojeździe i nie goni Cię policja.
]],

-- ["Racing.SpawnAI"] = [[
-- # -- How do I race with AI?

-- There are two ways of doing that:

-- **Option 1**
 -- |-- 1. Spawn any Glide, Simfphys or HL2 Jeep vehicle.
 -- |-- 2. Pull out the [string:tool.uvracermanager.name] tool.
 -- |-- 3. Press [+attack2] on the vehicle.
 -- |-- 4. Tweak the settings to your liking, then click [string:uv.tool.create].
 -- |-- 5. Repeat for every vehicle you want the AI to use.
 
-- **Option 2 (Recommended)**
 -- |-- 1. Open the [string:uv.airacer] tab.
 -- |-- 2. Enable [string:uv.airacer.override].
 -- |-- 3. In the list below the option, open the menus containing cars and press [+attack2] to add the vehicles to an AI vehicle list

-- **Notes**
 -- |-- Ensure the [string:uv.tool.base.title] variable matches your desired base.
-- ]],

["Racing.Resetting"] = [[
# -- Samochód utknął! Co robić?

 |-- Wciśnij [key:unitvehicle_keybind_resetposition] aby zresetować pozycję pojazdu
 |-- Poczekaj 3 sekundy
 |-- Twój samochód pojawi się na ostatnim przejechanym pkcie kontrolnym!
 
**Uwagi**
 |-- Nie można zresetować podczas aresztowania
 |-- Nie można zresetować podczas jazdy
]],


["Racing.Starting"] = [[
# -- Jak rozpocząć Wyścig?

Rozpocząć Wyścig można w [string:uv.rm] w oknie UV:
 |-- Wciśnij [string:uv.rm.loadrace]
 |-- Wybierz trasę z listy
 |-- Zaproś innych graczy lub wciśnij [string:uv.rm.startrace]
 |-- Możesz od razu rozpocząć Wyścig, lub pojawić SI które do niego dołączą


*Uwagi*
 |-- Potrzebne jest co najmniej 1 miejsce startowe do rozpoczęcia!
 |-- Możesz zaprosić graczy/SI wciskając [string:uv.rm.sendinvite] a następnie [string:uv.rm.startrace] o ile Wyścig jest wczytany
 |-- Jeśli nie istnieje gotowa trasa, musisz stworzyć nową
 |-- Ewentualnie możesz przeszukać Warsztat Steam!
]],


["Racing.Create"] = [[
# -- Jak stworzyć Wyścig?
Przy użyciu narzędzia [string:tool.uvracemanager.name]:


*-- Krok 1: Utwórz pkt kontrolne*
 |-- Wciśnij [+attack] w pierwszym rogu by zacząć kłaść pkt kontrolny
 |-- Wciśnij [+attack] w drugim aby postawić pkt kontrolny
 |-- Wskazówka: Przytrzymaj [+use] by automatycznie zwiększyć wysokość pkt kontrolnych.


*-- Krok 2: Ustaw dobrą kolejność pkt kontrolnych*
 |-- Wciśnij [+attack2] na danym pkcie.
 |-- Wpisz ID pktu
 |-- Upewnij się że ID pktów są w ciągu
 |-- Rozgałęzione pkty używają tego samego ID
 |-- SI zawsze będą używać ostatniego położonego ID pktu


*-- Krok 3: Utwórz miejsca startowe*
 |-- Wciśnij [+reload] aby położyć miejsce startowe
 |-- Numery na slotach pokazują kolej startowania
 |-- Chcesz więcej zawodników? Połóż więcej miejsc startowych!


*-- Krok 4: Eksportuj Wyścig*
 |-- Wyścig gotowy? Otwórz Spawnmenu i wciśnij [string:tool.uvracemanager.settings.saverace]
 |-- Nadaj trasie nazwę
 |-- Od teraz trasa będzie pokazywać się jako Wyścig do zaimportowania i rozpoczęcia!
]],
["Racing.Create.Speedlimit"] = [[
# -- Zawodnicy SI osiągają zbyt duże prędkości!


Przy tworzeniu pkt kontrolnych, musisz ustalić prędkość z jaką SI będzie starało się przez niego przejechać.
Jeśli SI jedzie zbyt szybko, będzie trzeba zmienić wartość limitu prędkości w ustawieniach [string:tool.uvracemanager.name].
Jeśli wyścig jest już wczytany, możesz wcisnąć [+attack2] na pkt kontrolny żeby go edytować i ustawić wybraną wartość limitu prędkości.
Zamiast tego możesz też zmienić ostatnią liczbę w pliku danych wyścigu.
]],


-- Pursuits
["Pursuit.Starting"] = [[
# -- Jak rozpocząć Pościg?

 |-- Otwórz [string:uv.pm]
 |-- Kliknij [string:uv.pm.pursuit.start]
 |-- Ewentualnie uderz w Jednostkę lub jeździj nieostrożnie w jej pobliżu.
 |-- Gaz do dechy!
]],


["Pursuit.JoinAsUnit"] = [[
# -- Mogę dołączyć do Pościgu jako Jednostka?

Tak! To dość proste:
 |-- Otwórz [string:uv.pm] lub [string:uv.menu.welcome]
 |-- Kliknij [string:uv.pm.spawnas]
 |-- Wybierz pojazd do którego chcesz wsiąść
 |-- Powodzenia!
]],
["Pursuit.Respawn"] = [[
# -- Auto utknęło lub jestem zbyt daleko od akcji! Jak je zresetować?

 |-- Wciśnij [key:unitvehicle_keybind_resetposition] aby otworzyć okno [string:uv.pm.spawnas]
 |-- Wybierz pojazd w którym chcesz się zresetować
 |-- Miłych gonitw!
 
**Uwagi**
 |-- Po zresetowaniu musisz odczekać chwilę
]],
["Pursuit.CreateUnits"] = [[
# -- Chcę stworzyć Jednostki. Jak to zrobić?

W ten sposób:
 |-- 1. Wyciągnij narzędzie [string:tool.uvunitmanager.name]
 |-- 2. Pojaw jakikolwiek pojazd
 |-- 3. Naciśnij [+attack2] na pojazd
 |-- 4. Daj Jednostce unikatowe imię
 |-- 5. (Opcjonalnie) Wybierz Poziom Obławy na którym Jednostka będzie się pojawiać
 |-- 6. (Opcjonalnie) Przestaw inne wartości według uznania
 |-- 7. Wciśnij [string:uv.tool.create]
 
Potwierdź zmiany używając narzędzia [string:tool.uvunitmanager.name], i Jednostka pojawi się przed tobą. Ewentualnie możesz pojawić się jako ta Jednostka.
]],
["Pursuit.Roadblocks"] = [[
# -- Chcę stworzyć blokady. Jak?

Użyj narzędzia [string:tool.uvroadblock.name]:
 |-- 1. Używając narzędzia, postaw obiekty i części niezbędne dla blokady
 |-- 2. Zespawaj wszystkie części używając narzędzia [string:tool.weld.name] (lub alternatyw) 
 |-- 3. Po zespawaniu, wciśnij [+attack2] na którykolwiek obiekt blokady
 |-- 4. Zmień ustawienia według uznania, następnie wciśnij [string:uv.tool.create]
 
Blokada będzie pojawiać się losowo podczas Pościgów.
]],
["Pursuit.Pursuitbreaker"] = [[
# -- Chcę stworzyć Spowalniacz Pościgu. Jak?

Używając narzędzia [string:tool.uvpursuitbreaker.name]:
 |-- 1. Pojaw obiekty i części z których będzie składać się Spowalniacz
 |-- 2. Zespawaj wszystkie części używając narzędzia [string:tool.weld.name] (lub alternatyw)
 |-- 3. Po zespawaniu, wciśnij [+attack2] na którykolwiek obiekt Spowalniacza
 |-- 4. Zmień ustawienia według uznania, następnie wciśnij [string:uv.tool.create]
]],


["Other.CreateTraffic"] = [[
# -- Jak pojawić Ruch Drogowy?

W następujący sposób:
 |-- 1. Wyciągnij narzędzie [string:tool.uvtrafficmanager.name]
 |-- 2. Pojaw dowolny pojazd
 |-- 3. Naciśnij [+attack2] na pojazd
 |-- 4. Nadaj mu unikatowe imię
 |-- 5. (Opcjonalnie) Dostosuj ustawienia według uznania
 |-- 6. Wciśnij [string:uv.tool.create]
 
Możesz zmienić ustawienia ogólne w zakładce [string:uv.tm] w oknie UV.
]],
["Other.PursuitTech"] = [[
# -- Czym są Narzędzia Pościgu?

Narzędzia Pościgu to zbiór broni i narzędzi używanych zarówno przez Jednostki jak i Podejrzanych.
Możesz nałożyć maksymalnie 2 Narzędzia na swój pojazd aby łatwiej aresztować Podejrzanych lub łatwiej uciec.


Tak się je nakłada i używa:
 |-- 1. Wyciągnij narzędzie [string:tool.uvpursuittech.name]
 |-- 2. Wybierz Narzędzia Pościgu jakie chcesz posiadać jako Jednostka lub Podejrzany
 |-- 3. Wciśnij [+attack] w swoim pojeździe
 
Możesz wcisnąć [key:unitvehicle_pursuittech_keybindslot_1] i [key:unitvehicle_pursuittech_keybindslot_2] aby użyć Narzędzi podczas Pościgu!
]],
["Other.RenameAI"] = [[
# -- Mogę zmienić imię Zawodnikom lub Jednostkom SI?

Tak, i całkiem to proste:
 |-- 1. Wyciągnij narzędzie [string:tool.uvnamechanger.name]
 |-- 2. Wpisz nowe imię dla SI
 |-- 3. Wciśnij [+attack] na SI
]],
["Other.DataFolder"] = [[
# -- Gdzie przechowywane są dane UV?

Dane związane z UV znajdziesz w folderze *data/unitvehicles*.
]],
}

-- 简体中文 (Chinese Simplified) zh-CN
UV.FAQ["zh-CN"] = {
-- Introduction
["Intro"] = [[
# -- 这是个什么样插件？

Unit Vehicles 是一款面向沙盒玩法的插件，让玩家无论是在多人模式还是与 AI 对战的单人模式中，都能在任何地图上体验高速警匪追逐与紧张刺激的竞速比赛。

**目前已支持的载具Base包括：**
 |-- prop_vehicle_jeep (原生载具Base)
 |-- simfphys
 |-- Glide (必要且强烈推荐)
]],
["Requirements"] = [[
# -- 我还需要为此安装其他插件吗？

是的。 *Decent Vehicle - Basic AI* 与 *Glide // Styled's Vehicle Base* 正常运行所必需的的必装前置插件。
 |-- Decent Vehicle 为 AI 提供生成点与巡逻路径，使 AI 能够在地图中生成并自由活动。
 |-- Glide 提供默认预设所需使用的车辆资源。
]],
["Github"] = [[
# -- 这个插件有GitHub代码仓库吗？

是的。目前仍处于私有状态，待正式发布后才会公开。
]],
["Roadmap"] = [[
# -- 如何获取最新更新？是否有开发导向图？

你可以通过关注我们的 Trello 页面，或加入我们的 Discord 服务器来获取最新动态。这两个链接都可以在我们的创意工坊页面中找到。
]],
["ConVars"] = [[
# -- 有哪些可以使用的控制台命令？

 |-- uv_spawnvehicles - 生成巡逻中的 AI 单位
 |-- uv_setheat [x] - 设置热度等级
 |-- uv_despawnvehicles - 移除所有巡逻中的 AI 单位
 |-- uv_resetallsettings - 将所有服务器设置重置为默认值
 |-- uv_startpursuit - 开始一次追逐前的倒计时
 |-- uv_stoppursuit - 停止当前追逐（AI 单位将认为你已成功逃脱）
 |-- uv_wantedtable - 在控制台中输出当前被通缉的嫌疑人列表
 |-- uv_clearbounty - 将悬赏值重置为 0
 |-- uv_setbounty [x] - 设置悬赏值
 |-- uv_spawn_as_unit - 允许你以单位身份加入
]],

-- Racing
["Racing.Joining"] = [[
# -- 我该如何加入比赛？

如果有人已经创建了一场比赛并向你发送了邀请，在你处于车辆中且当前没有进行中的追逐的情况下，你将会收到一个屏幕提示通知，邀请你加入该比赛。
]],

["Racing.SpawnAI"] = [[
# -- 我该如何与 AI 进行比赛？

有两种方式可以实现：

**方式一**
 |-- 1. 生成任意一辆 Glide、Simfphys 或 HL2 Jeep 载具。
 |-- 2. 拿出 [string:tool.uvracermanager.name] 工具。
 |-- 3. 对着载具按下 [+attack2]。
 |-- 4. 根据你的需求调整设置，然后点击 [string:uv.tool.create]。
 |-- 5. 对你希望 AI 使用的每一辆载具重复上述步骤。
 
**方式二（推荐）**
 |-- 1. 打开 [string:uv.airacer] 标签页。
 |-- 2. 启用 [string:uv.airacer.override]。
 |-- 3. 在该选项下方的列表中，展开包含车辆的菜单，并对车辆按下 [+attack2]，将其添加到 AI 车辆列表中。

**注意事项**
 |-- 请确保 [string:uv.tool.base.title] 变量与你想要使用的载具Base一致。
]],

["Racing.Resetting"] = [[
# -- 我卡住了！该如何重置？

 |-- 按下 [key:unitvehicle_keybind_resetposition] 重置你的车辆
 |-- 等待 3 秒
 |-- 你将回到最近通过的检查点！
 
**注意事项**
 |-- 被逮捕时无法重置
 |-- 车辆正在移动时无法重置
]],

["Racing.Starting"] = [[
# -- 我该如何开始比赛？

通过 UV 菜单中的 [string:uv.rm] 开始一场比赛：
 |-- 点击 [string:uv.rm.loadrace]
 |-- 从列表中选择任意一场比赛
 |-- 邀请其他赛车手，或直接点击 [string:uv.rm.startrace]
 |-- 你可以立即开始比赛，或让系统自动生成 AI 加入比赛


*注意事项*
 |-- 至少需要一个发车位才能开始比赛！
 |-- 只要已加载比赛，在点击 [string:uv.rm.startrace] 之前，你都可以通过 [string:uv.rm.sendinvite] 邀请好友 / AI 赛车手
 |-- 如果当前没有任何比赛，你需要自己创建一场
 |-- 或者，也可以前往创意工坊查找现成的比赛！
]],

["Racing.Create"] = [[
# -- 我该如何创建比赛？
使用 [string:tool.uvracemanager.name] 工具：


*-- 第一步：创建检查点*
 |-- 在一个角落按下 [+attack] 开始放置检查点
 |-- 在另一个位置按下 [+attack] 完成放置
 |-- 提示：按住 [+use] 可自动增加检查点高度
 

*-- 第二步：按顺序设置检查点*
 |-- 对检查点按下 [+attack2]
 |-- 输入检查点 ID
 |-- 确保 ID 按顺序递增
 |-- 分支检查点需要使用相同的 ID
 |-- AI 始终会使用最后放置的检查点 ID
 

*-- 第三步：创建发车位*
 |-- 按下 [+reload] 放置发车位
 |-- 发车位上的数字代表起跑顺序
 |-- 想要更多赛车手？放置更多发车位即可！
 

*-- 第四步：导出比赛*
 |-- 比赛制作完成后，打开生成菜单，点击 [string:tool.uvracemanager.settings.saverace]
 |-- 为比赛命名
 |-- 现在它将作为一场可导入并进行比赛的赛事出现！
]],
["Racing.Create.Speedlimit"] = [[
# -- AI 赛车在赛道上跑得太快了，怎么办？

在放置检查点时，你需要为 AI 指定通过该检查点时的速度。
如果 AI 速度过快，请调整 [string:tool.uvracemanager.name] 设置中的 speedlimit 数值。
如果当前已经加载了一场比赛，你可以对检查点按下 [+attack2] 进行编辑，并应用新的 speedlimit 设置。
另外，你也可以直接编辑比赛数据文件中最后一个数值来修改该检查点的速度限制。
]],

-- Pursuits
["Pursuit.Starting"] = [[
# -- 我该如何开始一场追逐？

 |-- 前往 [string:uv.pm]
 |-- 点击 [string:uv.pm.pursuit.start]
 |-- 或者，在单位附近高速行驶或进行危险驾驶
 |-- 然后，追逐正式开始！
]],

["Pursuit.JoinAsUnit"] = [[
# -- 我可以作为单位加入追逐吗？

当然可以！而且非常简单：
 |-- 前往 [string:uv.pm] 或 [string:uv.menu.welcome]
 |-- 点击 [string:uv.pm.spawnas]
 |-- 选择你想驾驶的车辆
 |-- 然后，立即加入追逐！
]],
["Pursuit.Respawn"] = [[
# -- 我卡住了，或者离嫌疑人太远了！该如何重置？

 |-- 按下 [key:unitvehicle_keybind_resetposition] 打开 [string:uv.pm.spawnas] 菜单
 |-- 选择你想要重置为的车辆
 |-- 然后，立刻重新加入追逐！
 
**注意事项**
 |-- 每次重置后，都需要等待一小段时间才能再次使用
]],
["Pursuit.CreateUnits"] = [[
# -- 我想创建单位，该怎么做？

按以下步骤操作：
 |-- 1. 取出 [string:tool.uvunitmanager.name] 工具
 |-- 2. 生成任意一辆车辆
 |-- 3. 对该车辆按下 [+attack2]
 |-- 4. 为该单位设置一个唯一名称
 |-- 5.（可选）选择该单位出现的热度等级
 |-- 6.（可选）根据需要调整其他数值
 |-- 7. 点击 [string:uv.tool.create]
 
完成后，通过 [string:tool.uvunitmanager.name] 工具应用该单位。此后，你将可能在追逐中面对你创建的单位，或作为该单位加入追逐，对抗逃跑的嫌疑人。
]],
["Pursuit.Roadblocks"] = [[
# -- 我想创建路障，该怎么做？

使用 [string:tool.uvroadblock.name] 工具：
 |-- 1. 使用该工具创建构成路障所需的道具和部件
 |-- 2. 使用 [string:tool.weld.name] 工具（或任意替代工具）将所有部件焊接在一起
 |-- 3. 焊接完成后，对路障的任意一个部件按下 [+attack2]
 |-- 4. 根据需要调整设置，然后点击 [string:uv.tool.create]
 
完成后，该路障将在追逐进行时随机生成并出现。
]],
["Pursuit.Pursuitbreaker"] = [[
# -- 我想创建追逐破坏器，该怎么做？

使用 [string:tool.uvpursuitbreaker.name] 工具：
 |-- 1. 创建构成追逐破坏器所需的道具和部件
 |-- 2. 使用 [string:tool.weld.name] 工具（或任意替代工具）将所有部件焊接在一起
 |-- 3. 焊接完成后，对追逐破坏器的任意一个部件按下 [+attack2]
 |-- 4. 根据需要调整设置，然后点击 [string:uv.tool.create]
]],

["Other.CreateTraffic"] = [[
# -- 我该如何生成交通车辆？

按以下步骤操作：
 |-- 1. 取出 [string:tool.uvtrafficmanager.name] 工具
 |-- 2. 生成任意一辆车辆
 |-- 3. 对车辆按下 [+attack2]
 |-- 4. 为该车辆设置一个唯一名称
 |-- 5.（可选）根据需要调整相关参数
 |-- 6. 点击 [string:uv.tool.create]
 
之后，你可以在 UV 菜单中的 [string:uv.tm] 标签页里调整交通系统的通用设置。
]],
["Other.PursuitTech"] = [[
# -- 什么是追击科技？

追击科技是一系列可供赛车手和单位使用的武器与辅助装置。
你最多可以为你的车辆安装两种追击科技，用于进攻对手或进行自我防御。

以下是安装与使用方法：
 |-- 1. 取出 [string:tool.uvpursuittech.name] 工具
 |-- 2. 选择你想作为赛车手或单位使用的追击科技
 |-- 3. 对你的车辆或单位按下 [+attack]
 
安装完成后，在驾驶过程中，你可以按下 [key:unitvehicle_pursuittech_keybindslot_1] 和 [key:unitvehicle_pursuittech_keybindslot_2] 来激活对应的追击科技！
]],
["Other.RenameAI"] = [[
# -- 我可以重命名 AI 赛车手和单位吗？

当然可以，而且非常简单：
 |-- 1. 取出 [string:tool.uvnamechanger.name] 工具
 |-- 2. 输入你希望 AI 使用的名称
 |-- 3. 对 AI 赛车手或单位按下 [+attack]
]],
["Other.DataFolder"] = [[
# -- 我的 UV 数据存放在哪里？

所有与 UV 相关的数据都存储在游戏目录下的 *data/unitvehicles* 文件夹中。
]],
}