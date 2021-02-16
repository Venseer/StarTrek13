//datum/game_mode
//	var/list/faction_participants = list(/datum/faction/starfleet, /datum/faction/romulan)
/*
/datum/game_mode/conquest
	name = "galactic conquest"
	config_tag = "conquest"
	announce_span = "danger"
	announce_text = "A romulan incursion into the neutral zone has put starfleet on red alert\n\
	<span class='danger'>Capture system outposts and accrue credits\n\
	<span class='danger'>The winning faction shall be the one with the most remaining credits."
	var/list/faction_participants = list("starfleet", "romulan empire", "the borg collective")

/datum/game_mode/conquest/pre_setup()
	for(var/datum/faction/F in SSfaction.factions)
		if(F.name in faction_participants)
			MESSAGE_ADMINS("DEBUG: [F] has been enabled for the round.")
			F.locked = FALSE
		else
			F.locked = TRUE //Lock specific factions out of gamemodes
	return ..()//We can add borg into this later, but no real need

/datum/game_mode/conquest/post_setup()
	return ..()

/datum/game_mode/conquest/generate_report()
	return "An advanced Romulan scout fleet has made an incursion into the neutral zone, if they prove to be hostile, engage with lethal force - Ensure you retain control of all outposts within our systems."

/datum/game_mode/conquest/special_report()
	var/list/schmoney = list()
	for(var/datum/faction/F in SSfaction.factions)
		schmoney += F.credits
	var/highest = max(schmoney)
	var/datum/faction/winner
	for(var/datum/faction/F in SSfaction.factions)
		if(F.credits >= highest)
			winner = F
	return "<div class='panel greenborder'><span class='header'>[winner] won the round with a total of [winner.credits] credits!</div>"
*/

//Deprecated. See gamemodes folder