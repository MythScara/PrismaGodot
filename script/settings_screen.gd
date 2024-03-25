extends Control

func _on_exit_button_pressed():
	get_tree().quit()

func _on_save_button_pressed():
	GameManager.save_game()
