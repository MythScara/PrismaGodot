extends Control

@onready var top = $OffensiveItemTop/Image
@onready var right = $OffensiveItemRight/Image
@onready var left = $OffensiveItemLeft/Image
@onready var bottom = $OffensiveItemBottom/Image

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
	PlayerStats.connect("pause_game", Callable(self, "update_values"))

func update_values():
	image_set("Top")
	image_set("Right")
	image_set("Left")
	image_set("Bottom")

func image_set(type):
	pass

func display_info(button, key_name, input):
	pass

func replace_field(type, text, values):
	pass

func display_field(button):
	pass

func _on_offensive_item_top_pressed():
	display_field("Top")

func _on_offensive_item_right_pressed():
	display_field("Right")

func _on_offensive_item_left_pressed():
	display_field("Left")

func _on_offensive_item_bottom_pressed():
	display_field("Bottom")
