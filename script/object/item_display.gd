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
		var path = "res://asset/hud_icons/locked_icon.png"

func replace_field(type, image, text, values, slot = 0):
	var original = PlayerInventory.current_inventory[type][slot].keys()[0]
	var cur_values = PlayerInventory.current_inventory[type][slot][original]
	
	if PlayerInventory.current_inventory[type][slot].keys()[0] != text:
		if type != null:
			PlayerStats.player_stat_change(cur_values, "Sub")
			PlayerStats.element_stat_change(cur_values, "Sub")
		
		PlayerInventory.current_inventory[type][slot] = {text: values}
		image_set(type, image, slot)

		PlayerStats.player_stat_change(values, "Add")
		PlayerStats.element_stat_change(values, "Add")
		
		PlayerInterface.clear_selection()
	else:
		print("This Item is Already Equipped")
		PlayerInterface.clear_selection()

func display_field(type, image, item_name, values, slot = 0):
	PlayerInterface.clear_selection()
	for key in PlayerInventory.equip_inventory[type].keys():
		var option = buttonstyle.instantiate()
		var input = PlayerInventory.equip_inventory[type]
		option.text = key
		option.add_theme_font_size_override("font_size", 20)
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option.connect("pressed", Callable(self, "display_info").bind(type, image, key, input[key], slot))
		option.pressed.connect(_on_Button_pressed.bind(option))
		PlayerInterface.selection_field.add_child(option)
		
		if key == PlayerInventory.current_inventory[type][slot].keys()[0]:
			_on_Button_pressed(option)
			display_info(type, image, key, input[key], slot)

func display_info(type, image, item_name, values, slot = 0):
	var compare_tag
	var compare_info
	
	if current_info != null:
		current_info.queue_free()
	
	if PlayerInventory.current_inventory[type][slot] != null:
		compare_tag = PlayerInventory.current_inventory[type][slot].keys()[0]
		compare_info = PlayerInventory.current_inventory[type][slot][compare_tag]
	else:
		return
	
	if item_name == null:
		item_name = PlayerInventory.current_inventory[type][slot].keys()[0]
		values = PlayerInventory.current_inventory[type][slot][item_name]
		
	if type != null:
		current_info = ItemInfo.instantiate()
		PlayerInterface.information_field.add_child(current_info)
		current_info.get_node("Name").text = item_name
		var item_type = type
		current_info.get_node("ItemType").text = item_type
		if "Tier" in values:
			current_info.get_node("ItemTier").text = values["Tier"]
		else:
			current_info.get_node("ItemTier").text = ""
		if "Quality" in values:
			current_info.get_node("ItemQuality").text = "Quality : " + str(values["Quality"])
		else:
			current_info.get_node("ItemQuality").text = ""
		if "Element" in values:
			current_info.get_node("ItemElement").text = values["Element"]
		else:
			current_info.get_node("ItemElement").text = ""
		if "Extra" in values:
			current_info.get_node("ItemExtra").text = values["Extra"]
		else:
			current_info.get_node("ItemExtra").text = ""
		var path = "res://asset/" + type.to_lower() + "_icons/" + item_name.to_lower() + ".png"
		if ResourceLoader.exists(path):
			pass
		else:
			path = "res://asset/hud_icons/locked_icon.png"
		current_info.get_node("ItemImage").texture = load(path)
		current_info.get_node("EquipButton").connect("pressed", Callable(self, "replace_field").bind(type, image, item_name, values, slot))
		current_info.get_node("EquipButton").text = "EQUIP " + type.to_upper()
		for key in values.keys():
			if key not in PlayerStats.excluded and (typeof(values[key]) == TYPE_FLOAT or typeof(values[key]) == TYPE_INT):
				print(values[key])
				print(typeof(values[key]))
				var hbox = HBoxContainer.new()
				current_info.get_node("Scroll/StatBar").add_child(hbox)
				var key_text = Label.new()
				key_text.text = key
				key_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
				key_text.add_theme_font_size_override("font_size", 20)
				hbox.add_child(key_text)
				
				var key_value = Label.new()
				key_value.text = str(values[key])
				
				if compare_info.has(key) and (typeof(compare_info[key]) == TYPE_FLOAT or typeof(compare_info[key]) == TYPE_INT):
					if values[key] > compare_info[key]:
						key_value.add_theme_color_override("font_color", Color(0, 1, 0))
					elif values[key] < compare_info[key]:
						key_value.add_theme_color_override("font_color", Color(1, 0, 0))
					
				key_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				key_value.add_theme_font_size_override("font_size", 20)
				key_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				hbox.add_child(key_value)

func update_values():
	return
	for type in PlayerInventory.equip_inventory.keys():
		image_set(type)
