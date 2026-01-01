# specialist_resource.gd
class_name SpecialistResource
extends Resource

@export_group("Identity")
@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export_enum("Ranged", "Melee") var weapon_type: String = "Ranged"

@export_group("Passives")
@export var passive_1: PassiveResource
@export var passive_2: PassiveResource
@export var passive_3: PassiveResource

@export_group("Default Techniques")
@export var technique_1: TechniqueResource
@export var technique_2: TechniqueResource
@export var technique_3: TechniqueResource

@export_group("Progression")
# Rank 0-10 Rewards. 
# This array can hold ItemResources, TechniqueResources, etc.
@export var rank_rewards: Array[Resource]
