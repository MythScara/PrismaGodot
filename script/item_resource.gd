# item_resource.gd
class_name ItemResource
extends Resource

@export_group("Identity")
@export var item_name: String = "Item Name"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Classification")
@export_enum("Outfit", "Weapon", "Armor_Belt", "Armor_Chest", "Armor_Pads", "Armor_Body", "Ring", "Artifact", "Soul_Stone") var item_category: String = "Outfit"
@export var tier: int = 1 # Iron, Copper, etc.

@export_group("Stats")
# These apply to Armor, Outfits, Rings, etc.
@export var hp_bonus: int = 0
@export var mp_bonus: int = 0
@export var shd_bonus: int = 0
@export var stm_bonus: int = 0
@export var ag_bonus: int = 0
@export var cap_bonus: int = 0
@export var shr_bonus: int = 0
@export var str_bonus: int = 0
# You can add Elemental Stats here too if needed for Soul Stones
