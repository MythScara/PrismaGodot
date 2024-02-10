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
			passive_method.call(true)
		else:
			print_debug("Passive Exists: " + identifier)
	elif modification == "Sub":
		if identifier in passives:
			var passive_method = passives[identifier]
			passive_method.call(false)
			passives.erase(identifier)
		else:
			print_debug("Passive Not Found: " + identifier)
	else:
		print_debug("Invalid Modification: " + modification)

func stat_change(target: Dictionary, stat_values: Dictionary, stat_mode: String):
	for key in stat_values.keys():
		var value_type = typeof(stat_values[key])
		
		var valid = false
		match stat_mode:
			"Add", "Sub", "Mod":
				valid = (value_type == TYPE_INT)
			"Mul":
				valid = (value_type == TYPE_INT or value_type == TYPE_FLOAT)
	
		if key in target and valid:
			match stat_mode:
				"Add":
					target[key] = clamp(target[key] + stat_values[key], 0, target.get("max_value", 100))
				"Sub":
					target[key] = clamp(target[key] - stat_values[key], 0, target.get("max_value", 100))
				"Mul":
					target[key] = clamp(target[key] * stat_values[key], 0, target.get("max_value", 100))
				"Mod":
					target[key] = stat_values[key]
				_:
					print_debug("Invalid Operation")
					return
		else:
			print_debug("Invalid Operation")
			return

func weapon_stat_change(stat_values, stat_type, stat_mode):
	if stat_type == "Ranged" or stat_type == "Both":
		ranged_stats["max_value"] = 100
		stat_change(ranged_stats, stat_values, stat_mode)
	if stat_type == "Melee" or stat_type == "Both":
		melee_stats["max_value"] = 100
		stat_change(melee_stats, stat_values, stat_mode)
	else:
		print_debug("Invalid Stat Type")
		return

func element_stat_change(stat_values, stat_mode):
	elements["max_value"] = 50000
	stat_change(elements, stat_values, stat_mode)

func player_stat_change(stat_values, stat_mode):
	for key in stat_values.keys():
		if key in ["HP", "MP"]:
			stats["max_value"] = 500000
		elif key in ["SHD", "STM"]:
			stats["max_value"] = 100000
		else:
			stats["max_value"] = 50000
		stat_change(stats, {key: stat_values[key]}, stat_mode)

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
