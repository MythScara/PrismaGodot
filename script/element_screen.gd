extends Control

@export var continue_screen : PackedScene

var element_info = {
	"SLR": {
	"Description": "Resistance value against [color='#FF0000']Solar[/color] Attacks, Pressure value using [color='#FF0000']Solar[/color] Attacks",
	"Strength": "[color='#00FF00']Nature[/color]",
	"Weakness": "[color='#00FFFF']Frost[/color]",
	"Reactions": {
		"[color='#FF0000']Burn[/color]" : "Deal [b]1% [/b]of user [b]ATK[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9[/b] seconds",
		"[color='#00FF00']Scorch[/color]": "Deplete [b]2% [/b]of target [b]Overshield[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#FFFF00']Blaze[/color]": "Target cannot receive any type of [b]Healing[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#AD00FF']Combust[/color]": "Prevent [b]Shield Recovery[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#0000FF']Spark[/color]" : "Target cannot receive any type of [b]Buff[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FFFF']Exhaust[/color]": "Prevent [b]Stamina Recovery[/b] for [b]10/15/20/25/30 [/b]seconds",
		"[color='#FF9600']Melt[/color]" : "Reduce target [b]DEF[/b] by [b]20% [/b]for [b]20/25/30/35/40 [/b]seconds",
		"[color='#C8C8C8']Overheat[/color]": "Deal [b]2%[/b] of [b]SLR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"NTR": {
	"Description": "Resistance value against [color='#00FF00']Nature[/color] Attacks, Pressure value using [color='#00FF00']Nature[/color] Attacks",
	"Strength": "[color='#FFFF00']Spirit[/color]",
	"Weakness": "[color='#FF0000']Solar[/color]",
	"Reactions": {
		"[color='#FF0000']Scorch[/color]" : "Deplete [b]2% [/b]of target [b]Overshield[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#00FF00']Knock[/color]": "Cancel any [b]Buff[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#FFFF00']Siphon[/color]": "User regains [b]2%[/b] of all damage dealt to target as [b]HP[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#AD00FF']Poison[/color]": "Deal [b]1% [/b]of user [b]MGA[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9 [/b]seconds",
		"[color='#0000FF']Thunder[/color]" : "Cancel any [b]Healing[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#00FFFF']Chill[/color]": "Increase target’s [b]Stamina[/b] usage by [b]20% [/b]for [b]10/12/14/16/18[/b] seconds",
		"[color='#FF9600']Corrode[/color]" : "Increase [b]Magic Damage[/b] taken by target by [b]15% [/b]for [b]30/35/40/45/50 [/b]seconds",
		"[color='#C8C8C8']Overgrow[/color]": "Deal [b]2%[/b] of [b]NTR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"SPR": {
	"Description": "Resistance value against [color='#FFFF00']Spirit[/color] Attacks, Pressure value using [color='#FFFF00']Spirit[/color] Attacks",
	"Strength": "[color='#AD00FF']Void[/color]",
	"Weakness": "[color='#00FF00']Nature[/color]",
	"Reactions": {
		"[color='#FF0000']Blaze[/color]" : "Target cannot receive any type of [b]Healing[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FF00']Siphon[/color]": "User regains [b]2%[/b] of all damage dealt to target as [b]HP[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#FFFF00']Blind[/color]": "Block target vision for [b]5/6/7/8/9[/b] seconds",
		"[color='#AD00FF']Curse[/color]": "Reduce target [b]ATK [/b]by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#0000FF']Radiate[/color]" : "Increase [b]Weakpoint[/b] damage on target by [b]10/15/20/25/30 %[/b] for [b]15 [/b]seconds",
		"[color='#00FFFF']Suppress[/color]": "Reduce target [b]MGA[/b] by [b]20%[/b] for the next [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Reflect[/color]" : "Any [b]Magic[/b] used by target is reflected back at target for [b]10/15/20/25/30 [/b]seconds",
		"[color='#C8C8C8']Overload[/color]": "Deal [b]2%[/b] of [b]SPR[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"VOD": {
	"Description": "Resistance value against [color='#AD00FF']Void[/color] Attacks, Pressure value using [color='#AD00FF']Void[/color] Attacks",
	"Strength": "[color='#0000FF']Arc[/color]",
	"Weakness": "[color='#FFFF00']Spirit[/color]",
	"Reactions": {
		"[color='#FF0000']Combust[/color]" : "Prevent [b]Shield Recovery[/b] for [b]10/15/20/25/30[/b] seconds",
		"[color='#00FF00']Poison[/color]": "Deal [b]1% [/b]of user [b]MGA[/b] as [b]True Damage[/b] to target every second for [b]5/6/7/8/9 [/b]seconds",
		"[color='#FFFF00']Curse[/color]": "Reduce target [b]ATK [/b]by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#AD00FF']Blight[/color]": "Next single target [b]Magic[/b] cast on target is spread to others within [b]3/4/5/6/7 [/b]meters",
		"[color='#0000FF']Null[/color]" : "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#00FFFF']Petrify[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#FF9600']Decay[/color]" : "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#C8C8C8']Overweigh[/color]": "Deal [b]2%[/b] of [b]VOD[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"ARC": {
	"Description": "Resistance value against [color='#0000FF']Arc[/color] Attacks, Pressure value using [color='#0000FF']Arc[/color] Attacks",
	"Strength": "[color='#00FFFF']Frost[/color]",
	"Weakness": "[color='#AD00FF']Void[/color]",
	"Reactions": {
		"[color='#FF0000']Spark[/color]" : "Target cannot receive any type of [b]Buff[/b] for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FF00']Thunder[/color]": "Cancel any [b]Healing[/b] currently on target and others within [b]2/3/4/5/6 [/b]meters",
		"[color='#FFFF00']Radiate[/color]": "Increase [b]Weakpoint[/b] damage on target by [b]10/15/20/25/30 %[/b] for [b]15 [/b]seconds",
		"[color='#AD00FF']Null[/color]": "Cancel any [b]Magic[/b] currently being conjured by target or others within [b]2/3/4/5/6 [/b]meters",
		"[color='#0000FF']Paralyze[/color]" : "Prevent target from moving or swapping weapons for [b]2/3/4/5/6[/b] seconds",
		"[color='#00FFFF']Ionize[/color]": "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#FF9600']Silence[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']Overcharge[/color]": "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"FST": {
	"Description": "Resistance value against [color='#00FFFF']Frost[/color] Attacks, Pressure value using [color='#00FFFF']Frost[/color] Attacks",
	"Strength": "[color='#FF0000']Solar[/color]",
	"Weakness": "[color='#0000FF']Arc[/color]",
	"Reactions": {
		"[color='#FF0000']Exhaust[/color]" : "Prevent [b]Stamina Recovery[/b] for [b]10/15/20/25/30 [/b]seconds",
		"[color='#00FF00']Chill[/color]": "Increase target’s [b]Stamina[/b] usage by [b]20% [/b]for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']Suppress[/color]": "Reduce target [b]MGA[/b] by [b]20%[/b] for the next [b]20/25/30/35/40[/b] seconds",
		"[color='#800080']Petrify[/color]": "Prevent target from attacking for [b]2/3/4/5/6[/b] seconds",
		"[color='#AD00FF']Ionize[/color]" : "User regains [b]2% [/b]of all damage dealt to target as [b]MP [/b]for [b]10/12/14/16/18 [/b]seconds",
		"[color='#00FFFF']Freeze[/color]": "Reduce target [b]AG[/b] by [b]20%[/b] for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Shatter[/color]" : "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#C8C8C8']Overflow[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"MTL": {
	"Description": "Resistance value against [color='#FF9600']Metal[/color] Attacks, Pressure value using [color='#FF9600']Metal[/color] Attacks",
	"Strength": "[color='#C8C8C8']Divine[/color]",
	"Weakness": "[color='#C8C8C8']Divine[/color]",
	"Reactions": {
		"[color='#FF0000']Melt[/color]" : "Reduce target [b]DEF[/b] by [b]20% [/b]for [b]20/25/30/35/40 [/b]seconds",
		"[color='#00FF00']Corrode[/color]": "Increase [b]Magic Damage[/b] taken by target by [b]15% [/b]for [b]30/35/40/45/50 [/b]seconds",
		"[color='#FFFF00']Reflect[/color]": "Any [b]Magic[/b] used by target is reflected back at target for [b]10/15/20/25/30 [/b]seconds",
		"[color='#AD00FF']Decay[/color]": "Deplete [b]2% [/b]of target [b]Magic Power[/b] per second for [b]5/6/7/8/9[/b] seconds",
		"[color='#0000FF']Silence[/color]" : "Prevent target from using any [b]Magic[/b] for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']Shatter[/color]": "Reduce target [b]MGD[/b] by [b]20% [/b]for [b]20/25/30/35/40[/b] seconds",
		"[color='#FF9600']Bleed[/color]" : "Increase [b]Physical Damage[/b] taken by target by [b]15%[/b] for [b]30/35/40/45/50 [/b]seconds",
		"[color='#C8C8C8']Overpower[/color]": "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
	"DVN": {
	"Description": "Resistance value against [color='#C8C8C8']Divine[/color] Attacks, Pressure value using [color='#C8C8C8']Divine[/color] Attacks",
	"Strength": "[color='#FF9600']Metal[/color]",
	"Weakness": "[color='#FF9600']Metal[/color]",
	"Reactions": {
		"[color='#FF0000']Overheat[/color]" : "Deal [b]2%[/b] of [b]SLR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FF00']Overgrow[/color]": "Deal [b]2%[/b] of [b]NTR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FFFF00']Overload[/color]": "Deal [b]2%[/b] of [b]SPR[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#AD00FF']Overweigh[/color]": "Deal [b]2%[/b] of [b]VOD[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#0000FF']Overcharge[/color]" : "Deal [b]2%[/b] of [b]ARC[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#00FFFF']Overflow[/color]": "Deal [b]2%[/b] of [b]FST[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#FF9600']Overpower[/color]" : "Deal [b]2%[/b] of [b]MTL[/b] damage per second for [b]10/12/14/16/18[/b] seconds",
		"[color='#C8C8C8']Overwhelm[/color]": "Deal [b]2%[/b] of [b]DVN[/b] damage per second for [b]10/12/14/16/18[/b] seconds"
		}
	},
}

var values = ["SLR", "NTR", "SPR", "VOD", "ARC", "FST", "MTL", "DVN"]
var base_stat = {"SLR": 2000,"NTR": 2000,"SPR": 2000,"VOD": 2000,"ARC": 2000,"FST": 2000,"MTL": 2000,"DVN": 2000}

var image_cache = {}

var point_count = 60

@onready var elementGrid = $ElementGrid
@onready var pointLabel = $PointLabel
@onready var reactionGrid = $ScrollContainer/InfoBox/ReactionGrid
@onready var solarButton = $SolarButton
@onready var natureButton = $NatureButton
@onready var spiritButton = $SpiritButton
@onready var voidButton = $VoidButton
@onready var arcButton = $ArcButton
@onready var frostButton = $FrostButton
@onready var metalButton = $MetalButton
@onready var divineButton = $DivineButton
@onready var continue_button = $ContinueButton
@onready var description = $ScrollContainer/InfoBox/ElementDescription
@onready var strength = $ScrollContainer/InfoBox/Strength
@onready var weakness = $ScrollContainer/InfoBox/Weakness
@onready var elementImage = $ElementImage
@onready var warning = $Warning

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
	strength.bbcode_text = "Strength : " + elements["Strength"]
	weakness.bbcode_text = "Weakness : " + elements["Weakness"]
	_update_reactions_grid(elements["Reactions"])
	
	if key in image_cache:
		elementImage.texture = image_cache[key]
	else:
		print_debug("Failed " + key)
	
func _update_reactions_grid(reactions: Dictionary):
	for child in reactionGrid.get_children():
		child.queue_free()
	
	for reaction in reactions.keys():		
		var reaction_label = RichTextLabel.new()
		reaction_label.bbcode_enabled = true
		
		var reaction_description = reactions[reaction]
		
		var reaction_text = reaction + " : " + reaction_description
		reaction_label.bbcode_text = reaction_text
		reaction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reaction_label.custom_minimum_size = Vector2(0,100)
		
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
		print_debug(PlayerStats.elements)
		get_tree().change_scene_to_packed(continue_screen)
	elif continue_screen and point_count != 0:
		warning.visible = true
	else:
		print("No Scene Set")

func _on_add_button_pressed():
	if selected_button != null and point_count > 0 and base_stat[selected_element] < 10000:
		point_count -= 1
		_update_point_label()
		_update_element_stat(400)
	else:
		pass

func _on_minus_button_pressed():
	if selected_button != null and point_count <= 60 and base_stat[selected_element] > 2000:
		point_count += 1
		_update_point_label()
		_update_element_stat(-400)
	else:
		pass

func _on_cancel_button_pressed():
	warning.visible = false

func _on_forfeit_continue_button_pressed():
	if continue_screen:
		PlayerStats.elements = base_stat
		print_debug(PlayerStats.elements)
		get_tree().change_scene_to_packed(continue_screen)
	else:
		print("No Scene Set")
