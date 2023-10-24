/datum/action/xeno_action/onclick/flight
	name = "Take Flight"
	action_icon_state = "xeno_spit"
	ability_name = "take flight"
	macro_path = /datum/action/xeno_action/verb/verb_take_flight
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_1
	xeno_cooldown = 1 SECONDS
	plasma_cost = 50

	var/duration = 25 SECONDS // 30 seconds base
	var/flight_timer_id = TIMER_ID_NULL
	var/alpha_amount = 125
	var/speed_buff = 0.4
	var/evasion_buff = 50

/datum/action/xeno_action/activable/xeno_spit/hawk
	name = "Spit Acid"
	action_icon_state = "xeno_spit"
	ability_name = "spit acid"
	macro_path = /datum/action/xeno_action/verb/verb_xeno_spit
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_2
	cooldown_message = "You feel your corrosive glands swell with acid. You can spit again."

/datum/action/xeno_action/activable/beak_strike
	name = "Beak Strike"
	action_icon_state = "xeno_spit"
	ability_name = "beak strike"
	macro_path = /datum/action/xeno_action/verb/verb_beak_strike
	action_type = XENO_ACTION_CLICK
	ability_primacy = XENO_PRIMARY_ACTION_3
	xeno_cooldown = 2 SECONDS
	plasma_cost = 1

	// Config values
	var/max_distance = 5 // 6 tiles between
	var/windup_duration = 10

