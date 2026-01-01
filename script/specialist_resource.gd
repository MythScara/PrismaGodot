class_name SpecialistResource
extends Resource

@export_group("Identity")
@export var name: String = "Specialist Name"
@export_multiline var description: String = ""
@export var icon: Texture2D 

@export_group("Base Stats") 
@export var hp_bonus: int = 0
@export var mp_bonus: int = 0
@export var shd_bonus: int = 0
@export var stm_bonus: int = 0
@export var ag_bonus: int = 0
@export var cap_bonus: int = 0
@export var shr_bonus: int = 0
@export var str_bonus: int = 0

@export_group("Equipment")
@export var exclusive_weapon_name: String = ""
@export_enum("Gun", "Bow", "Melee") var weapon_category: String = "Gun"

@export_group("Passives")
@export var passive_1_name: String = ""
@export_multiline var passive_1_desc: String = ""
@export var passive_2_name: String = ""
@export_multiline var passive_2_desc: String = ""
@export var passive_3_name: String = ""
@export_multiline var passive_3_desc: String = ""

@export_group("Techniques")
@export var technique_1_name: String = ""
@export_multiline var technique_1_desc: String = ""
@export var technique_2_name: String = ""
@export_multiline var technique_2_desc: String = ""
@export var technique_3_name: String = ""
@export_multiline var technique_3_desc: String = ""
