/////////////
//Nothing to see here yet, but I'm going to note down a cool thing I saw on the byond forums:

/*
var/list/teams = list()     // a global list of teams

team
  var/name
  var/list/players
  var/score = 0

  var/colorrgb
  var/teamicon

  New(mob/M, nm, r, g, b)   // player M starts a new team
    name = nm
    players = list()
    SetColor(r, g, b)
    Add(M)          // add M to the team
    teams += src    // add this team to the global list

  Del()
    teams -= src    // take this off the global teams list
    for(var/mob/M in players)
        M << "[name] disbands."
        M.team = null
        M.icon = initial(M.icon)
    ..()    // always call this at the end of Del()

  proc/SetColor(r,g,b)
    colorrgb = rgb(r, g, b)
    var/icon/ic = new('team_player.dmi')
    ic.Blend(colorrgb, ICON_MULTIPLY)
    teamicon = fcopy_rsc(ic)    // convert the /icon to a .dmi
    for(var/mob/M in players)
      M.icon = teamicon         // change color

  proc/Add(mob/M)
    if(M.team)
      if(M.team == src) return
      M.team.Remove(M)
    players << "[M.name] joins the team."
    players += M
    M << "You [(players.len>1)?"join":"form"] [name]."
    M.team = src
    M.icon = teamicon

  proc/Remove(mob/M)
    if(M.team == src)
      M.team = null
      M.icon = initial(M.icon)
      players -= M
      players << "[M.name] leaves the team."
      M << "You [(players.len)?"leave":"disband"] [name]."
      if(!players.len) del(src)     // if the team is empty, delete it

mob
  icon='player.dmi'
  var/team/team     // which team am I on?
*/

//Star Trek 13

var/global/list/factionRosters[][] = list(list("Independent Roster"),
									  list("Starfleet Roster"),
									  list("Klingon Roster"))
//first bracket contains the actual rosters of the factions, second brackets contain the mobs
//eg factionRosters[1][1] would get the first member of the first faction
//   factionRosters[2][1] would get the first member of the second faction

/datum/faction	//a holder datum for sorting players
	var/name = "a faction"
	var/list/members = list()
	var/description = "why are you seeing this."
	var/datum/species/required_race = null //Framework for having race only empires, IE if you want to be klingon you have to be klingon.
	var/flavourtext = "you shouldnt be here" //Sent to all new members upon recruitment.
	var/player_requirement = 0 //Is this population locked?
	var/pref_colour = "green" //Color that the background goes if this faction is selected in preferences
	var/obj/effect/spawns = list()
	var/faction_occupations = list()//List of occupations in this faction.
	var/datum/objective/current_objective //only one at a time, please.. These constantly check for completion. ~Cdey
	var/datum/objective/objectives = list()//IF there are multiple objectives. Also currently unused. ~Cdey
	var/credits = 10000 //Credits determine who wins, you lose credits as you lose ships, so stay safe friends!
	var/factag = "none" //Faction icon tag
	var/datum/species/speciestype = null
	var/locked = FALSE //Lock this one at roundstart?
	var/ships = 0 //How many ships have we built? PREVENT THE ROMULAN POWERBALL
	var/max_ships = 18
	var/metal = 0//used as a win condition
	var/dilithium = 0
	var/points = 0
/*
/datum/faction/independant
	name = "independant"
	description = "An independant faction, freelancers, traders, or even pirates, these people choose their own path and forge their own journey."
	flavourtext = "You are your own person, and no power hungry faction will tell you otherwise. You are in a group of likeminded people, to call your organization a true faction would be inapropriate. Create your own path." //Sent to all new members upon recruitment.
	pref_colour = "grey"
*/

//"<font color='#7289da'><B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B></font>")

/datum/faction/proc/faction_process()
	ships = 0
	for(var/obj/structure/overmap/ship/AI/OM in GLOB.overmap_ships)
		if(OM.faction == name && OM.counts_to_shipcap)
			ships ++


/datum/faction/starfleet
	name = "starfleet"
	description = "The military arm of the federation, its officers are disciplined and intelligent but there is plenty of room for ensigns and other inexperienced officers."
	flavourtext = "Starfleet is a stable career path, with luck you can work your way up the ranks all while protecting the values of the federation"
	pref_colour = "red"
	factag = "starfleet"

/*
/datum/faction/nanotrasen
	name = "nanotrasen"
	description = "Nanotrasen, or more specifically, their main corporate arm. Their goal is to make money and maintain the colonies, no matter who opposes them."
	flavourtext = "Nanotrasen is an oligarchy, but with merit you should be able to climb the ranks...up to a point."
	pref_colour = "blue"
*/

/datum/faction/romulan
	name = "romulan empire"
	description = "The Romulan Empire. One of the most powerful empires surrounding the Federation, they "
	flavourtext = "Welcome to the Romulan Empire. Play your cards wisely, for there is always a spy somewhere."
	pref_colour = "green"
	required_race = /datum/species/romulan
	factag = "romulan"
	speciestype = /datum/species/romulan

/datum/faction/borg
	name = "the borg collective"
	description = "The borg seek perfection through the integration of technology and culture from other species. There is no individual in the borg."
	flavourtext = "Diplomacy is irrelevant, resistance is futile. Assimilate lifeforms to add to our database."
	pref_colour = "green"
	required_race = null
	factag = "borg"
	speciestype = null

/datum/faction/empire
	name = "the empire"
	description = "The empire protects all, quells rebel scum and maintains order in the galaxy...but something's not quite right."
	flavourtext = "The ship's hyperdrive has malfunctioned! Coordinates: UNKNOWN. Establish contact with nearest imperial branch immediately."
	pref_colour = "red"
	required_race = /datum/species/human
	factag = "empire"
	speciestype = /datum/species/human
	locked = TRUE //Admin only..for now

/datum/faction/proc/add_objective(var/datum/factionobjective/O)
	if(O in subtypesof(/datum/factionobjective))
		if(current_objective)
			return FALSE
		var/datum/factionobjective/instance = new O
		current_objective = instance
		instance.iscurrent = TRUE
		instance.assigned_faction = src
		instance.setup()
		return TRUE

/datum/faction/proc/num_players()
	for(var/mob/P in GLOB.player_list)
		if(P.client)
			. ++

/datum/faction/New()
	var/datum/job/job
	for(job in SSjob.occupations)
		if(job.starting_faction == name)
			faction_occupations += job

	var/players = num_players()
	get_spawns()
	if(player_requirement > players)
		qdel(src)
		log_game("[name] faction could not be created, as there were not enough players")
	else
		. = ..()

/datum/faction/proc/get_spawns() //override this for each
	for(var/obj/effect/landmark/faction_spawn/F in world)
		if(F.name == name)
			spawns += F

/datum/faction/proc/broadcast(var/ping)	//broadcast4reps
//	if(!ping)
//		return 0 //No message was input..somehow
	for(var/mob/living/M in members)
		to_chat(M, ping)

/datum/faction/proc/addMember(mob/D)
	members += D
	if(D.client)
		if(D.client.prefs.player_faction)
			D.client.prefs.player_faction = src
	D.player_faction = src
	to_chat(D, "<FONT color='#7289da'><B>You have been recruited into [name]!</B></font>")
	to_chat(D, "<FONT color='[pref_colour]'><B>[flavourtext]</B></font>")
	onspawn(D)

/datum/faction/proc/onspawn(mob/living/carbon/human/D) //If you want things to happen to someone as they join a faction, put it here
	var/image/factionoverlay = new
	factionoverlay.icon = 'StarTrek13/icons/trek/faction_icons.dmi'
	factionoverlay.icon_state = "[factag]"
	D.add_overlay(factionoverlay)
	sleep(50)
	if(D in members)
		if(speciestype)
			D.set_species(speciestype)
			if(istype(src, /datum/faction/romulan))
				if(D.client)
					if(D.client.prefs.romulan_name && !isnull(D.client.prefs.romulan_name))
						D.real_name = D.client.prefs.romulan_name
						D.name = D.client.prefs.romulan_name
						to_chat(D, "You have been renamed to [D.client.prefs.romulan_name], your chosen romulan name.")
	for(var/datum/faction/F in SSfaction.factions)
		if(D in F.members)
			F.members -= D
	return


/datum/faction/borg/onspawn(mob/living/carbon/human/D)
	. = ..()
	sleep(40) //give autobalancer time to sort them
	if(!istype(D.player_faction, /datum/faction/borg))
		return
	var/area/A = get_area(D)
	if(istype(A, /area/ship/ds9)) //Ohhhh hello starfleet borg :)!!!!
		return
	if(D in members)
		D.make_borg()
		D.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE)

var/list/global/faction_spawns = list()

/obj/effect/landmark/faction_spawn
	name = "starfleet"

/obj/effect/landmark/faction_spawn/nanotrasen
	name = "nanotrasen"

/obj/effect/landmark/faction_spawn/independant
	name = "independant"

/obj/effect/landmark/faction_spawn/borg
	name = "the borg"

/obj/effect/landmark/faction_spawn/romulan
	name = "romulan empire"

/obj/item/clothing/neck/tie/faction_tag //I hate myself for doing this, but I don't have the time to mess around with antag huds...yet...
	name = "federation dogtag"
	desc = "Wear this to not get shot by your friends!."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "federationdogtag"
	item_state = ""	//no inhands
	item_color = "federationdogtag"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/tie/faction_tag/nanotrasen //I hate myself for doing this, but I don't have the time to mess around with antag huds...yet...
	name = "Nanotrasen dogtag"
	desc = "Wear this to not get shot by your friends!."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "nanotrasendogtag"
	item_state = ""	//no inhands
	item_color = "nanotrasendogtag"
	w_class = WEIGHT_CLASS_SMALL

/datum/faction/proc/removeMember(mob/living/D)
	if(D in members)
		if(isliving(D))
			members -= D
			to_chat(D, "<FONT color='red'><B>You have been removed from [name]!</B></font>")

/datum/faction/proc/addCredits(amount)
	credits += amount

//datum/objective/faction/

//Framework, finish this after factions are working

/datum/alliance  //A faction can ally itself with a group, so starfleet is allied to the federation, klingons allied to the federation etc.
	var/name = "the united federation of planets"
	var/decription = "Formed in 2161 this rather new entity is the governing body for a large chunk of the galaxy, it values freedom and order above all."
	var/datum/faction/member_factions = list()
	var/datum/alliance/at_war_with = list() //Enemy alliances
	var/joinMessage = "your faction has joined the federation"

/datum/alliance/proc/addMember(datum/faction/D)
	if(!D in member_factions)
		member_factions += D
		D.broadcast(joinMessage)

/datum/alliance/proc/removeMember(datum/faction/D)
	if(D in member_factions)
		member_factions -= D
		D.broadcast("Your faction has been removed from [name]!")


////objectives code\\\\
//Shitcoded by yours truly

/datum/factionobjective
	var/iscurrent = FALSE
	var/datum/faction/assigned_faction
	var/description = "ERROR: THIS MESSAGE SHOULD NOT BE DISPLAYED." //The "informative" message of the objective

/datum/factionobjective/proc/setup()
	assigned_faction.broadcast("<font color='red'><B>An error has occured with faction objectives, or a coder forgot to change something.</B></font>")
	return

/datum/factionobjective/proc/check_completion() //SHOULD be called every so often, to check for completion.
	return

//EXAMPLE
/datum/factionobjective/destroy1
	var/obj/structure/overmap/ship/objective

/datum/factionobjective/destroy1/setup() //shitty, but it's just an example for now. This means ALL ships, including your own faction's, will be able to be picked. Hopefully this will be fixed later.
	if(!global_ship_list)
		qdel(src)
		return
	var/list/pickables = global_ship_list
	for(var/obj/structure/overmap/ship/fighter/F in pickables)
		pickables -= F
	objective = pick(pickables)
	description = "<B>Locate the target vessel and destroy it. Your target: [objective.name]</B>"
	assigned_faction.broadcast("Your faction has been assigned an objective; [description]")

/datum/factionobjective/destroy1/check_completion(var/target)
	if(!target == objective)
		return FALSE

	assigned_faction.broadcast("<font color='#1459c7'><B>The target vessel has been destroyed. Congratulations!</B></font>")
	assigned_faction.addCredits(100)
	qdel(src)
	return TRUE
//END EXAMPLE

/datum/factionobjective/stealth //Place a tracker on a target ship's warp core to study it, you can get spotted 3 times before it fails
	var/spotted_amount = 0
	var/max_spots = 3
	var/obj/machinery/power/warpcore/target

/datum/factionobjective/stealth/setup()
	if(!global_ship_list)
		qdel(src)
		return
	var/list/pickables = global_ship_list
	for(var/obj/structure/overmap/ship/fighter/F in pickables)
		pickables -= F
	for(var/obj/machinery/power/warpcore/W in GLOB.sortedAreas)
		if(!W)
			return
		var/area/A = get_area(W)
		target = W
		description = "Perform a full scan of [W] aboard the [A] to better understand warp core mechanics. This is a stealth mission, if you are spotted more than [max_spots] times, you will fail the mission."
		break