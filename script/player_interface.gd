extends Node

@onready var health_bar = $GameInterface/HealthBar
@onready var magic_bar = $GameInterface/MagicBar
@onready var stamina_bar = $GameInterface/StaminaBar
@onready var overshield_bar = $GameInterface/OvershieldBar
@onready var experience_bar = $GameInterface/Experience/ExperienceBar
@onready var species_icon = $GameInterface/Emblem/Species
@onready var specialist_icon = $GameInterface/Emblem/Specialist
@onready var health_text = $GameInterface/HealthText
@onready var magic_text = $GameInterface/MagicText
@onready var stamina_text = $GameInterface/StaminaText
@onready var overshield_text = $GameInterface/OvershieldText

@onready var game_ui = $GameInterface
@onready var menu_ui = $MenuInterface

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	menu_ui.visible = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func initial_setup():
	health_bar.max_value = PlayerStats.stats["HP"]
	magic_bar.max_value = PlayerStats.stats["MP"]
	stamina_bar.max_value = PlayerStats.stats["STM"]
	overshield_bar.max_value = PlayerStats.stats["SHD"]
	experience_bar.max_value = PlayerStats.specialist_levels[PlayerStats.specialist][2]
	species_icon.texture = load("res://asset/emblems/" + PlayerStats.species.to_lower() + "_emblem.png")
	specialist_icon.texture = load("res://asset/specialist_emblems/" + PlayerStats.specialist.to_lower() + "_emblem.png")
	self.visible = true
	health_bar.value = PlayerStats.stats["HP"]
	magic_bar.value = PlayerStats.stats["MP"]
	stamina_bar.value = PlayerStats.stats["STM"]
	overshield_bar.value = PlayerStats.stats["SHD"]
	experience_bar.value = PlayerStats.specialist_levels[PlayerStats.specialist][1]
	health_text.text = str(PlayerStats.stats["HP"])
	magic_text.text = str(PlayerStats.stats["MP"])
	stamina_text.text = str(PlayerStats.stats["STM"])
	overshield_text.text = str(PlayerStats.stats["SHD"])

func update_values():
	pass
