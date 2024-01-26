extends Control

@export var continue_screen : PackedScene

var element_info = {
	"SLR": {
	"Description": "Resistance value against Solar Attacks, Pressure value using Solar Attacks",
	"Strength": "Nature",
	"Weakness": "Frost",
	"Reactions": ["Burn", "Scorch", "Blaze", "Combust", "Spark", "Exhaust", "Melt", "Overheat"]},
	"NTR": {
	"Description": "Resistance value against Nature Attacks, Pressure value using Nature Attacks",
	"Strength": "Spirit",
	"Weakness": "Solar",
	"Reactions": ["Scorch", "Knock", "Siphon", "Poison", "Thunder", "Chill", "Corrode", "Overgrow"]},
	"SPR": {
	"Description": "Resistance value against Spirit Attacks, Pressure value using Spirit Attacks",
	"Strength": "Void",
	"Weakness": "Nature",
	"Reactions": ["Blaze", "Siphon", "Blind", "Curse", "Radiate", "Suppress", "Reflect", "Overload"]},
	"VOD": {
	"Description": "Resistance value against Void Attacks, Pressure value using Void Attacks",
	"Strength": "Arc",
	"Weakness": "Spirit",
	"Reactions": ["Combust", "Poison", "Curse", "Blight", "Null", "Petrify", "Decay", "Overweigh"]},
	"ARC": {
	"Description": "Resistance value against Arc Attacks, Pressure value using Arc Attacks",
	"Strength": "Frost",
	"Weakness": "Void",
	"Reactions": ["Spark", "Thunder", "Radiate", "Null", "Paralyze", "Ionize", "Silence", "Overcharge"]},
	"FST": {
	"Description": "Resistance value against Frost Attacks, Pressure value using Frost Attacks",
	"Strength": "Solar",
	"Weakness": "Arc",
	"Reactions": ["Exhaust", "Chill", "Suppress", "Petrify", "Ionize", "Freeze", "Shatter", "Overflow"]},
	"MTL": {
	"Description": "Resistance value against Metal Attacks, Pressure value using Metal Attacks",
	"Strength": "Divine",
	"Weakness": "Divine",
	"Reactions": ["Melt", "Corrode", "Reflect", "Decay", "Silence", "Shatter", "Bleed", "Overpower"]},
	"DVN": {
	"Description": "Resistance value against Divine Attacks, Pressure value using Divine Attacks",
	"Strength": "Metal",
	"Weakness": "Metal",
	"Reactions": ["Overheat", "Overgrow", "Overload", "Overweigh", "Overcharge", "Overflow", "Overpower", "Overwhelm"]},
}

var values = ["SLR", "NTR", "SPR", "VOD", "ARC", "FST", "MTL", "DVN"]
var base_stat = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}

var image_cache = {}

var point_count = 60

@onready var elementGrid = $ElementGrid
@onready var pointLabel = $PointLabel
@onready var reactionGrid = $ReactionGrid
@onready var solarButton = $SolarButton
@onready var natureButton = $NatureButton
@onready var spiritButton = $SpiritButton
@onready var voidButton = $VoidButton
@onready var arcButton = $ArcButton
@onready var frostButton = $FrostButton
@onready var metalButton = $MetalButton
@onready var divineButton = $DivineButton
@onready var continue_button = $ContinueButton
@onready var description = $ElementDescription
@onready var strength = $Strength
@onready var weakness = $Weakness
@onready var elementImage = $ElementImage

var selected_button = null
var selected_element = null

func _ready():
	preload_images()
	_update_stats_grid(base_stat)
	_update_point_label()

func _on_solar_button_pressed():
	_set_active(solarButton)
	_update_information("SLR")

func _on_nature_button_pressed():
	_set_active(natureButton)
	_update_information("NTR")

func _on_spirit_button_pressed():
	_set_active(spiritButton)
	_update_information("SPR")

func _on_void_button_pressed():
	_set_active(voidButton)
	_update_information("VOD")

func _on_arc_button_pressed():
	_set_active(arcButton)
	_update_information("ARC")

func _on_frost_button_pressed():
	_set_active(frostButton)
	_update_information("FST")

func _on_metal_button_pressed():
	_set_active(metalButton)
	_update_information("MTL")

func _on_divine_button_pressed():
	_set_active(divineButton)
	_update_information("DVN")

func preload_images():
	for key in element_info.keys():
		var path = "res://asset/element_orbs/" + key + ".png"
		image_cache[key] = load(path)

func _update_point_label():
	pointLabel.text = str(point_count)

func _update_information(key : String):
	selected_element = key
	var elements = element_info[key]
	
	description.bbcode_text = elements["Description"]
	strength.text = "Strength : " + elements["Strength"]
	weakness.text = "Weakness : " + elements["Weakness"]
	_update_reactions_grid(elements["Reactions"])
	
	if key in image_cache:
		elementImage.texture = image_cache[key]
	else:
		print_debug("Failed " + key)
	
func _update_reactions_grid(reactions: Array):
	for child in reactionGrid.get_children():
		child.queue_free()
	
	for reaction in reactions:
		var reaction_label = Label.new()   
		reaction_label.text = reaction
		reaction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL      
		reaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reactionGrid.add_child(reaction_label)
	
	reactionGrid.queue_sort()  # Align the stat value to the right

func _update_element_stat(value):
	base_stat[selected_element] += value
	_update_stats_grid(base_stat)
	
func _update_stats_grid(stats):
	# Clear existing stats in the grid    
	for child in elementGrid.get_children():        
		child.queue_free()

	# Populate the grid with new stats
	for key in values:   
		var hbox = HBoxContainer.new()  # Create a new HBoxContainer for each stat
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var stat_label = Label.new()       
		stat_label.text = key
		stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL       
		stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT  # Align the stat name to the left
				
		var value_label = Label.new()   
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL       
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT  # Align the stat value to the right
		value_label.text = str(stats[key])
		
		# Add both labels to the hbox        
		hbox.add_child(stat_label)       
		hbox.add_child(value_label)
		# Add the hbox to the statGrid       
		elementGrid.add_child(hbox)

func _set_active(new_button: Button):
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)

func _on_continue_button_pressed():
	if continue_screen and point_count == 0:
		PlayerStats.elements = base_stat
		get_tree().change_scene_to_packed(continue_screen)
	else:
		print("No Scene Set")

func _on_add_button_pressed():
	if selected_button != null and point_count > 0 and base_stat[selected_element] < 10000:
		point_count -= 1
		_update_point_label()
		_update_element_stat(400)
		if point_count == 0:
			continue_button.visible = true
	else:
		pass

func _on_minus_button_pressed():
	if selected_button != null and point_count <= 60 and base_stat[selected_element] > 2000:
		point_count += 1
		_update_point_label()
		_update_element_stat(-400)
		if point_count != 0:
			continue_button.visible = false
	else:
		pass
