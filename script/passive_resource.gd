# passive_resource.gd
class_name PassiveResource
extends Resource

@export var passive_name: String
@export_multiline var description: String
@export var icon: Texture2D

@export_group("Trigger Logic")
# This tells the game WHEN to run the logic
@export_enum("Always_Active", "On_Damage_Taken", "On_Attack", "Low_Health") var trigger_type: String = "Always_Active"

# For simple stat boosts, we can put them here
@export_group("Stat Modifiers")
@export var stat_to_modify: String = "None" # e.g., "Ranged_DMG" 
@export var modifier_value: float = 0.0

# For complex immunity [cite: 412]
@export var immunity_tag: String = "None" # e.g., "Exhaust"
