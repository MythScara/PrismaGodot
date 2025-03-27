# SpeciesData.gd
## Resource defining all data for a selectable species.
## Create instances of this resource in the Godot editor FileSystem,
## then assign them to the SpeciesSelectionScreen's exported array.

extends Resource
class_name SpeciesData

@export var species_name: String = "Unnamed Species"

@export_group("Display")
@export var emblem_texture: Texture2D
@export var default_portrait: Texture2D
@export var background_texture: Texture2D
@export_multiline var description: String = "No description provided."
@export_multiline var lore: String = "No lore available."

@export_group("Gameplay")
# Array of Dictionaries: [{"name": "Bonus Name", "desc": "Bonus description"}]
@export var bonuses: Array[Dictionary] = []
# Array of Integers matching STAT_KEYS order in SpeciesSelectionScreen.gd
@export var stats: Array[int] = []
# Array of Strings: e.g., ["Melee", "Tank", "High HP"]
@export var playstyle_hints: Array[String] = []

@export_group("Variants")
# Dictionary: {"Variant Name": Texture2D} - e.g., {"Male": male_tex, "Female": female_tex}
@export var alternate_portraits: Dictionary = {}

# Optional: Add validation logic if needed
func _validate_stats(stat_keys_count: int) -> bool:
	if stats.size() != stat_keys_count:
		printerr("Species '%s': Stats array size (%d) does not match expected size (%d)." % [species_name, stats.size(), stat_keys_count])
		return false
	return true
