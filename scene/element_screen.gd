extends Control

# Exported variables
@export var continue_screen: PackedScene

# Node references
@onready var element_image = $ElementImage
@onready var info_box = $ScrollContainer/InfoBox
@onready var point_label = $PointLabel
@onready var continue_button = $ContinueButton
@onready var glow_effect = $ContinueButton/GlowEffect
@onready var warning = $Warning
@onready var audio_player = $AudioStreamPlayer
@onready var warning_audio = $WarningAudio
@onready var preview_image = $PreviewPanel/PreviewImage
@onready var preview_description = $PreviewPanel/PreviewDescription

# Data
var total_points = 60
var allocated_points = {"Solar": 0, "Nature": 0, "Spirit": 0, "Void": 0, "Arc": 0, "Frost": 0, "Metal": 0, "Divine": 0}
var selected_element = ""
var allocation_history = []

# Element data (example)
var elements = {
    "Solar": {"strength": "Fire Damage +10%", "weakness": "Frost Damage +5%", "image": "res://asset/elements/solar.png", "desc": "Boosts fire abilities."},
    "Nature": {"strength": "Healing +15%", "weakness": "Fire Damage +5%", "image": "res://asset/elements/nature.png", "desc": "Enhances nature skills."}
    # Add others similarly
}

func _ready():
    update_points_display()
    update_ui()

func update_points_display():
    point_label.text = str(total_points - allocated_points.values().sum())
    glow_effect.visible = (total_points - allocated_points.values().sum() > 0)

func update_ui():
    for element in allocated_points:
        var button = get_node(element + "Button")
        var progress = button.get_node(element + "Progress")
        var points_label = button.get_node(element + "Points")
        progress.value = allocated_points[element]
        points_label.text = str(allocated_points[element])

func _on_element_button_pressed(element: String):
    if selected_element != element:
        if selected_element != "":
            get_node(selected_element + "Button").button_pressed = false
        selected_element = element
        update_element_info()
        audio_player.play()
    else:
        selected_element = ""
        element_image.texture = null
        info_box.get_node("Strength").text = "Strength: "
        info_box.get_node("Weakness").text = "Weakness: "
        preview_image.texture = null
        preview_description.text = "Select an element to preview stats."

func update_element_info():
    var data = elements[selected_element]
    element_image.texture = load(data["image"])
    info_box.get_node("Strength").text = "Strength: " + data["strength"]
    info_box.get_node("Weakness").text = "Weakness: " + data["weakness"]
    preview_image.texture = load(data["image"])
    preview_description.text = data["desc"] + "\nCurrent: " + str(allocated_points[selected_element]) + " points"

func _on_add_button_pressed():
    if selected_element == "" or total_points - allocated_points.values().sum() <= 0:
        return
    allocated_points[selected_element] += 1
    allocation_history.append({"element": selected_element, "change": 1})
    update_points_display()
    update_ui()
    update_element_info()
    audio_player.play()

func _on_minus_button_pressed():
    if selected_element == "" or allocated_points[selected_element] <= 0:
        return
    allocated_points[selected_element] -= 1
    allocation_history.append({"element": selected_element, "change": -1})
    update_points_display()
    update_ui()
    update_element_info()
    audio_player.play()

func _on_reset_button_pressed():
    allocated_points = allocated_points.from_keys(allocated_points.keys(), 0)
    allocation_history.clear()
    selected_element = ""
    update_points_display()
    update_ui()
    update_element_info()
    audio_player.play()

func _on_continue_button_pressed():
    if total_points - allocated_points.values().sum() > 0:
        warning.visible = true
        warning_audio.play()
    else:
        save_character_data()
        get_tree().change_scene_to_packed(continue_screen)

func _on_forfeit_continue_button_pressed():
    save_character_data()
    get_tree().change_scene_to_packed(continue_screen)

func _on_cancel_button_pressed():
    warning.visible = false

func _on_button_hover(button_path: NodePath):
    var button = get_node(button_path)
    $AnimationPlayer.play("hover") # Define in AnimationPlayer

func save_character_data():
    var character_data = {"element": selected_element, "points": allocated_points}
    # Implement save logic (e.g., JSON file)
