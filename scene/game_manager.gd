extends Node

# Signals for game events
signal game_state_changed(new_state)
signal scene_changed(new_scene)

# Enum for game states
enum GameState { PLAYING, PAUSED, GAME_OVER }

# Variables
var current_state: GameState = GameState.PLAYING
var current_scene: Node = null

# UI node reference
@onready var state_label = $CanvasLayer/StateLabel

func _ready():
    # Load saved game data on startup
    load_game()
    # Set initial scene (replace with your starting scene)
    change_scene("res://scenes/main_menu.tscn")

func _process(delta):
    # Handle global inputs
    if Input.is_action_just_pressed("pause"):
        toggle_pause()

# Scene Management
func change_scene(path: String):
    # Unload current scene if it exists
    if current_scene:
        current_scene.queue_free()
    # Load and instantiate new scene
    var new_scene = load(path).instantiate()
    add_child(new_scene)
    current_scene = new_scene
    scene_changed.emit(new_scene)
    update_ui()

# State Management
func toggle_pause():
    if current_state == GameState.PLAYING:
        current_state = GameState.PAUSED
        get_tree().paused = true
    elif current_state == GameState.PAUSED:
        current_state = GameState.PLAYING
        get_tree().paused = false
    game_state_changed.emit(current_state)
    update_ui()

func game_over():
    current_state = GameState.GAME_OVER
    game_state_changed.emit(current_state)
    update_ui()
    # Add game over logic (e.g., show game over screen)

# UI Updates
func update_ui():
    state_label.text = "Game State: %s" % GameState.keys()[current_state]

# Persistence
func save_game():
    var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
    if file:
        file.store_var({
            "current_scene": current_scene.scene_file_path,
            "player_data": {}  # Placeholder for player-specific data
        })
        file.close()

func load_game():
    var file = FileAccess.open("user://savegame.save", FileAccess.READ)
    if file and file.is_open():
        var data = file.get_var()
        if data and "current_scene" in data:
            change_scene(data["current_scene"])
            # Apply additional player data here if needed
        file.close()
