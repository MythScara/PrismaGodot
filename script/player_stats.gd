extends Node

var species = null
var stats = {"HP": 40000, "MP": 40000, "SHD": 8000, "STM": 8000, "ATK": 4000, "DEF": 4000, "MGA": 4000, "MGD": 4000, "SHR": 4000, "STR": 4000, "AG": 4000, "CAP": 4000}
var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}
var elements = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}
var specialist = null
var immunities = []
var buffs = {}
var afflictions = {}
var passives = {}
var techniques = {"Skill": null, "Special": null, "Super": null}
var ranged_stats = {
	"DMG": 0, "RNG": 0, "MOB": 0, "HND": 0, "AC": 0, "RLD": 0, "FR": 0, "MAG": 0, "DUR": 0, "WCP": 0,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": null, "Tier": null, "Element": null}
var melee_stats = {
	"POW": 0, "RCH": 0, "MOB": 0, "HND": 0, "BLK": 0, "CHG": 0, "ASP": 0, "STE": 0, "DUR": 0, "WCP": 0,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": null, "Tier": null, "Element": null}

var specialist_cache = {}

signal activate_specialist(s_type)

func set_specialist(specialist_name):
	var specialist_class = load_specialist(specialist_name)
	
	if specialist_class:
		change_passive(specialist_name, "mind_passive", "Add")
		change_passive(specialist_name, "soul_passive", "Add")
		change_passive(specialist_name, "heart_passive", "Add")
		change_technique(specialist_name, "skill_technique")
		change_technique(specialist_name, "special_technique")
		change_technique(specialist_name, "super_technique")

func change_technique(specialist_name, technique_type):
	var specialist_class  = load_specialist(specialist_name)
	var technique_method = specialist_class.get(technique_type)
	
	if technique_method:
		if technique_type == "skill_technique":
			techniques["Skill"] = technique_method
		if technique_type == "special_technique":
			techniques["Special"] = technique_method
		if technique_type == "super_technique":
			techniques["Super"] = technique_method
	else:
		print_debug("Invalid Technique: " + technique_type)

func change_passive(specialist_name, passive_type, modification):
	var identifier = specialist_name + "_" + passive_type
	
	var specialist_class = load_specialist(specialist_name) if identifier in passives or modification == "Add" else null
	
	if modification == "Add":
		if identifier not in passives and specialist_class:
			var passive_method = specialist_class.get(passive_type)
			passives[identifier] = passive_method
		else:
			print_debug("Passive Exists: " + identifier)
	elif modification == "Sub":
		if identifier in passives:
			passives.erase(identifier)
		else:
			print_debug("Passive Not Found: " + identifier)
	else:
		print_debug("Invalid Modification: " + modification)

func weapon_stat_change(stat_values, stat_type, stat_mode):
	if stat_mode == "Add":
		if stat_type == "Ranged" or stat_type == "Both":
			for key in stat_values.keys():
				if key in ranged_stats and typeof(stat_values[key]) == TYPE_INT:
					ranged_stats[key] = clamp(ranged_stats[key] + stat_values[key], 0, 100)
		if stat_type == "Melee" or stat_type == "Both":
			for key in stat_values.keys():
				if key in melee_stats and typeof(stat_values[key]) == TYPE_INT:
					melee_stats[key] = clamp(melee_stats[key] + stat_values[key], 0, 100)
	elif stat_mode == "Sub":
		if stat_type == "Ranged" or stat_type == "Both":
			for key in stat_values.keys():
				if key in ranged_stats and typeof(stat_values[key]) == TYPE_INT:
					ranged_stats[key] = clamp(ranged_stats[key] - stat_values[key], 0, 100)
		if stat_type == "Melee" or stat_type == "Both":
			for key in stat_values.keys():
				if key in melee_stats and typeof(stat_values[key]) == TYPE_INT:
					melee_stats[key] = clamp(melee_stats[key] - stat_values[key], 0, 100)
	elif stat_mode == "Mod":
		if stat_type == "Ranged" or stat_type == "Both":
			for key in stat_values.keys():
				if key in ranged_stats:
					ranged_stats[key] = stat_values[key]
		if stat_type == "Melee" or stat_type == "Both":
			for key in stat_values.keys():
				if key in melee_stats:
					melee_stats[key] = stat_values[key]
	else:
		print_debug("Input was Incomplete or Incorrect")
		return

func element_stat_change(stat_values, stat_mode):
	if stat_mode == "Add":
		for key in stat_values.keys():
			if key in elements and typeof(stat_values[key]) == TYPE_INT:
				elements[key] = clamp(elements[key] + stat_values[key], 0, 50000)
	elif stat_mode == "Sub":
		for key in stat_values.keys():
			if key in elements and typeof(stat_values[key]) == TYPE_INT:
				elements[key] = clamp(elements[key] - stat_values[key], 0, 50000)
	elif stat_mode == "Mod":
		for key in stat_values.keys():
			if key in elements and typeof(stat_values[key]) == TYPE_INT:
				elements[key] = stat_values[key]
	else:
		print_debug("Input was Incomplete or Incorrect")
		return

func player_stat_change(stat_values, stat_mode):
	if stat_mode == "Add":
		for key in stat_values.keys():
			if key in stats and typeof(stat_values[key]) == TYPE_INT:
				if key == "HP" or key == "MP":
					stats[key] = clamp(stats[key] + stat_values[key], 0, 500000)
				elif key == "SHD" or "STM":
					stats[key] = clamp(stats[key] + stat_values[key], 0, 100000)
				else:
					stats[key] = clamp(stats[key] + stat_values[key], 0, 50000)
	elif stat_mode == "Sub":
		for key in stat_values.keys():
			if key in stats and typeof(stat_values[key]) == TYPE_INT:
				if key == "HP" or key == "MP":
					stats[key] = clamp(stats[key] - stat_values[key], 0, 500000)
				elif key == "SHD" or key == "STM":
					stats[key] = clamp(stats[key] - stat_values[key], 0, 100000)
				else:
					stats[key] = clamp(stats[key] - stat_values[key], 0, 50000)
	elif stat_mode == "Mod":
		for key in stat_values.keys():
			if key in stats and typeof(stat_values[key]) == TYPE_INT:
				stats[key] = stat_values[key]
	else:
		print_debug("Input was Incomplete or Incorrect")
		return

func set_stats(new_stats : Dictionary):
	stats = new_stats

func set_bonuses(new_bonuses : Dictionary):
	bonuses = new_bonuses

func set_elements(new_elements : Dictionary):
	elements = new_elements

func get_stats() -> Dictionary:
	return stats

func get_bonuses() -> Dictionary:
	return bonuses

func get_elements() -> Dictionary:
	return elements

func add_timer(timer : Timer) -> void:
	var cur_scene = get_tree().current_scene
	if cur_scene:
		cur_scene.add_child(timer)
	else:
		print_debug("No scene found")

func load_specialist(text : String):
	if not specialist_cache.has(text):
		var specialist_script = load("res://script/specialists/" + text.to_lower() + ".gd").new()
		specialist_script.initialize()
		specialist_cache[text] = specialist_script
	return specialist_cache[text]

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			if techniques["Skill"] != null:
				techniques["Skill"].call(true)
		if event.pressed and event.keycode == KEY_E:
			if techniques["Special"] != null:
				techniques["Special"].call(true)
		if event.pressed and event.keycode == KEY_G:
			if techniques["Super"] != null:
				techniques["Super"].call(true)
		if event.pressed and event.keycode == KEY_I:
			print_debug(species)
			print_debug(stats)
			print_debug(bonuses)
			print_debug(elements)
			print_debug(specialist)
			print_debug(immunities)
			print_debug(passives)
			print_debug(techniques)
			print_debug(ranged_stats)
			print_debug(melee_stats)
