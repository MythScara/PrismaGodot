extends Node

var species = null
var stats = {"HP": 40000, "MP": 40000, "SHD": 8000, "STM": 8000, "ATK": 4000, "DEF": 4000, "MGA": 4000, "MGD": 4000, "SHR": 4000, "STR": 4000, "AG": 4000, "CAP": 4000}
var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}
var elements = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}
var specialist = null

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
