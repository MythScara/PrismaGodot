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

func _ready():
	pass # Replace with function body.
