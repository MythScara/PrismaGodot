extends Control

@onready var ranged_weapon = $RangedWeapon/Image
@onready var melee_weapon = $MeleeWeapon/Image
@onready var soul_stone = $SoulStone/Image
@onready var summon = $Summon/Image
@onready var vehicle = $Vehicle/Image

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func image_set(type):
	if type != null and PlayerInventory.current_inventory[type].keys().size() > 0:
		var image = PlayerInventory.current_inventory[type].keys()[0]
		print(image)
	
	match type:
		"Ranged Weapon":
			ranged_weapon.texture = load("res://asset/weapon_icons/assault rifle.png")
		"Melee Weapon":
			melee_weapon.texture = load("res://asset/weapon_icons/long sword.png")
