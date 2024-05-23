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
	if type != null and PlayerInventory.current_inventory["Battle Item"][type] != null:
		var image = PlayerInventory.current_inventory["Battle Item"][type].keys()[0]
		var path = "res://asset/item_icons/" + image.to_lower() + ".png"
		if ResourceLoader.exists(path):
			pass
		else:
			path = "res://asset/hud_icons/locked_icon.png"
		
		match type:
			0:
				top.texture = load(path)
			1:
				left.texture = load(path)
			2:
				right.texture = load(path)
			3:
				bottom.texture = load(path)

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

func _on_offensive_item_top_pressed():
	display_field("Top")

func _on_offensive_item_right_pressed():
	display_field("Right")

func _on_offensive_item_left_pressed():
	display_field("Left")

func _on_offensive_item_bottom_pressed():
	display_field("Bottom")
