extends Node

var specialist_name = "Archer"
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000

var mind_ready = null
var soul_ready = null
var heart_ready = null
var skill_ready = null
var special_ready = null
var super_ready = null

var mind_signal = "Health Below 50%"
var soul_signal = ""
var heart_signal = "Support Item Used"

var specialist_info = {
	"Name": "Archer",
	"Description": "Fleet footed arrow master with an eye for kill zones. It only takes one good arrow to put down any target.",
	"Weapon": "Longbow",
	"Passive 1": {"Mind": "When [b]Health[/b] drops below [b]50%[/b], gain [b]2[/b] stacks of [b]Circulation[/b]. Does not stack with itself."},
	"Passive 2": {"Soul": "Increase [b]RNG[/b] by [b]10 [/b]on [b]Ranged Weapons[/b]."},
	"Passive 3": {"Heart": "Using a [b]Support Item [/b]reduces [b]Technique[/b] cooldowns by [b]10%[/b]."},
	"Technique 1": {"Skill": "Increase [b]MOB[/b] by [b]20 [/b]on [b]Melee Weapons[/b].", "TD": 10, "TC": 30},
	"Technique 2": {"Special": "Increase [b]SLS[/b] by [b]20 [/b]on [b]Ranged Weapons[/b].", "TD": 10, "TC": 40},
	"Technique 3": {"Super": "Gain [b]3[/b] stacks of [b]Steelborn[/b].", "TD": "SU", "TC": 60}
}

var specialist_rewards = {
	"Level 0": "Legendary Supply Crate",
	"Level 1": "Specialist Outfit",
	"Level 2": "Specialist Exclusive Weapon",
	"Level 3": "Specialist Belt",
	"Level 4": "Specialist Skill",
	"Level 5": "Specialist Pads",
	"Level 6": "Specialist Special",
	"Level 7": "Specialist Chest",
	"Level 8": "Specialist Super",
	"Level 9": "Specialist Body",
	"Level 10": "Specialist Heart Artifact"
}

var weapon_stats_r = {
	"DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "", "Tier": "Diamond", "Element": null, "Quality": null, "Max Value": 100}

var weapon_stats_m = {
	"POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "", "Tier": "Diamond", "Element": null, "Quality": null, "Max Value": 100}

func initialize():
	PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_specialist_activated(s_type):
	if s_type == specialist_name and active == false:
		active = true
		PlayerStats.set_specialist(specialist_name)
		if PlayerStats.specialist_levels.has(specialist_name):
			cur_level = PlayerStats.specialist_levels[specialist_name][0]
			cur_experience = PlayerStats.specialist_levels[specialist_name][1]
			experience_required = PlayerStats.specialist_levels[specialist_name][2]
		else:
			specialist_unlock(0)
			PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)
	elif s_type != specialist_name and active == true:
		active = false
		PlayerStats.change_passive(specialist_name, "mind_passive", "Sub")
		PlayerStats.change_passive(specialist_name, "soul_passive", "Sub")
		PlayerStats.change_passive(specialist_name, "heart_passive", "Sub")
	else:
		pass

func exp_handler(value):
	if cur_level != 10 and active == true:
		cur_experience += value
		if cur_experience >= experience_required:
			cur_level += 1
			PlayerStats.stat_points[0] += 2
			PlayerStats.element_points[0] += 2
			cur_experience -= experience_required
			experience_required += 1000
			specialist_unlock(cur_level)
			exp_handler(cur_experience)
		PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)

func specialist_unlock(level):
	level = int(level)
	match level:
		0:
			PlayerInventory.add_to_inventory("Crafting Resource", "Mithril Ore", {"Amount": 5, "Value": 700})
		1:
			PlayerInventory.add_to_inventory("Outfit", specialist_name+" Outfit", {"HP": 0, "MP": 0, "SHD": 0, "STM": 0, "Tier": "Obsidian", "Quality": 100})
		2:
			PlayerInventory.add_to_inventory("Ranged Weapon", specialist_name+" "+specialist_info["Weapon"], weapon_stats_r)
		3:
			PlayerInventory.add_to_inventory("Belt Armor", specialist_name+" Belt", {"AG": 0, "CAP": 0, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		4:
			PlayerInventory.add_to_inventory("Techniques", specialist_name+" Skill", {"Name": specialist_name, "Technique": "skill_technique"})
		5:
			PlayerInventory.add_to_inventory("Pad Armor", specialist_name+" Pads", {"AG": 0, "CAP": 0, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		6:
			PlayerInventory.add_to_inventory("Techniques", specialist_name+" Special", {"Name": specialist_name, "Technique": "special_technique"})
		7:
			PlayerInventory.add_to_inventory("Chest Armor", specialist_name+" Chest", {"AG": 0, "CAP": 0, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		8:
			PlayerInventory.add_to_inventory("Techniques", specialist_name+" Super", {"Name": specialist_name, "Technique": "super_technique"})
		9:
			PlayerInventory.add_to_inventory("Body Armor", specialist_name+" Body", {"AG": 0, "CAP": 0, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		10:
			PlayerInventory.add_to_inventory("Artifact", specialist_name+" Heart Artifact", {"HP": 0, "MP": 0, "SHD": 0, "STM": 0, "Tier": "Obsidian", "Quality": 100})
		_:
			print("No Match Found!")

func event_handler(event):
	if event == mind_signal:
		mind_passive("Active")
	if event == soul_signal:
		soul_passive("Active")
	if event == heart_signal:
		heart_passive("Active")

func connection_terminate():
	if mind_ready == null and soul_ready == null and heart_ready == null:
		if PlayerStats.is_connected("player_event", Callable(self, "event_handler")):
			PlayerStats.disconnect("player_event", Callable(self, "event_handler"))

func mind_passive(state):
	match state:
		"Ready":
			mind_ready = true
			if not PlayerStats.is_connected("player_event", Callable(self, "event_handler")) and mind_signal != "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if mind_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if mind_ready == false:
				PlayerStats.start_timer(specialist_name, "mind_passive", 5, "Ready")
		"Unready":
			mind_ready = null
			connection_terminate()

func soul_passive(state):
	match state:
		"Ready":
			soul_ready = true
			if not PlayerStats.is_connected("player_event", Callable(self, "event_handler")) and soul_signal != "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if soul_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if soul_ready == false:
				PlayerStats.start_timer(specialist_name, "soul_passive", 5, "Ready")
		"Unready":
			soul_ready = null
			connection_terminate()

func heart_passive(state):
	match state:
		"Ready":
			heart_ready = true
			if not PlayerStats.is_connected("player_event", Callable(self, "event_handler")) and heart_signal != "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if heart_ready == true:
				heart_ready = false
				heart_passive("Cooldown")
		"Cooldown":
			if heart_ready == false:
				PlayerStats.start_timer(specialist_name, "heart_passive", 5, "Ready")
		"Unready":
			heart_ready = null
			connection_terminate()

func skill_technique(state):
	match state:
		"Ready":
			if skill_ready == null:
				skill_ready = false
				skill_technique("Cooldown")
			else:
				skill_ready = true
		"Active":
			if skill_ready == true:
				skill_ready = false
				if typeof(specialist_info["Technique 1"]["TD"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TD"], "Cooldown")
				else:
					skill_technique("Cooldown")
				PlayerStats.emit_signal("player_event", "Technique Used")
		"Cooldown":
			if typeof(specialist_info["Technique 1"]["TC"]) == TYPE_INT:
				PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TC"], "Ready")
			else:
				skill_technique("Ready")
		"Unready":
			skill_ready = null

func special_technique(state):
	match state:
		"Ready":
			if special_ready == null:
				special_ready = false
				special_technique("Cooldown")
			else:
				special_ready = true
		"Active":
			if special_ready == true:
				special_ready = false
				if typeof(specialist_info["Technique 2"]["TD"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TD"], "Cooldown")
				else:
					special_technique("Cooldown")
				PlayerStats.emit_signal("player_event", "Technique Used")
		"Cooldown":
			if typeof(specialist_info["Technique 2"]["TC"]) == TYPE_INT:
				PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TC"], "Ready")
			else:
				special_technique("Ready")
		"Unready":
			special_ready = null

func super_technique(state):
	match state:
		"Ready":
			if super_ready == null:
				super_ready = false
				super_technique("Cooldown")
			else:
				super_ready = true
		"Active":
			if super_ready == true:
				super_ready = false
				if typeof(specialist_info["Technique 1"]["TD"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TD"], "Cooldown")
				else:
					super_technique("Cooldown")
				PlayerStats.emit_signal("player_event", "Technique Used")
		"Cooldown":
			if typeof(specialist_info["Technique 1"]["TC"]) == TYPE_INT:
				PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TC"], "Ready")
			else:
				super_technique("Ready")
		"Unready":
			super_ready = null
