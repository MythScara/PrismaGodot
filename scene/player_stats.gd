extends Node

# Signals for stat changes
signal health_changed(new_health, max_health)
signal experience_gained(new_experience, experience_to_level)
signal level_up(new_level)

# Player stats
var level: int = 1
var health: int = 100
var max_health: int = 100
var experience: int = 0
var experience_to_level: int = 100

# References to UI nodes
@onready var health_bar = $CanvasLayer/StatsUI/HealthBar
@onready var exp_bar = $CanvasLayer/StatsUI/ExperienceBar
@onready var stats_label = $CanvasLayer/StatsUI/StatsLabel

func _ready():
    # Load stats on startup
    load_stats()
    update_ui()

func take_damage(amount: int):
    health -= amount
    if health < 0:
        health = 0
    health_changed.emit(health, max_health)
    update_ui()
    if health <= 0:
        game_over()

func heal(amount: int):
    health += amount
    if health > max_health:
        health = max_health
    health_changed.emit(health, max_health)
    update_ui()

func gain_experience(amount: int):
    experience += amount
    while experience >= experience_to_level:
        experience -= experience_to_level
        level_up_player()
    experience_gained.emit(experience, experience_to_level)
    update_ui()

func level_up_player():
    level += 1
    max_health += 10
    health = max_health
    experience_to_level = calculate_experience_to_level(level)
    level_up.emit(level)
    update_ui()

func calculate_experience_to_level(current_level: int) -> int:
    # Example formula: increases by 100 per level
    return 100 * current_level

func game_over():
    print("Game Over")
    # Implement game over logic here

func update_ui():
    health_bar.value = (float(health) / max_health) * 100
    exp_bar.value = (float(experience) / experience_to_level) * 100
    stats_label.text = "Level: %d\nHealth: %d/%d\nExperience: %d/%d" % [level, health, max_health, experience, experience_to_level]

func save_stats():
    # Save stats to a file
    var file = FileAccess.open("user://player_stats.save", FileAccess.WRITE)
    if file:
        file.store_var({
            "level": level,
            "health": health,
            "max_health": max_health,
            "experience": experience,
            "experience_to_level": experience_to_level
        })
        file.close()

func load_stats():
    # Load stats from a file
    var file = FileAccess.open("user://player_stats.save", FileAccess.READ)
    if file and file.is_open():
        var data = file.get_var()
        if data:
            level = data["level"]
            health = data["health"]
            max_health = data["max_health"]
            experience = data["experience"]
            experience_to_level = data["experience_to_level"]
        file.close()
