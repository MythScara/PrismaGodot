extends ColorRect

@onready var main = $MainStats/SplitContainer
@onready var stat_c = $MainStats/SplitContainer/StatContainer
@onready var value_c = $MainStats/SplitContainer/ValueContainer

var stats = PlayerStats.stats
var elements = PlayerStats.elements
var all_stats
var current_stats = []  # Tracks the current list of stat keys
var value_labels = {}   # Maps stat keys to their value labels for quick updates

func _ready():
    stat_update()
    PlayerStats.connect("pause_game", Callable(self, "stat_update"))
    PlayerStats.connect("stat_update", Callable(self, "stat_update"))

func stat_update(_stat = null):
    # Refresh stats and elements from PlayerStats
    stats = PlayerStats.stats
    elements = PlayerStats.elements
    all_stats = stats.duplicate()
    all_stats.merge(elements)

    # If a specific stat is updated, update only its label
    if _stat != null and _stat in value_labels:
        var label = value_labels[_stat]
        label.text = str(all_stats[_stat])
        # Highlight the updated stat with a color animation
        label.modulate = Color.YELLOW
        var tween = create_tween()
        tween.tween_property(label, "modulate", Color.WHITE, 0.5)
    else:
        # Get the new list of stat keys, excluding those in PlayerStats.excluded, and sort for consistency
        var new_stats = all_stats.keys().filter(func(k): return k not in PlayerStats.excluded).sort()

        # If the stat list has changed, recreate the labels
        if new_stats != current_stats:
            # Clear existing labels
            for child in stat_c.get_children():
                child.queue_free()
            for child in value_c.get_children():
                child.queue_free()

            # Update the current stats list and clear the value labels dictionary
            current_stats = new_stats
            value_labels.clear()

            # Create new labels for each stat
            for key in current_stats:
                var label_key = Label.new()
                label_key.text = key
                label_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
                label_key.add_theme_font_size_override("font_size", 20)
                # Add tooltip if a description exists in PlayerStats.stat_descriptions
                label_key.tooltip_text = PlayerStats.stat_descriptions.get(key, "")
                stat_c.add_child(label_key)

                var label_value = Label.new()
                label_value.text = str(all_stats[key])
                label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
                label_value.add_theme_font_size_override("font_size", 20)
                value_c.add_child(label_value)
                value_labels[key] = label_value
        else:
            # If the stat list is unchanged, update only the value labels
            for key in current_stats:
                value_labels[key].text = str(all_stats[key])
