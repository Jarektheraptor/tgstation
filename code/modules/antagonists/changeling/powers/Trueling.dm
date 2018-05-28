+#define TRUE_CHANGELING_REFORM_THRESHOLD 0 //Can turn back at will, by default
+#define TRUE_CHANGELING_PASSIVE_HEAL 3 //Amount of brute damage restored per tick
+#define TRUE_CHANGELING_FORCED_REFORM 180 //3 minutes
+
+//Changelings in their true form.
+//Massive health and damage, but all of their chems and it's really obvious it's >them
+
+/mob/living/simple_animal/hostile/true_changeling
+	name = "horror"
+	real_name = "horror"
+	desc = "Holy shit, what the fuck is that thing?!"
+	speak_emote = list("says with one of its faces")
+	emote_hear = list("says with one of its faces")
+	icon = 'icons/mob/changeling.dmi'
+	icon_state = "horror1"
+	icon_living = "horror1"
+	icon_dead = "horror_dead"
+	speed = 0.5
+	gender = NEUTER
+	a_intent = "harm"
+	stop_automated_movement = TRUE
+	status_flags = 0
+	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	health = 240
	maxHealth = 240 //pretty durable
	damage_coeff = list(BRUTE = 0.75, BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //feel the burn!!
	force_threshold = 10
	healable = 0
	environment_smash = 1 //Tables, closets, etc.
	melee_damage_lower = 35
	melee_damage_upper = 35
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	wander = 0
	attacktext = "tears into"
	attack_sound = 'sound/creatures/hit3.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 15) //It's a pretty big dude. Actually killing one is a feat.
	var/time_spent_as_true = 0
	var/playstyle_string = "<b><span class='big danger'>We have entered our true form!</span><br>We are unbelievably deadly, and regenerate life at a steady rate. We must utilise the abilities that we have gained as a result of our transformation, as our old ones are not usable in this form. Taking too much damage will also turn us back into a \
	human in addition to knocking us out. We are not as strong health-wise as we are damage, and we must avoid fire at all costs. Finally, we will uncontrollably revert into a human after some time due to our inability to maintain this form.</b>"
	var/mob/living/carbon/human/stored_changeling = null //The changeling that transformed
	var/devouring = FALSE //If the true changeling is currently devouring a human
	var/wallcrawl = FALSE //If the true changeling is crawling around the place, allowing it to counteract gravity loss
	var/range = 7
	var/datum/action/innate/changeling/reform/reform
	var/datum/action/innate/changeling/devour/devour
	var/datum/action/innate/changeling/spine_crawl/spine_crawl

/mob/living/simple_animal/hostile/true_changeling/Initialize()
	. = ..()
	icon_state = "horror[rand(1, 5)]"
		reform = new
	reform.Grant(src)
	devour = new
	devour.Grant(src)
	spine_crawl = new
	spine_crawl.Grant(src)

/mob/living/simple_animal/hostile/true_changeling/Destroy()
	QDEL_NULL(reform)
	QDEL_NULL(devour)
QDEL_NULL(spine_crawl)
	stored_changeling = null
	return ..()

/mob/living/simple_animal/hostile/true_changeling/Login()
	. = ..()
	to_chat(usr, playstyle_string)

/mob/living/simple_animal/hostile/true_changeling/Life()
	..()
	adjustBruteLoss(-TRUE_CHANGELING_PASSIVE_HEAL) //True changelings slowly regenerate
	time_spent_as_true++ //Used for re-forming
	if(stored_changeling && time_spent_as_true >= TRUE_CHANGELING_FORCED_REFORM)
		death() //After a while, the ling'll revert back without being able to control it

/mob/living/simple_animal/hostile/true_changeling/Stat()
	..()
	if(statpanel("Status"))
		if(stored_changeling)
			var/time_left = TRUE_CHANGELING_FORCED_REFORM - time_spent_as_true
			time_left = CLAMP(time_left, 0, INFINITY)
			stat(null, "Time Remaining: [time_left]")
		stat(null, "Ignoring Gravity: [wallcrawl ? "YES" : "NO"]")

/mob/living/simple_animal/hostile/true_changeling/death()
	..(1)