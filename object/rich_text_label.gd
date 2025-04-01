extends RichTextLabel

@onready var timer = $TypingTimer
@onready var audio = $AudioStreamPlayer
var full_text = "[center][b]Welcome to Chaos[/b]\nUnleash the Glow[/center]"

func _ready():
    text = full_text
    visible_characters = 0
    timer.connect("timeout", _on_timer_timeout)
    timer.start()

func _on_timer_timeout():
    if visible_characters < full_text.length():
        visible_characters += 1
        audio.pitch_scale = randf_range(0.9, 1.1)  # Slight pitch variation
        audio.play()
    else:
        timer.stop()

func _process(delta):
    # Optional: Pulse glow effect
    var glow = theme_override_colors/font_outline_color
    glow.a = 0.8 + sin(Time.get_ticks_msec() * 0.001) * 0.2
    add_theme_color_override("font_outline_color", glow)
