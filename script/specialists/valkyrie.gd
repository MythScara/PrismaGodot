extends Node

# Core Specialist Properties
var specialist_name = "Valkyrie"
var active = false
var cur_level = 0
var cur_experience = 0
var experience_required = 1000
var max_level = 20  # Increased max level for extended progression

# Readiness States for Abilities
var mind_ready = null
var soul_ready = null
var heart_ready = null
var skill_ready = null
var special_ready = null
var super_ready = null
var shield_ready = null  # New technique
var reflect_ready = null  # New technique

# Event Signals for Passives
var mind_signal = "Health Below 50%"
var soul_signal = "Melee Attack Performed"
var heart_signal = "Support Item Used"
var balance_signal = "Level Up"  # New passive signal

# Specialist Information with Enhanced Descriptions
var specialist_info = {
    "Name": "Valkyrie",
    "Description": "Heavenly guards tasked with restoring balance and protecting the innocent. Their presence bolsters allies and deters foes.",
    "Weapon": "Warhammer",
    "Passive 1": {
        "Mind": "When [b]Health[/b] drops below [b]50%[/b], gain [b]2 + (Level / 5)[/b] stacks of [b]Unbreaking[/b] (scales with level). Does not stack with itself."
    },
    "Passive 2": {
        "Soul": "Each [b]Melee Attack[/b] increases [b]BLK[/b] by [b]10 + (Level / 2)[/b] for 5 seconds (scales with level, stacks up to 3 times)."
    },
    "Passive 3": {
        "Heart": "Using a [b]Support Item[/b] reduces [b]Summon[/b] cooldown by [b]10% + (Level * 2)%[/b] (scales with level)."
    },
    "Passive 4": {  # New Passive
        "Balance": "Upon [b]Level Up[/b], gain a temporary [b]Elemental Resistance[/b] buff (10% per level, lasts 30 seconds)."
    },
    "Technique 1": {
        "Skill": "Increase [b]BLK[/b] by [b]20 + (Level * 2)[/b] on [b]Melee Weapons[/b] for 10 seconds.", 
        "TD": 10,  # Technique Duration
        "TC": 30   # Technique Cooldown
    },
    "Technique 2": {
        "Special": "Next instance of [b]Magic Damage[/b] is nullified. If Level ≥ 10, also heal for [b]5% Max HP[/b].", 
        "TD": "SU",  # Single Use
        "TC": 20
    },
    "Technique 3": {
        "Super": "Gain [b]3 + (Level / 4)[/b] stacks of [b]Manawall[/b].", 
        "TD": "SU", 
        "TC": 60
    },
    "Technique 4": {  # New Technique: Shield of Valor
        "Shield": "Grant allies within 5 units [b]20 + (Level * 3)[/b] SHD for 8 seconds.", 
        "TD": 8, 
        "TC": 45
    },
    "Technique 5": {  # New Technique: Reflective Aura
        "Reflect": "Reflect [b]10% + (Level * 1%)[/b] of incoming damage back to attackers for 6 seconds.", 
        "TD": 6, 
        "TC": 50
    }
}

# Expanded Rewards System with Random Elements
var specialist_rewards = {
    "Level 0": {"Type": "Crafting Resource", "Item": "Mithril Ore", "Data": {"Amount": 5, "Value": 700}},
    "Level 1": {"Type": "Outfit", "Item": "Valkyrie Outfit", "Data": {"HP": 10, "MP": 5, "SHD": 0, "STM": 0, "Tier": "Obsidian", "Quality": 100}},
    "Level 2": {"Type": "Melee Weapon", "Item": "Valkyrie Warhammer", "Data": weapon_stats_m.duplicate()},
    "Level 3": {"Type": "Belt Armor", "Item": "Valkyrie Belt", "Data": {"AG": 5, "CAP": 10, "STR": 0, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
    "Level 4": {"Type": "Techniques", "Item": "Valkyrie Skill", "Data": {"Name": "Valkyrie", "Technique": "skill_technique"}},
    "Level 5": {"Type": "Pad Armor", "Item": "Valkyrie Pads", "Data": {"AG": 5, "CAP": 0, "STR": 5, "SHR": 0, "Tier": "Obsidian", "Quality": 100}},
    "Level 6": {"Type": "Techniques", "Item": "Valkyrie Special", "Data": {"Name": "Valkyrie", "Technique": "special_technique"}},
    "Level 7": {"Type": "Chest Armor", "Item": "Valkyrie Chest", "Data": {"AG": 0, "CAP": 0, "STR": 10, "SHR": 5, "Tier": "Obsidian", "Quality": 100}},
    "Level 8": {"Type": "Techniques", "Item": "Valkyrie Super", "Data": {"Name": "Valkyrie", "Technique": "super_technique"}},
    "Level 9": {"Type": "Body Armor", "Item": "Valkyrie Body", "Data": {"AG": 0, "CAP": 0, "STR": 0, "SHR": 10, "Tier": "Obsidian", "Quality": 100}},
    "Level 10": {"Type": "Artifact", "Item": "Valkyrie Heart Artifact", "Data": {"HP": 20, "MP": 10, "SHD": 10, "STM": 0, "Tier": "Obsidian", "Quality": 100}},
    "Level 15": {"Type": "Techniques", "Item": "Shield of Valor", "Data": {"Name": "Valkyrie", "Technique": "shield_technique"}},
    "Level 20": {"Type": "Techniques", "Item": "Reflective Aura", "Data": {"Name": "Valkyrie", "Technique": "reflect_technique"}}
}

# Weapon Stats Templates
var weapon_stats_r = {
    "DMG": 1, "RNG": 1, "MOB": 1, "HND": 1, "AC": 1, "RLD": 1, "FR": 1, "MAG": 1, "DUR": 1, "WCP": 1,
    "CRR": 0, "CRD": 0, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
    "Type": "", "Tier": "Diamond", "Element": "None", "Quality": 0, "Max Value": 100
}

var weapon_stats_m = {
    "POW": 10, "RCH": 2, "MOB": 1, "HND": 1, "BLK": 15, "CHG": 1, "ASP": 1, "STE": 1, "DUR": 10, "WCP": 1,
    "CRR": 5, "CRD": 10, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
    "Type": "Warhammer", "Tier": "Diamond", "Element": "Light", "Quality": 100, "Max Value": 100
}

# Skill Tree for Customization
var skill_tree = {
    "Defense": {"Points": 0, "Max": 10, "Effect": "Increase BLK by 2 per point"},
    "Support": {"Points": 0, "Max": 10, "Effect": "Reduce Technique Cooldowns by 1% per point"},
    "Retribution": {"Points": 0, "Max": 10, "Effect": "Increase reflected damage by 0.5% per point"}
}
var skill_points = 0

# Narrative Progression
var story_progress = {
    "Level 5": "The Valkyrie recalls her oath to protect the weak.",
    "Level 10": "A vision reveals her celestial origins.",
    "Level 15": "She senses a growing darkness threatening balance.",
    "Level 20": "The Valkyrie embraces her full divine power."
}

### Initialization and Activation

func initialize():
    PlayerStats.connect("activate_specialist", Callable(self, "_on_specialist_activated"))
    # Initialize passives
    mind_passive("Ready")
    soul_passive("Ready")
    heart_passive("Ready")
    balance_passive("Ready")

func _on_specialist_activated(s_type):
    if s_type == specialist_name and not active:
        active = true
        PlayerStats.set_specialist(specialist_name)
        load_specialist_data()
    elif s_type != specialist_name and active:
        active = false
        deactivate_passives()

func load_specialist_data():
    if PlayerStats.specialist_levels.has(specialist_name):
        cur_level = PlayerStats.specialist_levels[specialist_name][0]
        cur_experience = PlayerStats.specialist_levels[specialist_name][1]
        experience_required = PlayerStats.specialist_levels[specialist_name][2]
        skill_points = PlayerStats.specialist_levels[specialist_name][3] if PlayerStats.specialist_levels[specialist_name].size() > 3 else 0
    else:
        specialist_unlock(0)
        PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required, skill_points)

func deactivate_passives():
    PlayerStats.change_passive(specialist_name, "mind_passive", "Sub")
    PlayerStats.change_passive(specialist_name, "soul_passive", "Sub")
    PlayerStats.change_passive(specialist_name, "heart_passive", "Sub")
    PlayerStats.change_passive(specialist_name, "balance_passive", "Sub")

### Experience and Leveling System

func exp_handler(value):
    if cur_level >= max_level or not active:
        return
    cur_experience += value
    while cur_experience >= experience_required and cur_level < max_level:
        level_up()
    PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required, skill_points)

func level_up():
    cur_level += 1
    cur_experience -= experience_required
    experience_required = calculate_exp_required(cur_level)
    skill_points += 1
    PlayerStats.stat_points[0] += 2
    PlayerStats.element_points[0] += 2
    specialist_unlock(cur_level)
    if story_progress.has("Level " + str(cur_level)):
        PlayerStats.emit_signal("story_event", story_progress["Level " + str(cur_level)])

func calculate_exp_required(level):
    return int(1000 * pow(1.1, level))  # Exponential growth for experience

### Specialist Unlocks and Rewards

func specialist_unlock(level):
    if specialist_rewards.has("Level " + str(level)):
        var reward = specialist_rewards["Level " + str(level)]
        PlayerInventory.add_to_inventory(reward["Type"], reward["Item"], reward["Data"])
        if randf() < 0.2:  # 20% chance for bonus reward
            PlayerInventory.add_to_inventory("Crafting Resource", "Celestial Shard", {"Amount": 1, "Value": 1000})
    if cur_level >= 15:
        shield_technique("Ready")
    if cur_level >= 20:
        reflect_technique("Ready")

### Event Handling and Passives

func event_handler(event):
    if event == mind_signal:
        mind_passive("Active")
    if event == soul_signal:
        soul_passive("Active")
    if event == heart_signal:
        heart_passive("Active")
    if event == balance_signal:
        balance_passive("Active")

func connection_terminate():
    if mind_ready == null and soul_ready == null and heart_ready == null:
        if PlayerStats.is_connected("player_event", Callable(self, "event_handler")):
            PlayerStats.disconnect("player_event", Callable(self, "event_handler"))

func mind_passive(state):
    match state:
        "Ready":
            mind_ready = true
            connect_event_handler(mind_signal)
        "Active":
            if mind_ready:
                mind_ready = false
                var stacks = 2 + int(cur_level / 5)
                PlayerStats.add_buff("Unbreaking", stacks)
                mind_passive("Cooldown")
        "Cooldown":
            if not mind_ready:
                PlayerStats.start_timer(specialist_name, "mind_passive", 5, "Ready")
        "Unready":
            mind_ready = null
            connection_terminate()

func soul_passive(state):
    match state:
        "Ready":
            soul_ready = true
            connect_event_handler(soul_signal)
        "Active":
            if soul_ready:
                var bonus = 10 + int(cur_level / 2)
                PlayerStats.add_buff("BLK", bonus, 5, 3)  # Stacks up to 3 times
                soul_passive("Cooldown")
        "Cooldown":
            if not soul_ready:
                PlayerStats.start_timer(specialist_name, "soul_passive", 5, "Ready")
        "Unready":
            soul_ready = null
            connection_terminate()

func heart_passive(state):
    match state:
        "Ready":
            heart_ready = true
            connect_event_handler(heart_signal)
        "Active":
            if heart_ready:
                heart_ready = false
                var reduction = 0.1 + (cur_level * 0.02)
                PlayerStats.reduce_summon_cooldown(reduction)
                heart_passive("Cooldown")
        "Cooldown":
            if not heart_ready:
                PlayerStats.start_timer(specialist_name, "heart_passive", 5, "Ready")
        "Unready":
            heart_ready = null
            connection_terminate()

func balance_passive(state):
    match state:
        "Ready":
            connect_event_handler(balance_signal)
        "Active":
            var resistance = cur_level * 0.1
            PlayerStats.add_buff("Elemental Resistance", resistance, 30)
        "Unready":
            connection_terminate()

func connect_event_handler(signal_name):
    if signal_name != "" and not PlayerStats.is_connected("player_event", Callable(self, "event_handler")):
        PlayerStats.connect("player_event", Callable(self, "event_handler"))

### Techniques

func skill_technique(state):
    match state:
        "Ready":
            skill_ready = skill_ready == null ? false : true
            if not skill_ready:
                skill_technique("Cooldown")
        "Active":
            if skill_ready:
                skill_ready = false
                var bonus = 20 + (cur_level * 2)
                PlayerStats.add_buff("BLK", bonus, specialist_info["Technique 1"]["TD"])
                skill_technique("Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Technique 1"]["TC"] * (1 - skill_tree["Support"]["Points"] * 0.01), "Ready")
        "Unready":
            skill_ready = null

func special_technique(state):
    match state:
        "Ready":
            special_ready = special_ready == null ? false : true
            if not special_ready:
                special_technique("Cooldown")
        "Active":
            if special_ready:
                special_ready = false
                PlayerStats.nullify_next_magic_damage()
                if cur_level >= 10:
                    PlayerStats.heal(0.05 * PlayerStats.max_hp)
                special_technique("Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Technique 2"]["TC"] * (1 - skill_tree["Support"]["Points"] * 0.01), "Ready")
        "Unready":
            special_ready = null

func super_technique(state):
    match state:
        "Ready":
            super_ready = super_ready == null ? false : true
            if not super_ready:
                super_technique("Cooldown")
        "Active":
            if super_ready:
                super_ready = false
                var stacks = 3 + int(cur_level / 4)
                PlayerStats.add_buff("Manawall", stacks)
                super_technique("Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Technique 3"]["TC"] * (1 - skill_tree["Support"]["Points"] * 0.01), "Ready")
        "Unready":
            super_ready = null

func shield_technique(state):
    match state:
        "Ready":
            shield_ready = shield_ready == null ? false : true
            if not shield_ready:
                shield_technique("Cooldown")
        "Active":
            if shield_ready:
                shield_ready = false
                var shield = 20 + (cur_level * 3)
                PlayerStats.apply_aoe_buff("SHD", shield, 5, specialist_info["Technique 4"]["TD"])
                shield_technique("Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "shield_technique", specialist_info["Technique 4"]["TC"] * (1 - skill_tree["Support"]["Points"] * 0.01), "Ready")
        "Unready":
            shield_ready = null

func reflect_technique(state):
    match state:
        "Ready":
            reflect_ready = reflect_ready == null ? false : true
            if not reflect_ready:
                reflect_technique("Cooldown")
        "Active":
            if reflect_ready:
                reflect_ready = false
                var reflect_pct = 0.1 + (cur_level * 0.01) + (skill_tree["Retribution"]["Points"] * 0.005)
                PlayerStats.add_buff("Reflect Damage", reflect_pct, specialist_info["Technique 5"]["TD"])
                reflect_technique("Cooldown")
                PlayerStats.emit_signal("player_event", "Technique Used")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "reflect_technique", specialist_info["Technique 5"]["TC"] * (1 - skill_tree["Support"]["Points"] * 0.01), "Ready")
        "Unready":
            reflect_ready = null

### Skill Tree Management

func spend_skill_point(branch):
    if skill_points > 0 and skill_tree[branch]["Points"] < skill_tree[branch]["Max"]:
        skill_tree[branch]["Points"] += 1
        skill_points -= 1
        PlayerStats.update_specialist(specialist_name, cur_level, cur_experience, experience_required, skill_points)
        apply_skill_effects(branch)

func apply_skill_effects(branch):
    match branch:
        "Defense":
            PlayerStats.add_permanent_stat("BLK", 2)
        "Support":
            pass  # Cooldown reduction applied in technique functions
        "Retribution":
            pass  # Reflect increase applied in reflect_technique

### Utility Functions

func get_ui_data():
    return {
        "Level": cur_level,
        "Experience": cur_experience,
        "Exp Required": experience_required,
        "Skill Points": skill_points,
        "Abilities": specialist_info,
        "Skill Tree": skill_tree
    }
