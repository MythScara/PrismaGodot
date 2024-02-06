extends Node

var species = null
var stats = {"HP": 40000, "MP": 40000, "SHD": 8000, "STM": 8000, "ATK": 4000, "DEF": 4000, "MGA": 4000, "MGD": 4000, "SHR": 4000, "STR": 4000, "AG": 4000, "CAP": 4000}
var bonuses = {"Bonus 1": "", "Bonus 2": "", "Bonus 3": ""}
var elements = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}
var specialist = null
var immunities = []
var buffs = []
var passives = {"Mind": null, "Soul": null, "Heart": null}
var techniques = {"Skill": null, "Special": null, "Super": null}
var ranged_stats = {
	"DMG": 0, "RNG": 0, "MOB": 0, "HND": 0, "AC": 0, "RLD": 0, "FR": 0, "MAG": 0, "DUR": 0, "WCP": 0,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": null, "Tier": null, "Element": null}
var melee_stats = {
	"POW": 0, "RCH": 0, "MOB": 0, "HND": 0, "BLK": 0, "CHG": 0, "ASP": 0, "STE": 0, "DUR": 0, "WCP": 0,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": null, "Tier": null, "Element": null}

signal activate_specialist(s_type)

func set_specialist(specialist_name):
	var specialist_class = load("res://script/specialists/" + specialist_name.to_lower() + ".gd").new()
	if specialist_class:
		passives["Mind"] = specialist_class.mind_passive
		passives["Soul"] = specialist_class.soul_passive
		passives["Heart"] = specialist_class.heart_passive
		techniques["Skill"] = specialist_class.skill_technique
		techniques["Special"] = specialist_class.special_technique
		techniques["Super"] = specialist_class.super_technique

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

func add_timer(timer : Timer) -> void:
	var cur_scene = get_tree().current_scene
	if cur_scene:
		cur_scene.add_child(timer)
	else:
		print_debug("No scene found")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			if techniques["Skill"] != null:
				techniques["Skill"].call(true)
		if event.pressed and event.keycode == KEY_E:
			if techniques["Special"] != null:
				techniques["Special"].call(true)
		if event.pressed and event.keycode == KEY_G:
			if techniques["Super"] != null:
				techniques["Super"].call(true)
		if event.pressed and event.keycode == KEY_I:
			print_debug(species)
			print_debug(stats)
			print_debug(bonuses)
			print_debug(elements)
			print_debug(specialist)
			print_debug(immunities)
			print_debug(passives)
			print_debug(techniques)
			print_debug(ranged_stats)
			print_debug(melee_stats)
