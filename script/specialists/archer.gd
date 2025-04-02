extends Node

class_name SpecialistArcher

# Core Specialist Properties
@export var specialist_name: String = "Archer"
@export var max_level: int = 10
@export var base_exp_required: int = 1000
@export var exp_growth_factor: float = 1.2  # Exponential growth for exp requirement

var active: bool = false
var current_level: int = 0
var current_experience: int = 0
var experience_required: int = base_exp_required

# Constants for Technique and Passive Names (reduces string errors)
const MIND = "mind"
const SOUL = "soul"
const HEART = "heart"
const SKILL = "skill"
const SPECIAL = "special"
const SUPER = "super"

# Technique Definitions with Unlock State
var techniques: Dictionary = {
	MIND: {"unlocked": true, "ready": null, "signal": "Health Below 50%", "cooldown": 5.0},
	SOUL: {"unlocked": true, "ready": null, "signal": "", "cooldown": 5.0},
	HEART: {"unlocked": true, "ready": null, "signal": "Support Item Used", "cooldown": 5.0},
	SKILL: {"unlocked": false, "ready": null, "signal": "", "duration": 10.0, "cooldown": 30.0},
	SPECIAL: {"unlocked": false, "ready": null, "signal": "", "duration": 10.0, "cooldown": 40.0},
	SUPER: {"unlocked": false, "ready": null, "signal": "", "duration": "SU", "cooldown": 60.0}
}

# Event to Passive Mapping for Efficient Event Handling
var event_to_passives: Dictionary = {
	"Health Below 50%": [MIND],
	"Support Item Used": [HEART]
}

# Specialist Data (unchanged, provided for context)
var specialist_info: Dictionary = {
	"Name": "Archer",
	"Description": "Fleet-footed arrow master with an eye for kill zones. One well-placed arrow can down any target.",
	"Weapon": "Longbow",
	"Passive": {
		"Mind": "When [b]Health[/b] drops below [b]50%[/b], gain [b]2[/b] stacks of [b]Circulation[/b]. Does not stack with itself.",
		"Soul": "Increase [b]RNG[/b] by [b]10[/b] on [b]Ranged Weapons[/b].",
		"Heart": "Using a [b]Support Item[/b] reduces [b]Technique[/b] cooldowns by [b]10%[/b]."
	},
	"Techniques": {
		"Skill": {"Description": "Increase [b]MOB[/b] by [b]20[/b] on [b]Melee Weapons[/b].", "Duration": 10, "Cooldown": 30},
		"Special": {"Description": "Increase [b]SLS[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "Duration": 10, "Cooldown": 40},
		"Super": {"Description": "Gain [b]3[/b] stacks of [b]Steelborn[/b].", "Duration": "SU", "Cooldown": 60}
	}
}

var specialist_rewards: Dictionary = {
	0: {"Type": "Crafting Resource", "Item": "Mithril Ore", "Data": {"Amount": 5, "Value": 700}},
	1: {"Type": "Outfit", "Item": "Archer Outfit", "Data": {"HP": 5, "MP": 0, "SHD": 2, "STM": 0, "Tier": "Obsidian", "Quality": 100}},
	2: {"Type": "Ranged Weapon", "Item": "Archer Longbow", "Data": weapon_stats_r.duplicate()},
	3: {"Type": "Belt Armor", "Item": "Archer Belt", "Data": {"AG": 3, "CAP": 2, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
	4: {"Type": "Techniques", "Item": "Archer Skill", "Data": {"Name": "Archer", "Technique": "skill_technique"}},
	5: {"Type": "Pad Armor", "Item": "Archer Pads", "Data": {"AG": 5, "CAP": 0, "STR": 0, "SHR": 2, "Tier": "Obsidian", "Quality": 100}},
	6: {"Type": "Techniques", "Item": "Archer Special", "Data": {"Name": "Archer", "Technique": "special_technique"}},
	7: {"Type": "Chest Armor", "Item": "Archer Chest", "Data": {"AG": 7, "CAP": 0, "STR": 2, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
	8: {"Type": "Techniques", "Item": "Archer Super", "Data": {"Name": "Archer", "Technique": "super_technique"}},
	9: {"Type": "Body Armor", "Item": "Archer Body", "Data": {"AG": 10, "CAP": 0, "STR": 0, "SHR": 3, "Tier": "Obsidian", "Quality": 100}},
	10: {"Type": "Artifact", "Item": "Archer Heart Artifact", "Data": {"HP": 10, "MP": 5, "SHD": 5, "STM": 0, "Tier": "Obsidian", "Quality": 100}}
}

var weapon_stats_r: Dictionary = {
	"DMG": 10, "RNG": 15, "MOB": 5, "HND": 3, "AC": 2, "RLD": 1, "FR": 2, "MAG": 5, "DUR": 100, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Longbow", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}

var weapon_stats_m: Dictionary = {
	"POW": 8, "RCH": 5, "MOB": 10, "HND": 4, "BLK": 3, "CHG": 1, "ASP": 2, "STE": 1, "DUR": 100, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Dagger", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}

signal level_up(new_level: int, reward: Dictionary)
signal technique_activated(technique: String)
signal passive_triggered(passive: String)

# Lifecycle Methods
func _ready() -> void:
	initialize()

func initialize() -> void:
	"""Initialize the specialist by connecting signals and loading data."""
	if not PlayerStats.is_connected("activate_specialist", _on_specialist_activated):
		PlayerStats.connect("activate_specialist", _on_specialist_activated)
	if not PlayerStats.is_connected("player_event", event_handler):
		PlayerStats.connect("player_event", event_handler)
	load_specialist_data()

func load_specialist_data() -> void:
	"""Load or initialize specialist data from PlayerStats."""
	if PlayerStats.specialist_levels.has(specialist_name):
		var data = PlayerStats.specialist_levels[specialist_name]
		current_level = data[0]
		current_experience = data[1]
		experience_required = data[2]
	else:
		specialist_unlock(0)
		save_specialist_data()

func save_specialist_data() -> void:
	"""Save specialist data to PlayerStats."""
	PlayerStats.update_specialist(specialist_name, current_level, current_experience, experience_required)

# Activation/Deactivation
func _on_specialist_activated(s_type: String) -> void:
	"""Handle specialist activation/deactivation signals."""
	if s_type == specialist_name and not active:
		activate_specialist()
	elif s_type != specialist_name and active:
		deactivate_specialist()

func activate_specialist() -> void:
	"""Activate the specialist and apply passives."""
	active = true
	PlayerStats.set_specialist(specialist_name)
	apply_passives(true)
	save_specialist_data()

func deactivate_specialist() -> void:
	"""Deactivate the specialist and remove passives."""
	active = false
	apply_passives(false)
	save_specialist_data()

func apply_passives(enable: bool) -> void:
	"""Apply or remove specialist passives."""
	var action = "Add" if enable else "Sub"
	for passive in [MIND, SOUL, HEART]:
		PlayerStats.change_passive(specialist_name, passive + "_passive", action)
		if enable and techniques[passive]["signal"]:
			techniques[passive]["ready"] = true

# Experience and Leveling
func exp_handler(value: int) -> void:
	"""Handle experience gain and level progression."""
	if current_level >= max_level or not active:
		return
	
	current_experience += value
	while current_experience >= experience_required and current_level < max_level:
		current_level += 1
		current_experience -= experience_required
		experience_required = int(base_exp_required * pow(exp_growth_factor, current_level))
		upgrade_specialist()
		emit_signal("level_up", current_level, specialist_rewards[current_level])
	save_specialist_data()

func upgrade_specialist() -> void:
	"""Award stat points, unlock techniques, and rewards on level up."""
	PlayerStats.stat_points[0] += 2
	PlayerStats.element_points[0] += 2
	# Unlock techniques at specific levels
	match current_level:
		4: unlock_technique(SKILL)
		6: unlock_technique(SPECIAL)
		8: unlock_technique(SUPER)
	specialist_unlock(current_level)

func unlock_technique(technique: String) -> void:
	"""Unlock a technique when reaching the required level."""
	if technique in techniques and not techniques[technique]["unlocked"]:
		techniques[technique]["unlocked"] = true
		techniques[technique]["ready"] = true
		print("Technique unlocked: ", technique)

func specialist_unlock(level: int) -> void:
	"""Unlock rewards based on specialist level."""
	if level in specialist_rewards:
		var reward = specialist_rewards[level]
		PlayerInventory.add_to_inventory(reward["Type"], reward["Item"], reward["Data"])
	else:
		print("No reward for level: ", level)

# Passive and Technique Management
func event_handler(event: String) -> void:
	"""Handle game events triggering passives efficiently."""
	if event in event_to_passives:
		for passive in event_to_passives[event]:
			if techniques[passive]["ready"]:
				trigger_passive(passive)

func trigger_passive(passive: String) -> void:
	"""Trigger a passive effect and start its cooldown."""
	if not techniques[passive]["ready"]:
		return
	techniques[passive]["ready"] = false
	emit_signal("passive_triggered", passive)
	start_cooldown(passive)

func activate_technique(technique: String) -> void:
	"""Activate a technique if unlocked and ready."""
	if technique not in techniques or not techniques[technique]["unlocked"] or techniques[technique]["ready"] != true:
		return
	techniques[technique]["ready"] = false
	emit_signal("technique_activated", technique)
	var duration = techniques[technique]["duration"]
	if duration != "SU":
		PlayerStats.start_timer(specialist_name, technique + "_duration", duration, Callable(self, "_on_technique_duration_finished"))
	else:
		_on_technique_duration_finished(technique)

func start_cooldown(passive_or_technique: String) -> void:
	"""Start the cooldown timer with level-based reduction."""
	var timer_data = techniques[passive_or_technique]
	var adjusted_cooldown = get_adjusted_cooldown(passive_or_technique)
	var callback = Callable(self, "_on_" + passive_or_technique + "_cooldown_finished")
	PlayerStats.start_timer(specialist_name, passive_or_technique, adjusted_cooldown, callback)

func get_adjusted_cooldown(technique: String) -> float:
	"""Calculate adjusted cooldown based on specialist level."""
	var base_cooldown = techniques[technique]["cooldown"]
	var reduction = current_level  # 1 second reduction per level
	if current_level >= max_level:
		reduction += base_cooldown * 0.2  # Additional 20% reduction at max level
	return max(base_cooldown - reduction, 1.0)

func _on_technique_duration_finished(technique: String) -> void:
	"""Handle technique duration completion and start cooldown."""
	PlayerStats.start_timer(specialist_name, technique + "_cooldown", get_adjusted_cooldown(technique), Callable(self, "_on_" + technique + "_cooldown_finished"))

# Cooldown Callbacks
func _on_mind_cooldown_finished() -> void: techniques[MIND]["ready"] = true
func _on_soul_cooldown_finished() -> void: techniques[SOUL]["ready"] = true
func _on_heart_cooldown_finished() -> void: techniques[HEART]["ready"] = true
func _on_skill_cooldown_finished() -> void: techniques[SKILL]["ready"] = true
func _on_special_cooldown_finished() -> void: techniques[SPECIAL]["ready"] = true
func _on_super_cooldown_finished() -> void: techniques[SUPER]["ready"] = true

# Utility Methods
func get_specialist_info() -> Dictionary:
	"""Return specialist info for UI or external use."""
	return specialist_info

func get_level_progress() -> Dictionary:
	"""Return current level and experience progress."""
	return {
		"level": current_level,
		"experience": current_experience,
		"experience_required": experience_required
	}

func get_technique_status() -> Dictionary:
	"""Return the current status of all techniques for UI or debugging."""
	var status = {}
	for technique in techniques:
		status[technique] = {
			"unlocked": techniques[technique]["unlocked"],
			"ready": techniques[technique]["ready"],
			"cooldown_remaining": PlayerStats.get_timer_remaining(specialist_name, technique + "_cooldown") if not techniques[technique]["ready"] else 0.0
		}
	return status
