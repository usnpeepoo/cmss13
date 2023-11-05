/datum/caste_datum/hawk
	caste_type = XENO_CASTE_HAWK
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_2
	melee_damage_upper = XENO_DAMAGE_TIER_3
	melee_vehicle_damage = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_4
	plasma_gain = XENO_PLASMA_GAIN_TIER_7
	plasma_max = XENO_PLASMA_TIER_5
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2
	armor_deflection = XENO_ARMOR_TIER_1
	evasion = XENO_EVASION_LOW
	speed = XENO_SPEED_TIER_7

	behavior_delegate_type = /datum/behavior_delegate/hawk_base

	spit_types = list(/datum/ammo/xeno/acid/hawk)
	acid_level = 2

	spit_delay = 10

	evolution_allowed = TRUE
	deevolves_to = list(XENO_CASTE_RUNNER)
	caste_desc = "A nimble winged predator."
	evolves_to = list(XENO_CASTE_RAVAGER)

	tackle_min = 2
	tackle_max = 4
	tackle_chance = 25
	tacklestrength_min = 3
	tacklestrength_max = 4

	minimum_evolve_time = 9 MINUTES

	minimap_icon = "boiler"

/mob/living/carbon/xenomorph/hawk
	caste_type = XENO_CASTE_HAWK
	name = XENO_CASTE_HAWK
	desc = "A small but winged monstrosity, it has a visible green sac and a long tail."
	icon = 'icons/mob/xenos/hawk.dmi'
	icon_size = 64
	icon_state = "Hawk Walking"
	plasma_types = list(PLASMA_NEUROTOXIN)
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = 3
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	mutation_type = HAWK_NORMAL
	spit_delay  = 30
	tileoffset = 3
	viewsize = 7

	icon_xeno = 'icons/mob/xenos/hawk.dmi'
	icon_xenonid = 'icons/mob/xenonids/hawk.dmi'


	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/tail_stab/hawk,
		/datum/action/xeno_action/onclick/flight,
		/datum/action/xeno_action/activable/xeno_spit/hawk,
		/datum/action/xeno_action/activable/strike,
		/datum/action/xeno_action/onclick/tacmap,
	)
	mutation_icon_state = HAWK_NORMAL
	mutation_type = HAWK_NORMAL

/mob/living/carbon/xenomorph/hawk/Initialize(mapload, mob/living/carbon/xenomorph/oldxeno, h_number)
	. = ..()

	update_icon_source()

/mob/living/carbon/xenomorph/hawk/attack_hand()
	if(flight)
		return
	..()

/mob/living/carbon/xenomorph/hawk/attackby()
	if(flight)
		return
	..()


/datum/behavior_delegate/hawk_base
	name = "Base Hawk Behavior Delegate"

	var/flight_recharge_time = 250   // 15 seconds to recharge invisibility.
	var/flight_start_time = -1 // Special value for when we're not invisible
	var/flight_duration = 250  // so we can display how long the lurker is invisible to it
	var/can_take_flight = TRUE

/datum/behavior_delegate/hawk_base/proc/on_flight()
	ADD_TRAIT(bound_xeno, TRAIT_ABILITY_FLIGHT, TRAIT_SOURCE_ABILITY("Flight"))
	bound_xeno.flight = TRUE
	can_take_flight = FALSE
	flight_start_time = world.time


/datum/behavior_delegate/hawk_base/proc/on_flight_off()
	bound_xeno.flight = FALSE

	REMOVE_TRAIT(bound_xeno, TRAIT_ABILITY_FLIGHT, TRAIT_SOURCE_ABILITY("Flight"))

	// SLIGHTLY hacky because we need to maintain lots of other state on the lurker
	// whenever invisibility is on/off CD and when it's active.
	addtimer(CALLBACK(src, PROC_REF(regen_flight)), flight_recharge_time)

	flight_start_time = -1

/datum/behavior_delegate/hawk_base/proc/regen_flight()
	if (can_take_flight)
		return

	can_take_flight = TRUE
	if(bound_xeno)
		var/datum/action/xeno_action/onclick/flight/FLI = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/flight)
		if(FLI && istype(FLI))
			FLI.end_cooldown()

/datum/behavior_delegate/hawk_base/append_to_stat()
	. = list()
	var/flight_message = (flight_start_time == -1) ? "N/A" : "[(flight_duration-(world.time - flight_start_time))/10] seconds."
	. += "Flight Time Left: [flight_message]"

/datum/behavior_delegate/hawk_base/on_update_icons()
	if(bound_xeno.stat == DEAD)
		return

	if(bound_xeno.flight && bound_xeno.health > 0)
		bound_xeno.icon_state = "[bound_xeno.mutation_icon_state || bound_xeno.mutation_type] Hawk Flying"
		return TRUE
