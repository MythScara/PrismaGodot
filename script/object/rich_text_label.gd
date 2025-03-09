extends RichTextLabel

# Chaos-driven properties
@export var fade_duration: float = 1.0  # Duration for fade-in/out
@export var typing_speed: float = 0.05  # Seconds per character for typing effect
@export var auto_start: bool = true    # Auto-start typing on ready

var is_typing: bool = false
var full_text: String = ""
var current_char: int = 0
var elapsed: float = 0.0

@onready var audio_player = $AudioStreamPlayer

func _ready():
	full_text = text
	if auto_start:
		start_typing()

func start_typing() -> void:
	"""Start the chaos typing effect."""
	text = ""
	current_char = 0
	is_typing = true
	modulate.a = 0  # Start faded out
	audio_player.play()

func _process(delta: float) -> void:
	if is_typing:
		elapsed += delta
		# Fade in chaos
		modulate.a = min(elapsed / fade_duration, 1.0)
		
		if elapsed >= typing_speed:
			elapsed = 0
			if current_char < full_text.length():
				text += full_text[current_char]
				current_char += 1
				if full_text[current_char - 1] not in [" ", "\n"]:
					audio_player.play()  # Chaos tick sound per character
			else:
				is_typing = false
				finish_typing()

func finish_typing() -> void:
	"""Complete the typing effect and reset state."""
	text = full_text
	modulate.a = 1.0
	audio_player.stop()

func fade_out(callback: Callable = Callable()) -> void:
	"""Fade out the text with an optional callback."""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(callback)

func set_text_new(new_text: String) -> void:
	"""Set new text and restart chaos typing."""
	full_text = new_text
	start_typing()
