	new /obj/effect/gibspawner/human(get_turf(src))
	if(stored_changeling && mind)
		visible_message("<span class='warning'>[src] lets out a furious scream as it shrinks into its human form.</span>", \
						"<span class='userdanger'>We lack the power to maintain this form! We helplessly turn back into a human...</span>")
		stored_changeling.loc = get_turf(src)
		mind.transfer_to(stored_changeling)
		stored_changeling.Unconscious(300) //Make them helpless for some time
		stored_changeling.status_flags &= ~GODMODE
		qdel(src)
	else
		visible_message("<span class='warning'>[src] lets out a waning scream as it falls, twitching, to the floor.</span>", \
						"<span class='userdanger'>We have fallen! We begin the revival process...</span>")
		addtimer(CALLBACK(src, .proc/lingreform), 450)

/mob/living/simple_animal/hostile/true_changeling/proc/lingreform()
	if(!src)
		return FALSE
	visible_message("<span class='userdanger'>the twitching corpse of [src] reforms!</span>")
	for(var/mob/M in view(7, src))
		flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 5)
	new /obj/effect/gibspawner/human(get_turf(src))
	revive() //Changelings can self-revive, and true changelings are no exception

/mob/living/simple_animal/hostile/true_changeling/mob_negates_gravity()
	return wallcrawl

/mob/living/simple_animal/hostile/true_changeling/adjustFireLoss(amount)
	if(!stat)
		playsound(src, 'sound/creatures/ling_scream.ogg', 100, 1)
	..()

/datum/action/innate/changeling
	icon_icon = 'icons/mob/changeling.dmi'
	background_icon_state = "bg_ling"

/datum/action/innate/changeling/reform
	name = "Re-Form Human Shell"
	desc = "We turn back into a human. This takes considerable effort and will stun us for some time afterwards."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "reform"

/datum/action/innate/changeling/reform/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(!M.stored_changeling)
		to_chat(M, "<span class='warning'>We do not have a form other than this!</span>")
		return FALSE
	if(M.time_spent_as_true < TRUE_CHANGELING_REFORM_THRESHOLD)
		to_chat(M, "<span class='warning'>We are not able to change back at will!</span>")
		return FALSE
	M.visible_message("<span class='warning'>[M] suddenly crunches and twists into a smaller form!</span>", \
					"<span class='danger'>We return to our human form.</span>")
	M.stored_changeling.forceMove(get_turf(M))
	M.mind.transfer_to(M.stored_changeling)
	M.stored_changeling.Unconscious(200)
	M.stored_changeling.status_flags &= ~GODMODE
	qdel(M)
	return TRUE

/datum/action/innate/changeling/devour
	name = "Devour"
	desc = "We tear into the innards of a human. After some time, they will be significantly damaged and our health partially restored."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "devour"

/datum/action/innate/changeling/devour/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return
	if(M.devouring)
		to_chat(M, "<span class='warning'>We are already feasting on a human!</span>")
		return FALSE
	var/list/potential_targets = list()
	for(var/mob/living/carbon/human/H in range(1, M))
		potential_targets.Add(H)
	if(!potential_targets.len)
		to_chat(M, "<span class='warning'>There are no humans nearby!</span>")
		return FALSE
	var/mob/living/carbon/human/lunch
	if(potential_targets.len == 1)
		lunch = potential_targets[1]
	else
		lunch = input(src, "Choose a human to devour.", "Lunch") as null|anything in potential_targets
	if(!lunch)
		return FALSE
	if(lunch.getBruteLoss() >= 200)
		to_chat(M, "<span class='warning'>This human's flesh is too mangled to devour!</span>")
		return FALSE
	M.devouring = TRUE
	M.visible_message("<span class='warning'>[M] begins ripping apart and feasting on [lunch]!</span>", \
						"<span class='danger'>We begin to feast upon [lunch]...</span>")
	if(!do_mob(M, 50, target = lunch))
		M.devouring = FALSE
		return FALSE
	M.devouring = FALSE
	M.visible_message("<span class='warning'>[M] tears a chunk from [lunch]'s flesh!</span>", \
						"<span class='danger'>We tear a chunk of flesh from [lunch] and devour it!</span>")
	lunch.adjustBruteLoss(60)
	to_chat(lunch, "<span class='userdanger'>[M] tears into you!</span>")
	var/obj/effect/decal/cleanable/blood/gibs/G = new(get_turf(lunch))
	step(G, pick(GLOB.alldirs)) //Make some gibs spray out for dramatic effect
	playsound(lunch, 'sound/creatures/hit6.ogg', 100, 1)
	if(!lunch.stat)
		lunch.emote("scream")
	M.adjustBruteLoss(-50)

/datum/action/innate/changeling/spine_crawl
	name = "Spine Crawl"
	desc = "We use our spines to gouge into terrain and crawl along it, negating gravity loss. This makes us slower."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "spine"

/datum/action/innate/changeling/spine_crawl/Activate()
	var/mob/living/simple_animal/hostile/true_changeling/M = owner
	if(!istype(M))
		return FALSE
	M.wallcrawl = !M.wallcrawl
	if(M.wallcrawl)
		M.visible_message("<span class='danger'>[M] begins gouging its spines into the terrain!</span>", \
							"<span class='notice'>We begin using our spines for movement.</span>")
		M.speed = 1
	else
		M.visible_message("<span class='danger'>[M] recedes their spines back into their body!</span>", \
							"<span class='notice'>We return moving normally.</span>")
		M.speed = initial(M.speed)

undef TRUE_CHANGELING_REFORM_THRESHOLD
#undef TRUE_CHANGELING_PASSIVE_HEAL
#undef TRUE_CHANGELING_FORCED_REFORM