extends Node

var species = null
var specialist = null

var player_level = [0, 0, 1000]
var stat_points = [0, 0]
var element_points = [0, 0]

var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}
var stats = {"HP": 40000, "MP": 40000, "SHD": 8000, "STM": 8000, "ATK": 4000, "DEF": 4000, "MGA": 4000, "MGD": 4000, "SHR": 4000, "STR": 4000, "AG": 4000, "CAP": 4000}
var elements = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}

var immunities = []
var buffs = {}
var afflictions = {"Solar" : [], "Nature": [], "Spirit": [], "Void": [], "Arc": [], "Frost": [], "Metal": [], "Divine": []}

var passives = {}
var techniques = {"Skill": null, "Special": null, "Super": null}

var ranged_stats = {
	"DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Assault Rifle", "Tier": null, "Element": null, "Max Value": 100}
var melee_stats = {
	"POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Long Sword", "Tier": null, "Element": null, "Max Value": 100}

var excluded = ["Type", "Tier", "Element", "Max Value"]

var specialist_levels = {}
var specialist_cache = {}
var timer_cache = {}

signal activate_specialist(s_type)
signal player_event(event)
signal stat_update(stat)
signal exp_update(value)
signal spec_update(s_name)

var attacking = false
var cooldown_time = 0.0
var attack_cooldown = 0.04

func _ready():
	RandomNumberGenerator.new().randomize()

func set_specialist(specialist_name):
	var specialist_class = load_specialist(specialist_name)
	
	if specialist_class:
		change_passive(specialist_name, "mind_passive", "Add")
		change_passive(specialist_name, "soul_passive", "Add")
		change_passive(specialist_name, "heart_passive", "Add")
		change_technique(specialist_name, "skill_technique")
		change_technique(specialist_name, "special_technique")
		change_technique(specialist_name, "super_technique")

func randomize_weapon(type):
	match type:
		"Ranged":
			weapon_randomizer(ranged_stats)
		"Melee":
			weapon_randomizer(melee_stats)
		"Both":
			weapon_randomizer(ranged_stats)
			weapon_randomizer(melee_stats)

func weapon_randomizer(stat_value):
	var max_points = 0
	var tier_list = ["Iron", "Copper", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Obsidian", "Mithril", "Adamantine"]
	
	for key in stat_value.keys():
		if key not in excluded:
			stat_value[key] += randi() % 100 + 1
			max_points += stat_value[key]
	
	var tier_index = int((max_points - 600) / 100.0)
	
	var tier = "Iron"
	
	if tier_index >= 0 and tier_index < tier_list.size():
		tier = tier_list[tier_index]
	elif tier_index >= tier_list.size():
		tier = tier_list[-1]
	
	stat_value["Tier"] = tier

func start_timer(specialist_name, s_name, duration, s_type):
	var timer_id = str(specialist_name) + "_" + s_name + "_" + s_type
	var timer = Timer.new()
	timer.name = timer_id
	timer.set_wait_time(duration)
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self, "_on_timer_timeout").bind(timer_id))
	add_child(timer)
	timer.start()
	
	timer_cache[timer_id] = {"Specialist": specialist_name, "Method": s_name, "Argument": s_type}

func _on_timer_timeout(timer_id):
	var info = timer_cache[timer_id]
	if info:
		var specialist_id = specialist_cache[info["Specialist"]]
		if specialist_id:
			specialist_id.call(info["Method"], info["Argument"])
			timer_cache.erase(timer_id)
			var timer = get_node(timer_id)
			if timer:
				timer.queue_free()

func specialist_experience(value):
	var specialist_class = load_specialist(specialist)
	
	if specialist_class and specialist_class.has_method("exp_handler"):
		specialist_class.call("exp_handler", value)
	else:
		print_debug("Failed To Add Experience: " + specialist)

func change_technique(specialist_name, technique_type):
	var specialist_class  = load_specialist(specialist_name)
	var technique_method = specialist_class.get(technique_type)
	
	if technique_method:
		if technique_type == "skill_technique":
			techniques["Skill"] = technique_method
			technique_method.call("Ready")
		if technique_type == "special_technique":
			techniques["Special"] = technique_method
			technique_method.call("Ready")
		if technique_type == "super_technique":
			techniques["Super"] = technique_method
			technique_method.call("Ready")
	else:
		print_debug("Invalid Technique: " + technique_type)

func change_passive(specialist_name, passive_type, modification):
	var identifier = specialist_name + "_" + passive_type
	
	var specialist_class = load_specialist(specialist_name) if identifier in passives or modification == "Add" else null
	
	if modification == "Add":
		if identifier not in passives and specialist_class:
			var passive_method = specialist_class.get(passive_type)
			passives[identifier] = passive_method
			passive_method.call("Ready")
		else:
			print_debug("Passive Exists: " + identifier)
	elif modification == "Sub":
		if identifier in passives:
			var passive_method = passives[identifier]
			passive_method.call("Unready")
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
					target[key] = clamp(target[key] + stat_values[key], 0, target.get("Max Value", 100))
				"Sub":
					target[key] = clamp(target[key] - stat_values[key], 0, target.get("Max Value", 100))
				"Mul":
					target[key] = clamp(target[key] * stat_values[key], 0, target.get("Max Value", 100))
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
		stat_change(ranged_stats, stat_values, stat_mode)
	elif stat_type == "Melee" or stat_type == "Both":
		stat_change(melee_stats, stat_values, stat_mode)
	else:
		print_debug("Invalid Stat Type")
		return

func element_stat_change(stat_values, stat_mode):
	elements["Max Value"] = 50000
	stat_change(elements, stat_values, stat_mode)

func player_stat_change(stat_values, stat_mode):
	for key in stat_values.keys():
		if key in ["HP", "MP"]:
			stats["Max Value"] = 500000
			emit_signal("stat_update", key)
		elif key in ["SHD", "STM"]:
			stats["Max Value"] = 100000
			emit_signal("stat_update", key)
		else:
			stats["Max Value"] = 50000
		stat_change(stats, {key: stat_values[key]}, stat_mode)

func exp_handler(value):
	specialist_experience(value)
	if player_level[0] != 100:
		player_level[1] += value
		if player_level[1] >= player_level[2]:
			player_level[0] += 1
			stat_points[0] += 1
			player_level[1] -= player_level[2]
			player_level[2] += 1000
			exp_handler(player_level[1])
	emit_signal("exp_update")

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

func update_specialist(s_name, s_level, s_exp, s_expr):
	specialist_levels[s_name] = [s_level, s_exp, s_expr]
	emit_signal("spec_update")

func get_save_data() -> Dictionary:
	return {
		"species": species,
		"stats": stats,
		"bonuses": bonuses,
		"elements": elements,
		"specialist": specialist,
		"immunities": immunities,
		"buffs": buffs,
		"afflictions": afflictions,
		"passives": passives,
		"techniques": techniques,
		"ranged_stats": ranged_stats,
		"melee_stats": melee_stats,
		"timer_cache": timer_cache,
		"specialist_levels": specialist_levels,
		"player_levels": player_level
	}

func set_data(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			self[key] = data[key]

func _unhandled_input(event):
	if event.is_action("Attack"):
		attacking = event.is_pressed()
		if attacking and cooldown_time >= attack_cooldown:
			PlayerInterface.attack_action()
			cooldown_time = 0.0

func _input(event):
	if event is InputEventKey:
		if event.is_action_released("Technique 1"):
			if techniques["Skill"] != null:
				techniques["Skill"].call("Active")
		if event.is_action_released("Technique 2"):
			if techniques["Special"] != null:
				techniques["Special"].call("Active")
		if event.is_action_released("Technique 3"):
			if techniques["Super"] != null:
				techniques["Super"].call("Active")
		if event.is_action_released("Swap Weapon"):
			PlayerInterface.swap_active("Swap")
		if event.is_action_released("Unequip Weapon"):
			PlayerInterface.swap_active("None")
		if event.is_action_released("Ranged Weapon"):
			PlayerInterface.swap_active("Ranged")
		if event.is_action_released("Melee Weapon"):
			PlayerInterface.swap_active("Melee")
		if event.is_action_pressed("Reload"):
			PlayerInterface.reload()
		if event.is_action_pressed("Information"):
			#print_debug(species)
			#print_debug(stats)
			#print_debug(bonuses)
			#print_debug(elements)
			#print_debug(specialist)
			#print_debug(immunities)
			#print_debug(buffs)
			#print_debug(afflictions)
			#print_debug(passives)
			#print_debug(techniques)
			print_debug(ranged_stats)
			print_debug(melee_stats)
			#print_debug(specialist_levels)
			pass

func _process(delta):
	if attacking == true and cooldown_time >= attack_cooldown:
		PlayerInterface.attack_action()
		cooldown_time = 0.0
	elif cooldown_time < attack_cooldown:
		cooldown_time += delta
	
