extends Node

var specialist_name = ""
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000

var mind_ready = true
var soul_ready = true
var heart_ready = true
var skill_ready = true
var special_ready = true
var super_ready = true

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

func start_timer(seconds, s_name, cooldown):
	var timer = Timer.new()
	timer.set_wait_time(seconds)
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self,"_on_timer_timeout").bind(s_name, cooldown))
	PlayerStats.add_timer(timer)
	timer.start()

func _on_timer_timeout(s_name, cooldown):
	_timer_reached(s_name, cooldown)
	
	for child in get_children():
		if child is Timer and child.is_stopped():
			child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_specialist_activated(s_type):
	if s_type == specialist_name and active == false:
		active = true
		mind_passive(true)
		soul_passive(true)
		heart_passive(true)
		PlayerStats.set_specialist(specialist_name)
	elif s_type != specialist_name and active == true:
		active = false
		mind_passive(false)
		soul_passive(false)
		heart_passive(false)
	else:
		pass

func _timer_reached(s_name, cooldown):
	if cooldown == false:
		if s_name == "mind":
			mind_passive(false)
		elif s_name == "soul":
			soul_passive(false)
		elif s_name == "heart":
			heart_passive(false)
		elif s_name == "skill":
			skill_technique(false)
		elif s_name == "special":
			special_technique(false)
		elif s_name == "super":
			super_technique(false)
		else:
			pass
	elif cooldown == true:
		if s_name == "mind":
			print_debug(str(specialist_name) + " Mind Ready")
			mind_ready = true
		elif s_name == "soul":
			print_debug(str(specialist_name) + " Soul Ready")
			soul_ready = true
		elif s_name == "heart":
			print_debug(str(specialist_name) + " Heart Ready")
			heart_ready = true
		elif s_name == "skill":
			print_debug(str(specialist_name) + " Skill Ready")
			skill_ready = true
		elif s_name == "special":
			print_debug(str(specialist_name) + " Special Ready")
			special_ready = true
		elif s_name == "super":
			print_debug(str(specialist_name) + " Super Ready")
			super_ready = true

func mind_passive(s_active):
	if s_active == true:
		print_debug(str(specialist_name) + " Mind Activated")
		pass
	elif s_active == false:
		pass
	else:
		pass

func soul_passive(s_active):
	if s_active == true:
		print_debug(str(specialist_name) + " Soul Activated")
		pass
	elif s_active == false:
		pass
	else:
		pass

func heart_passive(s_active):
	if s_active == true:
		print_debug(str(specialist_name) + " Heart Activated")
		pass
	elif s_active == false:
		pass
	else:
		pass

func skill_technique(s_active):
	if s_active == true and skill_ready == true:
		print_debug(str(specialist_name) + " Skill Activated")
		start_timer(specialist_info["Technique 1"]["TD"], "skill", false)
		skill_ready = false
		pass
	elif s_active == false:
		print_debug(str(specialist_name) + " Skill Cooldown")
		start_timer(specialist_info["Technique 1"]["TC"], "skill", true)
		pass
	else:
		pass

func special_technique(s_active):
	if s_active == true and special_ready == true:
		print_debug(str(specialist_name) + " Special Activated")
		start_timer(specialist_info["Technique 2"]["TD"], "special", false)
		special_ready = false
		pass
	elif s_active == false:
		print_debug(str(specialist_name) + " Special Cooldown")
		start_timer(specialist_info["Technique 2"]["TC"], "special", true)
		pass
	else:
		pass

func super_technique(s_active):
	if s_active == true and super_ready == true:
		print_debug(str(specialist_name) + " Super Activated")
		start_timer(specialist_info["Technique 3"]["TD"], "super", false)
		super_ready = false
		pass
	elif s_active == false:
		print_debug(str(specialist_name) + " Super Cooldown")
		start_timer(specialist_info["Technique 3"]["TC"], "super", true)
		pass
	else:
		pass
