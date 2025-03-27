extends Node

class_name SpecialistWarden

# Core Properties with Export Variables
@export var specialist_name: String = "Warden"
@export var max_level: int = 15  # Expanded progression
@export var base_exp_required: int = 1000
@export var exp_growth_factor: float = 1.25  # Exponential growth for higher levels
@export var specialist_faction: String = "Knights of Valor"  # New: Faction affiliation

var active: bool = false
var current_level: int = 0
var current_experience: int = 0
var experience_required: int = base_exp_required
var mastery_points: int = 0  # New: Earned through experience, spent on upgrades

# Technique Readiness States
var mind_ready: bool = true
var soul_ready: bool = true
var heart_ready: bool = true
var skill_ready: bool = false
var special_ready: bool = false
var super_ready: bool = false
var valor_strike_ready: bool = false  # New Technique
var guardian_aura_ready: bool = false  # New Technique
var knightly_resolve_ready: bool = false  # New Technique

# Passive Signals
var mind_signal: String = "Physical Damage Dealt"
var soul_signal: String = ""
var heart_signal: String = "Summon Used"

# Specialist Information with Expanded Lore
var specialist_info: Dictionary = {
    "Name": "Warden",
    "Description": "A highborn knight sworn to protect the realm. Forged in honor, tempered by duty, the Warden stands as a bastion against darkness.",
    "Weapon": "Great Sword",
    "Faction": "Knights of Valor",
    "Passives": {
        "Mind": "Dealing [b]Physical Damage[/b] grants [b]1[/b] stack of [b]Rage[/b]. Does not stack with itself.",
        "Soul": "Increase [b]POW[/b] by [b]5[/b] on [b]Melee Weapons[/b].",
        "Heart": "Using a [b]Summon[/b] instantly recharges [b]Melee Weapons[/b] and starts [b]Shield Recovery[/b].",
        "Guardian Aura": "Allies within range gain [b]10%[/b] damage reduction.",
        "Knightly Resolve": "When health drops below [b]30%[/b], gain [b]50%[/b] increased defense for [b]10[/b] seconds."
    },
    "Techniques": {
        "Skill": {"Description": "Remove all [b]Status Affliction[/b] of type [b]Frost[/b].", "TD": "SU", "TC": 10},
        "Special": {"Description": "Increase [b]CRD[/b] by [b]20[/b] on [b]Melee Weapons[/b].", "TD": 10, "TC": 40},
        "Super": {"Description": "[b]Summon[/b] gains [b]Damage Mitigation[/b] and increases [b]DEF[/b] by [b]50%[/b].", "TD": 30, "TC": 120},
        "Valor Strike": {"Description": "Deal [b]200%[/b] weapon damage to all enemies in a cone.", "TD": "SU", "TC": 25},
        "Guardian Aura": {"Description": "Activate an aura that reduces damage taken by allies by [b]15%[/b] for [b]15[/b] seconds.", "TD": 15, "TC": 60},
        "Knightly Resolve": {"Description": "Instantly heal [b]20%[/b] of max health and gain [b]30%[/b] damage reduction for [b]10[/b] seconds.", "TD": 10, "TC": 90}
    },
    "Lore": [
        "Born to nobility, the Warden swore an oath to protect the weak.",
        "His greatsword, forged in dragonfire, cleaves through darkness.",
        "Legends speak of his unwavering courage in the face of despair."
    ]
}

# Expanded Rewards per Level
var specialist_rewards: Dictionary = {
    0: {"Type": "Crafting Resource", "Item": "Legendary Supply Crate", "Data": {"Amount": 1, "Value": 1000}},
    1: {"Type": "Outfit", "Item": "Warden's Plate", "Data": {"HP": 50, "DEF": 20, "Tier": "Obsidian", "Quality": 100}},
    2: {"Type": "Melee Weapon", "Item": "Warden's Greatsword", "Data": weapon_stats_m.duplicate()},
    3: {"Type": "Belt Armor", "Item": "Warden's Girdle", "Data": {"STR": 10, "VIT": 10, "Tier": "Obsidian", "Quality": 100}},
    4: {"Type": "Technique", "Item": "Skill", "Data": {"Name": "Warden", "Technique": "skill_technique"}},
    5: {"Type": "Pad Armor", "Item": "Warden's Greaves", "Data": {"AGI": 5, "DEF": 15, "Tier": "Obsidian", "Quality": 100}},
    6: {"Type": "Technique", "Item": "Special", "Data": {"Name": "Warden", "Technique": "special_technique"}},
    7: {"Type": "Chest Armor", "Item": "Warden's Breastplate", "Data": {"HP": 100, "DEF": 30, "Tier": "Obsidian", "Quality": 100}},
    8: {"Type": "Technique", "Item": "Super", "Data": {"Name": "Warden", "Technique": "super_technique"}},
    9: {"Type": "Body Armor", "Item": "Warden's Full Plate", "Data": {"DEF": 50, "VIT": 20, "Tier": "Obsidian", "Quality": 100}},
    10: {"Type": "Artifact", "Item": "Warden's Heart", "Data": {"HP": 200, "DEF": 50, "Tier": "Mythic", "Quality": 150}},
    11: {"Type": "Technique", "Item": "Valor Strike", "Data": {"Name": "Warden", "Technique": "valor_strike"}},
    12: {"Type": "Melee Weapon", "Item": "Dragonfire Greatsword", "Data": weapon_stats_m.duplicate()},
    13: {"Type": "Technique", "Item": "Guardian Aura", "Data": {"Name": "Warden", "Technique": "guardian_aura"}},
    14: {"Type": "Crafting Resource", "Item": "Dragon Scales", "Data": {"Amount": 10, "Value": 500}},
    15: {"Type": "Artifact", "Item": "Warden's Legacy", "Data": {"HP": 300, "DEF": 100, "Tier": "Mythic", "Quality": 200}}
}

# Enhanced Melee Weapon Stats Template
var weapon_stats_m: Dictionary = {
    "POW": 15, "RCH": 3, "MOB": 2, "HND": 2, "BLK": 5, "CHG": 1, "ASP": 1, "STE": 0, "DUR": 100, "WCP": 1,
    "CRR": 5, "CRD": 50, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
    "Type": "Great Sword", "Tier": "Diamond", "Element": "Fire", "Quality": 75, "Max Value": 100
}

# New: Equipment Slots
var equipment: Dictionary = {
    "weapon": null,
    "armor": null,
    "shield": null,
    "accessory": null
}

# New: Status Effects Tracking
var status_effects: Dictionary = {}

# Signals for Gameplay Integration
signal level_up(new_level: int, reward: Dictionary)
signal technique_activated(technique: String)
signal passive_triggered(passive: String)
signal mastery_points_gained(amount: int)

# Lifecycle Methods
func _ready() -> void:
    initialize()

func initialize() -> void:
    """Set up connections and load initial data."""
    if not PlayerStats.is_connected("activate_specialist", _on_specialist_activated):
        PlayerStats.connect("activate_specialist", _on_specialist_activated)
    if not PlayerStats.is_connected("player_event", event_handler):
        PlayerStats.connect("player_event", event_handler)
    load_specialist_data()

func load_specialist_data() -> void:
    """Load or initialize specialist data from PlayerStats."""
    if PlayerStats.specialist_levels.has(specialist_name):
        var data = PlayerStats.specialist_levels[specialist_name]
        current_level = data[0]
        current_experience = data[1]
        experience_required = data[2]
        mastery_points = data[3] if data.size() > 3 else 0
    else:
        specialist_unlock(0)
        save_specialist_data()

func save_specialist_data() -> void:
    """Save current specialist state."""
    PlayerStats.update_specialist(specialist_name, current_level, current_experience, experience_required, mastery_points)

# Activation Logic
func _on_specialist_activated(s_type: String) -> void:
    if s_type == specialist_name and not active:
        activate_specialist()
    elif s_type != specialist_name and active:
        deactivate_specialist()

func activate_specialist() -> void:
    """Activate the specialist with full system integration."""
    active = true
    PlayerStats.set_specialist(specialist_name)
    apply_passives(true)
    apply_equipment_effects(true)
    save_specialist_data()

func deactivate_specialist() -> void:
    """Deactivate and clean up."""
    active = false
    apply_passives(false)
    apply_equipment_effects(false)
    clear_status_effects()
    save_specialist_data()

func apply_passives(enable: bool) -> void:
    """Apply or remove passive effects."""
    var action = "Add" if enable else "Sub"
    for passive in ["mind", "soul", "heart", "guardian_aura", "knightly_resolve"]:
        PlayerStats.change_passive(specialist_name, passive + "_passive", action)

func apply_equipment_effects(enable: bool) -> void:
    """Apply or remove equipment effects."""
    var action = "Add" if enable else "Sub"
    for slot in equipment:
        if equipment[slot]:
            PlayerStats.apply_item_effects(equipment[slot], action)

# Experience and Leveling
func exp_handler(value: int) -> void:
    """Manage experience gain and leveling."""
    if current_level >= max_level or not active:
        return
    current_experience += value
    mastery_points += int(value / 20)  # Earn mastery points
    emit_signal("mastery_points_gained", int(value / 20))
    while current_experience >= experience_required and current_level < max_level:
        level_up()
    save_specialist_data()

func level_up() -> void:
    """Handle level-up process."""
    current_level += 1
    current_experience -= experience_required
    experience_required = int(base_exp_required * pow(exp_growth_factor, current_level))
    PlayerStats.stat_points[0] += 3  # More stat points per level
    PlayerStats.element_points[0] += 2
    specialist_unlock(current_level)
    emit_signal("level_up", current_level, specialist_rewards[current_level])

func specialist_unlock(level: int) -> void:
    """Unlock rewards and techniques at specific levels."""
    if level in specialist_rewards:
        var reward = specialist_rewards[level]
        PlayerInventory.add_to_inventory(reward["Type"], reward["Item"], reward["Data"])
        if reward["Type"] == "Technique":
            unlock_technique(reward["Data"]["Technique"])
    unlock_lore_entry(level)

func unlock_technique(technique: String) -> void:
    """Enable a technique based on its name."""
    match technique:
        "skill_technique": skill_ready = true
        "special_technique": special_ready = true
        "super_technique": super_ready = true
        "valor_strike": valor_strike_ready = true
        "guardian_aura": guardian_aura_ready = true
        "knightly_resolve": knightly_resolve_ready = true

func unlock_lore_entry(level: int) -> void:
    """Unlock lore progressively as the specialist levels up."""
    if level - 1 < specialist_info["Lore"].size():
        print("Lore Unlocked: ", specialist_info["Lore"][level - 1])

# Event and Passive Management
func event_handler(event: String) -> void:
    """Respond to player events for passive activation."""
    if event == mind_signal:
        mind_passive("Active")
    if event == heart_signal:
        heart_passive("Active")
    if event == "Low Health":
        knightly_resolve_passive("Active")

func mind_passive(state: String) -> void:
    """Mind passive: Grants Rage on physical damage."""
    match state:
        "Ready":
            mind_ready = true
        "Active":
            if mind_ready:
                mind_ready = false
                PlayerStats.add_status_effect("Rage", 1)
                mind_passive("Cooldown")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "mind_passive", 5, Callable(self, "mind_passive").bind("Ready"))

func heart_passive(state: String) -> void:
    """Heart passive: Recharge weapons and recover shield on summon."""
    match state:
        "Ready":
            heart_ready = true
        "Active":
            if heart_ready:
                heart_ready = false
                PlayerStats.recharge_melee_weapons()
                PlayerStats.start_shield_recovery()
                heart_passive("Cooldown")
        "Cooldown":
            PlayerStats.start_timer(specialist_name, "heart_passive", 5, Callable(self, "heart_passive").bind("Ready"))

func knightly_resolve_passive(state: String) -> void:
    """New passive: Boost defense at low health."""
    if state == "Active" and PlayerStats.health < PlayerStats.max_health * 0.3:
        apply_status_effect("Knightly Resolve", 1, 10)

# Technique Functions
func skill_technique(state: String) -> void:
    """Skill: Remove Frost afflictions."""
    match state:
        "Ready":
            skill_ready = true
        "Active":
            if skill_ready:
                skill_ready = false
                PlayerStats.remove_status_affliction("Frost")
                emit_signal("technique_activated", "Skill")
                PlayerStats.start_timer(specialist_name, "skill_technique", specialist_info["Techniques"]["Skill"]["TC"], Callable(self, "skill_technique").bind("Ready"))

func special_technique(state: String) -> void:
    """Special: Boost critical damage on melee weapons."""
    match state:
        "Ready":
            special_ready = true
        "Active":
            if special_ready:
                special_ready = false
                PlayerStats.add_stat("CRD", 20, specialist_info["Techniques"]["Special"]["TD"])
                emit_signal("technique_activated", "Special")
                PlayerStats.start_timer(specialist_name, "special_technique", specialist_info["Techniques"]["Special"]["TC"], Callable(self, "special_technique").bind("Ready"))

func super_technique(state: String) -> void:
    """Super: Enhance summon with mitigation and defense."""
    match state:
        "Ready":
            super_ready = true
        "Active":
            if super_ready:
                super_ready = false
                PlayerStats.apply_summon_buff("Damage Mitigation", 0.5, specialist_info["Techniques"]["Super"]["TD"])
                PlayerStats.add_stat("DEF", 50, specialist_info["Techniques"]["Super"]["TD"])
                emit_signal("technique_activated", "Super")
                PlayerStats.start_timer(specialist_name, "super_technique", specialist_info["Techniques"]["Super"]["TC"], Callable(self, "super_technique").bind("Ready"))

func valor_strike(state: String) -> void:
    """New Technique: Deal AoE damage in a cone."""
    match state:
        "Ready":
            valor_strike_ready = true
        "Active":
            if valor_strike_ready:
                valor_strike_ready = false
                PlayerStats.deal_aoe_damage(2.0 * PlayerStats.get_weapon_damage())
                emit_signal("technique_activated", "Valor Strike")
                PlayerStats.start_timer(specialist_name, "valor_strike", specialist_info["Techniques"]["Valor Strike"]["TC"], Callable(self, "valor_strike").bind("Ready"))

func guardian_aura(state: String) -> void:
    """New Technique: Reduce ally damage taken."""
    match state:
        "Ready":
            guardian_aura_ready = true
        "Active":
            if guardian_aura_ready:
                guardian_aura_ready = false
                PlayerStats.apply_ally_buff("Damage Reduction", 0.15, specialist_info["Techniques"]["Guardian Aura"]["TD"])
                emit_signal("technique_activated", "Guardian Aura")
                PlayerStats.start_timer(specialist_name, "guardian_aura", specialist_info["Techniques"]["Guardian Aura"]["TC"], Callable(self, "guardian_aura").bind("Ready"))

func knightly_resolve(state: String) -> void:
    """New Technique: Heal and reduce damage taken."""
    match state:
        "Ready":
            knightly_resolve_ready = true
        "Active":
            if knightly_resolve_ready:
                knightly_resolve_ready = false
                PlayerStats.heal(0.2 * PlayerStats.max_health)
                apply_status_effect("Damage Reduction", 0.3, 10)
                emit_signal("technique_activated", "Knightly Resolve")
                PlayerStats.start_timer(specialist_name, "knightly_resolve", specialist_info["Techniques"]["Knightly Resolve"]["TC"], Callable(self, "knightly_resolve").bind("Ready"))

# Status Effect Management
func apply_status_effect(effect: String, value: float, duration: float) -> void:
    """Apply a status effect with a duration."""
    status_effects[effect] = {"value": value, "duration": duration}
    if duration > 0:
        PlayerStats.start_timer(specialist_name, effect + "_effect", duration, Callable(self, "_on_effect_finished").bind(effect))

func _on_effect_finished(effect: String) -> void:
    """Remove expired status effects."""
    status_effects.erase(effect)

func clear_status_effects() -> void:
    """Clear all active status effects."""
    status_effects.clear()

# Equipment Management
func equip_item(slot: String, item: Dictionary) -> void:
    """Equip an item in a specified slot."""
    if slot in equipment:
        if equipment[slot]:
            PlayerStats.apply_item_effects(equipment[slot], "Sub")
        equipment[slot] = item
        if active:
            PlayerStats.apply_item_effects(item, "Add")

func unequip_item(slot: String) -> void:
    """Unequip an item from a slot."""
    if slot in equipment and equipment[slot]:
        PlayerStats.apply_item_effects(equipment[slot], "Sub")
        equipment[slot] = null

# Utility Functions
func get_specialist_info() -> Dictionary:
    """Return specialist information."""
    return specialist_info

func get_level_progress() -> Dictionary:
    """Return current level progression data."""
    return {"level": current_level, "experience": current_experience, "experience_required": experience_required, "mastery_points": mastery_points}

func get_technique_status() -> Dictionary:
    """Return readiness status of all techniques."""
    return {
        "skill": skill_ready,
        "special": special_ready,
        "super": super_ready,
        "valor_strike": valor_strike_ready,
        "guardian_aura": guardian_aura_ready,
        "knightly_resolve": knightly_resolve_ready
    }

func get_equipment() -> Dictionary:
    """Return current equipment setup."""
    return equipment.duplicate()

func get_status_effects() -> Dictionary:
    """Return active status effects."""
    return status_effects.duplicate()
