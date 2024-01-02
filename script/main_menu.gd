extends Control

@export var start_scene : PackedScene
@export var settings_scene : PackedScene

func _on_start_game_button_pressed():
	if start_scene:
		get_tree().change_scene_to_packed(start_scene)
	else:
		print("No Scene Set")

func _on_settings_button_pressed():
	if settings_scene:
		get_tree().change_scene_to_packed(settings_scene)
	else:
		print("No Scene Set")

func _on_exit_game_button_pressed():
	get_tree().quit()
