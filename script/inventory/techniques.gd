extends Control

@onready var skill_button = $Skill
@onready var special_button = $Special
@onready var super_button = $Super
@onready var selection = $SelectionField
@onready var information = $InformationField

func replace_technique(button, technique, method):
	match button:
		"Skill":
			skill_button.text = technique
			PlayerStats.change_technique(technique, method)
		"Special":
			special_button.text = technique
			PlayerStats.change_technique(technique, method)
		"Super":
			super_button.text = technique
			PlayerStats.change_technique(technique, method)

func display_technique(button):
	clear_selection()
	for key in PlayerInventory.equip_inventory["Techniques"].keys():
		var option = Button.new()
		var input = PlayerInventory.equip_inventory["Techniques"]
		option.text = input[key]["Name"]
		option.connect("pressed", Callable(self, "replace_technique").bind(button, input[key]["Name"], input[key]["Technique"]))
		selection.add_child(option)

func _on_skill_pressed():
	display_technique("Skill")

func _on_special_pressed():
	display_technique("Special")

func _on_super_pressed():
	display_technique("Super")

func clear_selection():
	if selection.get_child_count() > 0:
		for child in selection.get_children():
			child.queue_free()
		for child in information.get_children():
			child.queue_free()
