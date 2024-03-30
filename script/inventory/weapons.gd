extends Control

@onready var ranged_weapon = $RangedWeapon/Image
@onready var melee_weapon = $MeleeWeapon/Image
@onready var soul_stone = $SoulStone/Image
@onready var summon = $Summon/Image
@onready var vehicle = $Vehicle/Image

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.connect("pause_game", Callable(self, "update_values"))

func image_set(type):
	if type != null and PlayerInventory.current_inventory[type][0] != null:
		var image_id = PlayerInventory.current_inventory[type][0].keys()[0]
		var image_dict = PlayerInventory.current_inventory[type][0][image_id]
		var image = image_dict["Type"]
	
		match type:
			"Ranged Weapon":
				ranged_weapon.texture = load("res://asset/weapon_icons/" + image.to_lower() + ".png")
			"Melee Weapon":
				melee_weapon.texture = load("res://asset/weapon_icons/" + image.to_lower() + ".png")
			"Vehicle":
				vehicle.texture = load("res://asset/vehicle/" + image.to_lower() + ".png")
			"Summon":
				summon.texture = load("res://asset/summon/" + image.to_lower() + ".png")
			"Soul Stone":
				soul_stone.texture = load("res://asset/soul_stone/" + image.to_lower() + ".png")

func update_values():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")
	image_set("Soul Stone")
	image_set("Summon")
	image_set("Vehicle")

func _on_ranged_weapon_pressed():
	pass

func _on_melee_weapon_pressed():
	pass # Replace with function body.

func _on_soul_stone_pressed():
	pass # Replace with function body.

func _on_summon_pressed():
	pass # Replace with function body.

func _on_vehicle_pressed():
	pass # Replace with function body.
