///See credits for who made these!///
/turf/closed/wall/trek
	name = "Starship hull" //Right click, generate instances by dir, then by icon_state
	desc = "It's like something out of star trek!"
	smooth = FALSE
	icon = 'StarTrek13/icons/trek/flaksim_walls.dmi'

/turf/closed/wall/trek/galaxy
	name = "Starship hull"
	desc = "It's like something out of star trek!"
	smooth = FALSE
	icon = 'StarTrek13/icons/trek/flaksim_walls.dmi'
	icon_state = "galaxy"

/obj/structure/window/specialtrek
	name = "Starship viewport"
	icon = 'StarTrek13/icons/trek/flaksim_walls.dmi'
	icon_state = "window"
	smooth = FALSE

/obj/structure/table/trek
	name = "futuristic table"
	desc = "It's so futuristic, and smooth. You could really put things on it"
	icon = 'StarTrek13/icons/trek/flaksim_structures.dmi'
	smooth = FALSE

/turf/open/floor/hallway
	name = "Starship hull" //Right click, generate instances by dir, then by icon_state
	desc = "It's like something out of star trek!"
	smooth = FALSE
	icon = 'StarTrek13/icons/trek/flaksim_walls.dmi'
	icon_state = "hallway"
	CanAtmosPass = FALSE

/turf/open/floor/hallway/galaxy
	icon_state = "galaxyhall"

/turf/open/floor/trek
	name = "space carpet"
	desc = "the merits of a static charge generating material for flooring on a highly sensitive starship is questionable, but can you question that threadcount?"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version
	icon = 'StarTrek13/icons/trek/star_trek.dmi'
	icon_state = "bluetrek"

/obj/structure/ladder/unbreakable/lift
	name = "turbolift"
	desc = "Suffer not a human to climb, this model of lift has phased out the primitive turboladders of yore, allowing rapid movement up and down!"
	icon = 'StarTrek13/icons/trek/flaksim_structures.dmi'

/obj/structure/ladder/unbreakable/Destroy(var/sev = 0)
	switch(sev)
		if(0)
			return 0
		else
			GLOB.ladders -= src
			. = ..()
			qdel(src)


/obj/structure/ladder/unbreakable/lift/show_fluff_message(going_up, mob/user)
	shake_camera(user, 2, 10)
	if(going_up)
		user.visible_message("[src] ascends.","<span class='notice'>The lift ascends.</span>")
	else
		user.visible_message("[src] descends.","<span class='notice'>The lift descends</span>")

/obj/structure/bed/trek
	name = "large bed"
	desc = "This is used to lie in, sleep in or strap on. It's huge!"
	icon_state = "bed"
	icon = 'StarTrek13/icons/trek/oversized_beds.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30

/obj/structure/table/optable/trek
	name = "medical bed"
	icon = 'StarTrek13/icons/trek/oversized_beds.dmi'
	desc = "For patient restraint, recovery and rest, it's extra spacious!"
	icon_state = "medbay"