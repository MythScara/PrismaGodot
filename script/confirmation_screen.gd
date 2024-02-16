extends Control

func _ready():
	pass # Replace with function body.

func _on_start_adventure_button_pressed():
	GameManager.save_game()

func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
