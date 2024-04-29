extends Control

@onready var specialist_info = $Specialist
@onready var faction_info = $Faction

var ItemInfo = preload("res://object/item_info.tscn")
var cur_selected = null
var current_info = null

var buttonstyle = preload("res://object/standardbutton.tscn")
var textstyle = preload("res://object/standard_richtext.tscn")
var selected_button = null
signal button_pressed(text)
# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_fields"))
	update_fields()

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	emit_signal("button_pressed", new_button.text)

func update_fields():
	if PlayerInventory.current_inventory["Specialist"][0] != null:
		specialist_info.text = str(PlayerInventory.current_inventory["Specialist"][0].keys()[0])
	else:
		specialist_info.text = "Specialist"
	if PlayerInventory.current_inventory["Faction"][0] != null:
		faction_info.text = str(PlayerInventory.current_inventory["Faction"][0].keys()[0])
	else:
		faction_info.text = "Faction"

func display_info(button, key_name = null, input = null):
	if key_name == cur_selected:
		return
	
	if current_info != null:
		current_info.queue_free()
	
	if PlayerInventory.current_inventory[button][0] == null:
		return
	
	if key_name == null:
		key_name = PlayerInventory.current_inventory[button][0].keys()[0]
		input = PlayerInventory.current_inventory[button][0][key_name]
	
	var specialist = PlayerStats.load_specialist(input["Name"])
	var info = specialist.specialist_info
	cur_selected = key_name

func display_options(button):
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

func _on_specialist_pressed():
	display_options("Specialist")

func _on_faction_pressed():
	display_options("Faction")
