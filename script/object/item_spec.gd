extends Button

@export var item_name = ""
@export var slot = 0
@export var type = ""

@onready var image = $Image
@onready var values = {}

var current_equip

func _ready():
	check_value(type, slot)
	PlayerStats.connect("value_change", Callable(self, "check_value"))

func _pressed():
	PlayerInterface.set_display(type, image.texture, item_name, values, slot)

func check_value(type_in, slot_in):
	if type_in == type and slot_in == slot:
		#print("Value Changed: " + type_in + " " + str(slot_in))
		current_equip = PlayerInventory.current_inventory[type][slot]
		if current_equip != null:
			item_name = current_equip.keys()[0]
			values = current_equip[item_name]
			var path = "res://asset/" + type.to_lower() + "/" + item_name.to_lower() + ".png"
			if ResourceLoader.exists(path):
				pass
			else:
				path = "res://asset/" + type.to_lower() + "/" + type.to_lower() + ".png"
				if ResourceLoader.exists(path):
					pass
				else:
					path = "res://asset/hud_icons/locked_icon.png"
			
			image.texture = load(path)
		else:
			var path = "res://asset/hud_icons/locked_icon.png"
			image.texture = load(path)
