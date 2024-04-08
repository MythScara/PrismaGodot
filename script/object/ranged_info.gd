extends Control

@onready var name_label = $Name
@onready var type_label = $WeaponType
@onready var tier_label = $WeaponTier
@onready var type_image = $WeaponImage
@onready var element_label = $ElementType
@onready var quality_label = $QualityValue
@onready var firing_label = $FiringType

func _ready():
	name_label.text = ""
	type_label.text = ""
	tier_label.text = ""
	type_image.texture = null
	element_label.text = ""
	quality_label.text = ""
	firing_label.text = ""
