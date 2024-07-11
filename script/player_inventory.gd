extends Node

var extra_inventory = {
	"Consumable": {},
	"Crafting Resource": {},
	"Quest Item": {}
}
var equip_inventory = {
	"Ranged Weapon": {},
	"Melee Weapon": {},
	"Summon": {},
	"Outfit": {},
	"Ring": {},
	"Artifact": {},
	"Soul Stone": {},
	"Chest Armor": {},
	"Pad Armor": {},
	"Belt Armor": {},
	"Body Armor": {},
	"Battle Item": {},
	"Support Item": {},
	"Battle Magic": {},
	"Support Magic": {},
	"Technique": {},
	"Aspect": {},
	"Specialist": {},
	"Vehicle": {},
	"Faction": {}
}

var current_inventory = {
	"Ranged Weapon": [null],
	"Melee Weapon": [null],
	"Summon": [null],
	"Outfit": [null],
	"Ring": [null, null, null, null, null, null, null, null, null, null],
	"Artifact": [null, null, null],
	"Soul Stone": [null],
	"Chest Armor": [null],
	"Pad Armor": [null],
	"Belt Armor": [null],
	"Body Armor": [null],
	"Battle Item": [null, null, null, null],
	"Support Item": [null, null, null, null],
	"Battle Magic": [null, null, null, null],
	"Support Magic": [null, null, null, null],
	"Technique": [null, null, null],
	"Aspect": [null, null, null],
	"Specialist": [null],
	"Vehicle": [null],
	"Faction": [null]
}

func add_to_inventory(category: String, item_name: String, item_values: Dictionary) -> void:
	if equip_inventory.has(category):
		equip_inventory[category][item_name] = item_values
		var empty = current_inventory[category].find(null)
		if empty != -1:
			current_inventory[category][empty] = {item_name: item_values}
			PlayerStats.player_stat_change(item_values, "Add")
			PlayerStats.element_stat_change(item_values, "Add")
	elif extra_inventory.has(category):
		if extra_inventory[category].has(item_name):
			if extra_inventory[category][item_name]["Amount"] == 100:
				print_debug("Value Exceeds Max Capacity: Converting To Prisma")
				var prisma = item_values["Amount"] * item_values["Value"]
				PlayerStats.currency["Prisma"] += prisma
				return
				
			extra_inventory[category][item_name]["Amount"] += item_values["Amount"]
			
			if extra_inventory[category][item_name]["Amount"] > 100:
				var prisma = (item_values["Amount"] - 100) * item_values["Value"]
				PlayerStats.currency["Prisma"] += prisma
				extra_inventory[category][item_name]["Amount"] = 100
				print_debug("Value Exceeds Max Capacity: Converting To Prisma")
		else:
			if item_values["Amount"] > 100:
				var prisma = (item_values["Amount"] - 100) * item_values["Value"]
				PlayerStats.currency["Prisma"] += prisma
				item_values["Amount"] = 100
				print_debug("Value Exceeds Max Capacity: Converting To Prisma")
			extra_inventory[category][item_name] = item_values
	else:
		print_debug("Invalid Item Category")

func remove_from_inventory(category: String, item_name: String, item_values: Dictionary = {}) -> void:
	if equip_inventory.has(category):
		equip_inventory[category].erase(item_name)
	elif extra_inventory.has(category):
		if item_values != {}:
			if item_values["Amount"] < extra_inventory[category][item_name]["Amount"]:
				extra_inventory[category][item_name]["Amount"] -= item_values["Amount"]
			elif item_values["Amount"] == extra_inventory[category][item_name]["Amount"]:
				extra_inventory[category].erase(item_name)
			else:
				print_debug("Value Exceeds Available Inventory: Transaction Cancelled")
		else:
			extra_inventory[category].erase(item_name)
	else:
		print_debug("Invalid Item Category")

func equip_to_inventory(category: String, item_name: String, item_values: Dictionary, slot = null) -> void:
	if current_inventory.has(category):
		if slot != null:
			var cur_check = current_inventory[category][slot].keys()[0]
			var cur_values = current_inventory[category][slot][cur_check]
			PlayerStats.player_stat_change(cur_values, "Sub")
			PlayerStats.element_stat_change(cur_values, "Sub")
			current_inventory[category][slot] = {item_name: item_values}
			PlayerStats.player_stat_change(item_values, "Add")
			PlayerStats.element_stat_change(item_values, "Add")
		else:
			var empty = current_inventory[category].find(null)
			if empty != -1:
				current_inventory[category][empty] = {item_name: item_values}
				PlayerStats.player_stat_change(item_values, "Add")
				PlayerStats.element_stat_change(item_values, "Add")

func unequip_from_inventory(category: String, slot = null) -> void:
	if current_inventory.has(category):
		if slot != null:
			var cur_check = current_inventory[category][slot].keys()[0]
			var cur_values = current_inventory[category][slot][cur_check]
			PlayerStats.player_stat_change(cur_values, "Sub")
			PlayerStats.element_stat_change(cur_values, "Sub")
			current_inventory[category].remove(slot)
		else:
			current_inventory[category].remove(0)
	else:
		print("Invalid Item Category")

func get_inventory(category: String):
	if equip_inventory.has(category):
		for key in equip_inventory[category].keys():
			print_debug(key)
	elif extra_inventory.has(category):
		for key in extra_inventory[category].keys():
			print_debug(key)

func get_save_data() -> Dictionary:
	return {
		"extra_inventory": extra_inventory,
		"equip_inventory": equip_inventory,
		"current_inventory": current_inventory
	}

func set_data(data: Dictionary) -> void:
	for key in data.keys():
		if key in self:
			self[key] = data[key]
