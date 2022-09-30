/datum/action/xeno_action/activable/roar/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/xeno = owner
	if (!istype(xeno))
		return

	if (!action_cooldown_check())
		return
	if (!check_plasma_owner())
		return

	if(!xeno.check_state())
		return

	if (xeno.mutation_type == ROYAL_NORMAL)
		var/datum/behavior_delegate/royal/BD = xeno.behavior_delegate
		if (!istype(BD))
			return
		if (!BD.use_internal_blood_ability(screech_cost))
			return

	if (curr_effect_type == ROYAL_SCREECH_BUFF)


		playsound(xeno.loc, screech_sound_effectt, 55, 0, status = 0)
		xeno.visible_message(SPAN_XENOHIGHDANGER("[xeno] emits a guttural roar!"))
		xeno.create_shriekwave(color = "#07f707")
		var/screech_duration = 200
		var/image/buff_overlay = get_busy_icon(ACTION_GREEN_POWER_UP)
		var/mob/living/carbon/Xenomorph/Praetorian/P = owner
		if (!(P.screech_status_flags & ROYAL_SCREECH_BUFFED))
			P.armor_modifier += XENO_ARMOR_MOD_MED
			P.damage_modifier += XENO_DAMAGE_MOD_VERYSMALL
			P.recalculate_armor()
			P.recalculate_damage()
			P.screech_status_flags |= ROYAL_SCREECH_BUFFED
			to_chat(src, SPAN_XENOWARNING("Your roar empowers you to strike harder!"))
			buff_overlay.flick_overlay(P, 200)

			spawn (screech_duration)
				P.armor_modifier -= XENO_ARMOR_MOD_MED
				P.damage_modifier -= XENO_DAMAGE_MOD_VERYSMALL
				P.recalculate_armor()
				P.recalculate_damage()
				P.screech_status_flags &= ~ROYAL_SCREECH_BUFFED
				to_chat(src, SPAN_XENOWARNING("You feel the power of your roar wane."))

		else
			to_chat(src, SPAN_XENOWARNING("Your roar's effects do NOT stack with other roar's!"))

		for(var/mob/living/carbon/Xenomorph/XX in view(6, xeno))
			var/image/bufff_overlay = get_busy_icon(ACTION_GREEN_POWER_UP)
			if (!(XX.screech_status_flags & ROYAL_SCREECH_BUFFED))
				XX.armor_modifier += XENO_ARMOR_MOD_MED
				XX.damage_modifier += XENO_DAMAGE_MOD_VERYSMALL
				XX.screech_status_flags |= ROYAL_SCREECH_BUFFED
				XX.recalculate_armor()
				XX.recalculate_damage()
				bufff_overlay.flick_overlay(XX, 200)
				to_chat(XX, SPAN_XENOWARNING("You feel empowered after heearing the roar of [src]!"))

				spawn (screech_duration)
					XX.armor_modifier -= XENO_ARMOR_MOD_MED
					XX.damage_modifier -= XENO_DAMAGE_MOD_VERYSMALL
					XX.screech_status_flags &= ~ROYAL_SCREECH_BUFFED
					XX.recalculate_armor()
					XX.recalculate_damage()
					to_chat(XX, SPAN_XENOWARNING("You feel the effects of [src] wane!"))
			else
				to_chat(XX, SPAN_XENOWARNING("You can only be empowered by one roar at once!"))

	else if (curr_effect_type == ROYAL_SCREECH_DEBUFF)
		playsound(xeno.loc, screech_sound_effectt, 55, 0, status = 0)
		xeno.visible_message(SPAN_XENOHIGHDANGER("[xeno] emits a guttural roar!"))
		xeno.create_shriekwave(color = "#FF0000")
		var/slow_duration = 40

		for(var/mob/living/carbon/human/human in view(5, xeno))
			human.visible_message(SPAN_DANGER("[xeno]'s roar shakes your entire body, causing you to fall over in pain!"))
			if (!(xeno.screech_status_flags & ROYAL_SCREECH_DEBUFF))
				shake_camera(human, 2, 3)
				human.Daze(debuff_daze)
				human.KnockDown(get_xeno_stun_duration(human, 0.5))
				new /datum/effects/xeno_slow(human, xeno, null, null, get_xeno_stun_duration(human, slow_duration))

	apply_cooldown()
	..()
	return


/datum/action/xeno_action/activable/rooting_slash/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	if (!action_cooldown_check())
		return

	if (!X.check_state())
		return

	if (!check_and_use_plasma_owner())
		return

	if (!isXenoOrHuman(A) || X.can_not_harm(A))
		to_chat(X, SPAN_XENODANGER("You must target a hostile!"))
		return

	var/mob/living/carbon/H = A

	var/dist = get_dist(X, H)

	if (dist > range)
		to_chat(X, SPAN_WARNING("[H] is too far away!"))
		return

	if (dist > 1)
		var/turf/targetTurf = get_step(X, get_dir(X, H))
		if (targetTurf.density)
			to_chat(X, SPAN_WARNING("You can't attack through [targetTurf]!"))
			return
		else
			for (var/atom/I in targetTurf)
				if (I.density && !I.throwpass && !istype(I, /obj/structure/barricade) && !istype(I, /mob/living))
					to_chat(X, SPAN_WARNING("You can't attack through [I]!"))
					return


	if (H.stat == DEAD)
		to_chat(X, SPAN_XENODANGER("[H] is dead, why would you want to touch it?"))
		return

	if (X.mutation_type == ROYAL_NORMAL)
		var/datum/behavior_delegate/royal/BD = X.behavior_delegate
		if (!istype(BD))
			return
		if (!BD.use_internal_blood_ability(root_cost))
			return


	// Flick overlay and play sound
	X.animation_attack_on(A, 10)
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(H,S, 50, 1)

	var/root_duration = 1 SECONDS
	var/damage = 15

	X.visible_message(SPAN_XENODANGER("[X] extends with its claws and smashes [A], pinning them to the ground dealing damage!"), SPAN_XENOHIGHDANGER("You extend your claws and smash [A], pinning them to the ground and dealing damage!"))

	H.frozen = TRUE
	H.update_canmove()
	H.apply_armoured_damage(damage, ARMOR_MELEE, BRUTE, "chest", 15)

	if (ishuman(H))
		var/mob/living/carbon/human/Hu = H
		Hu.update_xeno_hostile_hud()

		addtimer(CALLBACK(GLOBAL_PROC, .proc/unroot_human, H), get_xeno_stun_duration(H, root_duration))
		to_chat(H, SPAN_XENOHIGHDANGER("[X] has pinned you to the ground! You cannot move!"))

	apply_cooldown()
	..()
	return

/datum/action/xeno_action/activable/cleave/proc/remove_bufff()
	buffed = FALSE
