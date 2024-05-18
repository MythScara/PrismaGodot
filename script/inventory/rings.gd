extends Control

@onready var ring_1 = $Ring1/Image
@onready var ring_2 = $Ring2/Image
@onready var ring_3 = $Ring3/Image
@onready var ring_4 = $Ring4/Image
@onready var ring_5 = $Ring5/Image
@onready var ring_6 = $Ring6/Image
@onready var ring_7 = $Ring7/Image
@onready var ring_8 = $Ring8/Image
@onready var ring_9 = $Ring9/Image
@onready var ring_10 = $Ring10/Image

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
	var compare_tag
	var compare_info
	
	if current_info != null:
		current_info.queue_free()
	
	if PlayerInventory.current_inventory[button][0] != null:
		compare_tag = PlayerInventory.current_inventory[button][0].keys()[0]
		compare_info = PlayerInventory.current_inventory[button][0][compare_tag]
	else:
		return
	
	if key_name == null:
		key_name = PlayerInventory.current_inventory[button][0].keys()[0]
		input = PlayerInventory.current_inventory[button][0][key_name]

func replace_field(type, text, values):
	pass

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
