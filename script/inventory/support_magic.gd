extends Control

@onready var top = $SupportMagicTop/Image
@onready var right = $SupportMagicRight/Image
@onready var left = $SupportMagicLeft/Image
@onready var bottom = $SupportMagicBottom/Image

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
	var original = PlayerInventory.current_inventory[type][0].keys()[0]
	var cur_values = PlayerInventory.current_inventory[type][0][original]
	
	if PlayerInventory.current_inventory[type][0].keys()[0] != text:
		if type != null:
			PlayerStats.player_stat_change(cur_values, "Sub")
			PlayerStats.element_stat_change(cur_values, "Sub")
		
		PlayerInventory.current_inventory[type][0] = {text: values}
		image_set(type)

		PlayerStats.player_stat_change(values, "Add")
		PlayerStats.element_stat_change(values, "Add")
		
		PlayerInterface.clear_selection()
	else:
		print("This Item is Already Equipped")
		PlayerInterface.clear_selection()

func display_field(button):
	PlayerInterface.clear_selection()
	for key in PlayerInventory.equip_inventory[button].keys():
		var option = buttonstyle.instantiate()
		var input = PlayerInventory.equip_inventory[button]
		option.text = key
		option.add_theme_font_size_override("font_size", 20)
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option.connect("pressed", Callable(self, "display_info").bind(button, key, input[key]))
		option.pressed.connect(_on_Button_pressed.bind(option))
		PlayerInterface.selection_field.add_child(option)
		
		if key == PlayerInventory.current_inventory[button][0].keys()[0]:
			_on_Button_pressed(option)
			display_info(button, key, input[key])

func _on_support_magic_top_pressed():
	display_field("Top")

func _on_support_magic_right_pressed():
	display_field("Right")

func _on_support_magic_left_pressed():
	display_field("Left")

func _on_support_magic_bottom_pressed():
	display_field("Bottom")