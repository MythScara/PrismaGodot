extends Control

@export var continue_screen : PackedScene

var species_data = {
	"Human": {
	"Description": "Humans are an immigrant race forced to evacuate their home planet Earth after it was destroyed by famine, pollution, and war. They sought refuge on Prismadiane and soon became the planets most abundant work force. Humans are dedicated and hardworking, they control most of the markets on Prismadiane giving them access to the planets best gear at exceptional prices.",
	"Bonus1": {"General Discount": "- Prisma cost for [b]General Vendor[/b] purchases is decreased by [b]10%[/b]"},
	"Bonus2": {"Summon Cooldown": "- [b]Summons[/b] cooldown reduced by [b]20%[/b]"},
	"Bonus3": {"Lucky Caches": "- Prisma gained from [b]Loot Caches[/b] increased by [b]5%[/b]"},
	"Stats": [20000, 48000, 9600, 8000, 2800, 6000, 4000, 2800, 4000, 4000, 2800, 6000]},
	"Meka": {
	"Description": "The Meka are cybernetic machines created by the Celestials who once ruled over planet Prismadiane. Their sole purpose was to aid the Celestials in battle but after being abandoned by their creators, they began to advance the weaponry in preparation for their masters’ return. The Meka are highly intelligent and are skilled craftsmen, with incredible efficiency they waste no time in the workshop or on the battlefield.",
	"Bonus1": {"Repair Discount": "- [b]Repair[/b] cost decreased by [b]20%[/b]"},
	"Bonus2": {"Forge Success": "- [b]Forge[/b] success rate increased by [b]5%[/b] and cost decreased by [b]10%[/b]"},
	"Bonus3": {"Transport Discount": "- [b]Transport[/b] cost decreased by [b]50%[/b]"},
	"Stats": [40000, 20000, 14400, 5600, 4000, 7200, 2800, 6000, 4800, 1200, 1200, 4800]},
	"Daemon": {
	"Description": "When the Demons of the underworld rose up and cast darkness upon the planet, they began to possess and absorb the civilians. As time passed, generation after generation began to develop resistance against the Demons; eventually these civilians mutated into the Demon hybrid known as Daemons. Daemons are persistent and resilient, never allowing themselves to be broken down. Their strengthened immune systems allow them to run headfirst into battle with overwhelming confidence.",
	"Bonus1": {"Corpse Siphon": "- [b]Magic Power[/b] gained from defeated enemies increased by [b]10%[/b]"},
	"Bonus2": {"Magic Library": "- [b]Magic Scrolls[/b] offer [b]1[/b] additional choice"},
	"Bonus3": {"Magical Summon": "- [b]Summons[/b] gain [b]20% MGA[/b] and [b]10% MGD[/b] while on the field"},
	"Stats": [28000, 72000, 2400, 9600, 7200, 4000, 6000, 2800, 2000, 1200, 4800, 4000]},
	"Sylph": {
	"Description": "Sylphs are distant descendants of the Celestials, and the true natives of Prismadiane. Natural power rushes through their veins and the purest magic flows in their blood. The Sylphs are known for their close bond to the planet and their flawless control over their summons. Although their power is far weaker than their ancestors’, once awakened the Sylphs can effortlessly vanquish foes with extraordinary prowess.",
	"Bonus1": {"Summon Discount": "- [b]Summons[/b] require [b]50%[/b] less [b]Summon Tokens[/b]"},
	"Bonus2": {"Healthy Summon": "- [b]Summons[/b] gain [b]20% HP[/b] and [b]10% MP[/b] while on the field"},
	"Bonus3": {"Planet Siphon": "- [b]Magic Power[/b] gained from planetary resources increased by [b]10%[/b]"},
	"Stats": [60000, 40000, 1200, 2800, 1200, 2000, 4800, 6000, 6000, 7200, 4000, 2800]},
	"Kaiju": {
	"Description": "The Kaiju are primal creatures who have evolved to the degree where they can no longer be considered simply animals. With heightened senses, Kaiju rely heavily on their instincts and are extremely prideful. The Kaiju are the planet’s most resourceful scavengers with an unmatched knowledge of their surroundings.",
	"Bonus1": {"Higher Bounties": "- Prisma reward from [b]Bounties[/b] increased by [b]20%[/b]"},
	"Bonus2": {"Lucky Corpses": "- Prisma reward from defeating enemies increased by [b]5%[/b]"},
	"Bonus3": {"Powerful Summon": "- [b]Summons[/b] gain [b]20% ATK[/b] and [b]20% DEF[/b] while on the field"},
	"Stats": [48000, 20000, 8000, 12000, 4800, 1200, 1200, 4000, 2800, 7200, 7200, 2800]}
}

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
	var species = species_data[key]
	# Update description and bonuses
	description.bbcode_text = species["Description"]  
	bonusOne.bbcode_text = species["Bonus1"].values()[0]
	bonusTwo.bbcode_text = species["Bonus2"].values()[0]
	bonusThree.bbcode_text = species["Bonus3"].values()[0]
	# Update stats in the grid
	_update_stats_grid(species["Stats"])
	
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
