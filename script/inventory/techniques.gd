extends Control

@onready var skill_button = $Skill
@onready var special_button = $Special
@onready var super_button = $Super

var ItemInfo = preload("res://object/item_info.tscn")
var cur_selected = null
var current_info = null

var buttonstyle = preload("res://object/standardbutton.tscn")
var textstyle = preload("res://object/standard_richtext.tscn")
var selected_button = null
signal button_pressed(text)

func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_techniques"))
	update_techniques()

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	emit_signal("button_pressed", new_button.text)

func update_techniques():
	var index = 0
	for tech in PlayerInventory.current_inventory["Techniques"]:
		var text = "Technique Available"
		if tech != null:
			for skill in tech.keys():
				text = skill
		match index:
			0:
				skill_button.text = text
			1:
				special_button.text = text
			2:
				super_button.text = text
		index += 1

func replace_technique(button, t_name, t_key, technique, method):
	if PlayerStats.change_technique(technique, method, button):
		match button:
			"Skill":
				skill_button.text = t_name
				PlayerInventory.equip_to_inventory("Techniques", t_name, t_key, 0)
				PlayerInterface.update_technique(0)
			"Special":
				special_button.text = t_name
				PlayerInventory.equip_to_inventory("Techniques", t_name, t_key, 1)
				PlayerInterface.update_technique(1)
			"Super":
				super_button.text = t_name
				PlayerInventory.equip_to_inventory("Techniques", t_name, t_key, 2)
				PlayerInterface.update_technique(2)
		PlayerInterface.clear_selection()
	else:
		print("Technique Change Failed")
		PlayerInterface.clear_selection()

func display_info(button, key_name = null, input = null):
	if key_name == cur_selected:
		return
	
	if current_info != null:
		current_info.queue_free()
	
	if PlayerInventory.current_inventory["Techniques"][0] == null:
		return
	
	var slot = 0
	
	match button:
		"Skill":
			slot = 0
		"Special":
			slot = 1
		"Super":
			slot = 2
	
	if key_name == null:
		key_name = PlayerInventory.current_inventory["Techniques"][slot].keys()[0]
		input = PlayerInventory.current_inventory["Techniques"][slot][key_name]
	
	var specialist = PlayerStats.load_specialist(input["Name"])
	var info = specialist.specialist_info
	cur_selected = key_name
	
	var t_name = null
	var t_type = null
	
	match input["Technique"]:
		"skill_technique":
			t_name = "Technique 1"
			t_type = "Skill"
		"special_technique":
			t_name = "Technique 2"
			t_type = "Special"
		"super_technique":
			t_name = "Technique 3"
			t_type = "Super"
	
	if button != null:
		current_info = ItemInfo.instantiate()
		PlayerInterface.information_field.add_child(current_info)
		current_info.get_node("Name").text = key_name
		var item_type = "Technique"
		current_info.get_node("ItemType").text = item_type
		current_info.get_node("ItemTier").text = "Standard"
		current_info.get_node("ItemQuality").text = "Duration: " + str(info[t_name]["TD"])
		current_info.get_node("ItemElement").text = "Cooldown: " + str(info[t_name]["TC"])
		current_info.get_node("ItemImage").texture = load("res://asset/technique_icons/" + key_name.to_lower() + ".png")
		current_info.get_node("ItemExtra").text = ""
		current_info.get_node("EquipButton").connect("pressed", Callable(self, "replace_technique").bind(button, key_name, input, input["Name"], input["Technique"]))
		current_info.get_node("EquipButton").text = "EQUIP TECHNIQUE"
		
		var key_text = textstyle.instantiate()
		current_info.get_node("Scroll/StatBar").add_child(key_text)
		key_text.bbcode_text = info[t_name][t_type]

func display_technique(button):
	PlayerInterface.clear_selection()
	for key in PlayerInventory.equip_inventory["Techniques"].keys():
		var option = buttonstyle.instantiate()
		var input = PlayerInventory.equip_inventory["Techniques"]
		option.text = key
		option.add_theme_font_size_override("font_size", 20)
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option.connect("pressed", Callable(self, "display_info").bind(button, key, input[key]))
		option.pressed.connect(_on_Button_pressed.bind(option))
		PlayerInterface.selection_field.add_child(option)
		
		var slot = 0
	
		match button:
			"Skill":
				slot = 0
			"Special":
				slot = 1
			"Super":
				slot = 2
		
		if key == PlayerInventory.current_inventory["Techniques"][slot].keys()[0]:
			_on_Button_pressed(option)
			display_info(button, key, input[key])

func _on_skill_pressed():
	display_technique("Skill")

func _on_special_pressed():
	display_technique("Special")

func _on_super_pressed():
	display_technique("Super")
