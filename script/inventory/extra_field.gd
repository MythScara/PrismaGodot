extends ColorRect

# Node references
@onready var main = $MainStats/SplitContainer
@onready var stat_container = $MainStats/SplitContainer/StatContainer
@onready var value_container = $MainStats/SplitContainer/ValueContainer

# Player stats references with type hints
var immunities: Array[String] = PlayerStats.immunities
var buffs: Array[String] = PlayerStats.buffs
var afflictions: Array[String] = PlayerStats.afflictions

# Custom styling constants
const FONT_SIZE: int = 20
const LABEL_PADDING: Vector2 = Vector2(10, 5)
const HOVER_COLOR: Color = Color(0.8, 0.8, 0.8, 1.0)

# Stat type enum for better organization
enum StatType {
    IMMUNITY,
    BUFF,
    AFFLICTION
}

# Cached descriptions for tooltips
const STAT_DESCRIPTIONS: Dictionary = {
    "poison": "Prevents damage over time from poison effects",
    "speed": "Increases movement speed by 20%",
    "burn": "Causes damage over time from fire"
}

# Called when the node enters the scene tree
func _ready() -> void:
    update_stats()
    # Connect signal with error checking
    if PlayerStats.is_connected("pause_game", Callable(self, "update_stats")):
        PlayerStats.disconnect("pause_game", Callable(self, "update_stats"))
    PlayerStats.connect("pause_game", Callable(self, "_on_game_paused"))

# Main update function
func update_stats() -> void:
    # Update local arrays
    immunities = PlayerStats.immunities
    buffs = PlayerStats.buffs
    afflictions = PlayerStats.afflictions
    
    # Clear existing children
    _clear_containers()
    
    # Update all stat categories
    _update_stat_category("Immunity", immunities, StatType.IMMUNITY)
    _update_stat_category("Buff", buffs, StatType.BUFF)
    _update_stat_category("Affliction", afflictions, StatType.AFFLICTION)

# Clear all children from containers
func _clear_containers() -> void:
    for child in stat_container.get_children():
        child.queue_free()
    for child in value_container.get_children():
        child.queue_free()

# Update a specific stat category
func _update_stat_category(category_name: String, stat_array: Array[String], type: StatType) -> void:
    for stat in stat_array:
        _create_stat_label(category_name, stat, type)

# Create and configure stat labels
func _create_stat_label(key: String, value: String, type: StatType) -> void:
    # Create key label
    var label_key := Label.new()
    label_key.text = key
    label_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    _configure_label(label_key, type)
    
    # Create value label
    var label_value := Label.new()
    label_value.text = value
    label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    _configure_label(label_value, type)
    
    # Add tooltip if description exists
    if STAT_DESCRIPTIONS.has(value.to_lower()):
        label_value.tooltip_text = STAT_DESCRIPTIONS[value.to_lower()]
    
    # Add labels to containers
    stat_container.add_child(label_key)
    value_container.add_child(label_value)

# Configure label appearance and behavior
func _configure_label(label: Label, type: StatType) -> void:
    label.add_theme_font_size_override("font_size", FONT_SIZE)
    label.custom_minimum_size = Vector2(0, FONT_SIZE + LABEL_PADDING.y * 2)
    
    # Apply type-specific coloring
    match type:
        StatType.IMMUNITY:
            label.add_theme_color_override("font_color", Color.GREEN)
        StatType.BUFF:
            label.add_theme_color_override("font_color", Color.BLUE)
        StatType.AFFLICTION:
            label.add_theme_color_override("font_color", Color.RED)
    
    # Add hover effect
    label.mouse_filter = Control.MOUSE_FILTER_PASS
    label.connect("mouse_entered", Callable(self, "_on_label_hover").bind(label, true))
    label.connect("mouse_exited", Callable(self, "_on_label_hover").bind(label, false))

# Handle game pause signal
func _on_game_paused() -> void:
    update_stats()

# Hover effect handler
func _on_label_hover(label: Label, is_hovering: bool) -> void:
    if is_hovering:
        label.modulate = HOVER_COLOR
    else:
        label.modulate = Color.WHITE

# Utility function to add a new stat dynamically
func add_stat(stat_type: StatType, stat_value: String) -> void:
    match stat_type:
        StatType.IMMUNITY:
            if not immunities.has(stat_value):
                immunities.append(stat_value)
        StatType.BUFF:
            if not buffs.has(stat_value):
                buffs.append(stat_value)
        StatType.AFFLICTION:
            if not afflictions.has(stat_value):
                afflictions.append(stat_value)
    update_stats()
