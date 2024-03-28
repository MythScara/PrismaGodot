extends Control

@export var continue_screen : PackedScene

@onready var description = $InfoBox/SpecialistDescription
@onready var weapon = $InfoBox/SpecialistWeapon
@onready var passive1 = $InfoBox/Passive1
@onready var passive2 = $InfoBox/Passive2
@onready var passive3 = $InfoBox/Passive3
@onready var technique1 = $InfoBox/Technique1
@onready var technique2 = $InfoBox/Technique2
@onready var technique3 = $InfoBox/Technique3
@onready var sprite = $EmblemSprite
@onready var species_sprite = $SpeciesSprite

var selected_specialist = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var vbox = get_node("ScrollContainer/VBoxContainer")
	vbox.connect("button_pressed", Callable(self, "update_text"))
	if PlayerStats.species != null:
		species_sprite.texture = load("res://asset/emblems/" + PlayerStats.species.to_lower() + "_emblem.png")
	else:
		species_sprite.texture = load("res://asset/emblems/human_emblem.png")

func update_text(text):
	if text == selected_specialist:
		return
	
	if sprite.visible == false:
		sprite.visible = true
	
	var specialist = PlayerStats.load_specialist(text)
	var info = specialist.specialist_info
	selected_specialist = text
	description.bbcode_text = "Description: " + info["Description"]
	weapon.bbcode_text = "Weapon: " + info["Weapon"]
	passive1.bbcode_text = "Passive 1: " + info["Passive 1"].values()[0]
	passive2.bbcode_text = "Passive 2: " + info["Passive 2"].values()[0]
	passive3.bbcode_text = "Passive 3: " + info["Passive 3"].values()[0]
	technique1.bbcode_text = "Technique 1: " + info["Technique 1"].values()[0] + " (" + str(info["Technique 1"]["TD"]) + ")" + " {" + str(info["Technique 1"]["TC"]) + "}"
	technique2.bbcode_text = "Technique 2: " + info["Technique 2"].values()[0] + " (" + str(info["Technique 2"]["TD"]) + ")" + " {" + str(info["Technique 2"]["TC"]) + "}"
	technique3.bbcode_text = "Technique 3: " + info["Technique 3"].values()[0] + " (" + str(info["Technique 3"]["TD"]) + ")" + " {" + str(info["Technique 3"]["TC"]) + "}"
	sprite.texture = load("res://asset/specialist_emblems/" + text.to_lower() + "_emblem.png")

func _on_continue_button_pressed():
	if continue_screen:
		PlayerStats.emit_signal("activate_specialist", selected_specialist)
		get_tree().change_scene_to_packed(continue_screen)
	else:
		print("No Scene Set")
