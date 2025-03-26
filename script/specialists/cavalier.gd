# CavalierSpecialist.gd
extends Node

#region Constants and Enums
# Define states for passives and techniques for clarity
enum AbilityState { UNREADY, READY, ACTIVE, COOLDOWN }

# Define keys used in specialist_info for easier access and less typos
const MIND: String = "Mind"
const SOUL: String = "Soul"
const HEART: String = "Heart"
const SKILL: String = "Skill"
const SPECIAL: String = "Special"
const SUPER: String = "Super"
const DESC: String = "Description"
const WEAPON: String = "Weapon"
const DURATION: String = "TD" # Technique Duration
const COOLDOWN: String = "TC" # Technique Cooldown

# Event Signals (match these with events emitted by PlayerStats)
const EVENT_PHYSICAL_DAMAGE_TAKEN: String = "Physical Damage Taken"
const EVENT_SUPPRESS_APPLIED: String = "Suppress Applied" # Example for Mind Passive trigger
const EVENT_RANGED_ATTACK: String = "Ranged Attack"       # Example for Soul Passive trigger
#endregion

#region Variables
var specialist_name: String = "Cavalier"
var active: bool = false
var cur_level: int = 0
var cur_experience: int = 0
var experience_required: int = 1000

# State variables for passives and techniques
var _mind_passive_state: AbilityState = AbilityState.UNREADY
var _soul_passive_state: AbilityState = AbilityState.UNREADY
var _heart_passive_state: AbilityState = AbilityState.UNREADY
var _skill_technique_state: AbilityState = AbilityState.UNREADY
var _special_technique_state: AbilityState = AbilityState.UNREADY
var _super_technique_state: AbilityState = AbilityState.UNREADY

# Signals expected from PlayerStats to trigger passives
# NOTE: Mind passive (Suppress Immunity) is likely always active, not event-triggered
# NOTE: Soul passive (+FR) is likely always active, not event-triggered
var mind_signal: String = "" # No trigger needed for constant immunity
var soul_signal: String = "" # No trigger needed for constant FR bonus
var heart_signal: String = EVENT_PHYSICAL_DAMAGE_TAKEN

# Detailed Specialist Information - Added more specific keys for values
var specialist_info: Dictionary = {
	"Name": "Cavalier",
	"Description": "Quick witted soldier trained to engage in close quarter combat. A flurry of bullets rather than pinpoint accuracy is the name of their game.",
	"Weapon": "Sub Machine Gun",
	"Passive 1": {
		MIND: "Gain immunity to [b]Suppress[/b].",
		"Effect_Type": "Immunity",
		"Status_Effect": "Suppress"
		},
	"Passive 2": {
		SOUL: "Increase [b]FR[/b] by [b]10[/b] on [b]Ranged Weapons[/b].",
		"Effect_Type": "Stat_Buff",
		"Stat": "FR",
		"Amount": 10.0,
		"Category": "Ranged Weapons"
		},
	"Passive 3": {
		HEART: "Taking [b]Physical Damage[/b] restores [b]2% Stamina[/b]. Can only occur once every [b]5 [/b]seconds.",
		"Effect_Type": "Resource_Restore",
		"Resource": "Stamina",
		"Percent": 2.0,
		COOLDOWN: 5.0 # Internal cooldown for the passive
		},
	"Technique 1": {
		SKILL: "Increase [b]MOB[/b] by [b]20[/b] on [b]Ranged Weapons[/b].",
		DURATION: 10.0, # Effect Duration
		COOLDOWN: 30.0, # Ability Cooldown
		"Effect_Type": "Stat_Buff_Timed",
		"Stat": "MOB",
		"Amount": 20.0,
		"Category": "Ranged Weapons"
		},
	"Technique 2": {
		SPECIAL: "[b]Stamina[/b] depleted is converted into [b]Overshield[/b].",
		DURATION: 15.0, # Effect Duration (Interpretation: For 15s, spent Stamina adds Overshield)
		COOLDOWN: 60.0, # Ability Cooldown
		"Effect_Type": "Conversion_Buff", # Custom effect type
		"Resource_In": "Stamina",
		"Resource_Out": "Overshield"
		},
	"Technique 3": {
		SUPER: "Gain [b]3[/b] stacks of [b]Momentum[/b].",
		DURATION: "SU", # Super Duration (often instant or channelled)
		COOLDOWN: 60.0, # Ability Cooldown (Super meter gain rate affects this)
		"Effect_Type": "Status_Effect_Apply",
		"Status_Effect": "Momentum",
		"Stacks": 3
		}
}

# Rewards per level - descriptions can be taken from specialist_info
var specialist_rewards: Dictionary = {
	0: "Legendary Supply Crate", # Initial unlock bonus
	1: "Specialist Outfit",
	2: "Specialist Exclusive Weapon",
	3: "Specialist Belt",
	4: "Specialist Skill Unlock", # Technique becomes available
	5: "Specialist Pads",
	6: "Specialist Special Unlock", # Technique becomes available
	7: "Specialist Chest",
	8: "Specialist Super Unlock", # Technique becomes available
	9: "Specialist Body",
	10: "Specialist Heart Artifact"
}

# Enhanced default stats for the Cavalier's SMG
var cavalier_weapon_stats_r: Dictionary = {
	"DMG": 12, "RNG": 60, "MOB": 90, "HND": 85, "AC": 70, "RLD": 80, "FR": 95, "MAG": 45, "DUR": 100, "WCP": 1,
	"CRR": 5, "CRD": 50, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "Sub Machine Gun", "Tier": "Diamond", "Element": "None", "Quality": 90, "Max Value": 100
}

# Template for Melee Weapon (Not used by Cavalier directly, but good to keep)
var weapon_stats_m: Dictionary = {
	"POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
	"CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
	"Type": "", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}
#endregion

#region Initialization and Activation
func _ready() -> void:
	# Connect to global signals ONCE. We'll check the 'active' flag inside handlers.
	if PlayerStats: # Basic check to see if PlayerStats exists
		if not PlayerStats.is_connected("activate_specialist", Callable(self, "_on_specialist_activated")):
			PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))
		if not PlayerStats.is_connected("player_event", Callable(self, "_event_handler")):
			PlayerStats.connect("player_event", Callable(self, "_event_handler")) # Connect general event handler
	else:
		printerr("CavalierSpecialist: PlayerStats singleton not found!")

func _on_specialist_activated(s_type: String) -> void:
	if s_type == specialist_name and not active:
		print("Activating Specialist: ", specialist_name)
		active = true
		# Ensure PlayerStats knows this is the current specialist
		if PlayerStats:
			PlayerStats.set_specialist(specialist_name)

			# Load or initialize level data
			if PlayerStats.specialist_levels.has(specialist_name):
				cur_level = PlayerStats.specialist_levels[specialist_name][0]
				cur_experience = PlayerStats.specialist_levels[specialist_name][1]
				experience_required = PlayerStats.specialist_levels[specialist_name][2]
			else:
				# First time activation, grant level 0 reward
				_specialist_unlock(0)
				PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)

			# Apply constant passives
			_apply_passive_effects(true)
			# Set initial states for triggered passives/techniques based on current level
			_update_ability_states()

		else:
			printerr("CavalierSpecialist: PlayerStats not found during activation!")

	elif s_type != specialist_name and active:
		print("Deactivating Specialist: ", specialist_name)
		active = false
		# Remove constant passives
		if PlayerStats:
			_apply_passive_effects(false)
		# Set all states to Unready when inactive
		_mind_passive_state = AbilityState.UNREADY
		_soul_passive_state = AbilityState.UNREADY
		_heart_passive_state = AbilityState.UNREADY
		_skill_technique_state = AbilityState.UNREADY
		_special_technique_state = AbilityState.UNREADY
		_super_technique_state = AbilityState.UNREADY
	# else: # Ignore if activating the already active specialist or deactivating an inactive one
	#    pass

# Sets the initial state of abilities based on unlock level when activated
func _update_ability_states() -> void:
	# Constant passives are handled by _apply_passive_effects

	# Heart Passive (Triggered) - Always available if Specialist active
	_set_passive_state(HEART, AbilityState.READY)

	# Techniques - Set to Ready/Cooldown based on unlock level
	_set_technique_state(SKILL, AbilityState.READY if cur_level >= 4 else AbilityState.UNREADY)
	_set_technique_state(SPECIAL, AbilityState.READY if cur_level >= 6 else AbilityState.UNREADY)
	_set_technique_state(SUPER, AbilityState.READY if cur_level >= 8 else AbilityState.UNREADY)

#endregion

#region Experience and Leveling
func gain_experience(value: int) -> void:
	if not active or cur_level >= 10:
		return # Only gain XP if active and not max level

	cur_experience += value
	print("%s gained %d XP (%d/%d)" % [specialist_name, value, cur_experience, experience_required])

	var leveled_up: bool = false
	while cur_experience >= experience_required and cur_level < 10:
		leveled_up = true
		cur_level += 1
		cur_experience -= experience_required
		experience_required += 1000 # Increase requirement for next level

		print("%s leveled up to Level %d!" % [specialist_name, cur_level])

		# Grant generic level up rewards (if any)
		if PlayerStats:
			PlayerStats.stat_points[0] += 2
			PlayerStats.element_points[0] += 2
			print("  Gained +2 Stat Points, +2 Element Points")

		# Grant specific level unlock
		_specialist_unlock(cur_level)

	if leveled_up:
		# Update ability states if a new technique was unlocked
		_update_ability_states()

	# Save progress
	if PlayerStats:
		PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)

# Grant rewards for reaching a specific level
func _specialist_unlock(level: int) -> void:
	if not PlayerInventory:
		printerr("CavalierSpecialist: PlayerInventory not found for unlocking rewards!")
		return

	var reward_desc: String = specialist_rewards.get(level, "Unknown Reward")
	print("  Level %d Unlock: %s" % [level, reward_desc])

	match level:
		0: # Initial Unlock Bonus
			PlayerInventory.add_to_inventory("Crafting Resource", "Mithril Ore", {"Amount": 5, "Value": 700})
		1: # Outfit
			PlayerInventory.add_to_inventory("Outfit", specialist_name + " Outfit", {"HP": 50, "MP": 0, "SHD": 20, "STM": 10, "Tier": "Obsidian", "Quality": 100})
		2: # Exclusive Weapon
			# Use the specific stats defined earlier
			var stats = cavalier_weapon_stats_r.duplicate(true)
			stats["Type"] = specialist_info[WEAPON] # Ensure type matches
			PlayerInventory.add_to_inventory("Ranged Weapon", specialist_name + " " + specialist_info[WEAPON], stats)
		3: # Belt
			PlayerInventory.add_to_inventory("Belt Armor", specialist_name + " Belt", {"AG": 5, "CAP": 10, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		4: # Skill Technique Unlock
			# The technique is now usable, state handled in _update_ability_states
			PlayerInventory.add_to_inventory("Techniques", specialist_name + " Skill", {"Name": specialist_name, "Technique": SKILL})
			_set_technique_state(SKILL, AbilityState.READY) # Ensure it's ready immediately if activated
		5: # Pads
			PlayerInventory.add_to_inventory("Pad Armor", specialist_name + " Pads", {"AG": 8, "CAP": 0, "STR": 3, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
		6: # Special Technique Unlock
			PlayerInventory.add_to_inventory("Techniques", specialist_name + " Special", {"Name": specialist_name, "Technique": SPECIAL})
			_set_technique_state(SPECIAL, AbilityState.READY)
		7: # Chest
			PlayerInventory.add_to_inventory("Chest Armor", specialist_name + " Chest", {"AG": 0, "CAP": 0, "STR": 10, "SHR": 5, "Tier": "Obsidian", "Quality": 100})
		8: # Super Technique Unlock
			PlayerInventory.add_to_inventory("Techniques", specialist_name + " Super", {"Name": specialist_name, "Technique": SUPER})
			_set_technique_state(SUPER, AbilityState.READY)
		9: # Body
			PlayerInventory.add_to_inventory("Body Armor", specialist_name + " Body", {"AG": 3, "CAP": 5, "STR": 8, "SHR": 3, "Tier": "Obsidian", "Quality": 100})
		10: # Heart Artifact
			# Assuming artifact grants the passive effect permanently or enhances it
			PlayerInventory.add_to_inventory("Artifact", specialist_name + " Heart Artifact", {"HP": 100, "MP": 0, "SHD": 0, "STM": 25, "Tier": "Obsidian", "Quality": 100, "SpecialEffect": "Enhance Heart Passive"})
		_:
			print("  No specific reward defined for level ", level)

#endregion

#region Event Handling
# Central handler for events from PlayerStats
func _event_handler(event_name: String, _event_data = null) -> void:
	# Ignore events if this specialist isn't active
	if not active:
		return

	# Check if the event matches a trigger for a ready passive
	if event_name == heart_signal and _heart_passive_state == AbilityState.READY:
		_trigger_passive(HEART)

	# Add other event triggers here if needed for future passives
	# Example:
	# if event_name == EVENT_SOME_OTHER_CONDITION and _some_other_passive_state == AbilityState.READY:
	#    _trigger_passive(SOME_OTHER_PASSIVE_KEY)

#endregion

#region Passive Abilities
# Applies or removes the effects of constant passives
func _apply_passive_effects(apply: bool) -> void:
	if not PlayerStats: return

	# Mind Passive: Suppress Immunity
	var mind_passive_info = specialist_info.get("Passive 1", {})
	if mind_passive_info.get("Effect_Type") == "Immunity":
		var status = mind_passive_info.get("Status_Effect", "")
		if status:
			if apply:
				PlayerStats.add_status_immunity(status, specialist_name + "_" + MIND)
				print("%s: Applied immunity to %s" % [specialist_name, status])
			else:
				PlayerStats.remove_status_immunity(status, specialist_name + "_" + MIND)
				print("%s: Removed immunity to %s" % [specialist_name, status])

	# Soul Passive: +FR on Ranged Weapons
	var soul_passive_info = specialist_info.get("Passive 2", {})
	if soul_passive_info.get("Effect_Type") == "Stat_Buff":
		var stat = soul_passive_info.get("Stat", "")
		var amount = soul_passive_info.get("Amount", 0.0)
		var category = soul_passive_info.get("Category", "")
		if stat and amount != 0.0:
			# Apply negative amount to remove the buff
			var value_to_apply = amount if apply else -amount
			PlayerStats.modify_stat(stat, value_to_apply, category, specialist_name + "_" + SOUL)
			print("%s: %s %s by %f for %s" % [specialist_name, "Applied" if apply else "Removed", stat, amount, category])


# Triggers the effect of an event-based passive and starts its cooldown
func _trigger_passive(passive_key: String) -> void:
	if not PlayerStats: return

	match passive_key:
		HEART:
			if _heart_passive_state != AbilityState.READY: return # Safety check
			var heart_info = specialist_info.get("Passive 3", {})
			if heart_info.get("Effect_Type") == "Resource_Restore":
				var percent = heart_info.get("Percent", 0.0)
				if percent > 0.0:
					PlayerStats.restore_stamina_percent(percent)
					print("%s Heart Passive: Restored %.1f%% Stamina" % [specialist_name, percent])

					# Start internal cooldown
					_set_passive_state(HEART, AbilityState.COOLDOWN)
					var cd = heart_info.get(COOLDOWN, 5.0)
					PlayerStats.start_timer(
						"%s_%s_CD" % [specialist_name, HEART],
						cd,
						Callable(self, "_set_passive_state").bind(HEART, AbilityState.READY)
					)
		# Add cases for other triggered passives here
		_:
			printerr("CavalierSpecialist: Attempted to trigger unknown passive key: ", passive_key)

# Sets the state of a passive ability
func _set_passive_state(passive_key: String, new_state: AbilityState) -> void:
	match passive_key:
		HEART:
			_heart_passive_state = new_state
			# print("Heart Passive State: ", AbilityState.keys()[new_state]) # Optional debug print
		# Add cases for other passives if they have states
		_:
			printerr("CavalierSpecialist: Attempted to set state for unknown passive key: ", passive_key)

#endregion

#region Active Techniques
# Public function to be called by player input to attempt using a technique
func use_technique(technique_key: String) -> void:
	if not active:
		print("Cannot use technique: %s specialist is not active." % specialist_name)
		return

	match technique_key:
		SKILL:
			if _skill_technique_state == AbilityState.READY:
				_activate_technique(SKILL)
			else:
				print("%s Skill is not ready (State: %s)" % [specialist_name, AbilityState.keys()[_skill_technique_state]])
		SPECIAL:
			if _special_technique_state == AbilityState.READY:
				_activate_technique(SPECIAL)
			else:
				print("%s Special is not ready (State: %s)" % [specialist_name, AbilityState.keys()[_special_technique_state]])
		SUPER:
			# Supers often have an additional cost (e.g., Super Meter) - check here
			# if PlayerStats.get_super_meter() >= 100: # Example check
			if _super_technique_state == AbilityState.READY:
				# PlayerStats.consume_super_meter(100) # Example cost
				_activate_technique(SUPER)
			else:
				print("%s Super is not ready (State: %s)" % [specialist_name, AbilityState.keys()[_super_technique_state]])
			# else:
			#    print("%s Super meter not full!" % specialist_name)
		_:
			printerr("CavalierSpecialist: Attempted to use unknown technique key: ", technique_key)

# Internal function to apply technique effects and manage state/cooldowns
func _activate_technique(technique_key: String) -> void:
	if not PlayerStats: return

	var tech_info: Dictionary
	var technique_index: int = -1 # For accessing the correct dictionary key

	match technique_key:
		SKILL:
			tech_info = specialist_info.get("Technique 1", {})
			technique_index = 1
			_set_technique_state(SKILL, AbilityState.ACTIVE) # Mark as active during effect (if applicable)
		SPECIAL:
			tech_info = specialist_info.get("Technique 2", {})
			technique_index = 2
			_set_technique_state(SPECIAL, AbilityState.ACTIVE)
		SUPER:
			tech_info = specialist_info.get("Technique 3", {})
			technique_index = 3
			# Supers are often instant, go straight to cooldown after effect
			# _set_technique_state(SUPER, AbilityState.ACTIVE) # Optional if effect is instant
		_:
			printerr("CavalierSpecialist: Invalid technique key in _activate_technique: ", technique_key)
			return

	if tech_info.is_empty():
		printerr("CavalierSpecialist: Could not find info for technique: ", technique_key)
		return

	print("%s used %s!" % [specialist_name, technique_key])
	PlayerStats.emit_signal("player_event", "Technique Used", {"specialist": specialist_name, "technique": technique_key})

	# Apply the actual effect based on "Effect_Type"
	var effect_type = tech_info.get("Effect_Type", "")
	var duration = tech_info.get(DURATION, 0.0) if typeof(tech_info.get(DURATION)) in [TYPE_INT, TYPE_FLOAT] else 0.0

	match effect_type:
		"Stat_Buff_Timed":
			var stat = tech_info.get("Stat", "")
			var amount = tech_info.get("Amount", 0.0)
			var category = tech_info.get("Category", "")
			if stat and amount != 0.0 and duration > 0.0:
				PlayerStats.modify_stat_timed(stat, amount, duration, category, "%s_%s" % [specialist_name, technique_key])
				print("  Applied +%f %s for %.1fs" % [amount, stat, duration])
		"Conversion_Buff": # Example: Stamina -> Overshield
			# Interpretation: Convert *currently depleted* Stamina instantly
			# More complex: Apply a buff that converts stamina spent *during* duration
			# Let's do a simpler instant conversion of current stamina for now:
			var current_stamina = PlayerStats.get_stat("STM")
			if current_stamina > 0:
				PlayerStats.add_overshield(current_stamina)
				PlayerStats.set_stamina(0) # Or maybe just drain it? Depends on design.
				print("  Converted %.1f Stamina into Overshield" % current_stamina)
			else:
				print("  No Stamina to convert.")
			# If it was a timed buff, we'd use PlayerStats.add_status_effect(...) here

		"Status_Effect_Apply":
			var status = tech_info.get("Status_Effect", "")
			var stacks = tech_info.get("Stacks", 1)
			# Assuming -1 duration means 'until consumed' or permanent while specialist active
			var effect_duration = -1.0
			if status:
				PlayerStats.add_status_effect(status, stacks, effect_duration, "%s_%s" % [specialist_name, technique_key])
				print("  Gained %d stacks of %s" % [stacks, status])

		_:
			print("  Technique effect type '%s' not implemented." % effect_type)


	# --- Manage Cooldowns and State Transitions ---
	var cooldown = tech_info.get(COOLDOWN, 0.0) if typeof(tech_info.get(COOLDOWN)) in [TYPE_INT, TYPE_FLOAT] else 0.0

	# If the technique has a duration and isn't instant (like Super might be)
	if duration > 0.0 and technique_key != SUPER:
		# Timer to transition from ACTIVE back to COOLDOWN (or READY if no cooldown)
		PlayerStats.start_timer(
			"%s_%s_DUR" % [specialist_name, technique_key],
			duration,
			Callable(self, "_technique_effect_ended").bind(technique_key)
		)
	else:
		# If no duration (instant effect) or it's the Super, go directly to cooldown management
		_technique_effect_ended(technique_key)


func _technique_effect_ended(technique_key: String) -> void:
	if not PlayerStats: return

	var tech_info: Dictionary
	match technique_key:
		SKILL: tech_info = specialist_info.get("Technique 1", {})
		SPECIAL: tech_info = specialist_info.get("Technique 2", {})
		SUPER: tech_info = specialist_info.get("Technique 3", {})
		_: return

	var cooldown = tech_info.get(COOLDOWN, 0.0) if typeof(tech_info.get(COOLDOWN)) in [TYPE_INT, TYPE_FLOAT] else 0.0

	if cooldown > 0.0:
		_set_technique_state(technique_key, AbilityState.COOLDOWN)
		print("%s %s is now on cooldown (%.1fs)" % [specialist_name, technique_key, cooldown])
		# Start the cooldown timer
		PlayerStats.start_timer(
			"%s_%s_CD" % [specialist_name, technique_key],
			cooldown,
			Callable(self, "_set_technique_state").bind(technique_key, AbilityState.READY)
		)
	else:
		# If no cooldown, it becomes ready immediately after effect ends
		_set_technique_state(technique_key, AbilityState.READY)


# Sets the state of a technique ability
func _set_technique_state(technique_key: String, new_state: AbilityState) -> void:
	# Prevent setting state if the technique isn't unlocked yet (unless setting to UNREADY)
	if new_state != AbilityState.UNREADY:
		match technique_key:
			SKILL:
				if cur_level < 4: return
			SPECIAL:
				if cur_level < 6: return
			SUPER:
				if cur_level < 8: return

	match technique_key:
		SKILL:
			_skill_technique_state = new_state
			# print("Skill State: ", AbilityState.keys()[new_state]) # Optional debug
		SPECIAL:
			_special_technique_state = new_state
			# print("Special State: ", AbilityState.keys()[new_state]) # Optional debug
		SUPER:
			_super_technique_state = new_state
			# print("Super State: ", AbilityState.keys()[new_state]) # Optional debug
		_:
			printerr("CavalierSpecialist: Attempted to set state for unknown technique key: ", technique_key)

	# Potentially emit a signal here for UI updates
	# emit_signal("technique_state_changed", technique_key, new_state)


#endregion

# Add a signal for UI if needed
# signal technique_state_changed(technique_key, new_state)
