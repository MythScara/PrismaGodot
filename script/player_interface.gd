extends Node

# UI References grouped by category
class_name PlayerHUD

# Stat Displays
@onready var stat_displays = {
	"health": {
		"bar": $GameInterface/Health/HealthBar,
		"text": $GameInterface/Health/HealthText
	},
	"overshield": {
		"bar": $GameInterface/Overshield/OvershieldBar,
		"text": $GameInterface/Overshield/OvershieldText
	},
	"magic": {
		"bar": $GameInterface/Magic/MagicBar,
		"text": $GameInterface/Magic/MagicText
	},
	"stamina": {
		"bar": $GameInterface/Stamina/StaminaBar,
		"text": $GameInterface/Stamina/StaminaText
	}
}

# Experience Displays
@onready var exp_displays = {
	"experience": $GameInterface/Experience/ExperienceBar,
	"specialist": $GameInterface/Experience/SpecialistBar,
	"species_icon": $GameInterface/Experience/SpecialistBar/Species,
	"specialist_icon": $GameInterface/Experience/SpecialistBar/Specialist,
	"player_level": $GameInterface/Experience/PlayerBar/Level,
	"specialist_rank": $GameInterface/Experience/PlayerBar/Rank,
	"rank_point": $GameInterface/Experience/PlayerBar/RankPoint,
	"level_point": $GameInterface/Experience/PlayerBar/LevelPoint
}

# Weapon Displays
@onready var weapon_displays = {
	"ranged": {
		"icon": $GameInterface/RangedWeapon/Weapon,
		"ammo": $GameInterface/RangedWeapon/Ammo,
		"active": $GameInterface/RangedWeapon/ActiveMode,
		"meter": $GameInterface/RangedWeapon/ActiveMode/AmmoRect
	},
	"melee": {
		"icon": $GameInterface/MeleeWeapon/Weapon,
		"charge": $GameInterface/MeleeWeapon/Charge,
		"active": $GameInterface/MeleeWeapon/ActiveMode,
		"meter": $GameInterface/MeleeWeapon/ActiveMode/ChargeRect
	}
}

# Interface References
@onready var game_ui = $GameInterface
@onready var menu_ui = $MenuInterface
@onready var inventory_screen = $MenuInterface/InventoryScreen
@onready var selection_field = $MenuInterface/InventoryScreen/SelectionScroll/SelectionField
@onready var information_field = $MenuInterface/InventoryScreen/InfoScroll/InformationField

# Selection Slots
@onready var selection_slots = [
	$GameInterface/SelectionSlots/Slot1,
	$GameInterface/SelectionSlots/Slot2,
	$GameInterface/SelectionSlots/Slot3,
	$GameInterface/SelectionSlots/Slot4
]
@onready var slot_label = $GameInterface/SelectionSlots/SelectionLabel

# State Variables
var weapon_stats: Dictionary
var damage: float = 0.0
var reloading: bool = false
var active_weapon: String = "None"

# Constants
const STAT_MAP = {
	"HP": "health",
	"MP": "magic",
	"STM": "stamina",
	"SHD": "overshield"
}

func _ready() -> void:
	menu_ui.hide()
	_connect_signals()
	await initial_setup()

func _connect_signals() -> void:
	if not PlayerStats.is_connected("stat_update", update_values):
		PlayerStats.connect("stat_update", update_values)
	if not PlayerStats.is_connected("exp_update", update_exp):
		PlayerStats.connect("exp_update", update_exp)
	if not PlayerStats.is_connected("spec_update", update_spec):
		PlayerStats.connect("spec_update", update_spec)

func initial_setup() -> void:
	# Initialize stat bars
	for stat_key in STAT_MAP:
		var display = stat_displays[STAT_MAP[stat_key]]
		_initialize_bar(display, PlayerStats.stats[stat_key])

	# Initialize experience
	_initialize_experience()

	# Initialize weapons
	_initialize_weapons()

func _initialize_bar(display: Dictionary, value: float) -> void:
	display.bar.max_value = value
	display.bar.value = value
	display.text.text = str(value)

func _initialize_experience() -> void:
	exp_displays.experience.max_value = PlayerStats.player_level[2]
	exp_displays.experience.value = PlayerStats.player_level[1]
	exp_displays.player_level.text = "Level %d" % PlayerStats.player_level[0]
	
	_update_specialist_display()
	
	_load_texture_safe(exp_displays.species_icon, "res://asset/emblems/", PlayerStats.species, "_emblem.png")

func _initialize_weapons() -> void:
	_load_texture_safe(weapon_displays.ranged.icon, "res://asset/ranged weapon/", PlayerStats.ranged_stats["Type"], ".png")
	weapon_displays.ranged.ammo.text = str(PlayerStats.ranged_values["MAG"])
	
	_load_texture_safe(weapon_displays.melee.icon, "res://asset/melee weapon/", PlayerStats.melee_stats["Type"], ".png")
	weapon_displays.melee.charge.text = str(PlayerStats.melee_values["STE"])

func _load_texture_safe(node: Node, path: String, name: String, suffix: String) -> void:
	var full_path = "%s%s%s" % [path, name.to_lower(), suffix]
	var texture = load(full_path)
	if texture:
		node.texture = texture
	else:
		push_warning("Failed to load texture: %s" % full_path)

func swap_active(state: String) -> void:
	if reloading: return
	
	match state:
		"Ranged":
			_set_weapon_state("ranged", true)
			_set_weapon_state("melee", false)
			weapon_stats = PlayerStats.ranged_stats
			PlayerStats.attack_cooldown = PlayerStats.ranged_values["FR"]
			active_weapon = "Ranged"
		"Melee":
			_set_weapon_state("ranged", false)
			_set_weapon_state("melee", true)
			weapon_stats = PlayerStats.melee_stats
			PlayerStats.attack_cooldown = PlayerStats.melee_values["ASP"]
			active_weapon = "Melee"
		"Swap":
			swap_active("Melee" if active_weapon == "Ranged" else "Ranged")
		"None":
			_set_weapon_state("ranged", false)
			_set_weapon_state("melee", false)
			weapon_stats = {}
			active_weapon = "None"

func _set_weapon_state(weapon: String, state: bool) -> void:
	weapon_displays[weapon].active.visible = state

func attack_action() -> void:
	if reloading or active_weapon == "None": return
	
	var weapon = weapon_displays[active_weapon.to_lower()]
	var current = int(weapon.ammo.text if active_weapon == "Ranged" else weapon.charge.text)
	
	if current > 0:
		current -= 1
		var max_value = (PlayerStats.ranged_values["MAG"] if active_weapon == "Ranged" 
			else PlayerStats.melee_values["STE"])
		var amount = float(current) / max_value
		
		if active_weapon == "Ranged":
			weapon.ammo.text = str(current)
			damage += PlayerStats.ranged_values["DMG"]
		else:
			weapon.charge.text = str(current)
			damage += PlayerStats.melee_values["POW"]
			
		weapon.meter.color = meter_update(amount)
	else:
		reload()

func reload() -> void:
	if reloading or active_weapon == "None" or stat_displays["magic"]["bar"].value < 1:
		if stat_displays["magic"]["bar"].value < 1:
			print("Insufficient Magic")
		return

	reloading = true
	var weapon = weapon_displays[active_weapon.to_lower()]
	weapon.active.color = Color.RED
	
	var reload_time = (PlayerStats.ranged_values["RLD"] if active_weapon == "Ranged" 
		else PlayerStats.melee_values["CHG"])
	
	await get_tree().create_timer(reload_time).timeout
	
	var max_value = (PlayerStats.ranged_values["MAG"] if active_weapon == "Ranged" 
		else PlayerStats.melee_values["STE"])
	
	if active_weapon == "Ranged":
		weapon.ammo.text = str(max_value)
	else:
		weapon.charge.text = str(max_value)
	
	var cost = -max_value * 100
	change_stat("MP", cost)
	
	weapon.active.color = Color.WHITE
	weapon.meter.color = Color.GREEN
	reloading = false
	damage = 0

func meter_update(amount: float) -> Color:
	return Color(1 - amount, amount, 0, 1)

func update_values(stat: String) -> void:
	if stat in STAT_MAP:
		stat_displays[STAT_MAP[stat]].bar.max_value = PlayerStats.stats[stat]

func change_stat(stat: String, value: float) -> void:
	if stat in STAT_MAP:
		var display = stat_displays[STAT_MAP[stat]]
		display.bar.value = clamp(display.bar.value + value, 0, display.bar.max_value)
		display.text.text = str(display.bar.value)

func update_exp() -> void:
	exp_displays.experience.max_value = PlayerStats.player_level[2]
	exp_displays.experience.value = PlayerStats.player_level[1]
	exp_displays.player_level.text = "Level %d" % PlayerStats.player_level[0]
	_update_point_indicators()

func update_spec() -> void:
	if PlayerStats.specialist:
		_update_specialist_display()
		_update_point_indicators()

func _update_specialist_display() -> void:
	var spec = PlayerStats.specialist
	if spec:
		var spec_levels = PlayerStats.specialist_levels[spec]
		exp_displays.specialist.max_value = spec_levels[2]
		exp_displays.specialist.value = spec_levels[1]
		exp_displays.specialist_rank.text = "%s Rank %d" % [spec.to_lower(), spec_levels[0]]
		_load_texture_safe(exp_displays.specialist_icon, "res://asset/specialist/", spec, "_emblem.png")

func _update_point_indicators() -> void:
	exp_displays.level_point.visible = PlayerStats.stat_points[0] > 0
	exp_displays.rank_point.visible = PlayerStats.element_points[0] > 0

func update_weapons(type: String) -> void:
	var weapon = weapon_displays[type.to_lower()]
	var stats = PlayerStats.ranged_stats if type == "Ranged" else PlayerStats.melee_stats
	var values = PlayerStats.ranged_values if type == "Ranged" else PlayerStats.melee_values
	
	_load_texture_safe(weapon.icon, "res://asset/%s weapon/" % type.to_lower(), stats["Type"], ".png")
	weapon.ammo.text = str(values["MAG" if type == "Ranged" else "STE"])

func swap_selection(state: String) -> void:
	slot_label.text = state.to_upper()

func update_technique(tech: int = -1) -> void:
	var techniques = PlayerStats.techniques
	for i in range(selection_slots.size()):
		if (tech == -1 or tech == i) and techniques[i] != null:
			var path = "res://asset/technique/%s.png" % techniques[i][0].to_lower()
			_load_texture_safe(selection_slots[i], "", path, "")
			selection_slots[i].texture_progress = selection_slots[i].texture_under

# New Features
func toggle_ui() -> void:
	game_ui.visible = !game_ui.visible

func set_stat_color(stat: String, color: Color) -> void:
	if stat in STAT_MAP:
		stat_displays[STAT_MAP[stat]].bar.modulate = color
