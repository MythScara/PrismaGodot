extends Control

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
	pass

func image_set(type):
	pass

func display_info(button, key_name, input):
	pass

func replace_field(type, text, values):
	pass

func display_field(button):
	pass

func _on_artifact_1_pressed():
	pass # Replace with function body.

func _on_artifact_2_pressed():
	pass # Replace with function body.

func _on_artifact_3_pressed():
	pass # Replace with function body.
