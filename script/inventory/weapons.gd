extends Control

@onready var ranged_weapon = $RangedWeapon/Image
@onready var melee_weapon = $MeleeWeapon/Image
@onready var soul_stone = $SoulStone/Image
@onready var summon = $Summon/Image
@onready var vehicle = $Vehicle/Image

var RangedInfo = preload("res://object/ranged_info.tscn")
var current_info = null

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
	var original = PlayerInventory.current_inventory[type][0].keys()[0]
	var cur_values = PlayerInventory.current_inventory[type][0][original]
	
	if PlayerInventory.current_inventory[type][0].keys()[0] != text:
		match type:
			"Ranged Weapon":
				PlayerStats.weapon_stat_change(cur_values, "Ranged", "Sub")
			"Melee Weapon":
				PlayerStats.weapon_stat_change(cur_values, "Melee", "Sub")
			"Soul Stone":
				PlayerStats.player_stat_change(cur_values, "Sub")
				PlayerStats.element_stat_change(cur_values, "Sub")
			"Vehicle":
				pass
			"Summon":
				pass
		
		PlayerInventory.current_inventory[type][0] = {text: values}
		image_set(type)
		match type:
			"Ranged Weapon":
				PlayerStats.weapon_stat_change(values, "Ranged", "Add")
			"Melee Weapon":
				PlayerStats.weapon_stat_change(values, "Melee", "Add")
			"Soul Stone":
				pass
			"Vehicle":
				pass
			"Summon":
				pass
		
		PlayerInterface.clear_selection()
	else:
		print("This Item is Already Equipped")
		PlayerInterface.clear_selection()

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

func display_info(button):
	if current_info != null:
		current_info.queue_free()
		
	match button:
		"Ranged Weapon":
			current_info = RangedInfo.instantiate()
			PlayerInterface.information_field.add_child(current_info)
			var item = PlayerInventory.current_inventory["Ranged Weapon"][0].keys()[0]
			current_info.get_node("Name").text = item
			var item_type = PlayerInventory.current_inventory["Ranged Weapon"][0][item]["Type"]
			current_info.get_node("WeaponType").text = item_type
			current_info.get_node("WeaponTier").text = PlayerInventory.current_inventory["Ranged Weapon"][0][item]["Tier"]
			current_info.get_node("QualityValue").text = "Quality : " + str(PlayerInventory.current_inventory["Ranged Weapon"][0][item]["Quality"])
			current_info.get_node("ElementType").text = PlayerInventory.current_inventory["Ranged Weapon"][0][item]["Element"]
			current_info.get_node("WeaponImage").texture = load("res://asset/weapon_icons/" + item_type.to_lower() + ".png")
			current_info.get_node("FiringType").text = GameInfo.firing_type(item_type)

func update_values():
	image_set("Ranged Weapon")
	image_set("Melee Weapon")
	image_set("Soul Stone")
	image_set("Summon")
	image_set("Vehicle")

func _on_ranged_weapon_pressed():
	display_field("Ranged Weapon")
	display_info("Ranged Weapon")

func _on_melee_weapon_pressed():
	display_field("Melee Weapon")

func _on_soul_stone_pressed():
	display_field("Soul Stone")

func _on_summon_pressed():
	display_field("Summon")

func _on_vehicle_pressed():
	display_field("Vehicle")
