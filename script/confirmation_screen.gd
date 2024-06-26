extends Control

func _ready():
	pass # Replace with function body.

func _on_start_adventure_button_pressed():
	if PlayerStats.ranged_stats["Tier"] == null:
		await PlayerStats.randomize_weapon("Ranged")
		await PlayerStats.randomize_weapon("Melee")
		PlayerStats.emit_signal("activate_specialist", PlayerStats.specialist)
	else:
		PlayerStats.emit_signal("activate_specialist", PlayerStats.specialist)
	PlayerInterface.initial_setup()
	GameManager.save_game()
	PlayerStats.player_active = true
	PlayerInterface.swap_active("None")
	get_tree().change_scene_to_file("res://scene/test_level_scene.tscn")

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
