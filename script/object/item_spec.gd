extends Button

@export var item_name = ""
@export var slot = 0
@export var type = ""

@onready var image = $Image
@onready var values = {}

var current_equip

func _ready():
	PlayerStats.connect("pause_game", Callable(self, "check_value"))

func _pressed():
	PlayerInterface.set_display(type, image.texture, item_name, values, slot)

func check_value():
	current_equip = PlayerInventory.current_inventory[type][slot]
	print(current_equip)
	if current_equip != null:
		item_name = current_equip.keys()[0]
		values = current_equip[item_name]
		var path = "res://asset/" + type.to_lower() + "_icons/" + item_name.to_lower() + ".png"
		if ResourceLoader.exists(path):
			pass
		else:
			path = "res://asset/hud_icons/locked_icon.png"
		
		image.texture = load(path)
