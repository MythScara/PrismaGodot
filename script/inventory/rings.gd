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
	image_set(0)
	image_set(1)
	image_set(2)
	image_set(3)
	image_set(4)
	image_set(5)
	image_set(6)
	image_set(7)
	image_set(8)
	image_set(9)

func image_set(type):
	pass

func display_info(button, key_name, input):
	pass

func replace_field(type, text, values):
	pass

func display_field(button):
	pass

func _on_ring_1_pressed():
	display_field("1")

func _on_ring_2_pressed():
	display_field("2")

func _on_ring_3_pressed():
	display_field("3")

func _on_ring_4_pressed():
	display_field("4")

func _on_ring_5_pressed():
	display_field("5")

func _on_ring_6_pressed():
	display_field("6")

func _on_ring_7_pressed():
	display_field("7")

func _on_ring_8_pressed():
	display_field("8")

func _on_ring_9_pressed():
	display_field("9")

func _on_ring_10_pressed():
	display_field("10")
