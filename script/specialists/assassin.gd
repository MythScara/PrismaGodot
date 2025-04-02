extends Node

class_name SpecialistAssassin

# Core Specialist Properties
@export var specialist_name: String = "Assassin"
@export var max_level: int = 15  # Increased max level for more progression
@export var base_exp_required: int = 1000
@export var exp_growth_factor: float = 1.25  # Slightly steeper curve
@export var specialist_faction: String = "Shadow Syndicate"  # New: Ties to lore/world
@export var rarity: String = "Epic"  # New: Influences power scaling

var active: bool = false
var current_level: int = 0
var current_experience: int = 0
var experience_required: int = base_exp_required
var mastery_points: int = 0  # New: Currency for technique/passive upgrades

# New: Core Stats for Combat and Roleplay
var stats: Dictionary = {
    "stealth": 10,
    "agility": 15,
    "accuracy": 20,
    "critical_chance": 5,
    "critical_damage": 150
}

# Constants for Technique and Passive Names
const MIND = "mind"
const SOUL = "soul"
const HEART = "heart"
const SKILL = "skill"
const SPECIAL = "special"
const SUPER = "super"
const STEALTH_STRIKE = "stealth_strike"
const SHADOW_VEIL = "shadow_veil"
const EXECUTE = "execute"

# Enhanced Technique Definitions with Levels and Scaling
var techniques: Dictionary = {
    MIND: {"unlocked": true, "level": 1, "max_level": 5, "ready": true, "signal": "", "cooldown": 5.0, "exp": 0, "exp_to_level": 100},
    SOUL: {"unlocked": true, "level": 1, "max_level": 5, "ready": true, "signal": "", "cooldown": 5.0, "exp": 0, "exp_to_level": 100},
    HEART: {"unlocked": true, "level": 1, "max_level": 5, "ready": true, "signal": "Battle Item Used", "cooldown": 5.0, "exp": 0, "exp_to_level": 100},
    SKILL: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "", "duration": 10.0, "cooldown": 30.0, "exp": 0, "exp_to_level": 200},
    SPECIAL: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "", "duration": 10.0, "cooldown": 40.0, "exp": 0, "exp_to_level": 300},
    SUPER: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "", "duration": "SU", "cooldown": 60.0, "exp": 0, "exp_to_level": 500},
    STEALTH_STRIKE: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "Stealth Attack", "damage_multiplier": 1.5, "cooldown": 20.0, "exp": 0, "exp_to_level": 250},
    SHADOW_VEIL: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "", "stealth_bonus": 20, "duration": 8.0, "cooldown": 25.0, "exp": 0, "exp_to_level": 300},
    EXECUTE: {"unlocked": false, "level": 0, "max_level": 5, "ready": false, "signal": "Low Health Enemy", "execute_threshold": 20, "cooldown": 45.0, "exp": 0, "exp_to_level": 400}
}

# New: Independent Passive System
var passives: Dictionary = {
    "Poison Immunity": {"level": 1, "max_level": 3, "effect": "Reduces poison damage by 50% + 10% per level"},
    "Shadow Mobility": {"level": 1, "max_level": 3, "effect": "Increases MOB by 10 + 5 per level on ranged weapons"},
    "Item Synergy": {"level": 1, "max_level": 3, "effect": "Battle items reduce summon cooldown by 10% + 5% per level"},
    "Critical Precision": {"level": 0, "max_level": 5, "effect": "Increases critical chance by 2% per level"}
}

# New: Synergy System
var synergies: Dictionary = {
    "Night Predator": {"required": [STEALTH_STRIKE, SHADOW_VEIL], "effect": "Stealth Strike deals 25% more damage from Shadow Veil"},
    "Assassin’s Resolve": {"required": [EXECUTE, SUPER], "effect": "Execute resets Super cooldown on success"}
}

# Event to Passive Mapping
var event_to_passives: Dictionary = {
    "Battle Item Used": [HEART],
    "Stealth Attack": [STEALTH_STRIKE],
    "Low Health Enemy": [EXECUTE],
    "Critical Hit": [],
    "Stealth Broken": []
}

# Specialist Data (Expanded with Lore)
var specialist_info: Dictionary = {
    "Name": "Assassin",
    "Description": "A master of shadows, forged in betrayal. Once a knight of honor, now a silent blade seeking retribution.",
    "Faction": "Shadow Syndicate",
    "Weapon": "Handgun",
    "Passive": {
        "Mind": "Gain immunity to [b]Poison[/b].",
        "Soul": "Increase [b]MOB[/b] by [b]10[/b] on [b]Ranged Weapons[/b].",
        "Heart": "Using a [b]Battle Item[/b] reduces [b]Summon[/b] cooldown by [b]10%[/b]."
    },
    "Techniques": {
        "Skill": {"Description": "Increase [b]HND[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "Duration": 10, "Cooldown": 30},
        "Special": {"Description": "Increase [b]CRD[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "Duration": 10, "Cooldown": 40},
        "Super": {"Description": "Gain [b]3[/b] stacks of [b]Energized[/b].", "Duration": "SU", "Cooldown": 60},
        "Stealth Strike": {"Description": "Deal 1.5x damage from stealth.", "Cooldown": 20},
        "Shadow Veil": {"Description": "Boost stealth by 20 for 8s.", "Duration": 8, "Cooldown": 25},
        "Execute": {"Description": "Instantly kill enemies below 20% HP.", "Cooldown": 45}
    },
    "Lore": ["Betrayed by his king, he vowed vengeance.", "The shadows became his home.", "His blade strikes without warning."]
}

# Rewards per Level (Expanded)
var specialist_rewards: Dictionary = {
    0: {"Type": "Crafting Resource", "Item": "Legendary Supply Crate", "Data": {"Amount": 1, "Value": 1000}},
    1: {"Type": "Outfit", "Item": "Assassin Cloak", "Data": {"HP": 10, "STM": 5, "Tier": "Obsidian", "Quality": 100}},
    2: {"Type": "Ranged Weapon", "Item": "Shadow Handgun", "Data": weapon_stats_r.duplicate()},
    3: {"Type": "Belt Armor", "Item": "Stealth Belt", "Data": {"AG": 5, "SHR": 5, "Tier": "Obsidian", "Quality": 100}},
    4: {"Type": "Technique", "Item": "Skill", "Data": {"Name": "Assassin", "Technique": SKILL}},
    5: {"Type": "Pad Armor", "Item": "Shadow Pads", "Data": {"AG": 10, "Tier": "Obsidian", "Quality": 100}},
    6: {"Type": "Technique", "Item": "Special", "Data": {"Name": "Assassin", "Technique": SPECIAL}},
    7: {"Type": "Chest Armor", "Item": "Assassin Vest", "Data": {"SHD": 15, "Tier": "Obsidian", "Quality": 100}},
    8: {"Type": "Technique", "Item": "Super", "Data": {"Name": "Assassin", "Technique": SUPER}},
    9: {"Type": "Technique", "Item": "Stealth Strike", "Data": {"Name": "Assassin", "Technique": STEALTH_STRIKE}},
    10: {"Type": "Artifact", "Item": "Heart of Shadows", "Data": {"HP": 20, "SHD": 10, "Tier": "Obsidian", "Quality": 100}},
    11: {"Type": "Technique", "Item": "Shadow Veil", "Data": {"Name": "Assassin", "Technique": SHADOW_VEIL}},
    12: {"Type": "Ranged Weapon", "Item": "Nightmare Pistol", "Data": weapon_stats_r.duplicate()},
    13: {"Type": "Technique", "Item": "Execute", "Data": {"Name": "Assassin", "Technique": EXECUTE}},
    14: {"Type": "Crafting Resource", "Item": "Shadow Essence", "Data": {"Amount": 5, "Value": 500}},
    15: {"Type": "Artifact", "Item": "Assassin’s Legacy", "Data": {"HP": 30, "AG": 20, "Tier": "Mythic", "Quality": 150}}
}

# Weapon Stats Templates (Enhanced)
var weapon_stats_r: Dictionary = {
    "DMG": 10, "RNG": 5, "MOB": 5, "HND": 5, "AC": 3, "RLD": 2, "FR": 1, "MAG": 8, "DUR": 50, "WCP": 1,
    "CRR": 5, "CRD": 50, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
    "Type": "Handgun", "Tier": "Diamond", "Element": "Shadow", "Quality": 75, "Max Value": 100
}

var weapon_stats_m: Dictionary = {
    "POW": 12, "RCH": 3, "MOB": 4, "HND": 4, "BLK": 2, "CHG": 1, "ASP": 1, "STE": 5, "DUR": 60, "WCP": 1,
    "CRR": 3, "CRD": 40, "INF": 0, "SLS": 0, "PRC": 0, "FRC": 0,
    "Type": "Dagger", "Tier": "Diamond", "Element": "Shadow", "Quality": 75, "Max Value": 100
}

# New: Equipment Slots
var equipment: Dictionary = {
    "primary_weapon": null,
    "secondary_weapon": null,
    "armor": null,
    "accessory": null
}

# New: Status Effects
var status_effects: Dictionary = {}

# Signals
signal level_up(new_level: int, reward: Dictionary)
signal technique_activated(technique: String, level: int)
signal passive_triggered(passive: String, level: int)
signal mastery_points_gained(amount: int)
signal synergy_activated(synergy: String)
signal stat_updated(stat: String, value: int)

# Lifecycle Methods
func _ready() -> void:
    initialize()

func initialize() -> void:
    """Initialize with expanded signal connections."""
    if not PlayerStats.is_connected("activate_specialist", _on_specialist_activated):
        PlayerStats.connect("activate_specialist", _on_specialist_activated)
    if not PlayerStats.is_connected("player_event", event_handler):
        PlayerStats.connect("player_event", event_handler)
    SignalBus.connect("stealth_broken", _on_stealth_broken)
    SignalBus.connect("critical_hit", _on_critical_hit)
    load_specialist_data()
    apply_base_stats()

# Data Management
func load_specialist_data() -> void:
    """Load or initialize specialist data with equipment."""
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
    """Save specialist data including mastery points."""
    PlayerStats.update_specialist(specialist_name, current_level, current_experience, experience_required, mastery_points)

# Activation/Deactivation
func _on_specialist_activated(s_type: String) -> void:
    if s_type == specialist_name and not active:
        activate_specialist()
    elif s_type != specialist_name and active:
        deactivate_specialist()

func activate_specialist() -> void:
    """Activate with full system integration."""
    active = true
    PlayerStats.set_specialist(specialist_name)
    apply_passives(true)
    apply_equipment_effects(true)
    check_synergies()
    save_specialist_data()

func deactivate_specialist() -> void:
    """Deactivate with cleanup."""
    active = false
    apply_passives(false)
    apply_equipment_effects(false)
    clear_status_effects()
    save_specialist_data()

func apply_passives(enable: bool) -> void:
    """Apply or remove passives with scaling."""
    var action = "Add" if enable else "Sub"
    for passive in passives:
        var level = passives[passive]["level"]
        if level > 0:
            PlayerStats.change_passive(specialist_name, passive, action, level)
    for technique in techniques:
        if enable and techniques[technique]["signal"]:
            techniques[technique]["ready"] = true

func apply_equipment_effects(enable: bool) -> void:
    """Apply or remove equipment effects."""
    var action = "Add" if enable else "Sub"
    for slot in equipment:
        if equipment[slot]:
            PlayerStats.apply_item_effects(equipment[slot], action)

# Experience and Leveling
func exp_handler(value: int, source: String = "general") -> void:
    """Handle experience with source-specific logic."""
    if current_level >= max_level or not active:
        return
    current_experience += value
    mastery_points += int(value / 10)  # Gain mastery points
    emit_signal("mastery_points_gained", int(value / 10))
    while current_experience >= experience_required and current_level < max_level:
        level_up()
    save_specialist_data()
    if source in techniques:
        technique_exp_handler(source, value)

func level_up() -> void:
    """Comprehensive level-up logic."""
    current_level += 1
    current_experience -= experience_required
    experience_required = int(base_exp_required * pow(exp_growth_factor, current_level))
    upgrade_specialist()
    emit_signal("level_up", current_level, specialist_rewards[current_level])
    update_stats()

func upgrade_specialist() -> void:
    """Upgrade specialist with new unlocks."""
    PlayerStats.stat_points[0] += 3
    PlayerStats.element_points[0] += 2
    match current_level:
        4: unlock_technique(SKILL)
        6: unlock_technique(SPECIAL)
        8: unlock_technique(SUPER)
        9: unlock_technique(STEALTH_STRIKE)
        11: unlock_technique(SHADOW_VEIL)
        13: unlock_technique(EXECUTE)
    specialist_unlock(current_level)

func technique_exp_handler(technique: String, value: int) -> void:
    """Level up techniques independently."""
    var tech = techniques[technique]
    if tech["unlocked"] and tech["level"] < tech["max_level"]:
        tech["exp"] += value
        while tech["exp"] >= tech["exp_to_level"] and tech["level"] < tech["max_level"]:
            tech["level"] += 1
            tech["exp"] -= tech["exp_to_level"]
            tech["exp_to_level"] = int(tech["exp_to_level"] * 1.5)
            upgrade_technique(technique)

func upgrade_technique(technique: String) -> void:
    """Scale technique effects."""
    var tech = techniques[technique]
    match technique:
        STEALTH_STRIKE: tech["damage_multiplier"] += 0.2
        SHADOW_VEIL: tech["stealth_bonus"] += 5
        EXECUTE: tech["execute_threshold"] += 5
    print("Technique upgraded: ", technique, " to level ", tech["level"])

func specialist_unlock(level: int) -> void:
    """Unlock rewards with narrative integration."""
    if level in specialist_rewards:
        var reward = specialist_rewards[level]
        PlayerInventory.add_to_inventory(reward["Type"], reward["Item"], reward["Data"])
        if "Technique" in reward["Type"]:
            unlock_technique(reward["Data"]["Technique"])
    unlock_lore_entry(level)

func unlock_lore_entry(level: int) -> void:
    """Reveal lore progressively."""
    if level - 1 < specialist_info["Lore"].size():
        print("Lore Unlocked: ", specialist_info["Lore"][level - 1])

# Passive and Technique Management
func event_handler(event: String) -> void:
    """Handle events with expanded logic."""
    if event in event_to_passives:
        for passive in event_to_passives[event]:
            if techniques[passive]["ready"]:
                trigger_passive(passive)

func trigger_passive(passive: String) -> void:
    """Trigger passive with scaling."""
    var tech = techniques[passive]
    if not tech["ready"]:
        return
    tech["ready"] = false
    emit_signal("passive_triggered", passive, tech["level"])
    start_cooldown(passive)

func activate_technique(technique: String) -> void:
    """Activate technique with enhanced effects."""
    var tech = techniques[technique]
    if technique not in techniques or not tech["unlocked"] or not tech["ready"]:
        return
    tech["ready"] = false
    apply_technique_effect(technique)
    emit_signal("technique_activated", technique, tech["level"])
    var duration = tech.get("duration", 0)
    if duration and duration != "SU":
        PlayerStats.start_timer(specialist_name, technique + "_duration", duration, Callable(self, "_on_technique_duration_finished").bind(technique))
    else:
        _on_technique_duration_finished(technique)

func apply_technique_effect(technique: String) -> void:
    """Apply specific technique effects."""
    var tech = techniques[technique]
    match technique:
        SKILL: PlayerStats.add_stat("HND", 20 * tech["level"])
        SPECIAL: PlayerStats.add_stat("CRD", 20 * tech["level"])
        SUPER: apply_status_effect("Energized", 3 * tech["level"], -1)
        STEALTH_STRIKE: PlayerStats.apply_damage_multiplier(tech["damage_multiplier"])
        SHADOW_VEIL: update_stat("stealth", tech["stealth_bonus"])
        EXECUTE: execute_enemy(tech["execute_threshold"])

func execute_enemy(threshold: int) -> void:
    """Execute low-health enemies."""
    if PlayerStats.current_enemy_health <= threshold:
        PlayerStats.kill_enemy()
        exp_handler(500, EXECUTE)

func start_cooldown(item: String) -> void:
    """Start cooldown with dynamic scaling."""
    var adjusted_cooldown = get_adjusted_cooldown(item)
    PlayerStats.start_timer(specialist_name, item, adjusted_cooldown, Callable(self, "_on_cooldown_finished").bind(item))

func get_adjusted_cooldown(item: String) -> float:
    """Calculate adjusted cooldown with equipment bonuses."""
    var base = techniques[item]["cooldown"]
    var reduction = current_level * 0.5 + (equipment["accessory"] != null and equipment["accessory"].get("CDR", 0))
    return max(base - reduction, 1.0)

func _on_technique_duration_finished(technique: String) -> void:
    start_cooldown(technique)

func _on_cooldown_finished(item: String) -> void:
    techniques[item]["ready"] = true

# New: Stat Management
func apply_base_stats() -> void:
    """Apply initial stats."""
    for stat in stats:
        emit_signal("stat_updated", stat, stats[stat])

func update_stat(stat: String, value: int) -> void:
    """Update a stat dynamically."""
    stats[stat] += value
    emit_signal("stat_updated", stat, stats[stat])

# New: Status Effects
func apply_status_effect(effect: String, stacks: int, duration: float) -> void:
    """Apply a status effect."""
    status_effects[effect] = {"stacks": stacks, "duration": duration}
    if duration > 0:
        PlayerStats.start_timer(specialist_name, effect + "_effect", duration, Callable(self, "_on_effect_finished").bind(effect))

func _on_effect_finished(effect: String) -> void:
    status_effects.erase(effect)

func clear_status_effects() -> void:
    status_effects.clear()

# New: Equipment Management
func equip_item(slot: String, item: Dictionary) -> void:
    """Equip an item."""
    if slot in equipment:
        if equipment[slot]:
            PlayerStats.apply_item_effects(equipment[slot], "Sub")
        equipment[slot] = item
        if active:
            PlayerStats.apply_item_effects(item, "Add")
        check_synergies()

func unequip_item(slot: String) -> void:
    """Unequip an item."""
    if slot in equipment and equipment[slot]:
        PlayerStats.apply_item_effects(equipment[slot], "Sub")
        equipment[slot] = null

# New: Synergy System
func check_synergies() -> void:
    """Check and activate synergies."""
    for synergy in synergies:
        var req = synergies[synergy]["required"]
        if req.all(func(t): return techniques[t]["unlocked"]):
            emit_signal("synergy_activated", synergy)
            apply_synergy_effect(synergy)

func apply_synergy_effect(synergy: String) -> void:
    """Apply synergy bonuses."""
    match synergy:
        "Night Predator": techniques[STEALTH_STRIKE]["damage_multiplier"] += 0.25
        "Assassin’s Resolve": techniques[SUPER]["cooldown"] = 0 if PlayerStats.last_action == EXECUTE else techniques[SUPER]["cooldown"]

# New: Mastery System
func spend_mastery_points(technique_or_passive: String, amount: int) -> void:
    """Spend mastery points to upgrade techniques or passives."""
    if mastery_points < amount:
        return
    if technique_or_passive in techniques:
        techniques[technique_or_passive]["exp"] += amount * 50
        technique_exp_handler(technique_or_passive, amount * 50)
    elif technique_or_passive in passives and passives[technique_or_passive]["level"] < passives[technique_or_passive]["max_level"]:
        passives[technique_or_passive]["level"] += 1
        mastery_points -= amount
        if active:
            PlayerStats.change_passive(specialist_name, technique_or_passive, "Add", passives[technique_or_passive]["level"])

# Event Handlers
func _on_stealth_broken() -> void:
    event_handler("Stealth Broken")

func _on_critical_hit() -> void:
    event_handler("Critical Hit")
    exp_handler(100, "Critical Hit")

# Utility Methods
func get_specialist_info() -> Dictionary:
    return specialist_info

func get_level_progress() -> Dictionary:
    return {"level": current_level, "experience": current_experience, "experience_required": experience_required, "mastery_points": mastery_points}

func get_technique_status() -> Dictionary:
    var status = {}
    for tech in techniques:
        status[tech] = {
            "unlocked": techniques[tech]["unlocked"],
            "level": techniques[tech]["level"],
            "ready": techniques[tech]["ready"],
            "cooldown_remaining": PlayerStats.get_timer_remaining(specialist_name, tech) if not techniques[tech]["ready"] else 0.0
        }
    return status

func get_passive_status() -> Dictionary:
    return passives.duplicate()

func get_equipment() -> Dictionary:
    return equipment.duplicate()

func get_status_effects() -> Dictionary:
    return status_effects.duplicate()
