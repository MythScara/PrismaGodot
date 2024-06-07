extends Button

@export var item_name = ""
@export var slot = 0
@export var type = ""

@onready var image = $Image

func _ready():
	pass

func _pressed():
	PlayerInterface.set_display(type, slot)
