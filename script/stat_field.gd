extends ColorRect

@onready var main = $MainStats/VBoxContainer
@onready var second = $SecondaryStats/VBoxContainer

var stats = PlayerStats.stats

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is ScrollContainer:
			var vbox = child.get_child(0)
			set_values(vbox)

func set_values(vbox):
	for key in stats.keys():
		var label = Label.new()
		label.text = "%s: %s" % [key, stats[key]]
		label.align = HORIZONTAL_ALIGNMENT_RIGHT
		vbox.add_child(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
