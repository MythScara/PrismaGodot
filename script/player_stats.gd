extends Node

var species = null
var stats = {}
var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}

func set_stats(new_stats : Dictionary):
	stats = new_stats

func set_bonuses(new_bonuses : Dictionary):
	bonuses = new_bonuses

func get_stats() -> Dictionary:
	return stats

func get_bonuses() -> Dictionary:
	return bonuses
