extends Button

@export var item_name = ""
@export var slot = 0
@export var type = ""

@onready var image = $Image
@onready var values = {}

func _pressed():
	PlayerInterface.set_display(type, image, item_name, values, slot)