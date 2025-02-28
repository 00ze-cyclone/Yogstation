/// The max range we can zoom in on people from.
#define MAX_LIONHUNTER_RANGE 30

// The Lionhunter, a gun for heretics
// The ammo it uses takes time to "charge" before firing,
// releasing a homing, very damaging projectile
/obj/item/gun/ballistic/rifle/boltaction/lionhunter
	name = "\improper Lionhunter's Rifle"
	desc = "An antique looking rifle that looks immaculate despite being clearly very old."
	slot_flags = ITEM_SLOT_BACK
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "lionhunter"
	item_state = "lionhunter"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	fire_sound = "sound/weapons/sniper_shot.ogg"
	zoomable = TRUE
	zoom_amt = 10 //Long range, enough to see in front of you, but no tiles behind you.
	zoom_out_amt = 5

/obj/item/ammo_box/magazine/internal/boltaction/lionhunter
	name = "lionhunter rifle internal magazine"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	caliber = CALIBER_310
	max_ammo = 3
	multiload = 1

/obj/item/ammo_casing/strilka310/lionhunter
	name = "strilka310 bullet casing"
	desc = "A .310 bullet casing."
	icon_state = "310-casing"
	caliber = CALIBER_310
	projectile_type = /obj/projectile/bullet/strilka310/lionhunter
	/// Whether we're currently aiming this casing at something
	var/currently_aiming = FALSE
	/// How many seconds it takes to aim per tile of distance between the target
	var/seconds_per_distance = 0.5 SECONDS
	/// The minimum distance required to gain a damage bonus from aiming
	var/min_distance = 4

/obj/item/ammo_casing/strilka310/lionhunter/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if(!BB)
		return
	if(!check_fire(target, user))
		return

	return ..()

/// Checks if we can successfully fire our projectile.
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire(atom/target, mob/living/user)
	// In case someone puts this in turrets or something wacky, just fire like normal
	if(!iscarbon(user) || !istype(loc, /obj/item/gun/ballistic/rifle/boltaction/lionhunter))
		return TRUE

	if(currently_aiming)
		user.balloon_alert(user, "already aiming!")
		return FALSE

	var/distance = get_dist(user, target)
	if(target.z != user.z || distance > MAX_LIONHUNTER_RANGE)
		return FALSE

	var/fire_time = min(distance * seconds_per_distance, 10 SECONDS)

	if(distance <= min_distance || !isliving(target))
		return TRUE

	user.balloon_alert(user, "taking aim...")
	user.playsound_local(get_turf(user), 'sound/weapons/chunkyrack.ogg', 100, TRUE)

	var/image/reticle = image(
		icon = 'icons/mob/actions/actions_items.dmi',
		icon_state = "sniper_zoom",
		layer = ABOVE_MOB_LAYER,
		loc = target,
	)
	reticle.alpha = 0

	var/list/mob/viewers = viewers(target)
	// The shooter might be out of view, but they should be included
	viewers |= user

	for(var/mob/viewer as anything in viewers)
		viewer.client?.images |= reticle

	// Animate the fade in
	animate(reticle, fire_time * 0.5, alpha = 255, transform = turn(reticle.transform, 180))
	animate(reticle, fire_time * 0.5, transform = turn(reticle.transform, 180))

	currently_aiming = TRUE
	. = do_after(user, fire_time, target, IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_fire_callback), target, user))
	currently_aiming = FALSE

	animate(reticle, 0.5 SECONDS, alpha = 0)
	for(var/mob/viewer as anything in viewers)
		viewer.client?.images -= reticle

	if(!.)
		user.balloon_alert(user, "interrupted!")

	return .

/// Callback for the do_after within the check_fire proc to see if something will prevent us from firing while aiming
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire_callback(mob/living/target, mob/living/user)
	if(!isturf(target.loc))
		return FALSE

	return TRUE

/obj/item/ammo_casing/strilka310/lionhunter/ready_proj(atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	if(!BB)
		return

	var/distance = get_dist(user, target)
	// If we're close range, or the target's not a living, OR for some reason a non-carbon is firing the gun
	// The projectile is dry-fired, and gains no buffs
	// BUT, if we're at a decent range and the target's a living mob,
	// the projectile's been channel fired. It has full effects and homes in.
	if(distance > min_distance && isliving(target) && iscarbon(user))
		BB.damage *= 2
		BB.stamina *= 2
		BB.knockdown = 0.5 SECONDS
		BB.stutter = 6 SECONDS
		BB.projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINES | PASSSTRUCTURE | PASSDOOR

		BB.homing = TRUE
		BB.homing_turn_speed = 80
		BB.set_homing_target(target)

	return ..()

/obj/projectile/bullet/strilka310/lionhunter
	name = "hunter's .310 bullet"
	// These stats are only applied if the weapon is fired fully aimed
	// If fired without aiming or at someone too close, it will do much less
	damage = 30
	stamina = 30
	penetration_type = 2
	penetrating = TRUE

// Extra ammunition can be made with a heretic ritual.
/obj/item/ammo_box/strilka310/lionhunter
	name = "stripper clip (.310 hunter)"
	desc = "A stripper clip of mysterious, atypical ammo. It doesn't fit into normal ballistic rifles."
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	max_ammo = 3
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/effect/temp_visual/bullet_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2

#undef MAX_LIONHUNTER_RANGE
