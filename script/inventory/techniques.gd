extends Control

@onready var skill_button = $Skill
@onready var special_button = $Special
@onready var super_button = $Super

func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_techniques"))
	update_techniques()

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
			"Special":
				special_button.text = t_name
				PlayerInventory.equip_to_inventory("Techniques", t_name, t_key, 1)
			"Super":
				super_button.text = t_name
				PlayerInventory.equip_to_inventory("Techniques", t_name, t_key, 2)
		PlayerInterface.clear_selection()
	else:
		print("Technique Change Failed")
		PlayerInterface.clear_selection()

func display_technique(button):
	PlayerInterface.clear_selection()
	for key in PlayerInventory.equip_inventory["Techniques"].keys():
		var option = Button.new()
		var input = PlayerInventory.equip_inventory["Techniques"]
		option.text = key
		option.connect("pressed", Callable(self, "replace_technique").bind(button, key, input[key], input[key]["Name"], input[key]["Technique"]))
		PlayerInterface.selection_field.add_child(option)

func _on_skill_pressed():
	display_technique("Skill")

func _on_special_pressed():
	display_technique("Special")

func _on_super_pressed():
	display_technique("Super")
