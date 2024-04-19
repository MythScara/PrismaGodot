extends ColorRect

@onready var main = $MainStats/SplitContainer
@onready var stat_c = $MainStats/SplitContainer/StatContainer
@onready var value_c = $MainStats/SplitContainer/ValueContainer

var stats = PlayerStats.stats
var elements = PlayerStats.elements
var all_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	stat_update()
	PlayerStats.connect("pause_game", Callable(self, "stat_update"))

func stat_update():
	stats = PlayerStats.stats
	elements = PlayerStats.elements
	all_stats = stats.duplicate()
	all_stats.merge(elements)
	
	for child in stat_c.get_children():
		child.queue_free()
	for child in value_c.get_children():
		child.queue_free()
	
	for key in all_stats.keys():
		if key not in PlayerStats.excluded:
			var label_key = Label.new()
			label_key.text = key
			label_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			label_key.add_theme_font_size_override("font_size", 20)
			stat_c.add_child(label_key)
			
			var label_value = Label.new()
			label_value.text = str(all_stats[key])
			label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			label_value.add_theme_font_size_override("font_size", 20)
			value_c.add_child(label_value)
