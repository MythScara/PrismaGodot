extends Node

# Class Name for better debugging and potential type hinting (Godot 4+)
class_name RogueSpecialist

# --- Configuration & Core Info ---
const SPECIALIST_NAME = "Rogue"
const MAX_LEVEL = 10
const BASE_EXPERIENCE_REQUIRED = 1000
const EXPERIENCE_INCREMENT_PER_LEVEL = 1000

# --- Signals ---
# Emitted when level changes for UI updates
signal level_changed(new_level)
# Emitted when experience changes for UI updates
signal experience_changed(current_exp, required_exp)
# Emitted when a technique's state changes (e.g., becomes ready, goes on cooldown)
signal technique_state_changed(technique_name, state) # state could be "Ready", "Active", "Cooldown"
# Emitted when a passive's state changes
signal passive_state_changed(passive_name, state) # state could be "Ready", "Active", "Cooldown"
# Emitted when status effects are gained or lost
signal status_effect_changed(effect_name, stacks, duration) # duration -1 for permanent until removed

# --- State Variables ---
var active: bool = false
var cur_level: int = 0
var cur_experience: int = 0
var experience_required: int = BASE_EXPERIENCE_REQUIRED

# --- Status Effects Tracking ---
# Dictionary to store active status effects managed by this specialist
# Format: { "EffectName": { "stacks": int, "duration_timer": Timer/float, "source": String } }
var active_status_effects: Dictionary = {}

# --- Technique & Passive States ---
enum AbilityState { UNREADY, READY, ACTIVE, COOLDOWN }

var mind_passive_state: AbilityState = AbilityState.UNREADY
var soul_passive_state: AbilityState = AbilityState.UNREADY
var heart_passive_state: AbilityState = AbilityState.UNREADY
var skill_technique_state: AbilityState = AbilityState.UNREADY
var special_technique_state: AbilityState = AbilityState.UNREADY
var super_technique_state: AbilityState = AbilityState.UNREADY

# --- Timers (Using SceneTreeTimers for simplicity, could use Timer nodes) ---
var mind_passive_cooldown_timer = null
var soul_passive_cooldown_timer = null
var heart_passive_cooldown_timer = null
var skill_technique_duration_timer = null
var skill_technique_cooldown_timer = null
var special_technique_duration_timer = null
var special_technique_cooldown_timer = null
var super_technique_duration_timer = null # "SU" likely means 'Sustained' or requires manual deactivation/duration elsewhere
var super_technique_cooldown_timer = null

# --- Event Signals for Passives (Can be configured per specialist) ---
# These define *what* game event triggers the passive check
var mind_trigger_signal: String = "status_effect_applied" # Example: Check when any status effect is applied
var soul_trigger_signal: String = "weapon_fired"         # Example: Check when any weapon fires
var heart_trigger_signal: String = "summon_used"         # Original: Check when a summon ability is used

# --- Specialist Definition Data ---
# Using more descriptive keys and adding potential resource costs/types
var specialist_info = {
	"Name": SPECIALIST_NAME,
	"Description": "Lone warrior, fierce and ferocious, who serves no one but themselves. Born without loyalty, dies free.",
	"Weapon_Proficiency": "Melee", # Primary weapon type
	"Attributes": ["Agility", "Stealth"], # Primary attributes this class scales with
	"Passives": {
		"Mind": {
			"Name": "Iron Will",
			"Description": "Gain immunity to [b]Chill[/b]. Become [b]Unflinching[/b] while below 25% Health.",
			"Trigger": mind_trigger_signal, # Connects to the signal name
			"Implementation": "_apply_mind_passive", # Function to call when triggered
			"Persistent": true # Does this passive apply constantly while active?
		},
		"Soul": {
			"Name": "Predator's Edge",
			"Description": "Increase [b]CHG[/b] (Charge Speed) by [b]10[/b] on [b]Melee Weapons[/b]. Landing a Critical Hit grants [b]1[/b] stack of [b]Momentum[/b] (Max 5).",
			"Trigger": soul_trigger_signal, # Example: Could be "critical_hit_landed"
			"Implementation": "_apply_soul_passive",
			"Persistent_Stat_Bonuses": { "CHG_Melee": 10 }, # Stats applied just by activating the specialist
			"Cooldown": 1.0 # Cooldown between Momentum stack gains
		},
		"Heart": {
			"Name": "Relentless Assault",
			"Description": "Using a [b]Summon[/b] instantly recharges [b]Melee Weapons[/b], starts [b]Stamina Recovery[/b], and grants [b]Haste[/b] for 5 seconds.",
			"Trigger": heart_trigger_signal,
			"Implementation": "_apply_heart_passive",
			"Cooldown": 15.0 # Cooldown for the entire passive effect
		}
	},
	"Techniques": {
		"Skill": {
			"Name": "Shadow Strike",
			"Description": "Increase [b]CHG[/b] by [b]20[/b] on [b]Melee Weapons[/b]. Your next Melee attack deals bonus [b]Shadow Damage[/b].",
			"Implementation": "_apply_skill_technique",
			"Duration": 10.0, # TD = Technique Duration
			"Cooldown": 30.0, # TC = Technique Cooldown
			"Resource_Cost": { "Stamina": 25 },
			"Buffs": { "CHG_Melee": 20 },
			"Effects": ["Apply_Shadow_Damage_On_Next_Hit"] # Special effect tags
		},
		"Special": {
			"Name": "Ghostwalk",
			"Description": "Become [b]Invisible[/b] and increase [b]SLS[/b] (Slice?) by [b]20[/b] on [b]Melee Weapons[/b]. Attacking breaks invisibility.",
			"Implementation": "_apply_special_technique",
			"Duration": 8.0,
			"Cooldown": 40.0,
			"Resource_Cost": { "Mana": 40 },
			"Buffs": { "SLS_Melee": 20 },
			"Effects": ["Apply_Invisibility"]
		},
		"Super": {
			"Name": "Umbral Embrace",
			"Description": "Gain [b]3[/b] stacks of [b]Darkborn[/b]. While active, drains Health but Melee attacks [b]Lifesteal[/b].",
			"Implementation": "_apply_super_technique",
			"Duration": "SU", # Sustained - potentially drains resource per second or lasts until toggled/resource depleted
			"Cooldown": 60.0,
			"Resource_Cost": { "Health": 50 }, # Initial cost
			"Sustained_Cost": { "Health_Per_Second": 5 }, # Example sustained cost
			"Effects": ["Apply_Darkborn_Stacks", "Apply_Lifesteal_Melee", "Apply_Health_Drain"]
		}
	}
}

# --- Level Rewards (More detailed structure) ---
var specialist_rewards = {
	0: {"Type": "Resource Crate", "Name": "Legendary Supply Crate", "Details": {"Resource": "Mithril Ore", "Amount": 5, "Value": 700}},
	1: {"Type": "Outfit", "Name": SPECIALIST_NAME + " Outfit", "Details": {"HP": 100, "MP": 0, "SHD": 50, "STM": 20, "Tier": "Obsidian", "Quality": 100}},
	2: {"Type": "Weapon", "Name": SPECIALIST_NAME + " " + specialist_info["Weapon_Proficiency"] + " Weapon", "Details": weapon_stats_m, "WeaponType": specialist_info["Weapon_Proficiency"]}, # Use proficiency
	3: {"Type": "Armor", "Name": SPECIALIST_NAME + " Belt", "Slot": "Belt", "Details": {"AG": 5, "CAP": 10, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
	4: {"Type": "Technique Unlock", "Name": specialist_info["Techniques"]["Skill"]["Name"], "TechniqueKey": "Skill"},
	5: {"Type": "Armor", "Name": SPECIALIST_NAME + " Pads", "Slot": "Pads", "Details": {"AG": 8, "CAP": 0, "STR": 3, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
	6: {"Type": "Technique Unlock", "Name": specialist_info["Techniques"]["Special"]["Name"], "TechniqueKey": "Special"},
	7: {"Type": "Armor", "Name": SPECIALIST_NAME + " Chest", "Slot": "Chest", "Details": {"AG": 5, "CAP": 0, "STR": 8, "SHR": 5, "Tier": "Obsidian", "Quality": 100}},
	8: {"Type": "Technique Unlock", "Name": specialist_info["Techniques"]["Super"]["Name"], "TechniqueKey": "Super"},
	9: {"Type": "Armor", "Name": SPECIALIST_NAME + " Body", "Slot": "Body", "Details": {"AG": 3, "CAP": 5, "STR": 5, "SHR": 8, "Tier": "Obsidian", "Quality": 100}},
	10: {"Type": "Artifact", "Name": SPECIALIST_NAME + " Heart Artifact", "Slot": "Heart", "Details": {"HP": 50, "MP": 25, "SHD": 0, "STM": 50, "SpecialEffect": "Rogue_Heart_Passive_Empowered", "Tier": "Obsidian", "Quality": 100}}
	# Potential for Post-Max Level rewards (Prestige?)
}

# --- Weapon Stat Templates (Kept as provided, could be loaded from resources) ---
var weapon_stats_r = {
	"DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}
var weapon_stats_m = {
	"POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}

# --- Initialization ---
func _ready():
	# Connect to a global signal dispatcher or PlayerStats if it handles activation signals
	# Assuming PlayerStats exists and emits "activate_specialist"
	if PlayerStats.is_connected("activate_specialist", Callable(self, "_on_specialist_activated")):
		print("Rogue: Already connected to activate_specialist")
	else:
		var err = PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))
		if err != OK:
			printerr("Rogue: Failed to connect to PlayerStats.activate_specialist")
	
	# Load state if persistence is needed across game sessions (beyond PlayerStats tracking)
	# _load_specialist_state() # Implement this if needed


# --- Activation / Deactivation Logic ---
func _on_specialist_activated(s_type: String):
	if s_type == SPECIALIST_NAME and not active:
		print("Activating Rogue Specialist")
		active = true
		# Tell PlayerStats this is the active specialist
		PlayerStats.set_specialist(SPECIALIST_NAME) # Assuming this function exists

		# Load Progress
		if PlayerStats.specialist_levels.has(SPECIALIST_NAME):
			var data = PlayerStats.specialist_levels[SPECIALIST_NAME]
			cur_level = data[0]
			cur_experience = data[1]
			experience_required = data[2]
		else:
			# First time activation or data lost - start fresh
			cur_level = 0
			cur_experience = 0
			experience_required = BASE_EXPERIENCE_REQUIRED
			specialist_unlock(0) # Grant level 0 reward
			PlayerStats.update_specialist(SPECIALIST_NAME, cur_level, cur_experience, experience_required)

		# Apply persistent passives and initial setup
		_apply_persistent_effects()
		_setup_event_listeners()
		_initialize_technique_states()

		emit_signal("level_changed", cur_level)
		emit_signal("experience_changed", cur_experience, experience_required)

	elif s_type != SPECIALIST_NAME and active:
		print("Deactivating Rogue Specialist")
		active = false
		# Remove persistent effects and listeners
		_remove_persistent_effects()
		_teardown_event_listeners()
		# Set all ability states to Unready
		mind_passive_state = AbilityState.UNREADY
		soul_passive_state = AbilityState.UNREADY
		heart_passive_state = AbilityState.UNREADY
		skill_technique_state = AbilityState.UNREADY
		special_technique_state = AbilityState.UNREADY
		super_technique_state = AbilityState.UNREADY
		# Clear any active status effects applied by this specialist
		_clear_all_specialist_status_effects()
		# Stop any active timers
		_cancel_all_timers()


# --- Experience and Leveling ---
func add_experience(value: int):
	if not active or cur_level >= MAX_LEVEL:
		return

	cur_experience += value
	var leveled_up = false

	while cur_experience >= experience_required and cur_level < MAX_LEVEL:
		cur_level += 1
		leveled_up = true
		print("Rogue leveled up to: ", cur_level)

		# Give generic rewards (if any)
		# PlayerStats.stat_points[0] += 2 # Assuming this structure exists
		# PlayerStats.element_points[0] += 2

		# Handle specific level unlocks
		specialist_unlock(cur_level)

		# Update experience
		cur_experience -= experience_required
		experience_required += EXPERIENCE_INCREMENT_PER_LEVEL # Simple linear increase

		emit_signal("level_changed", cur_level)

	# Save progress via PlayerStats
	PlayerStats.update_specialist(SPECIALIST_NAME, cur_level, cur_experience, experience_required)
	emit_signal("experience_changed", cur_experience, experience_required)

# --- Level Unlock Implementation ---
func specialist_unlock(level: int):
	if not specialist_rewards.has(level):
		printerr("Rogue: No reward defined for level ", level)
		return

	var reward = specialist_rewards[level]
	print("Rogue unlocking level ", level, " reward: ", reward["Name"])

	match reward["Type"]:
		"Resource Crate":
			# Assuming PlayerInventory.add_to_inventory exists and handles stacks/data
			PlayerInventory.add_to_inventory("Crafting Resource", reward["Details"]["Resource"], reward["Details"])
		"Outfit", "Armor", "Artifact":
			# Define item category based on reward type
			var category = reward["Type"]
			if reward.has("Slot"):
				category = reward["Slot"] + " Armor" # e.g., "Belt Armor"
			PlayerInventory.add_to_inventory(category, reward["Name"], reward["Details"])
		"Weapon":
			var weapon_type = reward.get("WeaponType", "Melee") # Default to Melee if not specified
			var stats_template = weapon_stats_m if weapon_type == "Melee" else weapon_stats_r
			# Merge specific reward details (like Name) with the template
			var final_stats = stats_template.duplicate(true) # Deep copy
			final_stats.merge(reward["Details"], true) # Overwrite template with specifics
			final_stats["Type"] = specialist_info.get("Weapon_Proficiency", "Unknown") # Set weapon type based on spec proficiency
			PlayerInventory.add_to_inventory(weapon_type + " Weapon", reward["Name"], final_stats)
		"Technique Unlock":
			# Enable the technique - state becomes READY after cooldown (or immediately if TC=0)
			var tech_key = reward["TechniqueKey"]
			match tech_key:
				"Skill":
					if skill_technique_state == AbilityState.UNREADY:
						_update_technique_state("Skill", AbilityState.READY) # Or COOLDOWN if initial TC > 0
						_start_technique_cooldown("Skill", 0) # Start ready
				"Special":
					if special_technique_state == AbilityState.UNREADY:
						_update_technique_state("Special", AbilityState.READY)
						_start_technique_cooldown("Special", 0)
				"Super":
					if super_technique_state == AbilityState.UNREADY:
						_update_technique_state("Super", AbilityState.READY)
						_start_technique_cooldown("Super", 0)
			print("Rogue: Unlocked Technique - ", reward["Name"])
		_:
			printerr("Rogue: Unknown reward type '", reward["Type"], "' for level ", level)


# --- Event Handling for Passive Triggers ---
func _game_event_handler(event_type: String, event_data = null):
	if not active: return

	# Check Mind Passive Trigger
	if event_type == mind_trigger_signal and mind_passive_state == AbilityState.READY:
		if specialist_info["Passives"]["Mind"].has("Implementation"):
			call(specialist_info["Passives"]["Mind"]["Implementation"], event_data)

	# Check Soul Passive Trigger
	if event_type == soul_trigger_signal and soul_passive_state == AbilityState.READY:
		if specialist_info["Passives"]["Soul"].has("Implementation"):
			call(specialist_info["Passives"]["Soul"]["Implementation"], event_data)

	# Check Heart Passive Trigger
	if event_type == heart_trigger_signal and heart_passive_state == AbilityState.READY:
		if specialist_info["Passives"]["Heart"].has("Implementation"):
			call(specialist_info["Passives"]["Heart"]["Implementation"], event_data)


# --- Passive Implementation Functions ---
# These functions contain the *actual logic* of the passives when triggered

func _apply_mind_passive(event_data = null):
	# Example: Implement Chill immunity and Unflinching
	# This assumes PlayerStats can grant immunity or check health
	print("Rogue: Mind Passive Triggered")
	
	# Check condition for Unflinching (if applicable based on event_data or player state)
	if PlayerStats.get_current_health_percentage() < 0.25:
		if not has_status_effect("Unflinching"):
			apply_status_effect("Unflinching", 1, -1, "Mind Passive") # Permanent while condition met
	else:
		if has_status_effect("Unflinching"):
			remove_status_effect("Unflinching")

	# If the passive has a cooldown after triggering
	var cooldown = specialist_info["Passives"]["Mind"].get("Cooldown", 0.0)
	if cooldown > 0:
		_update_passive_state("Mind", AbilityState.COOLDOWN)
		mind_passive_cooldown_timer = get_tree().create_timer(cooldown)
		mind_passive_cooldown_timer.connect("timeout", Callable(self, "_update_passive_state").bind("Mind", AbilityState.READY))


func _apply_soul_passive(event_data = null):
	# Example: Grant Momentum stack on Crit
	print("Rogue: Soul Passive Triggered (e.g., on Crit)")
	
	# Assuming event_data contains info about the event, like if it was a crit
	# Or assuming PlayerStats tracks the last hit type
	# if PlayerStats.last_hit_was_crit(): # Fictional check
	
	apply_status_effect("Momentum", 1, 10.0, "Soul Passive", true, 5) # Additive stack, 10s duration, max 5 stacks
	
	# Apply cooldown between stack gains
	var cooldown = specialist_info["Passives"]["Soul"].get("Cooldown", 0.0)
	if cooldown > 0:
		_update_passive_state("Soul", AbilityState.COOLDOWN)
		soul_passive_cooldown_timer = get_tree().create_timer(cooldown)
		soul_passive_cooldown_timer.connect("timeout", Callable(self, "_update_passive_state").bind("Soul", AbilityState.READY))

func _apply_heart_passive(event_data = null):
	print("Rogue: Heart Passive Triggered (Summon Used)")

	# 1. Instantly recharge Melee Weapons (Needs PlayerStats interaction)
	PlayerStats.recharge_weapon_type("Melee") # Fictional function

	# 2. Start Stamina Recovery (Needs PlayerStats interaction)
	PlayerStats.force_stamina_recovery(true) # Fictional function

	# 3. Grant Haste for 5 seconds (Apply as a status effect)
	apply_status_effect("Haste", 1, 5.0, "Heart Passive")

	# Apply cooldown for the passive
	var cooldown = specialist_info["Passives"]["Heart"].get("Cooldown", 0.0)
	if cooldown > 0:
		_update_passive_state("Heart", AbilityState.COOLDOWN)
		heart_passive_cooldown_timer = get_tree().create_timer(cooldown)
		heart_passive_cooldown_timer.connect("timeout", Callable(self, "_update_passive_state").bind("Heart", AbilityState.READY))


# --- Technique Activation Functions ---
# These are called by the player's input handler

func activate_skill_technique():
	if not active or skill_technique_state != AbilityState.READY:
		print("Rogue Skill not ready or specialist inactive.")
		return false

	var tech_data = specialist_info["Techniques"]["Skill"]

	# Check Resource Cost
	if not _check_and_consume_resources(tech_data.get("Resource_Cost", {})):
		print("Rogue Skill: Insufficient resources.")
		# PlayerFeedback.play_sound("error") # Give feedback
		return false

	print("Rogue: Activating Skill - ", tech_data["Name"])
	_update_technique_state("Skill", AbilityState.ACTIVE)

	# Apply Buffs/Effects
	if tech_data.has("Implementation"):
		call(tech_data["Implementation"]) # Call the specific logic function

	# Apply generic buffs listed
	_apply_technique_buffs("Skill", tech_data.get("Buffs", {}))

	# Handle Duration
	var duration = tech_data.get("Duration", 0.0)
	if duration > 0:
		skill_technique_duration_timer = get_tree().create_timer(duration)
		skill_technique_duration_timer.connect("timeout", Callable(self, "_on_technique_duration_end").bind("Skill"))
	else:
		# If no duration, go directly to cooldown
		_on_technique_duration_end("Skill")

	PlayerStats.emit_signal("player_event", "Technique Used", SPECIALIST_NAME, "Skill") # Announce technique use
	return true


func activate_special_technique():
	if not active or special_technique_state != AbilityState.READY:
		print("Rogue Special not ready or specialist inactive.")
		return false

	var tech_data = specialist_info["Techniques"]["Special"]
	if not _check_and_consume_resources(tech_data.get("Resource_Cost", {})):
		print("Rogue Special: Insufficient resources.")
		return false

	print("Rogue: Activating Special - ", tech_data["Name"])
	_update_technique_state("Special", AbilityState.ACTIVE)

	if tech_data.has("Implementation"):
		call(tech_data["Implementation"])
	_apply_technique_buffs("Special", tech_data.get("Buffs", {}))

	var duration = tech_data.get("Duration", 0.0)
	if duration > 0:
		special_technique_duration_timer = get_tree().create_timer(duration)
		special_technique_duration_timer.connect("timeout", Callable(self, "_on_technique_duration_end").bind("Special"))
	else:
		_on_technique_duration_end("Special")

	PlayerStats.emit_signal("player_event", "Technique Used", SPECIALIST_NAME, "Special")
	return true


func activate_super_technique():
	if not active or super_technique_state != AbilityState.READY:
		print("Rogue Super not ready or specialist inactive.")
		return false

	var tech_data = specialist_info["Techniques"]["Super"]
	if not _check_and_consume_resources(tech_data.get("Resource_Cost", {})):
		print("Rogue Super: Insufficient resources.")
		return false

	print("Rogue: Activating Super - ", tech_data["Name"])
	_update_technique_state("Super", AbilityState.ACTIVE)

	if tech_data.has("Implementation"):
		call(tech_data["Implementation"])
	_apply_technique_buffs("Super", tech_data.get("Buffs", {}))

	# Handle Duration ("SU" = Sustained)
	var duration = tech_data.get("Duration", 0.0)
	if duration == "SU":
		# Start sustained effects/costs here (e.g., using _process)
		# Needs a way to be deactivated (e.g., player input, running out of resource)
		print("Rogue Super is Sustained - requires manual deactivation or runs out of fuel.")
		# You might need a flag: var is_super_sustained = true
	elif duration > 0:
		super_technique_duration_timer = get_tree().create_timer(duration)
		super_technique_duration_timer.connect("timeout", Callable(self, "_on_technique_duration_end").bind("Super"))
	else:
		_on_technique_duration_end("Super") # No duration, just cooldown

	PlayerStats.emit_signal("player_event", "Technique Used", SPECIALIST_NAME, "Super")
	return true

# --- Technique Implementation Functions ---

func _apply_skill_technique():
	print("Applying Rogue Skill effects")
	# Example: Flag next melee hit for bonus shadow damage
	# This likely needs interaction with the combat system or PlayerStats
	PlayerStats.set_next_melee_hit_effect("Shadow_Damage_Bonus") # Fictional
	# Stat buffs (CHG_Melee) are handled by _apply_technique_buffs

func _apply_special_technique():
	print("Applying Rogue Special effects")
	# Example: Apply Invisibility status effect
	apply_status_effect("Invisibility", 1, specialist_info["Techniques"]["Special"]["Duration"], "Special Technique")
	# Player state might need changing (e.g., aggro radius)
	PlayerStats.set_state("Invisible", true) # Fictional

	# Need to handle breaking invisibility on attack
	# Connect to a player attack signal temporarily?
	# PlayerStats.connect("player_attacked", Callable(self, "_on_attack_break_invisibility"), CONNECT_ONE_SHOT)


func _apply_super_technique():
	print("Applying Rogue Super effects")
	# Example: Apply Darkborn stacks, Lifesteal, Health Drain
	apply_status_effect("Darkborn", 3, -1, "Super Technique") # Stacks, permanent until Super ends
	apply_status_effect("Melee_Lifesteal", 1, -1, "Super Technique") # Lifesteal active until Super ends
	apply_status_effect("Health_Drain", 5, -1, "Super Technique") # Drain 5 HP/sec until Super ends
	# The actual lifesteal/drain mechanics need implementation in PlayerStats or Combat system,
	# triggered by checking for these status effects.


# --- Technique Lifecycle Callbacks ---

func _on_technique_duration_end(tech_key: String):
	print("Rogue: ", tech_key, " duration ended.")
	var tech_data = specialist_info["Techniques"][tech_key]

	# Remove buffs applied by this technique
	_remove_technique_buffs(tech_key, tech_data.get("Buffs", {}))

	# Remove effects applied by this technique (e.g., Invisibility, specific status effects)
	_remove_technique_effects(tech_key)

	# If it was active, move to cooldown
	match tech_key:
		"Skill":
			if skill_technique_state == AbilityState.ACTIVE:
				_update_technique_state(tech_key, AbilityState.COOLDOWN)
				_start_technique_cooldown(tech_key, tech_data.get("Cooldown", 0.0))
		"Special":
			if special_technique_state == AbilityState.ACTIVE:
				_update_technique_state(tech_key, AbilityState.COOLDOWN)
				_start_technique_cooldown(tech_key, tech_data.get("Cooldown", 0.0))
		"Super":
			if super_technique_state == AbilityState.ACTIVE:
				# If sustained, this might be called by deactivation input instead
				_update_technique_state(tech_key, AbilityState.COOLDOWN)
				_start_technique_cooldown(tech_key, tech_data.get("Cooldown", 0.0))
				# Remove sustained effects here if duration ends
				# Example: remove_status_effect("Melee_Lifesteal"), remove_status_effect("Health_Drain")

func _start_technique_cooldown(tech_key: String, cooldown_time: float):
	if cooldown_time > 0:
		print("Rogue: Starting ", tech_key, " cooldown: ", cooldown_time)
		match tech_key:
			"Skill":
				skill_technique_cooldown_timer = get_tree().create_timer(cooldown_time)
				skill_technique_cooldown_timer.connect("timeout", Callable(self, "_update_technique_state").bind(tech_key, AbilityState.READY))
			"Special":
				special_technique_cooldown_timer = get_tree().create_timer(cooldown_time)
				special_technique_cooldown_timer.connect("timeout", Callable(self, "_update_technique_state").bind(tech_key, AbilityState.READY))
			"Super":
				super_technique_cooldown_timer = get_tree().create_timer(cooldown_time)
				super_technique_cooldown_timer.connect("timeout", Callable(self, "_update_technique_state").bind(tech_key, AbilityState.READY))
	else:
		# No cooldown, become ready immediately
		_update_technique_state(tech_key, AbilityState.READY)


# --- State Management ---

func _update_passive_state(passive_key: String, new_state: AbilityState):
	match passive_key:
		"Mind": mind_passive_state = new_state
		"Soul": soul_passive_state = new_state
		"Heart": heart_passive_state = new_state
	print("Rogue ", passive_key, " Passive state changed to: ", AbilityState.keys()[new_state])
	emit_signal("passive_state_changed", passive_key, AbilityState.keys()[new_state])

func _update_technique_state(tech_key: String, new_state: AbilityState):
	match tech_key:
		"Skill": skill_technique_state = new_state
		"Special": special_technique_state = new_state
		"Super": super_technique_state = new_state
	print("Rogue ", tech_key, " Technique state changed to: ", AbilityState.keys()[new_state])
	emit_signal("technique_state_changed", tech_key, AbilityState.keys()[new_state])


func _initialize_technique_states():
	# Set initial states based on unlocks (assuming level dictates unlocks)
	if cur_level >= specialist_rewards.find_key({"TechniqueKey": "Skill"}):
		_update_technique_state("Skill", AbilityState.READY) # Start ready
	else:
		_update_technique_state("Skill", AbilityState.UNREADY)

	if cur_level >= specialist_rewards.find_key({"TechniqueKey": "Special"}):
		_update_technique_state("Special", AbilityState.READY)
	else:
		_update_technique_state("Special", AbilityState.UNREADY)

	if cur_level >= specialist_rewards.find_key({"TechniqueKey": "Super"}):
		_update_technique_state("Super", AbilityState.READY)
	else:
		_update_technique_state("Super", AbilityState.UNREADY)


# --- Helper Functions ---

func _check_and_consume_resources(costs: Dictionary) -> bool:
	if costs.is_empty():
		return true # No cost

	# Check if PlayerStats has enough resources (fictional functions)
	for resource_type in costs:
		if not PlayerStats.has_resource(resource_type, costs[resource_type]):
			PlayerFeedback.show_message("Not enough " + resource_type) # Fictional UI feedback
			return false

	# If all checks pass, consume resources
	for resource_type in costs:
		PlayerStats.consume_resource(resource_type, costs[resource_type])

	return true

func _apply_persistent_effects():
	print("Rogue: Applying persistent effects")
	# Apply passive stat bonuses
	var soul_passive_stats = specialist_info["Passives"]["Soul"].get("Persistent_Stat_Bonuses", {})
	for stat in soul_passive_stats:
		PlayerStats.change_stat_modifier(stat, soul_passive_stats[stat], SPECIALIST_NAME + "_Soul_Passive") # Add modifier

	# Apply inherent immunities etc. from Mind passive
	if specialist_info["Passives"]["Mind"].get("Persistent", false):
		# Example: Apply Chill Immunity
		PlayerStats.add_status_immunity("Chill", SPECIALIST_NAME + "_Mind_Passive") # Fictional

	# Set initial passive states to Ready (if persistent or trigger-based)
	_update_passive_state("Mind", AbilityState.READY)
	_update_passive_state("Soul", AbilityState.READY)
	_update_passive_state("Heart", AbilityState.READY)

func _remove_persistent_effects():
	print("Rogue: Removing persistent effects")
	# Remove passive stat bonuses
	var soul_passive_stats = specialist_info["Passives"]["Soul"].get("Persistent_Stat_Bonuses", {})
	for stat in soul_passive_stats:
		PlayerStats.remove_stat_modifier(stat, SPECIALIST_NAME + "_Soul_Passive") # Remove modifier

	# Remove inherent immunities
	if specialist_info["Passives"]["Mind"].get("Persistent", false):
		PlayerStats.remove_status_immunity("Chill", SPECIALIST_NAME + "_Mind_Passive")

	# Set passives to Unready
	_update_passive_state("Mind", AbilityState.UNREADY)
	_update_passive_state("Soul", AbilityState.UNREADY)
	_update_passive_state("Heart", AbilityState.UNREADY)


func _apply_technique_buffs(tech_key: String, buffs: Dictionary):
	if buffs.is_empty(): return
	var source_name = SPECIALIST_NAME + "_" + tech_key + "_Technique"
	for stat in buffs:
		PlayerStats.change_stat_modifier(stat, buffs[stat], source_name)

func _remove_technique_buffs(tech_key: String, buffs: Dictionary):
	if buffs.is_empty(): return
	var source_name = SPECIALIST_NAME + "_" + tech_key + "_Technique"
	for stat in buffs:
		PlayerStats.remove_stat_modifier(stat, source_name)

func _remove_technique_effects(tech_key: String):
	# Remove specific status effects tied to the technique ending
	match tech_key:
		"Skill":
			PlayerStats.clear_next_melee_hit_effect("Shadow_Damage_Bonus") # Clear the flag
		"Special":
			remove_status_effect("Invisibility") # Remove invisibility when duration ends
			PlayerStats.set_state("Invisible", false) # Reset player state
			# Disconnect attack listener if used:
			# if PlayerStats.is_connected("player_attacked", Callable(self, "_on_attack_break_invisibility")):
			#    PlayerStats.disconnect("player_attacked", Callable(self, "_on_attack_break_invisibility"))
		"Super":
			# This might be handled differently if sustained/toggled
			remove_status_effect("Darkborn")
			remove_status_effect("Melee_Lifesteal")
			remove_status_effect("Health_Drain")


func _setup_event_listeners():
	# Connect to game events based on passive triggers
	# Assuming PlayerStats or a global dispatcher emits these signals
	if not PlayerStats.is_connected("game_event", Callable(self, "_game_event_handler")):
		var err = PlayerStats.connect("game_event", Callable(self, "_game_event_handler"))
		if err != OK:
			printerr("Rogue: Failed to connect to game_event signal.")

func _teardown_event_listeners():
	if PlayerStats.is_connected("game_event", Callable(self, "_game_event_handler")):
		PlayerStats.disconnect("game_event", Callable(self, "_game_event_handler"))

# --- Status Effect Management (Internal to this Specialist) ---

func apply_status_effect(effect_name: String, stacks: int = 1, duration: float = -1.0, source: String = "", additive: bool = true, max_stacks: int = -1):
	# This manages effects *applied by this specialist*. PlayerStats would have the global list.
	# This also tells PlayerStats to actually apply the effect's mechanics.

	var current_stacks = 0
	if active_status_effects.has(effect_name):
		current_stacks = active_status_effects[effect_name]["stacks"]

	var new_stacks = stacks
	if additive:
		new_stacks = current_stacks + stacks
	
	if max_stacks > 0:
		new_stacks = min(new_stacks, max_stacks)

	if new_stacks <= 0:
		remove_status_effect(effect_name)
		return

	# Stop existing timer if duration is reset/changed
	if active_status_effects.has(effect_name) and active_status_effects[effect_name].has("duration_timer"):
		var old_timer = active_status_effects[effect_name]["duration_timer"]
		if old_timer != null and is_instance_valid(old_timer): # Check if timer is valid
			 old_timer.disconnect("timeout", Callable(self, "remove_status_effect").bind(effect_name)) # Disconnect first
			 # No explicit cancel needed for SceneTreeTimer, just let it expire or replace it

	var effect_entry = {
		"stacks": new_stacks,
		"duration_timer": null, # Timer for removal
		"source": source
	}

	# Create a new timer if duration is positive
	var actual_duration = duration
	if active_status_effects.has(effect_name) and duration <= 0:
		# If refreshing an effect without changing duration, keep the old one if it exists and is valid
		var old_timer = active_status_effects[effect_name].get("duration_timer")
		if old_timer != null and is_instance_valid(old_timer) and old_timer.time_left > 0:
			effect_entry["duration_timer"] = old_timer
			actual_duration = old_timer.time_left # Report remaining duration
	elif duration > 0:
		var new_timer = get_tree().create_timer(duration)
		new_timer.connect("timeout", Callable(self, "remove_status_effect").bind(effect_name))
		effect_entry["duration_timer"] = new_timer
		actual_duration = duration

	active_status_effects[effect_name] = effect_entry
	
	# Notify PlayerStats to apply the actual game mechanics of the effect
	PlayerStats.apply_status_effect_mechanics(effect_name, new_stacks, source) # Fictional

	print("Rogue: Applied/Updated Status Effect - ", effect_name, " Stacks: ", new_stacks, " Duration: ", actual_duration)
	emit_signal("status_effect_changed", effect_name, new_stacks, actual_duration)


func remove_status_effect(effect_name: String):
	if active_status_effects.has(effect_name):
		print("Rogue: Removing Status Effect - ", effect_name)
		var effect_data = active_status_effects[effect_name]

		# Clean up timer connection if it exists and is valid
		var timer = effect_data.get("duration_timer")
		if timer != null and is_instance_valid(timer):
			if timer.is_connected("timeout", Callable(self, "remove_status_effect").bind(effect_name)):
				timer.disconnect("timeout", Callable(self, "remove_status_effect").bind(effect_name))

		active_status_effects.erase(effect_name)

		# Notify PlayerStats to remove the game mechanics
		PlayerStats.remove_status_effect_mechanics(effect_name, effect_data["source"]) # Fictional

		emit_signal("status_effect_changed", effect_name, 0, 0.0) # Signal removal

func has_status_effect(effect_name: String) -> bool:
	return active_status_effects.has(effect_name)

func get_status_effect_stacks(effect_name: String) -> int:
	if active_status_effects.has(effect_name):
		return active_status_effects[effect_name]["stacks"]
	return 0

func _clear_all_specialist_status_effects():
	# Iterate safely as remove_status_effect modifies the dictionary
	var effects_to_remove = active_status_effects.keys()
	for effect_name in effects_to_remove:
		remove_status_effect(effect_name)

# --- Timer Management ---
func _cancel_timer(timer_ref):
	if timer_ref != null and is_instance_valid(timer_ref):
		# SceneTreeTimers don't have a cancel, just disconnect and let them expire
		# Ensure all signal connections are severed if manually cancelling
		# This requires knowing what they were connected to.
		pass # For SceneTreeTimer, just nullifying the reference is usually enough

func _cancel_all_timers():
	# For SceneTreeTimers, just nullifying references prevents reuse.
	# If using Timer nodes, you'd call stop() here.
	mind_passive_cooldown_timer = null
	soul_passive_cooldown_timer = null
	heart_passive_cooldown_timer = null
	skill_technique_duration_timer = null
	skill_technique_cooldown_timer = null
	special_technique_duration_timer = null
	special_technique_cooldown_timer = null
	super_technique_duration_timer = null
	super_technique_cooldown_timer = null

	# Also cancel timers associated with status effects
	for effect_name in active_status_effects:
		var effect_data = active_status_effects[effect_name]
		var timer = effect_data.get("duration_timer")
		if timer != null and is_instance_valid(timer):
			if timer.is_connected("timeout", Callable(self, "remove_status_effect").bind(effect_name)):
				timer.disconnect("timeout", Callable(self, "remove_status_effect").bind(effect_name))
			effect_data["duration_timer"] = null # Clear reference


# --- Potential _process function for sustained effects ---
# func _process(delta):
# 	if not active: return
#
# 	# Handle sustained Super technique costs/effects
# 	if super_technique_state == AbilityState.ACTIVE and specialist_info["Techniques"]["Super"]["Duration"] == "SU":
# 		var sustained_cost = specialist_info["Techniques"]["Super"].get("Sustained_Cost", {})
# 		if not sustained_cost.is_empty():
# 			for resource_type in sustained_cost:
# 				cost_per_sec = sustained_cost[resource_type]
# 				if PlayerStats.has_resource(resource_type, cost_per_sec * delta):
# 					PlayerStats.consume_resource(resource_type, cost_per_sec * delta)
# 				else:
# 					# Out of fuel, deactivate Super
# 					print("Rogue Super ran out of fuel.")
# 					_on_technique_duration_end("Super") # Trigger end sequence
# 					break # Stop checking other costs for this frame
#
# 	# Handle status effect mechanics that need per-frame updates (like Health_Drain)
# 	if has_status_effect("Health_Drain"):
# 		var drain_amount = get_status_effect_stacks("Health_Drain") # Assuming stack = amount/sec
# 		PlayerStats.take_damage(drain_amount * delta, "Health_Drain Effect", true) # Fictional, true = ignore armor


# --- Cleanup ---
func _exit_tree():
	# Ensure listeners are removed when the node is removed from the scene
	_teardown_event_listeners()
	_cancel_all_timers()
	# If active, maybe try to remove persistent effects? Or rely on deactivate signal?
	if active:
		_remove_persistent_effects()
		_clear_all_specialist_status_effects()
