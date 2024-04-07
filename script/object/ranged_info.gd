extends Control

@onready var name_label = $Name
@onready var type_label = $WeaponType
@onready var tier_label = $WeaponTier
@onready var type_image = $WeaponImage
@onready var element_label = $ElementType
@onready var quality_label = $QualityValue
@onready var firing_label = $FiringType

func _ready():
	name_label.text = "Default Weapon Label"
