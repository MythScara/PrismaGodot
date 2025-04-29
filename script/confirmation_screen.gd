extends Control

# Constant array of available difficulty levels
const DIFFICULTIES = ["Easy", "Medium", "Hard"]

# Exported variable for hover sound (optional, assign in editor)
@export var hover_sound: AudioStream

func _ready():
    # Validate required nodes
    _validate_nodes()
    
    # Initialize UI based on saved game state
    if GameManager.has_saved_game():
        $StartAdventureButton.text = "Continue Adventure"
    else:
        $StartAdventureButton.text = "Start Adventure"
    
    # Set default difficulty if not already set and update button text
    if PlayerStats.difficulty == "":
        PlayerStats.difficulty = "Medium"  # Default difficulty
    $DifficultyButton.text = PlayerStats.difficulty
    
    # Hide stats label initially
    $StatsLabel.hide()
    
    # Ensure player is not active when this menu loads
    PlayerStats.player_active = false
    
    # Connect fade animation signal
    if $FadeAnimation:
        $FadeAnimation.connect("animation_finished", _on_fade_animation_finished)

# Validate presence of required nodes
func _validate_nodes():
    var required_nodes = ["StartAdventureButton", "DifficultyButton", "StatsLabel", "ButtonSound"]
    for node_name in required_nodes:
        if not has_node(node_name):
            print("Warning: Missing required node: %s" % node_name)

# Centralized function to change scenes with a fade-out animation
func change_scene_with_fade(scene_path: String):
    if $FadeAnimation:
        $FadeAnimation.play("fade_out")
        # Scene change handled in _on_fade_animation_finished
    else:
        _change_scene_directly(scene_path)

func _on_fade_animation_finished(anim_name: String):
    if anim_name == "fade_out":
        var scene_path = _get_pending_scene_path()
        if scene_path:
            _change_scene_directly(scene_path)

func _change_scene_directly(scene_path: String):
    var error = get_tree().change_scene_to_file(scene_path)
    if error != OK:
        print("Failed to load scene: %s, Error: %d" % [scene_path, error])

# Placeholder for tracking pending scene path (customize as needed)
var _pending_scene = ""
func _get_pending_scene_path() -> String:
    return _pending_scene

func _set_pending_scene_path(path: String):
    _pending_scene = path

# Play sound effect for button interactions
func _play_button_sound():
    if $ButtonSound:
        $ButtonSound.play()

# Optional hover sound for buttons
func _on_button_hovered():
    if hover_sound and $HoverSound:
        $HoverSound.stream = hover_sound
        $HoverSound.play()

func _on_start_adventure_button_pressed():
    _play_button_sound()
    
    # Randomize weapons with error checking
    if PlayerStats.ranged_stats["Tier"] == null:
        var ranged_success = await PlayerStats.randomize_weapon("Ranged")
        if not ranged_success:
            print("Error: Failed to randomize ranged weapon")
            return
    if PlayerStats.melee_stats["Tier"] == null:
        var melee_success = await PlayerStats.randomize_weapon("Melee")
        if not melee_success:
            print("Error: Failed to randomize melee weapon")
            return
    
    # Activate specialist and setup
    PlayerStats.emit_signal("activate_specialist", PlayerStats.specialist)
    PlayerInterface.initial_setup()
    GameManager.save_game()
    PlayerStats.player_active = true
    PlayerInterface.swap_active("None")
    
    # Transition with fade
    _set_pending_scene_path("res://scene/test_level_scene.tscn")
    change_scene_with_fade(_pending_scene)

func _on_return_button_pressed():
    _play_button_sound()
    $ReturnConfirmation.popup()

func _on_return_confirmed():
    _set_pending_scene_path("res://scene/main_menu.tscn")
    change_scene_with_fade(_pending_scene)

func _on_settings_button_pressed():
    _play_button_sound()
    _set_pending_scene_path("res://scene/settings_menu.tscn")
    change_scene_with_fade(_pending_scene)

# Toggle stats display with updated content
func _on_show_stats_button_pressed():
    _play_button_sound()
    if $StatsLabel.visible:
        $StatsLabel.hide()
    else:
        _update_stats_display()

# Update stats display in a separate function
func _update_stats_display():
    var stats_text = "Player Stats:\n"
    stats_text += "Ranged Tier: %s\n" % (PlayerStats.ranged_stats["Tier"] if PlayerStats.ranged_stats["Tier"] != null else "None")
    stats_text += "Melee Tier: %s\n" % (PlayerStats.melee_stats["Tier"] if PlayerStats.melee_stats["Tier"] != null else "None")
    $StatsLabel.text = stats_text
    $StatsLabel.show()

# Cycle through difficulty levels
func _on_difficulty_button_pressed():
    _play_button_sound()
    var current_index = DIFFICULTIES.find(PlayerStats.difficulty)
    if current_index == -1:
        PlayerStats.difficulty = DIFFICULTIES[0]
    else:
        PlayerStats.difficulty = DIFFICULTIES[(current_index + 1) % DIFFICULTIES.size()]
    $DifficultyButton.text = PlayerStats.difficulty
