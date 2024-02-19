extends Control

@export var start_scene : PackedScene
@export var settings_scene : PackedScene
@export var continue_scene : PackedScene
@export var credits_scene : PackedScene

func _ready():
	$ContinueGameButton.disabled = true
	$DeleteGameButton.disabled = true
	checkfile()

func _on_start_game_button_pressed():
	if start_scene:
		get_tree().change_scene_to_packed(start_scene)
	else:
		print_debug("No Scene Set")

func _on_settings_button_pressed():
	if settings_scene:
		get_tree().change_scene_to_packed(settings_scene)
	else:
		print_debug("No Scene Set")

func _on_exit_game_button_pressed():
	get_tree().quit()

func checkfile():
	if GameManager.save_exists():
		$ContinueGameButton.disabled = false
		$DeleteGameButton.disabled = false
	else:
		$ContinueGameButton.disabled = true
		$DeleteGameButton.disabled = true

func _on_continue_game_button_pressed():
	if continue_scene:
		GameManager.load_game()
		get_tree().change_scene_to_packed(continue_scene)
	else:
		print_debug("No Scene Set")


func _on_delete_save_data_pressed():
	GameManager.delete_save()
	checkfile()


func _on_credits_button_pressed():
	if credits_scene:
		get_tree().change_scene_to_packed(credits_scene)
	else:
		print_debug("No Scene Set")
