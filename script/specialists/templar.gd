extends Node

# Core Specialist Properties
var specialist_name = "Templar"
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000

# Arcane Energy Resource
var arcane_energy = 0
var max_arcane_energy = 10
var energy_timer = 0.0  # For passive energy regeneration

# Readiness States for Passives and Techniques
var mind_ready = null
var soul_ready = null
var heart_ready = null
var skill_ready = null
var special_ready = null
var super_ready = null
var pulse_ready = null  # New technique: Arcane Pulse

# Signal Triggers
var mind_signal = "Enemy Killed"
var soul_signal = "Spell Cast"  # Updated to trigger on spell casting
var heart_signal = ""

# Specialist Information with Enhanced Descriptions
var specialist_info = {
    "Name": "Templar",
    "Description": "Keeper of magic tomes, a bookworm with dealings in all sorts of otherworldly powers. Wisdom is a virtue.",
    "Weapon": "Staff",
    "Passive 1": {"Mind": "Killing an enemy grants [b]2[/b] stacks of [b]Energized[/b] and [b]1 Arcane Energy[/b]. Does not stack with itself."},
    "Passive 2": {"Soul": "Increase [b]PRC[/b] by [b]5 + (Level / 2)[/b] on all weapons. Casting a spell has a [b]10%[/b] chance to reset a random technique cooldown."},
    "Passive 3": {"Heart": "Regenerate [b]100 + (10 * Level)[/b] Magic Power per second."},
    "Technique 1": {"Skill": "Regenerate [b]2% Health[/b] per second for 5s. If [b]5 Arcane Energy[/b] is consumed, also gain [b]10% Magic Damage[/b] for 5s.", "TD": 5, "TC": 20},
    "Technique 2": {"Special": "[b]Magic Power[/b] depleted is converted into [b]Overshield[/b] for 15s. Conversion rate increases by [b]10%[/b] per Arcane Energy.", "TD": 15, "TC": 60},
    "Technique 3": {"Super": "Gain [b]3 + Arcane Energy[/b] stacks of [b]Soulborn[/b]. Consumes all Arcane Energy.", "TD": "SU", "TC": 60},
    "Technique 4": {"Arcane Pulse": "Consume all [b]Arcane Energy[/b] to deal area magic damage ([b]100% + 20% per Energy[/b] of Magic Power).", "TD": 1, "TC": 45}
}

# Expanded Specialist Rewards
var specialist_rewards = {
    "Level 0": "Legendary Supply Crate",
    "Level 1": "Specialist Outfit",
    "Level 2": "Specialist Exclusive Weapon",
    "Level 3": "Specialist Belt",
    "Level 4": "Specialist Skill",
    "Level 5": "Arcane Pulse Technique",
    "Level 6": "Specialist Special",
    "Level 7": "Tome of Wisdom",
    "Level 8": "Specialist Super",
    "Level 9": "Specialist Body",
    "Level 10": "Specialist Heart Artifact",
    "Level 15": "Choose: Master of Tomes or Arcane Savant"
}

# Weapon Stats for Staff (Ranged)
var weapon_stats_r = {
    "DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
    "CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 5, "FRC": 0,
    "Type": "Staff", "Tier": "Diamond", "Element": "Arcane", "Quality": 0, "Max Value": 100
}

# Weapon Stats for Melee (Unused but included for completeness)
var weapon_stats_m = {
    "POW": 1, "RCH": 1, "MOB": 1, "HND": 1, "BLK": 1, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 1, "WCP": 1,
    "CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 5, "FRC": 0,
    "Type": "Staff", "Tier": "Diamond", "Element": "Arcane", "Quality": 0, "Max Value": 100
}

### Initialization and Core Functions

func initialize():
    PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))

func _on_specialist_activated(s_type):
    if s_type == specialist_name and not active:
        active = true
        PlayerStats.set_specialist(specialist_name)
        if PlayerStats.specialist_levels.has(specialist_name):
            cur_level = PlayerStats.specialist_levels[specialist_name][0]
            cur_experience = PlayerStats.specialist_levels[specialist_name][1]
            experience_required = PlayerStats.specialist_levels[specialist_name][2]
        else:
            specialist_unlock(0)
            PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)
        apply_passives()
    elif s_type != specialist_name and active:
        active = false
        remove_passives()

func _process(delta):
    if active:
        energy_timer += delta
        if energy_timer >= 10.0:
            energy_timer -= 10.0
            arcane_energy = min(arcane_energy + 1, max_arcane_energy)

### Experience and Leveling

func exp_handler(value):
    if cur_level < 15 and active:  # Extended max level to 15
        cur_experience += value
        while cur_experience >= experience_required and cur_level < 15:
            cur_level += 1
            PlayerStats.stat_points[0] += 2
            PlayerStats.element_points[0] += 2
            cur_experience -= experience_required
            experience_required += 1000
            specialist_unlock(cur_level)
            apply_passives()  # Update passives on level up
        PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required)

func specialist_unlock(level):
    level = int(level)
    match level:
        0:
            PlayerInventory.add_to_inventory("Crafting Resource", "Mithril Ore", {"Amount": 5, "Value": 700})
        1:
            PlayerInventory.add_to_inventory("Outfit", specialist_name + " Outfit", {"HP": 0, "MP": 50, "SHD": 0, "STM": 0, "Tier": "Obsidian", "Quality": 100})
        2:
            PlayerInventory.add_to_inventory("Ranged Weapon", specialist_name + " Staff", weapon_stats_r)
        3:
            PlayerInventory.add_to_inventory("Belt Armor", specialist_name + " Belt", {"AG": 0, "CAP": 10, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100})
        4:
            PlayerInventory.add_to_inventory("Techniques", specialist_name + " Skill", {"Name": specialist_name, "Technique": "skill_technique"})
        5:
            PlayerInventory.add_to_inventory("Techniques", specialist_name + " Arcane Pulse", {"Name": specialist_name, "Technique": "pulse_technique"})
        6:
            PlayerInventory.add_to_inventory("Techniques", specialist_name + " Special", {"Name": specialist_name, "Technique": "special_technique"})
        7:
            PlayerInventory.add_to_inventory("Artifact", "Tome of Wisdom", {"MP": 20, "Quality": 100, "Effect": "Increase technique effects by 10%"})
        8:
            PlayerInventory.add_to_inventory("Techniques", specialist_name + " Super", {"Name": specialist_name, "Technique": "super_technique"})
        9:
            PlayerInventory.add_to_inventory("Body Armor", specialist_name + " Body", {"AG": 0, "CAP": 0, "STR": 0, "SHR": 20, "Tier": "Obsidian", "Quality": 100})
        10:
            PlayerInventory.add_to_inventory("Artifact", specialist_name + " Heart Artifact", {"HP": 50, "MP": 50, "SHD": 0, "STM": 0, "Tier": "Obsidian", "Quality": 100})
        15:
            # Placeholder for choice between "Master of Tomes" or "Arcane Savant"
            print("Choose: Master of Tomes (+20% spectral tome chance) or Arcane Savant (+5 Max Arcane Energy)")
        _:
            print("No Match Found!")

### Passive and Technique Management

func apply_passives():
    if active:
        var prc_bonus = 5 + int(cur_level / 2)
        var mp_regen = 100 + 10 * cur_level
        PlayerStats.add_stat("PRC", prc_bonus)
        PlayerStats.set_mp_regen(mp_regen)
        PlayerStats.change_passive(specialist_name, "mind_passive", "Add")

func remove_passives():
    var prc_bonus = 5 + int(cur_level / 2)
    var mp_regen = 100 + 10 * cur_level
    PlayerStats.add_stat("PRC", -prc_bonus)
    PlayerStats.set_mp_regen(0)
    PlayerStats.change_passive(specialist_name, "mind_passive", "Sub")

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

### Passives

func mind_passive(state):
    match state:
        "Ready":
            mind_ready = true
            if not PlayerStats.is_connected("player_event", Callable(self, "event_handler")) and mind_signal != "":
                PlayerStats.connect("player_event", Callable(self, "event_handler"))
        "Active":
            if mind_ready == true:
                mind_ready = false
                PlayerStats.add_energized_stacks(2)
                arcane_energy = min(arcane_energy + 1, max_arcane_energy)
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
                soul_ready = false
                if randf() < 0.1:  # 10% chance to reset a technique cooldown
                    reset_random_technique_cooldown()
                soul_passive("Cooldown")
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
        "Active":
            # Passive is always active, no trigger needed
            pass
        "Cooldown":
            pass
        "Unready":
            heart_ready = null

### Techniques

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
                if arcane_energy >= 5:
                    arcane_energy -= 5
                    PlayerStats.regenerate_health(0.02 * PlayerStats.max_health, 5)
                    PlayerStats.add_buff("Magic Damage", 0.1, 5)
                else:
                    PlayerStats.regenerate_health(0.02 * PlayerStats.max_health, 5)
                PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TD"], "Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TC"], "Ready")
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
                var conversion_rate = 1.0 + (0.1 * arcane_energy)
                PlayerStats.convert_mp_to_overshield(conversion_rate, 15)  # Assuming this function exists
                PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TD"], "Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TC"], "Ready")
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
                var additional_stacks = arcane_energy
                arcane_energy = 0
                PlayerStats.add_soulborn_stacks(3 + additional_stacks)
                PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TC"], "Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TC"], "Ready")
        "Unready":
            super_ready = null

func pulse_technique(state):
    match state:
        "Ready":
            if pulse_ready == null:
                pulse_ready = false
                pulse_technique("Cooldown")
            else:
             Ulse_ready = true
        "Active":
            if pulse_ready == true:
                pulse_ready = false
                var damage_multiplier = 1.0 + (0.2 * arcane_energy)
                arcane_energy = 0
                PlayerStats.deal_area_damage(damage_multiplier * PlayerStats.magic_power)  # Assuming this function exists
                PlayerStats.start_timer(specialist_name, "pulse_technique", specialist_info["Technique 4"]["TD"], "Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "pulse_technique", specialist_info["Technique 4"]["TC"], "Ready")
        "Unready":
            pulse_ready = null

### Utility Functions

func reset_random_technique_cooldown():
    var techniques = ["skill_technique", "special_technique", "super_technique", "pulse_technique"]
    var on_cooldown = []
    for tech in techniques:
        var ready_var = get(tech.split("_")[0] + "_ready")
        if ready_var == false:
            on_cooldown.append(tech)
    if on_cooldown.size() > 0:
        var random_tech = on_cooldown[randi() % on_cooldown.size()]
        set(random_tech.split("_")[0] + "_ready", true)

func get_ui_data():
    return {
        "level": cur_level,
        "experience": cur_experience,
        "experience_required": experience_required,
        "arcane_energy": arcane_energy,
        "techniques": {
            "skill": skill_ready,
            "special": special_ready,
            "super": super_ready,
            "pulse": pulse_ready
        }
    }
