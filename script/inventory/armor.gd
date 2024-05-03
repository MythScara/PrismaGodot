extends Control

@onready var chest = $ChestArmor/Image
@onready var pad = $PadArmor/Image
@onready var belt = $BeltArmor/Image
@onready var body = $BodyArmor/Image
@onready var outfit = $Outfit/Image

var ItemInfo = preload("res://object/item_info.tscn")
var current_info = null

var buttonstyle = preload("res://object/standardbutton.tscn")
var selected_button = null
signal button_pressed(text)

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	emit_signal("button_pressed", new_button.text)

func image_set(type):
		if type != null and PlayerInventory.current_inventory[type][0] != null:
			var image = PlayerInventory.current_inventory[type][0].keys()[0]
	
			match type:
				"Chest Armor":
					chest.texture = load("res://asset/armor_icons/" + image.to_lower + ".png")
				"Pad Armor":
					pad.texture = load("res://asset/armor_icons/" + image.to_lower + ".png")
				"Belt Armor":
					belt.texture = load("res://asset/armor_icons/" + image.to_lower + ".png")
				"Body Armor":
					body.texture = load("res://asset/armor_icons/" + image.to_lower + ".png")
				"Outift":
					outfit.texture = load("res://asset/armor_icons/" + image.to_lower + ".png")

func update_values():
	image_set("Body Armor")
	image_set("Pad Armor")
	image_set("Belt Armor")
	image_set("Body Armor")
	image_set("Outfit")

func _ready():
	update_values()
