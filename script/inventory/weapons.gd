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

func update_values():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")

func _on_ranged_weapon_pressed():
	pass
