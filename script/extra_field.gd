extends ColorRect

@onready var main = $MainStats/SplitContainer
@onready var stat_c = $MainStats/SplitContainer/StatContainer
@onready var value_c = $MainStats/SplitContainer/ValueContainer

var immunities = PlayerStats.immunities
var buffs = PlayerStats.buffs
var afflictions = PlayerStats.afflictions

# Called when the node enters the scene tree for the first time.
func _ready():
	update_stats(stat_c, value_c)

func update_stats(vbox1, vbox2):
	for child in vbox1.get_children():
		child.queue_free()
	for child in vbox2.get_children():
		child.queue_free()
	stat_update("Immunity", immunities, stat_c, value_c)
	stat_update("Buff", buffs, stat_c, value_c)
	stat_update("Affliction", afflictions, stat_c, value_c)

func stat_update(key, array, vbox1, vbox2):
	for value in array:
		var label_key = Label.new()
		label_key.text = key
		label_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label_key.add_theme_font_size_override("font_size", 20)
		vbox1.add_child(label_key)
		
		var label_value = Label.new()
		label_value.text = value
		label_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label_value.add_theme_font_size_override("font_size", 20)
		vbox2.add_child(label_value)
