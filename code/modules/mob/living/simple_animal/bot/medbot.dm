//MEDBOT
//MEDBOT PATHFINDING
//MEDBOT ASSEMBLY
#define MEDBOT_PANIC_NONE	0
#define MEDBOT_PANIC_LOW	15
#define MEDBOT_PANIC_MED	35
#define MEDBOT_PANIC_HIGH	55
#define MEDBOT_PANIC_FUCK	70
#define MEDBOT_PANIC_ENDING	90
#define MEDBOT_PANIC_END	100


/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "medibot0"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB

	status_flags = (CANPUSH | CANSTUN)

	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL

	bot_type = MED_BOT
	model = "Medibot"
	bot_core_type = /obj/machinery/bot_core/medbot
	window_id = "automed"
	window_name = "Automatic Medical Unit v1.1"
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED
	path_image_color = "#DDDDFF"

	var/obj/item/reagent_containers/glass/reagent_glass = null //Can be set to draw from this for reagents.
	var/healthanalyzer = /obj/item/healthanalyzer
	var/firstaid = /obj/item/storage/firstaid
	var/skin = null //Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_newpatient_speak = 0 //Don't spam the "HEY I'M COMING" messages
	var/injection_amount = 15 //How much reagent do we inject at a time?
	var/heal_threshold = 10 //Start healing when they have this much damage in a category
	var/use_beaker = 0 //Use reagents in beaker instead of default treatment agents.
	var/declare_crit = 1 //If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_cooldown = 0 //Prevents spam of critical patient alerts.
	var/stationary_mode = 0 //If enabled, the Medibot will not move automatically.
	///How panicked we are about being tipped over (why would you do this?)
	var/tipped_status = MEDBOT_PANIC_NONE
	///The name we got when we were tipped
	var/tipper_name
	///The last time we were tipped/righted and said a voice line, to avoid spam
	var/last_tipping_action_voice = 0
	//Setting which reagents to use to treat what by default. By id.
	var/treatment_brute_avoid = /datum/reagent/medicine/tricordrazine
	var/treatment_brute = /datum/reagent/medicine/c2/libital
	var/treatment_oxy_avoid = null
	var/treatment_oxy = /datum/reagent/medicine/dexalin
	var/treatment_fire_avoid = /datum/reagent/medicine/tricordrazine
	var/treatment_fire = /datum/reagent/medicine/c2/aiuri
	var/treatment_tox_avoid = /datum/reagent/medicine/tricordrazine
	var/treatment_tox = /datum/reagent/medicine/charcoal
	var/treatment_virus_avoid = null
	var/treatment_virus = /datum/reagent/medicine/spaceacillin
	var/treat_virus = 1 //If on, the bot will attempt to treat viral infections, curing them if possible.
	var/shut_up = 0 //self explanatory :)

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_brute = /datum/reagent/medicine/tricordrazine
	treatment_fire = /datum/reagent/medicine/tricordrazine
	treatment_tox = /datum/reagent/medicine/tricordrazine

/mob/living/simple_animal/bot/medbot/derelict
	name = "\improper Old Medibot"
	desc = "Looks like it hasn't been modified since the late 2080s."
	skin = "bezerk"
	heal_threshold = 0
	declare_crit = 0
	treatment_oxy = /datum/reagent/toxin/pancuronium
	treatment_brute_avoid = null
	treatment_brute = /datum/reagent/toxin/pancuronium
	treatment_fire_avoid = null
	treatment_fire = /datum/reagent/toxin/sodium_thiopental
	treatment_tox_avoid = null
	treatment_tox = /datum/reagent/toxin/sodium_thiopental

/mob/living/simple_animal/bot/medbot/update_icon()
	cut_overlays()
	if(skin)
		add_overlay("medskin_[skin]")
	if(!on)
		icon_state = "medibot0"
		return
	if(IsStun() || IsParalyzed())
		icon_state = "medibota"
		return
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"

/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	var/datum/job/doctor/J = new /datum/job/doctor
	access_card.access += J.get_access()
	prev_access = access_card.access
	qdel(J)
	skin = new_skin
	update_icon()

/mob/living/simple_animal/bot/medbot/update_mobility()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	patient = null
	oldpatient = null
	oldloc = null
	last_found = world.time
	declare_cooldown = 0
	update_icon()

/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	patient = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()

/mob/living/simple_animal/bot/medbot/set_custom_texts()

	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"

/mob/living/simple_animal/bot/medbot/attack_paw(mob/user)
	return attack_hand(user)

/mob/living/simple_animal/bot/medbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Medical Unit Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if(reagent_glass)
		dat += "<A href='?src=[REF(src)];eject=1'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "<TT>Healing Threshold: "
		dat += "<a href='?src=[REF(src)];adj_threshold=-10'>--</a> "
		dat += "<a href='?src=[REF(src)];adj_threshold=-5'>-</a> "
		dat += "[heal_threshold] "
		dat += "<a href='?src=[REF(src)];adj_threshold=5'>+</a> "
		dat += "<a href='?src=[REF(src)];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='?src=[REF(src)];adj_inject=-5'>-</a> "
		dat += "[injection_amount] "
		dat += "<a href='?src=[REF(src)];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='?src=[REF(src)];use_beaker=1'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treat Viral Infections: <a href='?src=[REF(src)];virus=1'>[treat_virus ? "Yes" : "No"]</a><br>"
		dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=[REF(src)];togglevoice=[1]'>Toggle</a><br>"
		dat += "Critical Patient Alerts: <a href='?src=[REF(src)];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"
		dat += "Patrol Station: <a href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</a><br>"
		dat += "Stationary Mode: <a href='?src=[REF(src)];stationary=1'>[stationary_mode ? "Yes" : "No"]</a><br>"

	return dat

/mob/living/simple_animal/bot/medbot/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["adj_threshold"])
		var/adjust_num = text2num(href_list["adj_threshold"])
		heal_threshold += adjust_num
		if(heal_threshold < 5)
			heal_threshold = 5
		if(heal_threshold > 75)
			heal_threshold = 75

	else if(href_list["adj_inject"])
		var/adjust_num = text2num(href_list["adj_inject"])
		injection_amount += adjust_num
		if(injection_amount < 5)
			injection_amount = 5
		if(injection_amount > 15)
			injection_amount = 15

	else if(href_list["use_beaker"])
		use_beaker = !use_beaker

	else if(href_list["eject"] && (!isnull(reagent_glass)))
		reagent_glass.forceMove(drop_location())
		reagent_glass = null

	else if(href_list["togglevoice"])
		shut_up = !shut_up

	else if(href_list["critalerts"])
		declare_crit = !declare_crit

	else if(href_list["stationary"])
		stationary_mode = !stationary_mode
		path = list()
		update_icon()

	else if(href_list["virus"])
		treat_virus = !treat_virus

	update_controls()
	return

/mob/living/simple_animal/bot/medbot/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
		if(locked)
			to_chat(user, span_warning("You cannot insert a beaker because the panel is locked!"))
			return
		if(!isnull(reagent_glass))
			to_chat(user, span_warning("There is already a beaker loaded!"))
			return
		if(!user.transferItemToLoc(W, src))
			return

		reagent_glass = W
		to_chat(user, span_notice("You insert [W]."))
		show_controls(user)

	else
		var/current_health = health
		..()
		if(health < current_health) //if medbot took some damage
			step_to(src, (get_step_away(src,user)))

/mob/living/simple_animal/bot/medbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		declare_crit = 0
		if(user)
			to_chat(user, span_notice("You short out [src]'s reagent synthesis circuits."))
		audible_message(span_danger("[src] buzzes oddly!"))
		flick("medibot_spark", src)
		playsound(src, "sparks", 75, TRUE)
		if(user)
			oldpatient = user

/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return

	if((H == oldpatient) && (world.time < last_found + 200))
		return

	if(assess_patient(H))
		last_found = world.time
		if((last_newpatient_speak + (emagged ? 20 : 300)) < world.time) //Don't spam these messages!
			var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/medbot/coming.ogg',"Wait [H.name]! I want to help!" = 'sound/voice/medbot/help.ogg',"[H.name], you appear to be injured!" = 'sound/voice/medbot/injured.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 50, 0)
			last_newpatient_speak = world.time
		return H
	else
		return

/mob/living/simple_animal/bot/medbot/proc/tip_over(mob/user)
	mobility_flags &= ~MOBILITY_MOVE
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	user.visible_message(span_danger("[user] tips over [src]!"), span_danger("You tip [src] over!"))
	mode = BOT_TIPPED
	var/matrix/mat = transform
	transform = mat.Turn(180)
	tipper_name = user.name

/mob/living/simple_animal/bot/medbot/proc/set_right(mob/user)
	mobility_flags &= MOBILITY_MOVE
	var/list/messagevoice

	if(user)
		user.visible_message(span_notice("[user] sets [src] right-side up!"), span_green("You set [src] right-side up!"))
		if(user.name == tipper_name)
			messagevoice = list("I forgive you." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Thank you!" = 'sound/voice/medbot/thank_you.ogg', "You are a good person." = 'sound/voice/medbot/youre_good.ogg')
	else
		visible_message(span_notice("[src] manages to writhe wiggle enough to right itself."))
		messagevoice = list("Fuck you." = 'sound/voice/medbot/fuck_you.ogg', "Your behavior has been reported, have a nice day." = 'sound/voice/medbot/reported.ogg')

	tipper_name = null
	if(world.time > last_tipping_action_voice + 15 SECONDS)
		last_tipping_action_voice = world.time
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	tipped_status = MEDBOT_PANIC_NONE
	mode = BOT_IDLE
	transform = matrix()

/// if someone tipped us over, check whether we should ask for help or just right ourselves eventually
/mob/living/simple_animal/bot/medbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice

	switch(tipped_status)
		if(MEDBOT_PANIC_LOW)
			messagevoice = list("I require assistance." = 'sound/voice/medbot/i_require_asst.ogg')
		if(MEDBOT_PANIC_MED)
			messagevoice = list("Please put me back." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(MEDBOT_PANIC_HIGH)
			messagevoice = list("Please, I am scared!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(MEDBOT_PANIC_FUCK)
			messagevoice = list("I DON'T LIKE THIS, I NEED HELP!" = 'sound/voice/medbot/dont_like.ogg', "THIS HURTS, MY PAIN IS REAL!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(MEDBOT_PANIC_ENDING)
			messagevoice = list("Is this the end?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nooo!" = 'sound/voice/medbot/nooo.ogg')
		if(MEDBOT_PANIC_END)
			speak("PSYCH ALERT: Crewmember [tipper_name] recorded displaying antisocial tendencies by torturing bots in [get_area(src)]. Please schedule psych evaluation.", radio_channel)
			set_right() // strong independent medbot

	if(prob(tipped_status))
		do_jitter_animation(tipped_status * 0.1)

	if(messagevoice)
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 70)
	else if(prob(tipped_status * 0.2))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30, extrarange=-2)

/mob/living/simple_animal/bot/medbot/examine(mob/user)
	. = ..()
	if(tipped_status == MEDBOT_PANIC_NONE)
		return

	switch(tipped_status)
		if(MEDBOT_PANIC_NONE to MEDBOT_PANIC_LOW)
			. += "It appears to be tipped over, and is quietly waiting for someone to set it right."
		if(MEDBOT_PANIC_LOW to MEDBOT_PANIC_MED)
			. += "It is tipped over and requesting help."
		if(MEDBOT_PANIC_MED to MEDBOT_PANIC_HIGH)
			. += "They are tipped over and appear visibly distressed." // now we humanize the medbot as a they, not an it
		if(MEDBOT_PANIC_HIGH to MEDBOT_PANIC_FUCK)
			. += span_warning("They are tipped over and visibly panicking!")
		if(MEDBOT_PANIC_FUCK to INFINITY)
			. += span_warning("<b>They are freaking out from being tipped over!</b>")

/mob/living/simple_animal/bot/medbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_TIPPED)
		handle_panic()
		return

	if(mode == BOT_HEALING)
		return

	if(IsStun() || IsParalyzed())
		oldpatient = patient
		patient = null
		mode = BOT_IDLE
		return

	if(frustration > 8)
		oldpatient = patient
		soft_reset()

	if(QDELETED(patient))
		if(!shut_up && prob(1))
			if((emagged || !shut_up) && prob(emagged ? 8 : 1))
				var/list/i_need_scissors = list('sound/voice/medbot/fuck_you.ogg', 'sound/voice/medbot/turn_off.ogg', 'sound/voice/medbot/im_different.ogg', 'sound/voice/medbot/close.ogg', 'sound/voice/medbot/shindemashou.ogg')
				playsound(src, pick(i_need_scissors), 70)
			else
				var/list/messagevoice = list("Radar, put a mask on!" = 'sound/voice/medbot/radar.ogg',"There's always a catch, and I'm the best there is." = 'sound/voice/medbot/catch.ogg',"I knew it, I should've been a plastic surgeon." = 'sound/voice/medbot/surgeon.ogg',"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/medbot/flies.ogg',"Delicious!" = 'sound/voice/medbot/delicious.ogg', "Why are we still here? Just to suffer?" = 'sound/voice/medbot/why.ogg')
				var/message = pick(messagevoice)
				speak(message)
				playsound(src, messagevoice[message], 50)

		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(/mob/living/carbon/human, oldpatient, scan_range)
		oldpatient = patient

	if(patient && (get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			update_icon()
			frustration = 0
			medicate_patient(patient)
		return

	//Patient has moved away from us!
	else if(patient && path.len && (get_dist(patient,path[path.len]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(stationary_mode && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && path.len == 0 && (get_dist(src,patient) > 1))
		path = get_path_to(src, get_turf(patient), /turf/proc/Distance_cardinal, 0, 30,id=access_card)
		mode = BOT_MOVING
		if(!path.len) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, get_turf(patient), /turf/proc/Distance_cardinal, 0, 30,1,id=access_card)
			if(!path.len) //Do not chase a patient we cannot reach.
				soft_reset()

	if(path.len > 0 && patient)
		if(!bot_move(path[path.len]))
			oldpatient = patient
			soft_reset()
		return

	if(path.len > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	return

/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	//Time to see if they need medical help!
	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		return FALSE	//welp too late for them!

	if(!(loc == C.loc) && !(isturf(C.loc) && isturf(loc)))
		return FALSE

	if(C.suiciding)
		return FALSE //Kevorkian school of robotic medical assistants.

	if(HAS_TRAIT(C,TRAIT_MEDICALIGNORE))
		return FALSE

	if(emagged == 2) //Everyone needs our medicine. (Our medicine is toxins)
		return TRUE

	var/can_inject = FALSE
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/part = X
		if(part.status == BODYPART_ORGANIC)
			can_inject = TRUE
	if(!can_inject)
		return FALSE

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
			var/obj/item/clothing/CS = H.wear_suit
			var/obj/item/clothing/CH = H.head
			if (CS.clothing_flags & CH.clothing_flags & THICKMATERIAL)
				return FALSE // Skip over them if they have no exposed flesh.


	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	//If they're injured, we're using a beaker, and don't have one of our WONDERCHEMS.
	if((reagent_glass) && (use_beaker) && ((C.getBruteLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getToxLoss() >= heal_threshold) || (C.getOxyLoss() >= (heal_threshold + 15))))
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.type))
				return TRUE

	var/robotic_brute = 0 // brute damage to robotic limbs
	var/robotic_burn = 0 // burn damage to robotic limbs
	for(var/obj/item/bodypart/limb in C.get_damaged_bodyparts(TRUE, TRUE, FALSE, BODYPART_ROBOTIC))
		robotic_brute += limb.get_damage(TRUE, FALSE, FALSE)
		robotic_burn += limb.get_damage(FALSE, TRUE, FALSE)

	//They're injured enough for it!
	if((!C.reagents.has_reagent(treatment_brute_avoid)) && ((C.getBruteLoss()-robotic_brute) >= heal_threshold) && (!C.reagents.has_reagent(treatment_brute)))
		return TRUE //If they're already medicated don't bother!

	if((!C.reagents.has_reagent(treatment_oxy_avoid)) && (C.getOxyLoss() >= (15 + heal_threshold)) && (!C.reagents.has_reagent(treatment_oxy)))
		return TRUE

	if((!C.reagents.has_reagent(treatment_fire_avoid)) && ((C.getFireLoss()-robotic_burn) >= heal_threshold) && (!C.reagents.has_reagent(treatment_fire)))
		return TRUE

	if((!C.reagents.has_reagent(treatment_tox_avoid)) && (C.getToxLoss() >= heal_threshold) && (!C.reagents.has_reagent(treatment_tox)))
		return TRUE

	if(treat_virus && !C.reagents.has_reagent(treatment_virus_avoid) && !C.reagents.has_reagent(treatment_virus))
		for(var/thing in C.diseases)
			var/datum/disease/D = thing
			//the medibot can't detect viruses that are undetectable to Health Analyzers or Pandemic machines.
			if(!(D.visibility_flags & HIDDEN_SCANNER || D.visibility_flags & HIDDEN_PANDEMIC) \
			&& D.severity != DISEASE_SEVERITY_POSITIVE \
			&& (D.stage > 1 || (D.spread_flags & DISEASE_SPREAD_AIRBORNE))) // medibot can't detect a virus in its initial stage unless it spreads airborne.
				return TRUE //STOP DISEASE FOREVER

	return FALSE

/mob/living/simple_animal/bot/medbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_DISARM && mode != BOT_TIPPED)
		H.visible_message(span_danger("[H] begins tipping over [src]."), span_warning("You begin tipping over [src]..."))

		if(world.time > last_tipping_action_voice + 15 SECONDS)
			last_tipping_action_voice = world.time // message for tipping happens when we start interacting, message for righting comes after finishing
			var/list/messagevoice = list("Hey, wait..." = 'sound/voice/medbot/hey_wait.ogg',"Please don't..." = 'sound/voice/medbot/please_dont.ogg',"I trusted you..." = 'sound/voice/medbot/i_trusted_you.ogg', "Nooo..." = 'sound/voice/medbot/nooo.ogg', "Oh fuck-" = 'sound/voice/medbot/oh_fuck.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(src, messagevoice[message], 70, FALSE)

		if(do_after(H, 3 SECONDS, src))
			tip_over(H)

	else if(H.a_intent == INTENT_HELP && mode == BOT_TIPPED)
		H.visible_message(span_notice("[H] begins righting [src]."), span_notice("You begin righting [src]..."))
		if(do_after(H, 3 SECONDS, src))
			set_right(H)
	else
		..()


/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		patient = C
		mode = BOT_HEALING
		update_icon()
		medicate_patient(C)
		update_icon()
	else
		..()

/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view())
	..()
	if(!is_blind(src))
		chemscan(src, A)

/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	if(!on)
		return

	if(!istype(C))
		oldpatient = patient
		soft_reset()
		return

	if(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_FAKEDEATH)))
		var/list/messagevoice = list("No! Stay with me!" = 'sound/voice/medbot/no.ogg',"Live, damnit! LIVE!" = 'sound/voice/medbot/live.ogg',"I...I've never lost a patient before. Not today, I mean." = 'sound/voice/medbot/lost.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50)
		oldpatient = patient
		soft_reset()
		return

	var/reagent_id = null

	if(emagged == 2) //Emagged! Time to poison everybody.
		reagent_id = /datum/reagent/toxin

	else
		if(treat_virus)
			var/virus = 0
			for(var/thing in C.diseases)
				var/datum/disease/D = thing
				//detectable virus
				if((!(D.visibility_flags & HIDDEN_SCANNER)) || (!(D.visibility_flags & HIDDEN_PANDEMIC)))
					if(D.severity != DISEASE_SEVERITY_POSITIVE)      //virus is harmful
						if((D.stage > 1) || (D.spread_flags & DISEASE_SPREAD_AIRBORNE))
							virus = 1

			if(!reagent_id && (virus))
				if(!C.reagents.has_reagent(treatment_virus) && !C.reagents.has_reagent(treatment_virus_avoid))
					reagent_id = treatment_virus

		if(!reagent_id && (C.getBruteLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_brute) && !C.reagents.has_reagent(treatment_brute_avoid))
				reagent_id = treatment_brute

		if(!reagent_id && (C.getOxyLoss() >= (15 + heal_threshold)))
			if(!C.reagents.has_reagent(treatment_oxy) && !C.reagents.has_reagent(treatment_oxy_avoid))
				reagent_id = treatment_oxy

		if(!reagent_id && (C.getFireLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_fire) && !C.reagents.has_reagent(treatment_fire_avoid))
				reagent_id = treatment_fire

		if(!reagent_id && (C.getToxLoss() >= heal_threshold))
			if(!C.reagents.has_reagent(treatment_tox) && !C.reagents.has_reagent(treatment_tox_avoid))
				reagent_id = treatment_tox

		//If the patient is injured but doesn't have our special reagent in them then we should give it to them first
		if(reagent_id && use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
			for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
				if(!C.reagents.has_reagent(R.type) && !check_overdose(patient, R.type, injection_amount))
					reagent_id = "internal_beaker"
					break

	if(!reagent_id) //If they don't need any of that they're probably cured!
		if(C.maxHealth - C.health < heal_threshold)
			to_chat(src, span_notice("[C] is healthy! Your programming prevents you from injecting anyone without at least [heal_threshold] damage of any one type ([heal_threshold + 15] for oxygen damage.)"))
		var/list/messagevoice = list("All patched up!" = 'sound/voice/medbot/patchedup.ogg',"An apple a day keeps me away." = 'sound/voice/medbot/apple.ogg',"Feel better soon!" = 'sound/voice/medbot/feelbetter.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50)
		bot_reset()
		return
	else
		if(!emagged && (reagent_id != "internal_beaker") && check_overdose(patient, reagent_id, injection_amount))
			soft_reset()
			return
		C.visible_message(span_danger("[src] is trying to inject [patient]!"), \
			span_userdanger("[src] is trying to inject you!"))

		var/failed = FALSE
		if(do_mob(src, patient, 30))
			if((get_dist(src, patient) <= 1) && (on) && assess_patient(patient))
				if(reagent_id == "internal_beaker")
					if(use_beaker && reagent_glass && reagent_glass.reagents.total_volume)
						var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
						var/reagentlist = pretty_string_from_reagent_list(reagent_glass.reagents.reagent_list)
						log_combat(src, patient, "injected", "beaker source", "[reagentlist]:[injection_amount]")
						reagent_glass.reagents.reaction(patient, INJECT, fraction)
						reagent_glass.reagents.trans_to(patient,injection_amount) //Inject from beaker instead.
				else
					patient.reagents.add_reagent(reagent_id,injection_amount)
					log_combat(src, patient, "injected", "internal synthesizer", "[reagent_id]:[injection_amount]")
				C.visible_message(span_danger("[src] injects [patient] with its syringe!"), \
					span_userdanger("[src] injects you with its syringe!"))
			else
				failed = TRUE
		else
			failed = TRUE

		if(failed)
			visible_message("[src] retracts its syringe.")
		update_icon()
		soft_reset()
		return

/mob/living/simple_animal/bot/medbot/proc/check_overdose(mob/living/carbon/patient,reagent_id,injection_amount)
	var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
	if(!R.overdose_threshold) //Some chems do not have an OD threshold
		return FALSE
	var/current_volume = patient.reagents.get_reagent_amount(reagent_id)
	if(current_volume + injection_amount > R.overdose_threshold)
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	drop_part(firstaid, Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	drop_part(healthanalyzer, Tsec)

	if(reagent_glass)
		drop_part(reagent_glass, Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	if(emagged && prob(25))
		playsound(src, 'sound/voice/medbot/insult.ogg', 50)

	do_sparks(3, TRUE, src)
	..()

/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(declare_cooldown > world.time)
		return
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient || "A patient"] is in critical condition at [location]!",radio_channel)
	declare_cooldown = world.time + 200

/obj/machinery/bot_core/medbot
	req_one_access = list(ACCESS_MEDICAL, ACCESS_ROBO_CONTROL)

#undef MEDBOT_PANIC_NONE
#undef MEDBOT_PANIC_LOW
#undef MEDBOT_PANIC_MED
#undef MEDBOT_PANIC_HIGH
#undef MEDBOT_PANIC_FUCK
#undef MEDBOT_PANIC_ENDING
#undef MEDBOT_PANIC_END
