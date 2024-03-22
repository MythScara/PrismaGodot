extends Node

@onready var health_bar = $GameInterface/Health/HealthBar
@onready var health_text = $GameInterface/Health/HealthText

@onready var overshield_bar = $GameInterface/Overshield/OvershieldBar
@onready var overshield_text = $GameInterface/Overshield/OvershieldText

@onready var magic_bar = $GameInterface/Magic/MagicBar
@onready var magic_text = $GameInterface/Magic/MagicText

@onready var stamina_bar = $GameInterface/Stamina/StaminaBar
@onready var stamina_text = $GameInterface/Stamina/StaminaText

@onready var experience_bar = $GameInterface/Experience/ExperienceBar
@onready var specialist_bar = $GameInterface/Experience/SpecialistBar

@onready var species_icon = $GameInterface/Experience/SpecialistBar/Species
@onready var specialist_icon = $GameInterface/Experience/SpecialistBar/Specialist

@onready var player_level = $GameInterface/Experience/PlayerBar/Level
@onready var specialist_rank = $GameInterface/Experience/PlayerBar/Rank

@onready var rank_point = $GameInterface/Experience/PlayerBar/RankPoint
@onready var level_point = $GameInterface/Experience/PlayerBar/LevelPoint

@onready var ranged_weapon = $GameInterface/RangedWeapon/Weapon
@onready var melee_weapon = $GameInterface/MeleeWeapon/Weapon

@onready var ammo = $GameInterface/RangedWeapon/Ammo
@onready var charge = $GameInterface/MeleeWeapon/Charge

@onready var ranged_active = $GameInterface/RangedWeapon/ActiveMode
@onready var melee_active = $GameInterface/MeleeWeapon/ActiveMode

@onready var ranged_meter = $GameInterface/RangedWeapon/ActiveMode/AmmoRect
@onready var melee_meter = $GameInterface/MeleeWeapon/ActiveMode/ChargeRect

@onready var game_ui = $GameInterface
@onready var menu_ui = $MenuInterface

var weapon_stats
var damage = 0
var reloading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	menu_ui.visible = false
	PlayerStats.connect("stat_update", Callable(self, "update_values"))
	PlayerStats.connect("exp_update", Callable(self, "update_exp"))
	PlayerStats.connect("spec_update", Callable(self, "update_spec"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initial_setup():
	# Define a dictionary to map stats to their respective bars and text labels.
	var progress_bars = {
		"HP": {"bar": health_bar, "text": health_text},
		"MP": {"bar": magic_bar, "text": magic_text},
		"STM": {"bar": stamina_bar, "text": stamina_text},
		"SHD": {"bar": overshield_bar, "text": overshield_text}
	}

	# Loop through each stat, setting the bar's max value, value, and corresponding text.
	for stat in progress_bars.keys():
		var components = progress_bars[stat]
		var bar = components["bar"]
		var text_label = components["text"]
		bar.max_value = PlayerStats.stats[stat]
		bar.value = PlayerStats.stats[stat]  # Assuming you want to initialize the value to max_value
		text_label.text = str(PlayerStats.stats[stat])

	# Handle the experience bar separately since it doesn't fit the same pattern.
	experience_bar.max_value = PlayerStats.player_level[2]
	experience_bar.value = PlayerStats.player_level[1]
	player_level.text = "Level " + str(PlayerStats.player_level[0])
	specialist_bar.max_value = PlayerStats.specialist_levels[PlayerStats.specialist][2]
	specialist_bar.value = PlayerStats.specialist_levels[PlayerStats.specialist][1]
	specialist_rank.text = PlayerStats.specialist.to_lower() + " Rank " + str(PlayerStats.specialist_levels[PlayerStats.specialist][0])

	# Load textures for species and specialist icons.
	species_icon.texture = load("res://asset/emblems/" + PlayerStats.species.to_lower() + "_emblem.png")
	specialist_icon.texture = load("res://asset/specialist_emblems/" + PlayerStats.specialist.to_lower() + "_emblem.png")
	ranged_weapon.texture = load("res://asset/weapon_icons/" + PlayerStats.ranged_stats["Type"].to_lower() + ".png")
	ammo.text = str(PlayerStats.ranged_values["MAG"])
	melee_weapon.texture = load("res://asset/weapon_icons/" + PlayerStats.melee_stats["Type"].to_lower() + ".png")
	charge.text = str(PlayerStats.melee_values["STE"])

	# Ensure the UI is visible.
	self.visible = true

func swap_active(state):
	if reloading:
		return
	
	match state:
		"Ranged":
			melee_active.visible = false
			ranged_active.visible = true
			weapon_stats = PlayerStats.ranged_stats
			PlayerStats.attack_cooldown = PlayerStats.ranged_values["FR"]
		"Melee":
			ranged_active.visible = false
			melee_active.visible = true
			weapon_stats = PlayerStats.melee_stats
			PlayerStats.attack_cooldown = PlayerStats.melee_values["ASP"]
		"Swap":
			if ranged_active.visible == true:
				ranged_active.visible = false
				melee_active.visible = true
				weapon_stats = PlayerStats.melee_stats
				PlayerStats.attack_cooldown = PlayerStats.melee_values["ASP"]
			else:
				melee_active.visible = false
				ranged_active.visible = true
				weapon_stats = PlayerStats.ranged_stats
				PlayerStats.attack_cooldown = PlayerStats.ranged_values["FR"]
		"None":
			melee_active.visible = false
			ranged_active.visible = false
			weapon_stats = null

func attack_action():
	if ranged_active.visible == true:
		if reloading:
			return
			
		var cur = int(ammo.text)
		var amount
		if cur > 0:
			cur -= 1
			ammo.text = str(cur)
			amount = float(cur) / PlayerStats.ranged_values["MAG"]
			ranged_meter.color = meter_update(amount)
			damage += PlayerStats.ranged_values["DMG"]
		else:
			reload()
	elif melee_active.visible == true:
		if reloading:
			return
			
		var cur = int(charge.text)
		var amount
		if cur > 0:
			cur -= 1
			charge.text = str(cur)
			amount = float(cur) / PlayerStats.melee_values["STE"]
			melee_meter.color = meter_update(amount)
			damage += PlayerStats.melee_values["POW"]
		else:
			reload()
	else:
		pass

func reload():
	
	var time_r = PlayerStats.ranged_values["RLD"]
	var time_m = PlayerStats.melee_values["CHG"]
	
	if reloading:
		return
	
	if magic_bar.value < 1:
		print("Insufficient Magic")
		return
	
	reloading = true
	print_debug(damage)
	
	if ranged_active.visible == true:
		ranged_active.color = Color(1, 0, 0, 1)
		await get_tree().create_timer(time_r).timeout
		ammo.text = str(PlayerStats.ranged_values["MAG"])
		var cost = -int(ammo.text)*100
		change_stat("MP", cost)
		ranged_active.color = Color(1, 1, 1, 1)
		ranged_meter.color = Color(0, 1, 0, 1)
	elif melee_active.visible == true:
		melee_active.color = Color(1, 0, 0, 1)
		await get_tree().create_timer(time_m).timeout
		charge.text = str(PlayerStats.melee_values["STE"])
		var cost = -int(charge.text)*100
		change_stat("MP", cost)
		melee_active.color = Color(1, 1, 1, 1)
		melee_meter.color = Color(0, 1, 0, 1)
		
	reloading = false
	damage = 0

func meter_update(amount):
	return Color(1 - amount, amount, 0 ,1)

func update_exp():
	experience_bar.max_value = PlayerStats.player_level[2]
	experience_bar.value = PlayerStats.player_level[1]
	player_level.text = "Level " + str(PlayerStats.player_level[0])
	if PlayerStats.stat_points[0] > 0:
		$GameInterface/Experience/PlayerBar/LevelPoint.visible = true
	else:
		$GameInterface/Experience/PlayerBar/LevelPoint.visible = false
	if PlayerStats.element_points[0] > 0:
		$GameInterface/Experience/PlayerBar/RankPoint.visible = true
	else:
		$GameInterface/Experience/PlayerBar/RankPoint.visible = false

func update_spec():
	if PlayerStats.specialist != null:
		specialist_bar.max_value = PlayerStats.specialist_levels[PlayerStats.specialist][2]
		specialist_bar.value = PlayerStats.specialist_levels[PlayerStats.specialist][1]
		specialist_rank.text = PlayerStats.specialist.to_lower() + " Rank " + str(PlayerStats.specialist_levels[PlayerStats.specialist][0])
	if PlayerStats.stat_points[0] > 0:
		$GameInterface/Experience/PlayerBar/LevelPoint.visible = true
	else:
		$GameInterface/Experience/PlayerBar/LevelPoint.visible = false
	if PlayerStats.element_points[0] > 0:
		$GameInterface/Experience/PlayerBar/RankPoint.visible = true
	else:
		$GameInterface/Experience/PlayerBar/RankPoint.visible = false

func update_values(stat):
	match stat:
		"HP":
			health_bar.max_value = PlayerStats.stats["HP"]
		"MP":
			magic_bar.max_value = PlayerStats.stats["MP"]
		"SHD":
			overshield_bar.max_value = PlayerStats.stats["SHD"]
		"STM":
			stamina_bar.max_value = PlayerStats.stats["STM"]

func change_stat(stat, value):
	match stat:
		"HP":
			health_bar.value += value
			health_text.text = str(health_bar.value)
		"MP":
			magic_bar.value += value
			magic_text.text = str(magic_bar.value)
		"SHD":
			overshield_bar.value += value
			overshield_text.text = str(overshield_bar.value)
		"STM":
			stamina_bar.value += value
			stamina_text.text = str(stamina_bar.value)
