# technique_resource.gd
class_name TechniqueResource
extends Resource

@export_group("Display")
@export var technique_name: String = "Technique Name"
@export_multiline var description: String = "Description of what it does."
@export var icon: Texture2D

@export_group("Mechanics")
@export var cooldown: float = 10.0
@export var duration: float = 5.0
@export var is_single_use: bool = false # For (SU) types [cite: 389]
@export_enum("Tier 1", "Tier 2", "Tier 3") var tier: String = "Tier 1"

# We will use this later for the code logic
@export var script_logic: Script
