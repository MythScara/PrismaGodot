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

func replace_field(type, text, values):
	if PlayerInventory.current_inventory[type][0].keys()[0] != text:
		PlayerInventory.current_inventory[type][0] = {text: values}
		image_set(type)
		match type:
			"Ranged Weapon":
				PlayerStats.weapon_stat_change(values, "Ranged", "Mod")
			"Melee Weapon":
				PlayerStats.weapon_stat_change(values, "Melee", "Mod")
			
	else:
		print("This Item is Already Equipped")

func display_field(button):
	PlayerInterface.clear_selection()
	for key in PlayerInventory.equip_inventory[button].keys():
		var option = Button.new()
		var input = PlayerInventory.equip_inventory[button]
		option.text = key
		option.add_theme_font_size_override("font_size", 20)
		option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option.connect("pressed", Callable(self, "replace_field").bind(button, key, input[key]))
		PlayerInterface.selection_field.add_child(option)

func update_values():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")
	image_set("Soul Stone")
	image_set("Summon")
	image_set("Vehicle")

func _on_ranged_weapon_pressed():
	display_field("Ranged Weapon")

func _on_melee_weapon_pressed():
	display_field("Melee Weapon")

func _on_soul_stone_pressed():
	display_field("Soul Stone")

func _on_summon_pressed():
	display_field("Summon")

func _on_vehicle_pressed():
	display_field("Vehicle")
