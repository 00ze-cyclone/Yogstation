GLOBAL_VAR_INIT(security_level, SEC_LEVEL_GREEN)
//SEC_LEVEL_GREEN = code green
//SEC_LEVEL_BLUE = code blue
//SEC_LEVEL_RED = code red
//SEC_LEVEL_GAMMA = code gamma
//SEC_LEVEL_EPSILON = code epsilon
//SEC_LEVEL_DELTA = code delta

//config.alert_desc_blue_downto

//set all area lights on station level to red if true, do otherwise if false
/proc/change_areas_lights_alarm(red=TRUE)
	if(red)
		for(var/area/A in GLOB.delta_areas)
			A.set_fire_alarm_effect(TRUE)
	else
		for(var/area/A in GLOB.delta_areas)
			A.unset_fire_alarm_effects(TRUE)

/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("gamma")
			level = SEC_LEVEL_GAMMA
		if("epsilon")
			level = SEC_LEVEL_EPSILON
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		var/modTimer
		switch(level)
			if(SEC_LEVEL_GREEN)
				minor_announce(CONFIG_GET(string/alert_green), "Attention! Security level lowered to green:")
				sound_to_playing_players('sound/misc/notice2.ogg')
				if(GLOB.security_level >= SEC_LEVEL_RED)
					modTimer = 4
				else
					modTimer = 2

			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					minor_announce(CONFIG_GET(string/alert_blue_upto), "Attention! Security level elevated to blue:", TRUE)
					sound_to_playing_players('sound/misc/notice1.ogg')
					modTimer = 0.5
				else
					minor_announce(CONFIG_GET(string/alert_blue_downto), "Attention! Security level lowered to blue:")
					modTimer = 2

			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					minor_announce(CONFIG_GET(string/alert_red_upto), "Attention! Code red!", TRUE)
					sound_to_playing_players('sound/misc/notice4.ogg')
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						modTimer = 0.25
					else
						modTimer = 0.5
				else
					minor_announce(CONFIG_GET(string/alert_red_downto), "Attention! Code red!")
					if(GLOB.security_level == SEC_LEVEL_GAMMA)
						modTimer = 2

			if(SEC_LEVEL_GAMMA)
				minor_announce(CONFIG_GET(string/alert_gamma), "Attention! Gamma security level activated!", TRUE)
				sound_to_playing_players('sound/misc/gamma_alert.ogg')
				if(GLOB.security_level == SEC_LEVEL_GREEN)
					modTimer = 0.25
				else if(GLOB.security_level == SEC_LEVEL_BLUE)
					modTimer = 0.50
				else if(GLOB.security_level == SEC_LEVEL_RED)
					modTimer = 0.75

			if(SEC_LEVEL_EPSILON)
				minor_announce(CONFIG_GET(string/alert_epsilon), "Attention! Epsilon security level reached!", TRUE)
				sound_to_playing_players('sound/misc/epsilon_alert.ogg')
				send_to_playing_players(span_notice("You get a bad feeling as you hear the Epsilon alert siren."))
				if(GLOB.security_level < SEC_LEVEL_EPSILON)
					modTimer = 1

			if(SEC_LEVEL_DELTA)
				minor_announce(CONFIG_GET(string/alert_delta), "Attention! Delta security level reached!", TRUE)
				sound_to_playing_players('sound/misc/delta_alert.ogg')
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						modTimer = 0.25
					else if(GLOB.security_level == SEC_LEVEL_BLUE)
						modTimer = 0.5

		GLOB.security_level = level
		for(var/obj/machinery/firealarm/FA in GLOB.machines)
			if(is_station_level(FA.z))
				FA.update_appearance(UPDATE_ICON)

		for(var/obj/machinery/level_interface/LI in GLOB.machines)
			LI.update_appearance(UPDATE_ICON)

		if(level >= SEC_LEVEL_RED)
			for(var/obj/machinery/computer/shuttle/pod/pod in GLOB.machines)
				pod.admin_controlled = FALSE
			for(var/obj/machinery/door/D in GLOB.machines)
				if(D.red_alert_access)
					D.visible_message(span_notice("[D] whirrs as it automatically lifts access requirements!"))
					playsound(D, 'sound/machines/boltsup.ogg', 50, TRUE)

		if(level == SEC_LEVEL_DELTA)
			change_areas_lights_alarm()
		else
			change_areas_lights_alarm(FALSE)

		if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
			SSshuttle.emergency.modTimer(modTimer)

		SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
		SSnightshift.check_nightshift()
	else
		return

/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("gamma")
			return SEC_LEVEL_GAMMA
		if("epsilon")
			return SEC_LEVEL_EPSILON
		if("delta")
			return SEC_LEVEL_DELTA
