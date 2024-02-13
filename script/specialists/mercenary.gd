extends Node

var specialist_name = "Mercenary"
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

var mind_signal = ""
var soul_signal = ""
var heart_signal = "Technique Used"

var specialist_info = {
	"Name": "Mercenary",
	"Description": "Hired militant officer with training in all forms of modern warfare. Loyalty to the highest bidder and an aptitude for survival.",
	"Weapon": "Assault Rifle",
	"Passive 1": {"Mercenary Mind": "Gain immunity to [b]Blaze[/b]."},
	"Passive 2": {"Mercenary Soul": "Increase [b]DMG[/b] by [b]5[/b] on [b]Ranged Weapons[/b]."},
	"Passive 3": {"Mercenary Heart": "Taking [b]Physical Damage[/b] restores [b]2% Overshield[/b]. Can only occur once every [b]5 [/b]seconds."},
	"Technique 1": {"Mercenary Skill": "Increase [b]RLD[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "TD": 10, "TC": 30},
	"Technique 2": {"Mercenary Special": "Increase [b]INF[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "TD": 10, "TC": 40},
	"Technique 3": {"Mercenary Super": "All [b]Ranged Weapon[/b] hits register as [b]Weakpoint[/b].", "TD": 15, "TC": 90}
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
	elif s_type != specialist_name and active == true:
		active = false
		PlayerStats.change_passive(specialist_name, "mind_passive", "Sub")
		PlayerStats.change_passive(specialist_name, "soul_passive", "Sub")
		PlayerStats.change_passive(specialist_name, "heart_passive", "Sub")
	else:
		pass

func event_handler(event):
	if event == mind_signal:
		mind_passive("Active")
	if event == soul_signal:
		soul_passive("Active")
	if event == heart_signal:
		heart_passive("Active")

func mind_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Mind Ready")
			mind_ready = true
			PlayerStats.immunities.append("Blaze")
			if not PlayerStats.connect("player_event", Callable(self, "event_handler")) and mind_signal == "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if mind_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if mind_ready == false:
				PlayerStats.start_timer(specialist_name, "mind_passive", 5, "Ready")
		"Unready":
			if PlayerStats.connect("player_event", Callable(self, "event_handler")):
				PlayerStats.disconnect("player_event", Callable(self, "event_handler"))
			mind_ready = null
			PlayerStats.immunities.erase("Blaze")

func soul_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Soul Ready")
			soul_ready = true
			PlayerStats.weapon_stat_change({"DMG": 5}, "Ranged", "Add")
			if not PlayerStats.connect("player_event", Callable(self, "event_handler")) and soul_signal == "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if soul_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if soul_ready == false:
				PlayerStats.start_timer(specialist_name, "soul_passive", 5, "Ready")
		"Unready":
			if PlayerStats.connect("player_event", Callable(self, "event_handler")):
				PlayerStats.disconnect("player_event", Callable(self, "event_handler"))
			soul_ready = null
			PlayerStats.weapon_stat_change({"DMG": 5}, "Ranged", "Sub")

func heart_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Heart Ready")
			heart_ready = true
			if not PlayerStats.connect("player_event", Callable(self, "event_handler")) and heart_signal == "":
				PlayerStats.connect("player_event", Callable(self, "event_handler"))
		"Active":
			if heart_ready == true:
				print_debug("Overshield Restored")
				heart_ready = false
				heart_passive("Cooldown")
		"Cooldown":
			if heart_ready == false:
				PlayerStats.start_timer(specialist_name, "heart_passive", 5, "Ready")
		"Unready":
			if PlayerStats.connect("player_event", Callable(self, "event_handler")):
				PlayerStats.disconnect("player_event", Callable(self, "event_handler"))
			heart_ready = null

func skill_technique(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Skill Ready")
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
			if skill_ready == false:
				if typeof(specialist_info["Technique 1"]["TC"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TC"], "Ready")
				else:
					skill_technique("Ready")
		"Unready":
			skill_ready = null

func special_technique(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Special Ready")
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
			if special_ready == false:
				if typeof(specialist_info["Technique 2"]["TC"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TC"], "Ready")
				else:
					special_technique("Ready")
		"Unready":
			special_ready = null

func super_technique(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Super Ready")
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
			if super_ready == false:
				if typeof(specialist_info["Technique 1"]["TC"]) == TYPE_INT:
					PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TC"], "Ready")
				else:
					super_technique("Ready")
		"Unready":
			super_ready = null
