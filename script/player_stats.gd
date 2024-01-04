extends Node

var species = null
var stats = {}
var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}
var elements = {}

func set_stats(new_stats : Dictionary):
	stats = new_stats

func set_bonuses(new_bonuses : Dictionary):
	bonuses = new_bonuses

func set_elements(new_elements : Dictionary):
	elements = new_elements

func get_stats() -> Dictionary:
	return stats

func get_bonuses() -> Dictionary:
	return bonuses

func get_elements() -> Dictionary:
	return elements
