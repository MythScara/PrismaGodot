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
	"Techniques": {},
	"Specialist": {},
	"Vehicle": {}
}

var current_inventory = {
	"Ranged Weapon": [],
	"Melee Weapon": [],
	"Summon": [],
	"Outfit": [],
	"Ring": [],
	"Artifact": [],
	"Soul Stone": [],
	"Chest Armor": [],
	"Pad Armor": [],
	"Belt Armor": [],
	"Body Armor": [],
	"Battle Item": [],
	"Support Item": [],
	"Battle Magic": [],
	"Support Magic": [],
	"Techniques": [],
	"Specialist": [],
	"Vehicle": []
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func add_to_inventory(category: String, item_name: String, item_values: Dictionary) -> void:
	print("Added")
	if equip_inventory.has(category):
		equip_inventory[category][item_name] = item_values
		if current_inventory[category].size() < GameInfo.slot_size[category]:
			current_inventory[category].append({item_name: item_values})
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
	
	get_inventory(category)

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
			current_inventory[category][slot] = {item_name: item_values}
		else:
			if current_inventory[category].size() < GameInfo.slot_size[category]:
				current_inventory[category].append({item_name: item_values})

func unequip_from_inventory(category: String, item_name: String, item_values: Dictionary, slot = null) -> void:
	if current_inventory.has(category):
		if slot != null:
			current_inventory[category].remove(slot)
		else:
			current_inventory[category].remove(0)
	else:
		print("Invalide Item Category")

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
