extends Control

var ItemInfo = preload("res://object/item_info.tscn")
var current_info = null

var buttonstyle = preload("res://object/standardbutton.tscn")
var selected_button = null
signal button_pressed(text)

func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_values"))

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	emit_signal("button_pressed", new_button.text)

func image_set(type, texture = null, slot = 0):
	if type != null and texture != null and PlayerInventory.current_inventory[type][slot] != null:
		var image = PlayerInventory.current_inventory[type][slot].keys()[0]
		var path = "res://asset/" + type.to_lower() + "_icons/" + image.to_lower() + ".png"
		if ResourceLoader.exists(path):
			pass
		else:
			path = "res://asset/hud_icons/locked_icon.png"
	else:
		print("Missing Data!")

func replace_field(type, text, values, texture, slot = 0):
	var original = PlayerInventory.current_inventory[type][slot].keys()[0]
	var cur_values = PlayerInventory.current_inventory[type][slot][original]
	
	if PlayerInventory.current_inventory[type][slot].keys()[0] != text:
		if type != null:
			PlayerStats.player_stat_change(cur_values, "Sub")
			PlayerStats.element_stat_change(cur_values, "Sub")
		
		PlayerInventory.current_inventory[type][slot] = {text: values}
		image_set(type, texture, slot)

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

func display_info(type, key_name, input, slot = 0):
	var compare_tag
	var compare_info
	
	if current_info != null:
		current_info.queue_free()
	
	if PlayerInventory.current_inventory[type][slot] != null:
		compare_tag = PlayerInventory.current_inventory[type][slot].keys()[0]
		compare_info = PlayerInventory.current_inventory[type][slot][compare_tag]
	else:
		return
	
	if key_name == null:
		key_name = PlayerInventory.current_inventory[type][slot].keys()[0]
		input = PlayerInventory.current_inventory[type][slot][key_name]
		
	if type != null:
		current_info = ItemInfo.instantiate()
		PlayerInterface.information_field.add_child(current_info)
		current_info.get_node("Name").text = key_name
		var item_type = type
		current_info.get_node("ItemType").text = item_type
		current_info.get_node("ItemTier").text = input["Tier"]
		current_info.get_node("ItemQuality").text = "Quality : " + str(input["Quality"])
		current_info.get_node("ItemElement").text = input["Element"]
		current_info.get_node("ItemExtra").text = input["Extra"]
		current_info.get_node("ItemImage").texture = load("res://asset/" + type.to_lower() + "_icons/" + key_name.to_lower() + ".png")
		current_info.get_node("EquipButton").connect("pressed", Callable(self, "replace_field").bind(type, key_name, input, slot))
		current_info.get_node("EquipButton").text = "EQUIP " + type.to_upper()
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
	pass
