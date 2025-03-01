extends Control

# Exported variables for easy tweaking in the editor
@export var continue_screen: PackedScene
@export var default_sprite: Texture2D  # Default emblem if none selected
@export var stat_colors: Dictionary = {
	"higher": Color(0, 1, 0, 1),  # Green for buffs
	"lower": Color(1, 0, 0, 1),   # Red for nerfs
	"neutral": Color(1, 1, 1, 1)  # White for unchanged
}

# Constants for stats and base values
const STAT_KEYS: Array = ["HP", "MP", "SHD", "STM", "ATK", "DEF", "MGA", "MGD", "SHR", "STR", "AG", "CAP"]
const BASE_STATS: Array = [40000, 40000, 8000, 8000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000]
const SPECIES_BUTTONS: Array = ["Human", "Meka", "Daemon", "Sylph", "Kaiju"]

# Node references
@onready var description: RichTextLabel = $SpeciesDescription
@onready var bonuses: Array[RichTextLabel] = [$SpeciesBonus1, $SpeciesBonus2, $SpeciesBonus3]
@onready var stat_grid: GridContainer = $SpeciesStatGrid
@onready var species_buttons: Dictionary = {
	"Human": $HumanButton, "Meka": $MekaButton, "Daemon": $DaemonButton,
	"Sylph": $SylphButton, "Kaiju": $KaijuButton
}
@onready var continue_button: Button = $ContinueButton
@onready var emblem_sprite: Sprite2D = $EmblemSprite

# State tracking
var selected_species: String = ""
var is_initialized: bool = false

func _ready() -> void:
	# Initialize default state
	_setup_buttons()
	_update_stats_grid(BASE_STATS)
	emblem_sprite.texture = default_sprite
	emblem_sprite.visible = true
	continue_button.disabled = true
	is_initialized = true

# Centralized button setup with signal connections
func _setup_buttons() -> void:
	for species in SPECIES_BUTTONS:
		var button: Button = species_buttons[species]
		button.pressed.connect(_on_species_button_pressed.bind(species))

# Unified species button handler
func _on_species_button_pressed(species: String) -> void:
	_set_active_button(species_buttons[species])
	_update_information(species)

# Update UI and player stats based on selected species
func _update_information(species: String) -> void:
	if not GameInfo.species_info.has(species):
		push_error("Species %s not found in GameInfo!" % species)
		return
	
	var species_data: Dictionary = GameInfo.species_info[species]
	
	# Update description and bonuses
	description.bbcode_text = species_data["Description"]
	for i in range(bonuses.size()):
		bonuses[i].bbcode_text = species_data["Bonus%d" % (i + 1)].values()[0]
	
	# Update emblem sprite with error handling
	var emblem_path: String = "res://asset/emblems/%s_emblem.png" % species.to_lower()
	if ResourceLoader.exists(emblem_path):
		emblem_sprite.texture = load(emblem_path)
	else:
		emblem_sprite.texture = default_sprite
		push_warning("Emblem for %s not found, using default!" % species)
	
	# Update stats grid
	_update_stats_grid(species_data["Stats"])
	
	# Set player stats and bonuses
	var stats_dict: Dictionary = _array_to_dict(species_data["Stats"])
	PlayerStats.set_stats(stats_dict)
	PlayerStats.species = species
	
	var bonuses_dict: Dictionary = {
		"Bonus 1": species_data["Bonus1"].keys()[0],
		"Bonus 2": species_data["Bonus2"].keys()[0],
		"Bonus 3": species_data["Bonus3"].keys()[0]
	}
	PlayerStats.set_bonuses(bonuses_dict)
	
	# Trigger animation feedback
	_play_selection_feedback()

# Convert stat array to dictionary
func _array_to_dict(stats: Array) -> Dictionary:
	var dict: Dictionary = {}
	for i in range(stats.size()):
		dict[STAT_KEYS[i]] = stats[i]
	return dict

# Update the stats grid with dynamic coloring
func _update_stats_grid(stats: Array) -> void:
	stat_grid.columns = 4  # Ensure grid layout
	
	# Clear existing children efficiently
	for child in stat_grid.get_children():
		child.queue_free()
	
	# Populate with new stats
	for i in range(stats.size()):
		var stat_label: Label = Label.new()
		stat_label.text = STAT_KEYS[i]
		stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var value_label: Label = Label.new()
		value_label.text = str(stats[i])
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		# Dynamic color based on base stats
		var base: int = BASE_STATS[i]
		value_label.modulate = _get_stat_color(stats[i], base)
		
		stat_grid.add_child(stat_label)
		stat_grid.add_child(value_label)

# Determine stat color based on comparison
func _get_stat_color(value: int, base: int) -> Color:
	if value > base:
		return stat_colors["higher"]
	elif value < base:
		return stat_colors["lower"]
	return stat_colors["neutral"]

# Manage active button state
func _set_active_button(new_button: Button) -> void:
	if not is_initialized:
		return
	
	continue_button.disabled = false
	if selected_species and species_buttons[selected_species] != new_button:
		species_buttons[selected_species].set_pressed_no_signal(false)
	
	selected_species = species_buttons.find_key(new_button)
	new_button.set_pressed_no_signal(true)

# Continue to next scene
func _on_continue_button_pressed() -> void:
	if continue_screen and PlayerStats.species:
		get_tree().change_scene_to_packed(continue_screen)
	else:
		push_error("Continue failed: No scene or species set!")

# New Feature: Visual feedback on selection
func _play_selection_feedback() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(emblem_sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(emblem_sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Flash the continue button
	continue_button.modulate = Color(1, 1, 0, 1)  # Yellow flash
	await get_tree().create_timer(0.2).timeout
	continue_button.modulate = Color(1, 1, 1, 1)  # Reset

# New Feature: Reset to default state
func _reset_to_default() -> void:
	selected_species = ""
	continue_button.disabled = true
	_update_stats_grid(BASE_STATS)
	emblem_sprite.texture = default_sprite
	description.bbcode_text = "[center]Select a species to begin[/center]"
	for bonus in bonuses:
		bonus.bbcode_text = ""
	for button in species_buttons.values():
		button.set_pressed_no_signal(false)

# Optional: Connect reset to a signal or button (e.g., BackButton)
# func _on_reset_button_pressed() -> void:
# 	_reset_to_default()
