/datum/action/innate/exit
	name = "Exit ship"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "exit"
	var/obj/structure/overmap/ship

/datum/action/innate/exit/Activate()
	ship.exit()

#define FIRE_PHASER 1
#define FIRE_PHOTON 2

/datum/action/innate/weaponswitch
	name = "Switch weapon"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "phaser"
	var/obj/structure/overmap/ship
	var/selected = 1

/datum/action/innate/shieldtoggle
	name = "Toggle Shields"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "shieldtoggle"
	var/obj/structure/overmap/ship

/datum/action/innate/shieldtoggle/Trigger()
	ship.weapons.shieldgen.toggle(ship.pilot)

/datum/action/innate/weaponswitch/Trigger()
	ship.switch_mode(ship.pilot)
	switch(ship.fire_mode)
		if(1)
			button_icon_state = "phaser"
		if(2)
			button_icon_state = "photon"

/datum/action/innate/warp
	name = "Engage warp drive"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "warp"
	var/warping = FALSE
	var/obj/structure/overmap/ship
	var/warp_cost = 4000 //Lotsa energy to warp it

/datum/action/innate/warp/Activate()
	to_chat(ship.pilot, "This feature is disabled, use the helm console to set speed.")
	return
/*
	if(ship.SC.engines.try_warp())
		switch(warping)
			if(TRUE)
				to_chat(ship.pilot, "Warping deactivated")
				ship.can_move = TRUE
				ship.vel = 1
				warping = FALSE
			if(FALSE)
				SEND_SOUND(ship.pilot, 'StarTrek13/sound/trek/ship_effects/warp.ogg')
				to_chat(ship.pilot, "Engaging warp")
				ship.can_move = FALSE
				ship.vel = ship.max_warp
				warping = TRUE
				for(var/mob/L in ship.linked_ship)
					SEND_SOUND(L, 'StarTrek13/sound/trek/ship_effects/warp.ogg')
					to_chat(L, "The deck plates shudder as the ship builds up immense speed.")
		return
*/

/datum/action/innate/stopfiring
	name = "Disengage weapons lock"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "stopfiring"
	var/obj/structure/overmap/ship

/datum/action/innate/stopfiring/Activate()
	ship.stop_firing()

/datum/action/innate/redalert
	name = "Toggle red alert"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "redalert"
	var/obj/structure/overmap/ship

/datum/action/innate/redalert/Activate()
	ship.weapons.redalert()

/datum/action/innate/autopilot
	name = "Engage autopilot"
	icon_icon = 'StarTrek13/icons/actions/overmap_ui.dmi'
	button_icon_state = "autopilot"
	var/obj/structure/overmap/ship

/datum/action/innate/autopilot/Activate()
	ship.set_nav_target(ship.pilot)

//input_warp_target(user)



/obj/structure/overmap/proc/GrantActions()
	//dont need jump cam action
	if(exit_action)
		exit_action.target = pilot
		exit_action.Grant(pilot)
		exit_action.ship = src

	if(weaponswitch)
		weaponswitch.target = pilot
		weaponswitch.Grant(pilot)
		weaponswitch.ship = src

	if(warp_action)
		warp_action.target = pilot
		warp_action.Grant(pilot)
		warp_action.ship = src

	if(shieldtoggle_action)
		shieldtoggle_action.target = pilot
		shieldtoggle_action.Grant(pilot)
		shieldtoggle_action.ship = src

	if(stopfiring_action)
		stopfiring_action.target = pilot
		stopfiring_action.Grant(pilot)
		stopfiring_action.ship = src


	if(redalert_action)
		redalert_action.target = pilot
		redalert_action.Grant(pilot)
		redalert_action.ship = src


	if(autopilot_action)
		autopilot_action.target = pilot
		autopilot_action.Grant(pilot)
		autopilot_action.ship = src


/obj/structure/overmap/proc/RemoveActions()
	//dont need jump cam action
	if(exit_action)
		exit_action.target = null
		exit_action.Remove(pilot)
	if(warp_action)
		warp_action.target = null
		warp_action.Remove(pilot)
	if(stopfiring_action)
		stopfiring_action.target = null
		stopfiring_action.Remove(pilot)
	if(shieldtoggle_action)
		shieldtoggle_action.target = null
		shieldtoggle_action.Remove(pilot)
	if(redalert_action)
		redalert_action.target = null
		redalert_action.Remove(pilot)
	if(autopilot_action)
		autopilot_action.target = null
		autopilot_action.Remove(pilot)
	if(weaponswitch)
		weaponswitch.target = null
		weaponswitch.Remove(pilot)