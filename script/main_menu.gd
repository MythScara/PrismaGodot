extends Control

@export var start_scene : PackedScene
@export var settings_scene : PackedScene
@export var continue_scene : PackedScene
@export var credits_scene : PackedScene

@onready var text_1 = $Background
@onready var text_2 = $BackgroundExtra
var tween: Tween

func _ready():
	tween = get_tree().create_tween()
	tween.tween_property(text_1, "modulate", Color(1,0,0), 5)
	tween.tween_property(text_2, "modulate", Color(1,1,1), 5)
	tween.set_loops()
	tween.play()
	$ContinueGameButton.disabled = true
	$DeleteGameButton.disabled = true
	checkfile()

func _process(_delta):
	if tween.loop_finished:
		var temp = text_1.modulate
		text_1.modulate = text_2.modulate
		text_2.modulate = temp

func _on_start_game_button_pressed():
	if start_scene:
		tween.kill()
		get_tree().change_scene_to_packed(start_scene)
	else:
		print_debug("No Scene Set")

func _on_settings_button_pressed():
	if settings_scene:
		tween.kill()
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
		tween.kill()
		get_tree().change_scene_to_packed(continue_scene)
	else:
		print_debug("No Scene Set")

func _on_delete_save_data_pressed():
	GameManager.delete_save()
	checkfile()

func _on_credits_button_pressed():
	if credits_scene:
		tween.kill()
		get_tree().change_scene_to_packed(credits_scene)
	else:
		print_debug("No Scene Set")
