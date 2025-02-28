
/obj/item/reagent_containers/food/snacks/store/bread
	icon = 'icons/obj/food/burgerbread.dmi'
	volume = 80
	slices_num = 5
	tastes = list("bread" = 10)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice
	icon = 'icons/obj/food/burgerbread.dmi'
	bitesize = 2
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/sandwich
	filling_color = "#FFA500"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	slot_flags = ITEM_SLOT_HEAD
	customfoodfilling = 0 //to avoid infinite bread-ception
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/store/bread/plain
	name = "bread"
	desc = "Some plain old earthen bread."
	icon_state = "bread"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 7)
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	custom_food_type = /obj/item/reagent_containers/food/snacks/customizable/bread
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/plain
	tastes = list("bread" = 10)
	foodtype = GRAIN
	burns_in_oven = TRUE

/obj/item/reagent_containers/food/snacks/breadslice/plain
	name = "bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	customfoodfilling = 1
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/breadslice/plain/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/breadslice/toast, rand(20 SECONDS, 30 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/store/bread/meat
	name = "meat bread"
	desc = "The culinary base of every self-respecting eloquent gentleman."
	icon_state = "meatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/meat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "meat" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/breadslice/meat
	name = "meat bread slice"
	desc = "A slice of delicious meat bread."
	icon_state = "meatbreadslice"
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/store/bread/xenomeat
	name = "xenomeat bread"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/xenomeat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "acid" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/breadslice/xenomeat
	name = "xenomeat bread slice"
	desc = "A slice of delicious meat bread. Extra heretical."
	icon_state = "xenobreadslice"
	filling_color = "#32CD32"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/store/bread/spidermeat
	name = "spidermeat bread"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/spidermeat
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 30, /datum/reagent/toxin = 15, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "cobwebs" = 5)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/breadslice/spidermeat
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	filling_color = "#7CFC00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/store/bread/banana
	name = "banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/banana
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/banana = 20)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/banana = 20)
	tastes = list("bread" = 10) // bananjuice will also flavour
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/breadslice/banana
	name = "banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#FFD700"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/banana = 4)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/store/bread/tofu
	name = "tofu bread"
	desc = "Like meat bread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/tofu
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 10)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "tofu" = 10)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/breadslice/tofu
	name = "tofu bread slice"
	desc = "A slice of delicious tofu bread."
	icon_state = "tofubreadslice"
	filling_color = "#FF8C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/store/bread/creamcheese
	name = "cream cheese bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/creamcheese
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "cheese" = 10)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/breadslice/creamcheese
	name = "cream cheese bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#FF8C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/store/bread/mimana
	name = "mimana bread"
	desc = "Best eaten in silence."
	icon_state = "mimanabread"
	slice_path = /obj/item/reagent_containers/food/snacks/breadslice/mimana
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	list_reagents = list(/datum/reagent/consumable/nutriment = 20, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/consumable/nothing = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("bread" = 10, "silence" = 10)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/breadslice/mimana
	name = "mimana bread slice"
	desc = "A slice of silence!"
	icon_state = "mimanabreadslice"
	filling_color = "#C0C0C0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/toxin/mutetoxin = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/breadslice/custom
	name = "bread slice"
	icon_state = "tofubreadslice"
	filling_color = "#FFFFFF"
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/baguette
	name = "baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	item_state = "baguette"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 1)
	bitesize = 3
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	tastes = list("bread" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = "Alas, it is limited."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "garlicbread"
	item_state = "garlicbread"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/garlic = 2)
	bitesize = 3
	tastes = list("bread" = 1, "garlic" = 1, "butter" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/butterbiscuit
	name = "butter biscuit"
	desc = "Well butter my biscuit!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterbiscuit"
	filling_color = "#F0E68C"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("butter" = 1, "biscuit" = 1)
	foodtype = GRAIN | DAIRY | BREAKFAST

/obj/item/reagent_containers/food/snacks/butterdog
	name = "butterdog"
	desc = "Made from exotic butters."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "butterdog"
	bitesize = 1
	filling_color = "#F1F49A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("bread" = 1, "exotic butter" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/butterdog/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 80)

/obj/item/reagent_containers/food/snacks/danish_hotdog
	name = "danish hotdog"
	desc = "Appetizing bun, with a sausage in the middle, covered with sauce, fried onion and pickle rings."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "danish_hotdog"
	filling_color = "#F1F49A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/ketchup = 3, /datum/reagent/consumable/nutriment/vitamin = 7)
	tastes = list("bun" = 3, "meat" = 2, "fried onion" = 1, "pickles" = 1)
	foodtype = GRAIN | MEAT | VEGETABLES

/obj/item/reagent_containers/food/snacks/frenchtoast
	name = "French toast"
	desc = "A slice of bread soaked in an egg mixture and grilled until golden-brown. Drizzled with syrup!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "frenchtoast"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/cinnamon = 2, /datum/reagent/consumable/sugar = 2) //yogs, values differ from tg
	tastes = list("french toast" = 1, "syrup" = 1, "golden deliciousness" = 1)
	foodtype = GRAIN | EGG | SUGAR | BREAKFAST
	burns_on_grill = TRUE

/obj/item/reagent_containers/food/snacks/frenchtoast/raw
	name = "raw French toast"
	desc = "A slice of bread soaked in a beaten egg mixture. Put it on a griddle to start cooking!"
	icon_state = "raw_frenchtoast"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/cinnamon = 2, /datum/reagent/consumable/sugar = 2)  //yogs, values differ from tg
	tastes = list("raw egg" = 2, "soaked bread" = 1)
	foodtype = GRAIN | RAW | BREAKFAST

/obj/item/reagent_containers/food/snacks/frenchtoast/raw/MakeGrillable()
	AddComponent(/datum/component/grillable, /obj/item/reagent_containers/food/snacks/frenchtoast, rand(20 SECONDS, 30 SECONDS), TRUE)

/obj/item/reagent_containers/food/snacks/breadstick
	name = "breadstick"
	desc = "A delicious, buttery breadstick. Highly addictive, but oh-so worth it."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "breadstick"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("bread" = 1, "butter" = 2)
	foodtype = GRAIN | DAIRY
	burns_in_oven = TRUE

/obj/item/reagent_containers/food/snacks/breadstick/raw
	name = "raw breadstick"
	desc = "An uncooked strip of dough in the shape of a breadstick."
	icon_state = "raw_breadstick"
	tastes = list("raw dough" = 2, "butter" = 1)
	foodtype = GRAIN | DAIRY | RAW

/obj/item/reagent_containers/food/snacks/breadstick/raw/MakeBakeable()
	AddComponent(/datum/component/bakeable, /obj/item/reagent_containers/food/snacks/breadstick, rand(20 SECONDS, 30 SECONDS), TRUE)

//DEEP FRYER
/obj/item/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = ""
	bitesize = 2
	fryable = FALSE

/obj/item/reagent_containers/food/snacks/deepfryholder/Initialize(mapload, obj/item/fried)
	. = ..()
	name = fried.name //We'll determine the other stuff when it's actually removed
	appearance = fried.appearance
	layer = initial(layer)
	plane = initial(plane)
	lefthand_file = fried.lefthand_file
	righthand_file = fried.righthand_file
	item_state = fried.item_state
	desc = fried.desc
	w_class = fried.w_class
	slowdown = fried.slowdown
	equip_delay_self = fried.equip_delay_self
	equip_delay_other = fried.equip_delay_other
	strip_delay = fried.strip_delay
	species_exception = fried.species_exception
	item_flags = fried.item_flags
	obj_flags = fried.obj_flags

	if(istype(fried, /obj/item/reagent_containers/food/snacks))
		fried.reagents.trans_to(src, fried.reagents.total_volume)
		qdel(fried)
	else
		fried.forceMove(src)
		trash = fried

/obj/item/reagent_containers/food/snacks/deepfryholder/Destroy()
	if(trash)
		QDEL_NULL(trash)
	. = ..()

/obj/item/reagent_containers/food/snacks/deepfryholder/On_Consume(mob/living/eater)
	if(trash)
		QDEL_NULL(trash)
	..()

/obj/item/reagent_containers/food/snacks/deepfryholder/generate_trash(atom/location)
	if(trash)
		QDEL_NULL(trash)

/obj/item/reagent_containers/food/snacks/deepfryholder/proc/fry(cook_time = 30)
	switch(cook_time)
		if(0 to 15)
			add_atom_colour(rgb(166,103,54), FIXED_COLOUR_PRIORITY)
			name = "lightly-fried [name]"
			desc = "[desc] It's been lightly fried in a deep fryer."
		if(16 to 49)
			add_atom_colour(rgb(103,63,24), FIXED_COLOUR_PRIORITY)
			name = "fried [name]"
			desc = "[desc] It's been fried, increasing its tastiness value by [rand(1, 75)]%."
		if(50 to 59)
			add_atom_colour(rgb(63,23,4), FIXED_COLOUR_PRIORITY)
			name = "deep-fried [name]"
			desc = "[desc] Deep-fried to perfection."
		if(60 to INFINITY)
			add_atom_colour(rgb(33,19,9), FIXED_COLOUR_PRIORITY)
			name = "the physical manifestation of the very concept of fried foods"
			desc = "A heavily-fried...something. Who can tell anymore?"
	filling_color = color
	foodtype |= FRIED
