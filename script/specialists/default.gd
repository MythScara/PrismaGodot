extends Node

var specialist_name = ""
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

var specialist_info = {
	"Name": "",
	"Description": "",
	"Weapon": "",
	"Passive 1": {"Mind": ""},
	"Passive 2": {"Soul": ""},
	"Passive 3": {"Heart": ""},
	"Technique 1": {"Skill": "", "TD": 0, "TC": 0},
	"Technique 2": {"Special": "", "TD": 0, "TC": 0},
	"Technique 3": {"Super": "", "TD": 0, "TC": 0}
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
	match event:
		"Technique Used":
			pass
		"Battle Magic Cast":
			pass
		"Support Magic Cast":
			pass
		"Battle Item Used":
			pass
		"Support Item Used":
			pass
		"Physical Damage Taken":
			pass
		"Magic Damage Taken":
			pass
		"Elemental Damage Taken":
			pass
		"Fatal Damage Taken":
			pass
		"Summon Used":
			pass
		"Health Warning":
			pass
		"Health Critical":
			pass
		"Physical Damage Dealt":
			pass
		"Magic Damage Dealt":
			pass
		"Elemental Damage Dealt":
			pass
		"Fatal Damage Dealt":
			pass

func mind_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Mind Ready")
			mind_ready = true
		"Active":
			if mind_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if mind_ready == false:
				PlayerStats.start_timer(specialist_name, "mind_passive", 5, "Ready")
		"Unready":
			mind_ready = null

func soul_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Soul Ready")
			soul_ready = true
		"Active":
			if soul_ready == true:
				mind_ready = false
				mind_passive("Cooldown")
		"Cooldown":
			if soul_ready == false:
				PlayerStats.start_timer(specialist_name, "soul_passive", 5, "Ready")
		"Unready":
			soul_ready = null

func heart_passive(state):
	match state:
		"Ready":
			print_debug(specialist_name + " Heart Ready")
			heart_ready = true
		"Active":
			if heart_ready == true:
				heart_ready = false
				heart_passive("Cooldown")
		"Cooldown":
			if heart_ready == false:
				PlayerStats.start_timer(specialist_name, "heart_passive", 5, "Ready")
		"Unready":
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
