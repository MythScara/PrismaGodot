extends Control

@onready var ranged_weapon = $RangedWeapon/Image
@onready var melee_weapon = $MeleeWeapon/Image
@onready var soul_stone = $SoulStone/Image
@onready var summon = $Summon/Image
@onready var vehicle = $Vehicle/Image

# Called when the node enters the scene tree for the first time.
func _ready():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")

func image_set(type):
	if type != null and PlayerInventory.current_inventory[type][0] != null:
		var image = PlayerInventory.current_inventory[type][0]
		print(image)
	
	match type:
		"Ranged Weapon":
			ranged_weapon.texture = load("res://asset/weapon_icons/assault rifle.png")
		"Melee Weapon":
			melee_weapon.texture = load("res://asset/weapon_icons/long sword.png")
