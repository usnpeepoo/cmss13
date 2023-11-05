/datum/action/xeno_action/onclick/flight/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno = owner
	if(!xeno.check_state())
		return

	if(!action_cooldown_check())
		return

	if (!check_and_use_plasma_owner())
		return

	xeno.balloon_alert_to_viewers("begins to take flight!")

	xeno.update_icons()
	animate(xeno, pixel_y = 16, alpha = alpha_amount, time = 0.50 SECONDS, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL)
	playsound(xeno,'sound/weapons/alien_flight.ogg', 55)
	xeno.speed_modifier -= speed_buff
	xeno.evasion_modifier += evasion_buff
	xeno.recalculate_speed()
	xeno.recalculate_evasion()

	if (xeno.mutation_type == HAWK_NORMAL)
		var/datum/behavior_delegate/hawk_base/behavior = xeno.behavior_delegate
		behavior.on_flight()

	// if we go off early, this also works fine.
	flight_timer_id = addtimer(CALLBACK(src, PROC_REF(flight_off)), duration, TIMER_STOPPABLE)
	xeno.add_temp_pass_flags(PASS_MOB_THRU|PASS_BUILDING|PASS_UNDER)

	apply_cooldown_override(1000000000)
	return ..()

/datum/action/xeno_action/proc/flight_off()

	var/flight_timer_id = 25 SECONDS
	var/speed_buff = 0.4
	var/evasion_buff = 40

	if(!owner || owner.alpha == initial(owner.alpha))
		return


	if (flight_timer_id != TIMER_ID_NULL)
		deltimer(flight_timer_id)
		flight_timer_id = TIMER_ID_NULL

	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.speed_modifier += speed_buff
	xeno.evasion_modifier -= evasion_buff
	xeno.recalculate_speed()
	xeno.recalculate_evasion()

	xeno.update_icons()
	animate(xeno, alpha = initial(xeno.alpha), pixel_y = initial(xeno.pixel_y),time = 0.5 SECONDS, easing = LINEAR_EASING)
	playsound(xeno,'sound/weapons/alien_landing.ogg', 70)
	to_chat(xeno, SPAN_XENOHIGHDANGER("You feel your wing strength waver!"))
	xeno.balloon_alert_to_viewers("begins to land!")
	xeno.remove_temp_pass_flags(PASS_MOB_THRU|PASS_BUILDING|PASS_UNDER)

	if (xeno.mutation_type == HAWK_NORMAL)
		var/datum/behavior_delegate/hawk_base/behavior = xeno.behavior_delegate
		if (istype(behavior))
			behavior.on_flight_off()

/datum/action/xeno_action/onclick/flight/ability_cooldown_over()
	to_chat(owner, SPAN_XENOHIGHDANGER("You are ready to take flight again!"))
	..()

/datum/action/xeno_action/activable/strike/use_ability(atom/targeted_atom)
	var/mob/living/carbon/xenomorph/xeno = owner

	if(!action_cooldown_check())
		return

	if(!xeno.check_state())
		return

	if(!iscarbon(targeted_atom))
		return

	var/mob/living/carbon/hit_target = targeted_atom

	if (!check_and_use_plasma_owner())
		return

	if(xeno.can_not_harm(hit_target))
		return

	if(hit_target.stat == DEAD)
		to_chat(xeno, SPAN_XENODANGER("You can't strike a dead target!"))
		return

	if(xeno.stat == UNCONSCIOUS)
		return

	if(xeno.stat == DEAD)
		return

	if(HAS_TRAIT(xeno, TRAIT_ABILITY_FLIGHT))
		var/mob/living/carbon/target = targeted_atom
		target.targeted_by = xeno
		target.target_locked = image("icon" = 'icons/effects/Targeted.dmi', "icon_state" = "locking")
		new /datum/effects/xeno_slow(hit_target, xeno, null, null, get_xeno_stun_duration(hit_target, 10))
		target.update_targeted()
		if (!do_after(xeno, windup_duration, INTERRUPT_ALL & ~INTERRUPT_MOVED, BUSY_ICON_HOSTILE))
			target.targeted_by = null
			target.target_locked = null
			hit_target.update_targeted()
			to_chat(xeno, SPAN_XENODANGER("The target moved out of range or you were incapacitated!"))
			return
		// Needs to occur AFTER the do_after resolves.
		if (get_dist(hit_target, xeno) > max_distance)
			target.targeted_by = null
			target.target_locked = null
			hit_target.update_targeted()
			to_chat(xeno, SPAN_XENODANGER("The target moved out of range or you were incapacitated!"))
			return
		target.targeted_by = null
		target.target_locked = null
		hit_target.update_targeted()
		to_chat(xeno, SPAN_XENOHIGHDANGER("You attempt to fly through [hit_target]!"))
		to_chat(hit_target, SPAN_XENOHIGHDANGER("[xeno] flies towards you!"))
		playsound(hit_target, 'sound/weapons/alien_bite1.ogg', 50, TRUE)
		xeno.throw_atom(get_step_towards(hit_target, xeno), max_distance, SPEED_FAST, xeno)
		xeno.flick_attack_overlay(hit_target, "headbite")
		xeno.animation_attack_on(hit_target, pixel_offset = 16)
		hit_target.apply_armoured_damage(35, ARMOR_MELEE, BRUTE, "chest", 10)
		hit_target.apply_effect(1, WEAKEN)
		xeno.emote("roar")
		flight_off()
		apply_cooldown()
	else
		if(!xeno.Adjacent(hit_target))
			to_chat(xeno, SPAN_XENOHIGHDANGER("You can only strike an adjacent target!"))
			return
		to_chat(xeno, SPAN_XENOHIGHDANGER("You bite [hit_target]’s chest!"))
		playsound(hit_target,'sound/weapons/alien_bite2.ogg', 50, TRUE)
		xeno.visible_message(SPAN_DANGER("[xeno] bites [hit_target]’s chest!."))
		xeno.flick_attack_overlay(hit_target, "headbite")
		xeno.animation_attack_on(hit_target, pixel_offset = 16)
		hit_target.apply_armoured_damage(30, ARMOR_MELEE, BRUTE, "chest", 5)
		hit_target.apply_effect(2, DAZE)
	apply_cooldown()
	return ..()

/datum/action/xeno_action/activable/tail_stab/hawk/use_ability(atom/A)
	var/target = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.apply_effect(2, SLOW)
		carbon_target.reagents.add_reagent("molecularacid", 0.75)
		carbon_target.reagents.set_source_mob(owner, /datum/reagent/toxin/molecular_acid)
