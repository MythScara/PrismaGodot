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
var buffs = []
var afflictions = []
#var afflictions = {"Solar" : [], "Nature": [], "Spirit": [], "Void": [], "Arc": [], "Frost": [], "Metal": [], "Divine": []}

var passives = {}
var techniques = [null, null, null]

var currency = {"Prisma": 0}

var ranged_stats = {
	"DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Assault Rifle", "Tier": null, "Element": null, "Quality": null, "Max Value": 100}
var melee_stats = {
	"POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Long Sword", "Tier": null, "Element": null, "Quality": null, "Max Value": 100}

var ranged_values = {}
var melee_values = {}

var excluded = ["Type", "Tier", "Element", "Quality", "Max Value"]

var specialist_levels = {}
var specialist_cache = {}
var timer_cache = {}

var player_active = false

signal activate_specialist(s_type)
signal player_event(event)
signal stat_update(stat)
signal exp_update(value)
signal spec_update(s_name)
signal pause_game

var attacking = false
var cooldown_time = 0.0
var attack_cooldown = 0.04

func _ready():
	RandomNumberGenerator.new().randomize()
	for key in GameInfo.specialist_list:
		load_specialist(key)

func set_specialist(specialist_name):
	if specialist_name != specialist:
		var specialist_class = load_specialist(specialist_name)
		
		if specialist_class:
			specialist = specialist_name
			change_passive(specialist_name, "mind_passive", "Add")
			change_passive(specialist_name, "soul_passive", "Add")
			change_passive(specialist_name, "heart_passive", "Add")
			change_technique(specialist_name, "skill_technique", "Skill")
			change_technique(specialist_name, "special_technique", "Special")
			change_technique(specialist_name, "super_technique", "Super")
	
	else:
		activate_passives()
		activate_techniques()
	
	PlayerInterface.specialist_icon.texture = load("res://asset/specialist_emblems/" + specialist_name.to_lower() + "_emblem.png")

func calculate_values(stat_value, stat_type):
	var tier
	var type
	var value
	
	if stat_type == "Ranged":
		tier = GameInfo.ranged_tier[stat_value["Tier"]]
		type = GameInfo.ranged_info[stat_value["Type"]]
		value = ranged_values
	elif stat_type == "Melee":
		tier = GameInfo.melee_tier[stat_value["Tier"]]
		type = GameInfo.melee_info[stat_value["Type"]]
		value = melee_values
	
	for key in stat_value.keys():
		if key not in excluded:
			match key:
				"DMG":
					value[key] = round((sqrt(stat_value[key])*tier[key])*type[key]*sqrt(stats["ATK"]))
				"POW":
					value[key] = round((sqrt(stat_value[key])*tier[key])*type[key]*sqrt(stats["ATK"]))
				"RNG":
					value[key] = adjustment(type[key]+((stat_value[key]*tier[key]/100.0)*type[key]))
				"RCH":
					value[key] = adjustment(type[key]+((stat_value[key]*tier[key]/100.0)*type[key]))
				"MOB":
					value[key] = adjustment(((50.0+(sqrt(stat_value[key])*tier[key])*5.0)/100.0)*type[key]*(3+stats["AG"]/10000.0))
				"HND":
					value[key] = adjustment(((20.0+(sqrt(stat_value[key])*tier[key])*3.0)/100.0)*type[key]*(3+stats["AG"]/10000.0))
				"AC":
					value[key] = adjustment(value["RNG"]*((20.0+((stat_value[key]*tier[key])/1.25))/100.0))
				"BLK":
					value[key] = adjustment(type[key]*(20.0+((stat_value[key]*tier[key])/1.25)*2.0))
				"RLD":
					value[key] = adjustment(((3+sqrt(sqrt(101.0-stat_value[key])))*tier[key])*(type[key]/(3+stats["AG"]/10000.0)))
				"CHG":
					value[key] = adjustment(((3+sqrt(sqrt(101.0-stat_value[key])))*tier[key])*(type[key]/(3+stats["AG"]/10000.0)))
				"FR":
					value[key] = adjustment(1/((type[key]*(sqrt(sqrt(stat_value[key]))*tier[key]))/60.0))
				"ASP":
					value[key] = adjustment(1/((type[key]*(sqrt(sqrt(sqrt(stat_value[key])))*tier[key]))/60.0))
				"MAG":
					value[key] = round((1+((stat_value[key]/33.33)*tier[key]))*type[key])
				"STE":
					value[key] = round((1+((stat_value[key]/33.33)*tier[key]))*type[key])
				"DUR":
					value[key] = round(type[key]*(sqrt(stat_value[key])*tier[key]*30.0))
				"WCP":
					value[key] = round(type[key]*((11.0-sqrt(stat_value[key]))*tier[key]))
				"CRR":
					value[key] = adjustment((tier[key]+(stat_value[key]*0.25))*(1.0/type[key]))
				"CRD":
					if stat_type == "Ranged":
						value[key] = round((2.0*tier[key]+(stat_value[key]/100.0))*value["DMG"])
					elif stat_type == "Melee":
						value[key] = round((2.0*tier[key]+(stat_value[key]/100.0))*value["POW"])
				"INF":
					value[key] = adjustment(stat_value[key]*tier[key])
				"SLS":
					value[key] = adjustment((tier[key]+(stat_value[key]*0.95))*(1.0/type[key]))
				"PRC":
					value[key] = adjustment((tier[key]+(stat_value[key]*0.95))*(1.0/type[key]))
				"FRC":
					value[key] = int(ceil(stat_value[key]*tier[key]/20.0))

func adjustment(value: float, decimal: int = 2):
	var mult = pow(10.0, decimal)
	return round(value * mult) / mult

func randomize_weapon(type):
	match type:
		"Ranged":
			weapon_randomizer(ranged_stats, "Ranged")
		"Melee":
			weapon_randomizer(melee_stats, "Melee")
		"Both":
			weapon_randomizer(ranged_stats, "Ranged")
			weapon_randomizer(melee_stats, "Melee")

func weapon_randomizer(stat_value, stat_type):
	var max_points = 0
	var tier_list = ["Iron", "Copper", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Obsidian", "Mithril", "Adamantine"]
	var type_list = ["Assault Rifle", "Sub Machine Gun", "Light Machine Gun", "Machine Pistol", "Sniper Rifle", "Marksman Rifle", "Handgun", "Launcher", "Longbow", "Crossbow", "Shotgun",
	"Long Sword", "Great Sword", "Katana", "Mace", "Gauntlet", "Battle Axe", "Warhammer", "Scythe", "Staff", "Spear", "Polearm", "Shield", "Dagger", "Halberd"]
	var element_list = ["Solar", "Nature", "Spirit", "Void", "Arc", "Frost", "Metal", "Divine", "None"]
	
	for key in stat_value.keys():
		if key not in excluded:
			stat_value[key] = min(stat_value[key] + randi() % 100, 100)
			max_points += stat_value[key]
	
	var tier_index = int(ceil((max_points - 700) / 100.0))
	
	var tier = "Iron"
	var type = "Unknown"
	var elem = "None"
	var quality = 0
	
	if tier_index >= 0 and tier_index < tier_list.size():
		tier = tier_list[tier_index]
	elif tier_index >= tier_list.size():
		tier = tier_list[-1]
	
	if stat_type == "Ranged":
		var type_index = randi() % 11
		type = type_list[type_index]
	elif stat_type == "Melee":
		var type_index = randi() % 13 + 12
		type = type_list[type_index]
	
	if max_points >= 1000:
		var elem_index = randi() % 10
		elem = element_list[elem_index]
	
	if max_points >= 600:
		quality = max_points % 100
		if quality == 0:
			quality = 100
	else:
		quality = 0
	
	stat_value["Tier"] = tier
	stat_value["Quality"] = quality
	stat_value["Type"] = type
	stat_value["Element"] = elem
	
	PlayerInventory.add_to_inventory(stat_type + " Weapon", "Random " + type, stat_value)
	calculate_values(stat_value, stat_type)

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

func check_technique(identifier):
	for technique in techniques:
		if technique and technique[0] == identifier:
			return true
	return false

func change_technique(specialist_name, technique_type, slot):
	var timer_check = specialist_name + "_" + technique_type
	
	for key in timer_cache.keys():
		if timer_check in key:
			print("Technique on Cooldown: Cannot currently be Swapped")
			return false
	
	var identifier = specialist_name + " " + slot
	
	if check_technique(identifier):
		print("Technique Already Equipped")
		return false
	
	var specialist_class = load_specialist(specialist_name)
	var technique_method = specialist_class.get(technique_type)
	
	if technique_method:
		match slot:
			"Skill":
				techniques[0] = [identifier, technique_method]
			"Special":
				techniques[1] = [identifier, technique_method]
			"Super":
				techniques[2] = [identifier, technique_method]
		technique_method.call("Unready")
		technique_method.call("Ready")
		return true
	else:
		print_debug("Invalid Technique: " + technique_type)
		return false

func change_passive(specialist_name, passive_type, modification):
	var identifier = specialist_name + " " + passive_type
	
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
	elif modification == "Reset":
		if identifier in passives and specialist_class:
			var passive_method = specialist_class.get(passive_type)
			passives[identifier] = passive_method
			passive_method.call("Unready")
			passive_method.call("Ready")
	else:
		print_debug("Invalid Modification: " + modification)

func activate_techniques():
	timer_cache.clear()
	for identifier in techniques:
		if identifier != null:
			var parts = identifier[0].split(" ")
			var specialist_name = parts[0]
			var technique_type = identifier[1]
			var slot = parts[1]
			change_technique(specialist_name, technique_type, slot)
		
func activate_passives():
	for identifier in passives.keys():
		var parts = identifier.split(" ")
		var specialist_name = parts[0]
		var passive_type = parts[1]
		change_passive(specialist_name, passive_type, "Reset")

func stat_change(target: Dictionary, stat_values: Dictionary, stat_mode: String):
	for key in stat_values.keys():
		var value_type = typeof(stat_values[key])
		
		var valid = false
		
		var mode = stat_mode
		if key in excluded:
			mode = "Mod"
		
		match mode:
			"Add", "Sub":
				valid = (value_type == TYPE_INT or value_type == TYPE_FLOAT)
			"Mul":
				valid = (value_type == TYPE_INT or value_type == TYPE_FLOAT)
			"Mod":
				valid = (value_type == TYPE_INT or value_type == TYPE_FLOAT or value_type == TYPE_STRING or value_type == TYPE_NIL)
	
		if key in target and valid:
			match mode:
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
			print_debug("Invalid Operation: " + key)
			return

func weapon_stat_change(stat_values, stat_type, stat_mode):
	if stat_type == "Ranged" or stat_type == "Both":
		await stat_change(ranged_stats, stat_values, stat_mode)
		calculate_values(ranged_stats, "Ranged")
	elif stat_type == "Melee" or stat_type == "Both":
		await stat_change(melee_stats, stat_values, stat_mode)
		calculate_values(melee_stats, "Melee")
	else:
		print_debug("Invalid Stat Type")
		return

func element_stat_change(stat_values, stat_mode):
	elements["Max Value"] = 50000
	await stat_change(elements, stat_values, stat_mode)
	calculate_values(ranged_stats, "Ranged")
	calculate_values(melee_stats, "Melee")

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
		await stat_change(stats, {key: stat_values[key]}, stat_mode)
		calculate_values(ranged_stats, "Ranged")
		calculate_values(melee_stats, "Melee")

func exp_handler(value):
	specialist_experience(value)
	if player_level[0] != 100:
		player_level[1] += value
		if player_level[1] >= player_level[2]:
			player_level[0] += 1
			stat_points[0] += 7
			element_points[0] += 3
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
		"currency": currency,
		"ranged_stats": ranged_stats,
		"melee_stats": melee_stats,
		"timer_cache": timer_cache,
		"specialist_levels": specialist_levels,
		"player_level": player_level,
		"ranged_values": ranged_values,
		"melee_values": melee_values
	}

func set_data(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			self[key] = data[key]

func _unhandled_input(event):
	if event.is_action("Attack") and player_active == true:
		attacking = event.is_pressed()
		if attacking and cooldown_time >= attack_cooldown:
			PlayerInterface.attack_action()
			cooldown_time = 0.0

func _input(event):
	if event is InputEventKey:
		if event.is_action_released("Technique 1"):
			if techniques[0] != null:
				var technique = techniques[0][1]
				technique.call("Active")
		if event.is_action_released("Technique 2"):
			if techniques[1] != null:
				var technique = techniques[1][1]
				technique.call("Active")
		if event.is_action_released("Technique 3"):
			if techniques[2] != null:
				var technique = techniques[2][1]
				technique.call("Active")
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
			print(get_save_data())
			print(PlayerInventory.get_save_data())
		if event.is_action_pressed("Cheat Menu"):
			exp_handler(400)
		if event.is_action_pressed("Pause Menu"):
			PlayerInterface.menu_ui.visible = !PlayerInterface.menu_ui.visible
			player_active = !player_active
			emit_signal("pause_game")

func _process(delta):
	if attacking == true and cooldown_time >= attack_cooldown:
		PlayerInterface.attack_action()
		cooldown_time = 0.0
	elif cooldown_time < attack_cooldown:
		cooldown_time += delta
	
