extends Control

@export var continue_screen : PackedScene

var values = ["HP", "MP", "SHD", "STM", "ATK", "DEF", "MGA", "MGD", "SHR", "STR", "AG", "CAP"]
var base_stat = [40000, 40000, 8000, 8000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000]

@onready var description = $SpeciesDescription
@onready var bonusOne = $SpeciesBonus1
@onready var bonusTwo = $SpeciesBonus2
@onready var bonusThree = $SpeciesBonus3
@onready var statGrid = $SpeciesStatGrid
@onready var human_button = $HumanButton
@onready var meka_button = $MekaButton
@onready var daemon_button = $DaemonButton
@onready var sylph_button = $SylphButton
@onready var kaiju_button = $KaijuButton
@onready var continue_button = $ContinueButton
@onready var sprite = $EmblemSprite
var selected_button = null

func _ready():
	_update_stats_grid(base_stat)

func _on_human_button_pressed():
	_set_active(human_button)
	_update_information("Human")
	
func _on_meka_button_pressed():
	_set_active(meka_button)
	_update_information("Meka")

func _on_daemon_button_pressed():
	_set_active(daemon_button)
	_update_information("Daemon")

func _on_sylph_button_pressed():
	_set_active(sylph_button)
	_update_information("Sylph")

func _on_kaiju_button_pressed():
	_set_active(kaiju_button)
	_update_information("Kaiju")

func _update_information(key: String):
	var species = GameInfo.species_info[key]
	# Update description and bonuses
	description.bbcode_text = species["Description"]  
	bonusOne.bbcode_text = species["Bonus1"].values()[0]
	bonusTwo.bbcode_text = species["Bonus2"].values()[0]
	bonusThree.bbcode_text = species["Bonus3"].values()[0]
	sprite.texture = load("res://asset/emblems/" + key.to_lower() + "_emblem.png")
	# Update stats in the grid
	_update_stats_grid(species["Stats"])
	
	if sprite.visible == false:
		sprite.visible = true
	
	var stats_dict = {}
	for i in range(species["Stats"].size()):
		stats_dict[values[i]] = species["Stats"][i]
	PlayerStats.set_stats(stats_dict)
	PlayerStats.species = key
	
	var bonuses_dict = {
		"Bonus 1": species["Bonus1"].keys()[0],
		"Bonus 2": species["Bonus2"].keys()[0],
		"Bonus 3": species["Bonus3"].keys()[0]
	}
	PlayerStats.set_bonuses(bonuses_dict)

func _update_stats_grid(stats: Array):
	# Clear existing stats in the grid    
	for child in statGrid.get_children():        
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
		statGrid.add_child(hbox)

func _set_active(new_button: Button):
	if continue_button.disabled == true:
		continue_button.disabled = false
	
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)

func _on_continue_button_pressed():
	if continue_screen and PlayerStats.species != null:
		get_tree().change_scene_to_packed(continue_screen)
	else:
		print("No Scene Set")
