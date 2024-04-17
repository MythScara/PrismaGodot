extends Control

@onready var name_label = $Name
@onready var type_label = $ItemType
@onready var tier_label = $ItemTier
@onready var type_image = $ItemImage
@onready var element_label = $ItemElement
@onready var quality_label = $ItemQuality
@onready var firing_label = $ItemExtra
@onready var equip = $EquipButton

func _ready():
	name_label.text = ""
	type_label.text = ""
	tier_label.text = ""
	type_image.texture = null
	element_label.text = ""
	quality_label.text = ""
	firing_label.text = ""
