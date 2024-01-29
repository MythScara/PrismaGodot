extends Node

var specialist_name = "Mercenary"
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000

signal activation_timer(s_name)

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

func _timer_reached(s_name):
	pass

func _mind_passive(s_active):
	if s_active == true:
		PlayerStats.immunities.append("Blaze")
		print_debug("Blaze")
	else:
		PlayerStats.immunities.erase("Blaze")

func _soul_passive(s_active):
	if s_active == true:
		PlayerStats.immunities.append("Corrode")
		print_debug("Corrode")
	else:
		PlayerStats.immunities.erase("Corrode")

func _heart_passive(s_active):
	if s_active == true:
		PlayerStats.immunities.append("Siphon")
		print_debug("Siphon")
	else:
		PlayerStats.immunities.erase("Siphon")

func _skill_technique(s_active):
	pass

func _special_technique(s_active):
	pass

func _super_technique(s_active):
	pass
