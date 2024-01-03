extends Control

var values = ["SLR", "NTR", "SPR", "VOD", "ARC", "FST", "MTL", "DVN"]
var base_stat = [2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000]

@onready var elementGrid = $ElementGrid

func _ready():
	_update_stats_grid(base_stat)

func _update_stats_grid(stats: Array):
	# Clear existing stats in the grid    
	for child in elementGrid.get_children():        
		child.queue_free()

	# Populate the grid with new stats
	for i in range(stats.size()):   
		var hbox = HBoxContainer.new()  # Create a new HBoxContainer for each stat
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var stat_label = Label.new()       
		stat_label.text = values[i]  
		stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL       
		stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT  # Align the stat name to the left
				
		var value_label = Label.new()   
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL       
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT  # Align the stat value to the right
		value_label.text = str(stats[i])
		
		var base = base_stat[i]
		var color = Color(1,1,1,1) # White
		if stats[i] > base:
			color = Color(0,1,0,1) # Green
		elif stats[i] < base:
			color = Color(1,0,0,1) # Red
		
		value_label.modulate = color
		# Add both labels to the hbox        
		hbox.add_child(stat_label)       
		hbox.add_child(value_label)
		# Add the hbox to the statGrid       
		elementGrid.add_child(hbox)

func _on_continue_button_pressed():
	pass # Replace with function body.
