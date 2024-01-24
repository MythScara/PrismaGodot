extends Control

func _ready():
	pass # Replace with function body.

func _on_start_adventure_button_pressed():
	print_debug(PlayerStats.get_stats())
	print_debug(PlayerStats.get_bonuses())
	print_debug(PlayerStats.get_elements())

func _on_return_button_pressed():
	pass # Replace with function body.
