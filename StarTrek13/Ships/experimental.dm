/*
	These are simple defaults for your project.
 */

#define NORMAL = CONFIG_GET(string/default_view)
#define LARGE = 20
#define MASSIVE = 25

/obj/structure/overmap
	animate_movement = 0 //set it
//	pixel_z = -128
//	pixel_w = -120
	appearance_flags = PIXEL_SCALE //to make sprite look smooth when rotating... sorta
	var/angle = 0 //the angle
	var/vel = 0 //the velocity
	var/turnspeed = 0.5 //how fast does this bitch turn
	var/speed = 0 //speed
	var/max_speed = 2 //High warp can get you into the 30s
	var/acceleration = 0.5 //speed up
	pixel_collision_size_x = -128
	pixel_collision_size_y = -120
	var/engine_sound = null
	var/engine_prob = 20 //20% chance to play engine sound
	/*
	The part below is no longer useless
	*/
	proc/EditAngle()
		var/matrix/M = matrix() //create matrix
		M.Turn(-angle) //reverse angle
		src.transform = M //set matrix

	proc/ProcessMove()
		EditAngle() //we need to edit the transform just incase
		if(nav_target)
			if(nav_target in orange(src, 1)) //if we're near our navigational target, slam on the brakes
				if(vel > 0)
					if(vel >= 40)
						vel -= 10
					else if(vel >= 20)
						vel -= 2 //Smooth stop, even at high warp.
					else
						vel -= acceleration
		var/x_speed = vel * cos(angle)
		var/y_speed = vel * sin(angle)
		PixelMove(x_speed,y_speed)
		if(!SUPERLAGMODE)
			parallax_update()
		if(pilot && pilot.client)
			pilot.client.pixelXYshit()


/obj/effect/ship_overlay
	var/angle = 0 //the angle
	proc/EditAngle()
		var/matrix/M = matrix() //create matrix
		M.Turn(-angle) //reverse angle
		src.transform = M //set matrix
	proc/ProcessMove()
		EditAngle() //we need to edit the transform just incase

		var/x_speed = 5 * cos(angle)
		var/y_speed = 5 * sin(angle)

		PixelMove(x_speed,y_speed)

/obj/structure/overmap/proc/parallax_update()
	if(pilot && pilot.client)
		for(var/PP in pilot.client.parallax_layers)
		//	var/turf/posobj = get_turf(src)
			var/obj/screen/parallax_layer/P = PP
			var/x_speed = 5 * cos(angle)
			var/y_speed = 5 * sin(angle)
			P.PixelMove(x_speed,y_speed)
			pilot.hud_used.update_parallax()

/obj/structure/overmap/proc/enter(mob/user)
	if(user.client)
		if(pilot)
			var/mode = input("[pilot] is already on the helm, kick them off?", "Are you sure?")in list("yes","no")
			if(mode == "yes")
				to_chat(user, "you kick [pilot] off the ship controls!")
				exit()
				return FALSE
			else
				return FALSE
		initial_loc = user.loc
		user.loc = src
		pilot = user
		pilot.overmap_ship = src
		GrantActions()
		pilot.throw_alert("Weapon charge", /obj/screen/alert/charge)
		pilot.throw_alert("Hull integrity", /obj/screen/alert/charge/hull)
		for(var/obj/screen/alert/charge/C in pilot.alerts)
			C.theship = src
		pilot.whatimControllingOMFG = src
		pilot.client.pixelXYshit()
		pilot.status_flags |= GODMODE
		if(size_class && pilot.client)
			pilot.client.change_view(size_class)
		var/area/A = get_area(src)
		if(A)
			A.Entered(user)
		while(1)
			stoplag()
			ProcessMove()
			ProcessFire()
			if(nav_target)
				navigate()


/obj/structure/overmap/proc/ProcessFire()
	if(firinginprogress) //Star trek legacy like weapons here we come!!!
		if(attempt_fire())
			return
		else
			firinginprogress = FALSE
			target_ship = null
			target_turf = null
			return

/obj/structure/overmap/proc/exit(mob/user)
	pilot.status_flags &= ~GODMODE
	pilot.forceMove(initial_loc)
	initial_loc = null
	if(pilot.client)
		pilot.client.change_view(CONFIG_GET(string/default_view))
		pilot.client.widescreen = FALSE //So they get widescreen mode back after we dick with their view
		pilot.clear_alert("Weapon charge", /obj/screen/alert/charge)
		pilot.clear_alert("Hull integrity", /obj/screen/alert/charge/hull)
		RemoveActions()
		stop_firing() //to stop the firing indicators staying with the pilot
		to_chat(pilot,"you have stopped controlling [src]")
	//	pilot.status_flags -= GODMODE
		pilot.overmap_ship = null
		pilot.incorporeal_move = 1 //Refresh movement to fix an issue
		pilot.incorporeal_move = 0
		pilot.whatimControllingOMFG = null
		pilot.client.pixelXYshit()
		pilot = null
	else
		pilot.incorporeal_move = 1 //Refresh movement to fix an issue
		pilot.incorporeal_move = 0
		pilot.overmap_ship = null
		pilot.clear_alert("Weapon charge", /obj/screen/alert/charge)
		pilot.clear_alert("Hull integrity", /obj/screen/alert/charge/hull)
		RemoveActions()
		stop_firing() //to stop the firing indicators staying with the pilot
		to_chat(pilot,"you have stopped controlling [src]")
		pilot = null


mob
	var/obj/structure/overmap/whatimControllingOMFG = null

client
	perspective = EYE_PERSPECTIVE //Use this perspective or else shit will break! (sometimes screen will turn black)
	proc/pixelXYshit()
		if(mob.whatimControllingOMFG)
			pixel_x = mob.whatimControllingOMFG.pixel_x
			pixel_y = mob.whatimControllingOMFG.pixel_y
			eye = mob.whatimControllingOMFG
		else
			pixel_x = 0
			pixel_y = 0
			eye = mob


atom/movable
	var
		real_pixel_x = 0 //variables for the real pixel_x
		real_pixel_y = 0 //variables for shit
		pixel_collision_size_x = 0
		pixel_collision_size_y = 0
	proc
		PixelMove(var/x_to_move,var/y_to_move) //FOR THIS TO LOOK SMOOTH, ANIMATE_MOVEMENT needs to be 0!
		//	var/HOLYSHITICRASHED = 0
			for(var/turf/e in obounds(src, real_pixel_x + x_to_move + pixel_collision_size_x/4, real_pixel_y + y_to_move + pixel_collision_size_y/4, real_pixel_x + x_to_move + -pixel_collision_size_x/4, real_pixel_y + y_to_move + -pixel_collision_size_x/4) )//Basic block collision
				if(e.density == 1) //We can change this so the ship takes damage later
			//		HOLYSHITICRASHED = HOLYSHITICRASHED + 1
					if(istype(src, /obj/structure/overmap))
						var/obj/structure/overmap/O = src
						if(O.navigating)
							O.navigating = FALSE
						O.angle -= 180
						O.EditAngle()
						O.vel = 1
						sleep(10)
						O.vel = 0
					return 0
			real_pixel_x = real_pixel_x + x_to_move
			real_pixel_y = real_pixel_y + y_to_move
			while(real_pixel_x > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
				real_pixel_x = real_pixel_x - 32
				x = x + 1
			while(real_pixel_x < -32)
				real_pixel_x = real_pixel_x + 32
				x = x - 1
			while(real_pixel_y > 32) //Modulo doesn't work with this kind of stuff, don't know if there's a better method.
				real_pixel_y = real_pixel_y - 32
				y = y + 1
			while(real_pixel_y < -32)
				real_pixel_y = real_pixel_y + 32
				y = y - 1
			pixel_x = real_pixel_x
			pixel_y = real_pixel_y

/obj/structure/overmap/ship/relaymove(mob/mob,dir) //fuckoff I want to do my own shitcode :^)
	if(engine_sound)
		if(prob(engine_prob))
			playsound(src,engine_sound,40,1)
	check_overlays()
	if(SC)
		if(SC.engines)
			if(!SC.engines.check_power())
				return
	if(can_move)
		if(assimilation_tier >= 5) //Borg cube hyperspeed cock block brigade here lads.
			turnspeed = 1
			max_speed = 2
		switch(dir)
			if(NORTH)
				if(mob.whatimControllingOMFG)
					if(mob.whatimControllingOMFG.vel < max_speed) //burn to speed up
						mob.whatimControllingOMFG.vel += acceleration
					else
						mob.whatimControllingOMFG.vel = max_speed
					mob.client.pixelXYshit()
				else
					..()
			if(SOUTH)
				if(mob.whatimControllingOMFG)
					if(mob.whatimControllingOMFG.vel > 0)
						mob.whatimControllingOMFG.vel -= acceleration
					else
						mob.whatimControllingOMFG.vel = 0
					mob.whatimControllingOMFG.ProcessMove()
					mob.client.pixelXYshit()
				else
					..()
			if(EAST)
				if(mob.whatimControllingOMFG)
					for(var/obj/effect/ship_overlay/S in overlays)
						S.angle = mob.whatimControllingOMFG.angle - turnspeed
						S.EditAngle()
					mob.whatimControllingOMFG.angle = mob.whatimControllingOMFG.angle - turnspeed
					mob.whatimControllingOMFG.EditAngle()
				else
					..()
			if(NORTHEAST)
				if(mob.whatimControllingOMFG)
					if(mob.whatimControllingOMFG.vel < max_speed) //burn to speed up
						mob.whatimControllingOMFG.vel += acceleration
					else
						mob.whatimControllingOMFG.vel = max_speed
					for(var/obj/effect/ship_overlay/S in overlays)
						S.angle = mob.whatimControllingOMFG.angle - turnspeed
						S.EditAngle()
					mob.whatimControllingOMFG.angle = mob.whatimControllingOMFG.angle - turnspeed
					mob.client.pixelXYshit()
				else
					..()
			if(WEST)
				if(mob.whatimControllingOMFG)
					for(var/obj/effect/ship_overlay/S in overlays)
						S.angle = mob.whatimControllingOMFG.angle - turnspeed
						S.EditAngle()
					mob.whatimControllingOMFG.angle = mob.whatimControllingOMFG.angle + turnspeed
					mob.whatimControllingOMFG.EditAngle()
			if(NORTHWEST)
				if(mob.whatimControllingOMFG)
					if(mob.whatimControllingOMFG.vel < max_speed) //burn to speed up
						mob.whatimControllingOMFG.vel += acceleration
					else
						mob.whatimControllingOMFG.vel = max_speed
					for(var/obj/effect/ship_overlay/S in overlays)
						S.angle = mob.whatimControllingOMFG.angle - turnspeed
						S.EditAngle()
					mob.whatimControllingOMFG.angle = mob.whatimControllingOMFG.angle + turnspeed
					mob.client.pixelXYshit()
				else
					..()

/obj/structure/overmap/proc/TurnTo(atom/target)
	if(target)
		var/obj/structure/overmap/ship/self = src //I'm a reel cumputer syentist :)
		EditAngle()
		var/target_angle = 450 - SIMPLIFY_DEGREES(ATAN2((32*target.y+target.pixel_y) - (32*self.y+self.pixel_y), (32*target.x+target.pixel_x) - (32*self.x+self.pixel_x)))
		if(angle > target_angle)
			angle -= turnspeed
		if(angle < target_angle)
			angle += turnspeed
		if(angle == target_angle)
			return