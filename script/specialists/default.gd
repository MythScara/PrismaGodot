extends Node

var specialist_name = ""
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000

signal activation_timer(s_name)

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
	connect("activation_timer", Callable(self, "_timer_reached"))
	PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start_timer(seconds, s_name):
	var timer = Timer.new()
	timer.set_wait_time(seconds)
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self,"_on_timer_timeout").bind(s_name))
	add_child(timer)
	timer.start()

func _on_timer_timeout(s_name):
	emit_signal("activation_timer", s_name)
	
	for child in get_children():
		if child is Timer and child.is_stopped():
			child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_specialist_activated(s_type):
	if s_type == "Mercenary":
		active = true
		_mind_passive(true)
		_soul_passive(true)
		_heart_passive(true)
	else:
		active = false
		_mind_passive(false)
		_soul_passive(false)
		_heart_passive(false)

func _timer_reached(s_name):
	if s_name == "mind":
		_mind_passive(false)
	if s_name == "soul":
		_soul_passive(false)
	if s_name == "heart":
		_heart_passive(false)
	if s_name == "skill":
		_skill_technique(false)
	if s_name == "special":
		_special_technique(false)
	if s_name == "super":
		_super_technique(false)
	else:
		pass

func _mind_passive(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass

func _soul_passive(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass

func _heart_passive(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass

func _skill_technique(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass

func _special_technique(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass

func _super_technique(s_active):
	if s_active == true:
		pass
	elif s_active == false:
		pass
	else:
		pass
