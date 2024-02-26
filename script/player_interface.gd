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

@onready var game_ui = $GameInterface
@onready var menu_ui = $MenuInterface

var weapon_stats
var reloading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	menu_ui.visible = false
	PlayerStats.connect("stat_update", Callable(self, "update_values"))

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
	ammo.text = str(PlayerStats.ranged_stats["MAG"])
	melee_weapon.texture = load("res://asset/weapon_icons/" + PlayerStats.melee_stats["Type"].to_lower() + ".png")
	charge.text = str(PlayerStats.melee_stats["CHG"])

	# Ensure the UI is visible.
	self.visible = true
	ammo.text = "100" #remove after testing
	charge.text = "100" #remove after testing

func swap_active(state):
	match state:
		"Ranged":
			melee_active.visible = false
			ranged_active.visible = true
			weapon_stats = PlayerStats.ranged_stats
		"Melee":
			ranged_active.visible = false
			melee_active.visible = true
			weapon_stats = PlayerStats.melee_stats
		"Swap":
			if ranged_active.visible == true:
				ranged_active.visible = false
				melee_active.visible = true
				weapon_stats = PlayerStats.melee_stats
			else:
				melee_active.visible = false
				ranged_active.visible = true
				weapon_stats = PlayerStats.ranged_stats
		"None":
			melee_active.visible = false
			ranged_active.visible = false
			weapon_stats = null

func attack_action():
	if ranged_active.visible == true:
		var cur = int(ammo.text)
		if cur > 0:
			cur -= 1
			ammo.text = str(cur)
		else:
			reload()
	elif melee_active.visible == true:
		var cur = int(charge.text)
		if cur > 0:
			cur -= 1
			charge.text = str(cur)
		else:
			reload()
	else:
		print_debug("No Weapon Equipped")

func reload(time: float = 2.0):
	if reloading:
		return
	
	reloading = true
	
	if ranged_active.visible == true:
		await get_tree().create_timer(time).timeout
		ammo.text = str(PlayerStats.ranged_stats["MAG"])
		ammo.text = "100" #remove after testing
	elif melee_active.visible == true:
		await get_tree().create_timer(time).timeout
		charge.text = str(PlayerStats.melee_stats["CHG"])
		charge.text = "100" #remove after testing
		
	reloading = false

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
