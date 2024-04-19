extends Control

@onready var ranged_weapon = $RangedWeapon/Image
@onready var melee_weapon = $MeleeWeapon/Image
@onready var soul_stone = $SoulStone/Image
@onready var summon = $Summon/Image
@onready var vehicle = $Vehicle/Image

var ItemInfo = preload("res://object/item_info.tscn")
var current_info = null

var buttonstyle = preload("res://object/standardbutton.tscn")
var selected_button = null
signal button_pressed(text)
# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_values"))

func image_set(type):
	if type != null and PlayerInventory.current_inventory[type][0] != null:
		var image_id = PlayerInventory.current_inventory[type][0].keys()[0]
		var image_dict = PlayerInventory.current_inventory[type][0][image_id]
		var image = image_dict["Type"]
	
		match type:
			"Ranged Weapon":
				ranged_weapon.texture = load("res://asset/weapon_icons/" + image.to_lower() + ".png")
			"Melee Weapon":
				melee_weapon.texture = load("res://asset/weapon_icons/" + image.to_lower() + ".png")
			"Vehicle":
				vehicle.texture = load("res://asset/vehicle/" + image.to_lower() + ".png")
			"Summon":
				summon.texture = load("res://asset/summon/" + image.to_lower() + ".png")
			"Soul Stone":
				soul_stone.texture = load("res://asset/soul_stone/" + image.to_lower() + ".png")

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	emit_signal("button_pressed", new_button.text)

func replace_field(type, text, values):
	
	var original = PlayerInventory.current_inventory[type][0].keys()[0]
	var cur_values = PlayerInventory.current_inventory[type][0][original]
	
	if PlayerInventory.current_inventory[type][0].keys()[0] != text:
		match type:
			"Ranged Weapon":
				PlayerStats.weapon_stat_change(cur_values, "Ranged", "Sub")
			"Melee Weapon":
				PlayerStats.weapon_stat_change(cur_values, "Melee", "Sub")
			"Soul Stone":
				PlayerStats.player_stat_change(cur_values, "Sub")
				PlayerStats.element_stat_change(cur_values, "Sub")
			"Vehicle":
				pass
			"Summon":
				pass
		
		PlayerInventory.current_inventory[type][0] = {text: values}
		image_set(type)
		match type:
			"Ranged Weapon":
				PlayerStats.weapon_stat_change(values, "Ranged", "Add")
				PlayerInterface.update_weapons("Ranged")
			"Melee Weapon":
				PlayerStats.weapon_stat_change(values, "Melee", "Add")
				PlayerInterface.update_weapons("Melee")
			"Soul Stone":
				PlayerStats.player_stat_change(values, "Add")
				PlayerStats.element_stat_change(values, "Add")
			"Vehicle":
				pass
			"Summon":
				pass
		
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

func display_info(button, key_name = null, input = null):
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
		var item_type = input["Type"]
		current_info.get_node("ItemType").text = item_type
		current_info.get_node("ItemTier").text = input["Tier"]
		current_info.get_node("ItemQuality").text = "Quality : " + str(input["Quality"])
		current_info.get_node("ItemElement").text = input["Element"]
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
		
		match button:
			"Ranged Weapon", "Melee Weapon":
				current_info.get_node("ItemImage").texture = load("res://asset/weapon_icons/" + item_type.to_lower() + ".png")
				current_info.get_node("ItemExtra").text = GameInfo.firing_type(item_type)
			"Soul Stone":
				current_info.get_node("ItemImage").texture = load("res://asset/soul_stone/" + key_name.to_lower() + ".png")
				current_info.get_node("ItemExtra").text = "Energy : " + str(input["Energy"])
			

func update_values():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")
	image_set("Soul Stone")
	image_set("Summon")
	image_set("Vehicle")

func _on_ranged_weapon_pressed():
	display_field("Ranged Weapon")
	display_info("Ranged Weapon")

func _on_melee_weapon_pressed():
	display_field("Melee Weapon")
	display_info("Melee Weapon")

func _on_soul_stone_pressed():
	display_field("Soul Stone")
	display_info("Soul Stone")

func _on_summon_pressed():
	display_field("Summon")
	display_info("Summon")

func _on_vehicle_pressed():
	display_field("Vehicle")
	display_info("Vehicle")
