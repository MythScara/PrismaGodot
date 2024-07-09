extends Control

@onready var name_label = $Name
@onready var type_label = $ItemType
@onready var tier_label = $ItemTier
@onready var type_image = $ItemImage
@onready var element_label = $ItemElement
@onready var quality_label = $ItemQuality
@onready var extra_label = $ItemExtra
@onready var equip = $EquipButton
@onready var description = $Scroll/StatBar/ItemDescription

func _ready():
	name_label.text = ""
	type_label.text = ""
	tier_label.text = ""
	type_image.texture = null
	element_label.text = ""
	quality_label.text = ""
	extra_label.text = ""
	description.text = ""
