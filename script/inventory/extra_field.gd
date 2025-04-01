# StatDisplayUI.gd
extends ColorRect

# --- Exports ---
@export_group("Node References")
# Assign the path to the VBoxContainer that will hold the stat labels
@export var stats_list_container_path: NodePath = ^""

@export_group("Styling")
# Allow overriding the font size in the editor
@export var font_size_override: int = 16
# Color tint applied when hovering over a stat label
@export var hover_modulate_color: Color = Color(0.8, 0.8, 0.8, 1.0)
# Colors for different stat types (Consider using a Theme resource for larger projects)
@export var immunity_color: Color = Color.MEDIUM_SEA_GREEN
@export var buff_color: Color = Color.CORNFLOWER_BLUE
@export var affliction_color: Color = Color.TOMATO

# --- Constants ---
# Tooltip Data (Consider moving to an external resource/data singleton for larger games)
const STAT_DESCRIPTIONS: Dictionary = {
    "poison": "Prevents damage over time from poison effects.",
    "speed": "Increases movement speed by 20%.",
    "burn": "Causes damage over time from fire.",
    # Add other descriptions here...
}

# --- Node Cache ---
@onready var stats_list_container: VBoxContainer = get_node_or_null(stats_list_container_path)

#-----------------------------------------------------------------------------#
# Godot Lifecycle Functions                                                   #
#-----------------------------------------------------------------------------#

func _ready() -> void:
    # Validate node path is assigned and points to the correct type
    if not stats_list_container:
        printerr("Stat Display UI Error: stats_list_container node not found or path not set.")
        printerr("Please assign the NodePath in the inspector for: ", name)
        return
    elif not stats_list_container is VBoxContainer:
        printerr("Stat Display UI Error: Node at stats_list_container_path is not a VBoxContainer.")
        return

    # Connect to PlayerStats signal (assuming it emits 'stats_changed')
    # IMPORTANT: Ensure PlayerStats actually emits this signal when stats are modified.
    if PlayerStats.has_signal("stats_changed"):
         # Check if already connected (safety measure)
        if not PlayerStats.is_connected("stats_changed", _on_player_stats_changed):
            # Using CONNECT_PERSIST ensures connection survives scene saves/loads if needed
            var err = PlayerStats.connect("stats_changed", _on_player_stats_changed, CONNECT_PERSIST)
            if err != OK:
                printerr("Failed to connect to PlayerStats.stats_changed signal. Error code: ", err)
    else:
        # Fallback or Warning: If no central signal exists, updates might not trigger automatically.
        # You might need to manually call _update_display() or connect to other signals.
        print_rich("[color=orange]Warning:[/color] PlayerStats singleton does not have a 'stats_changed' signal. Stat display may not update automatically.")
        # Alternatively, you could revert to connecting to 'pause_game' or another signal if that's intended.
        # PlayerStats.connect("pause_game", _on_player_stats_changed) # Example fallback

    # Initial population of the display
    _update_display()

func _exit_tree() -> void:
    # Disconnect signals when the node is removed from the tree to prevent errors
    if PlayerStats.has_signal("stats_changed"):
        if PlayerStats.is_connected("stats_changed", _on_player_stats_changed):
            PlayerStats.disconnect("stats_changed", _on_player_stats_changed)
    # Disconnect any other signals connected in _ready (like 'pause_game' if used as fallback)
    # if PlayerStats.is_connected("pause_game", _on_player_stats_changed):
        # PlayerStats.disconnect("pause_game", _on_player_stats_changed)

#-----------------------------------------------------------------------------#
# Signal Handlers                                                             #
#-----------------------------------------------------------------------------#

# Called when PlayerStats indicates that data has changed
func _on_player_stats_changed() -> void:
    _update_display()

# --- Internal Functions ---

# Clears and redraws the entire list of stats
func _update_display() -> void:
    if not stats_list_container: return # Should have been caught in _ready, but good practice

    # 1. Clear previous entries
    for child in stats_list_container.get_children():
        child.queue_free()

    # 2. Add Headers and Stat Labels directly from PlayerStats
    # --- Immunities ---
    _add_category_header("Immunities")
    if PlayerStats.immunities.is_empty():
        _add_placeholder_label("(None)")
    else:
        for immunity in PlayerStats.immunities:
            _add_stat_label(immunity, immunity_color)

    # --- Buffs ---
    _add_category_header("Buffs")
    if PlayerStats.buffs.is_empty():
        _add_placeholder_label("(None)")
    else:
        for buff in PlayerStats.buffs:
            _add_stat_label(buff, buff_color)

    # --- Afflictions ---
    _add_category_header("Afflictions")
    if PlayerStats.afflictions.is_empty():
        _add_placeholder_label("(None)")
    else:
        for affliction in PlayerStats.afflictions:
            _add_stat_label(affliction, affliction_color)


# Helper to create and add a category header label
func _add_category_header(text: String) -> void:
    var header := Label.new()
    header.name = text + "Header" # Give it a somewhat unique name for debugging
    header.text = text + ":"
    # Optional: Add specific styling for headers (e.g., bold, slightly larger font)
    # You might want to create a theme variation for headers.
    header.add_theme_font_size_override("font_size", font_size_override + 1) # Slightly larger
    # Example using theme constant (if defined in project settings or theme):
    # header.add_theme_font_override("font", preload("res://path/to/bold_font.tres"))
    # header.add_theme_constant_override("line_spacing", 5) # Add space below
    header.modulate = Color.WHITE # Ensure it's not colored like stats
    stats_list_container.add_child(header)
    # Optional: Add a small separator after the header
    # var sep = HSeparator.new()
    # stats_list_container.add_child(sep)


# Helper to create and add a label for an individual stat
func _add_stat_label(stat_name: String, color: Color) -> void:
    var label := Label.new()
    label.name = stat_name + "Label" # Debugging name
    label.text = "- " + stat_name # Indent slightly with a dash
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER # Align text vertically if label height > font height

    # Apply Theme Overrides (Consider using a Theme resource)
    label.add_theme_font_size_override("font_size", font_size_override)
    label.add_theme_color_override("font_color", color)

    # Tooltip
    var stat_key = stat_name.to_lower() # Normalize for dictionary lookup
    if STAT_DESCRIPTIONS.has(stat_key):
        label.tooltip_text = STAT_DESCRIPTIONS[stat_key]
        label.mouse_filter = Control.MOUSE_FILTER_PASS # Ensure mouse can interact for tooltip
    else:
         label.mouse_filter = Control.MOUSE_FILTER_IGNORE # No tooltip, ignore mouse

    # Connect hover effects only if there's a tooltip (or always if desired)
    if label.mouse_filter == Control.MOUSE_FILTER_PASS:
        label.mouse_entered.connect(_on_label_mouse_entered.bind(label))
        label.mouse_exited.connect(_on_label_mouse_exited.bind(label))

    stats_list_container.add_child(label)


# Helper to add a placeholder label (e.g., "(None)")
func _add_placeholder_label(text: String) -> void:
    var label := Label.new()
    label.name = "PlaceholderLabel"
    label.text = text
    label.modulate = Color(0.7, 0.7, 0.7) # Dim color for placeholder
    label.add_theme_font_size_override("font_size", font_size_override)
    # Optional: Make it italic via theme override or font resource
    # label.add_theme_font_override("font", preload("res://path/to/italic_font.tres"))
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE # No interaction needed
    stats_list_container.add_child(label)


# --- Hover Effect Handlers ---
func _on_label_mouse_entered(label: Label) -> void:
    # Apply hover modulation tint
    label.modulate = hover_modulate_color

func _on_label_mouse_exited(label: Label) -> void:
    # Reset modulation tint to default (white = no tint)
    label.modulate = Color.WHITE
