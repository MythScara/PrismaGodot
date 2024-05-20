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
		var path = "res://asset/armor_icons/" + image.to_lower() + ".png"
		if ResourceLoader.exists(path):
			pass
		else:
			path = "res://asset/hud_icons/locked_icon.png"
		
		match type:
			"Chest Armor":
				chest.texture = load(path)
			"Pad Armor":
				pad.texture = load(path)
			"Belt Armor":
				belt.texture = load(path)
			"Body Armor":
				body.texture = load(path)
			"Outfit":
				outfit.texture = load(path)

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
		
	if button != null:
		current_info = ItemInfo.instantiate()
		PlayerInterface.information_field.add_child(current_info)
		current_info.get_node("Name").text = key_name
		var item_type = button
		current_info.get_node("ItemType").text = item_type
		current_info.get_node("ItemTier").text = input["Tier"]
		current_info.get_node("ItemQuality").text = "Quality : " + str(input["Quality"])
		current_info.get_node("ItemElement").text = ""
		current_info.get_node("ItemImage").texture = load("res://asset/armor_icons/" + item_type.to_lower() + ".png")
		current_info.get_node("EquipButton").connect("pressed", Callable(self, "replace_field").bind(button, key_name, input))
		current_info.get_node("EquipButton").text = "EQUIP " + button.to_upper()
		for key in input.keys():
			if key not in PlayerStats.excluded:
				var hbox = HBoxContainer.new()
				current_info.get_node("Scroll/StatBar").add_child(hbox)
				var key_text = Label.new()
				key_text.text = key
				key_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
				key_text.add_theme_font_size_override("font_size", 20)
				hbox.add_child(key_text)
				
				var key_value = Label.new()
				key_value.text = str(input[key])
				
				if compare_info.has(key) and (typeof(compare_info[key]) == TYPE_FLOAT or typeof(compare_info[key]) == TYPE_INT):
					if input[key] > compare_info[key]:
						key_value.add_theme_color_override("font_color", Color(0, 1, 0))
					elif input[key] < compare_info[key]:
						key_value.add_theme_color_override("font_color", Color(1, 0, 0))
					
				key_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				key_value.add_theme_font_size_override("font_size", 20)
				key_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(key_value)

func update_values():
	image_set("Body Armor")
	image_set("Pad Armor")
	image_set("Belt Armor")
	image_set("Chest Armor")
	image_set("Outfit")

func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_values"))

func _on_chest_armor_pressed():
	display_field("Chest Armor")

func _on_pad_armor_pressed():
	display_field("Pad Armor")

func _on_belt_armor_pressed():
	display_field("Belt Armor")

func _on_body_armor_pressed():
	display_field("Body Armor")

func _on_outfit_pressed():
	display_field("Outfit")
