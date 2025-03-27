extends RichTextLabel

# ==============================================================================
# --- Chaos-Driven Properties ---
# ==============================================================================
@export var fade_duration: float = 0.3 # Even snappier default
@export var base_typing_speed: float = 0.04 # Base speed, can be modified by BBCode
@export var auto_start: bool = true
@export var sound_per_character: bool = true
@export var random_pitch_range: float = 0.15
@export var punctuation_pause_multiplier: float = 2.0
@export var delay_before_start: float = 0.0
@export var caret_blink_speed: float = 0.6
@export var caret_character: String = "_"
@export var show_caret_during_typing: bool = true
@export var reset_on_new_text: bool = true
@export var use_bbcode_effects: bool = true
@export var play_sound_on_finish: bool = false
@export var finish_sound: AudioStream = null
@export var loop_typing_sound: bool = false # Loop the character sound during typing

# ==============================================================================
# --- Custom BBCode Tags & Constants ---
# ==============================================================================
const BBCODE_SHAKE = "shake"
const SHAKE_FREQUENCY = 15.0
const SHAKE_INTENSITY = 3.0

const BBCODE_WAVE = "wave"
const WAVE_FREQUENCY = 7.0
const WAVE_AMPLITUDE = 4.0

const BBCODE_JUMP = "jump"
const JUMP_STRENGTH = 5.0
const JUMP_FREQUENCY = 12.0

const BBCODE_COLOR_WAVE = "color_wave"
const COLOR_WAVE_SPEED = 2.0
@export var color_wave_colors: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE]

const BBCODE_SIZE_PULSE = "size_pulse"
const SIZE_PULSE_SPEED = 3.0
const SIZE_PULSE_AMOUNT = 0.2 # Percentage of original size

const BBCODE_SPEED = "speed" # [speed=0.02]...[/speed] to override typing speed

# ==============================================================================
# --- State Variables ---
# ==============================================================================
var is_typing: bool = false
var full_text: String = ""
var visible_text: String = ""
var current_char: int = 0
var elapsed: float = 0.0
var start_time: float = -1.0
var caret_visible: bool = false
var caret_timer: float = 0.0
var current_typing_speed: float = base_typing_speed
var bbcode_stack: Array[Dictionary] = [] # Stack to manage nested BBCode effects

# ==============================================================================
# --- Nodes ---
# ==============================================================================
@onready var audio_player = $AudioStreamPlayer
@onready var finish_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var caret_node = Label.new()

# ==============================================================================
# --- Signals ---
# ==============================================================================
signal typing_started()
signal character_typed(character: String)
signal typing_finished()

# ==============================================================================
# --- Initialization ---
# ==============================================================================
func _init():
	add_child(caret_node)
	caret_node.set("theme_override_colors/font_color", get("theme_override_colors/default_color"))
	caret_node.set("theme_override_fonts/font", get("theme_override_fonts/normal_font"))
	caret_node.set("theme_override_font_sizes/font_size", get("theme_override_font_sizes/font_size"))
	caret_node.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	caret_node.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	caret_node.hide()
	add_child(finish_audio_player)
	finish_audio_player.stream = finish_sound

func _ready():
	full_text = text
	if auto_start and full_text.length() > 0:
		await get_tree().create_timer(delay_before_start).timeout
		start_typing()
	elif show_caret_during_typing and caret_blink_speed > 0 and full_text.length() == 0:
		_update_caret_position()
		caret_node.show()
		caret_visible = true

# ==============================================================================
# --- Typing Control ---
# ==============================================================================
func start_typing() -> void:
	"""Start the chaos typing effect."""
	if is_typing:
		return
	text = ""
	visible_text = ""
	current_char = 0
	elapsed = 0.0
	start_time = -1.0
	is_typing = true
	modulate.a = 0.0
	current_typing_speed = base_typing_speed
	bbcode_stack.clear()
	if sound_per_character and audio_player.stream != null:
		audio_player.play()
		if random_pitch_range != 0.0:
			audio_player.pitch_scale = randf_range(1.0 - random_pitch_range, 1.0 + random_pitch_range)
		audio_player.loop = loop_typing_sound
	emit_signal("typing_started")
	if show_caret_during_typing and caret_blink_speed > 0:
		caret_node.show()
		caret_visible = true

func _process(delta: float) -> void:
	if is_typing:
		if start_time == -1.0:
			start_time = get_time_sec()

		elapsed += delta
		modulate.a = min((get_time_sec() - start_time) / fade_duration, 1.0)

		if elapsed >= current_typing_speed:
			elapsed = 0.0
			if current_char < full_text.length():
				var char = full_text[current_char]
				visible_text += char
				if use_bbcode_effects:
					text = _parse_and_apply_bbcode(full_text.substr(0, current_char + 1), get_time_sec() - start_time)
				else:
					text = visible_text
				current_char += 1
				emit_signal("character_typed", char)
				if sound_per_character and audio_player.stream != null and char not in [" ", "\n"]:
					if not audio_player.playing or not loop_typing_sound:
						audio_player.play()
					if random_pitch_range != 0.0:
						audio_player.pitch_scale = randf_range(1.0 - random_pitch_range, 1.0 + random_pitch_range)
				if char in [".", "!", "?"]:
					elapsed -= current_typing_speed * (punctuation_pause_multiplier - 1.0)
			else:
				is_typing = false
				finish_typing()

	_update_caret(delta)

func finish_typing() -> void:
	"""Complete the typing effect and reset state."""
	text = full_text
	visible_text = full_text
	modulate.a = 1.0
	if sound_per_character and audio_player.stream != null and not loop_typing_sound:
		audio_player.stop()
	is_typing = false
	emit_signal("typing_finished")
	if play_sound_on_finish and finish_audio_player.stream != null:
		finish_audio_player.play()
	_update_caret(0) # Ensure caret is in the final position
	if show_caret_during_typing:
		caret_node.text = caret_character
		caret_node.show()

func fade_out(callback: Callable = Callable()) -> void:
	"""Fade out the text with an optional callback."""
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(callback)

func set_text_new(new_text: String) -> void:
	"""Set new text and restart chaos typing."""
	full_text = new_text
	if reset_on_new_text:
		await get_tree().create_timer(delay_before_start).timeout
		start_typing()
	else:
		text = new_text
		visible_text = new_text
		current_char = full_text.length()
		is_typing = false
		modulate.a = 1.0
		_update_caret(0)
		if show_caret_during_typing and caret_blink_speed > 0 and full_text.length() > 0:
			caret_node.show()
			caret_visible = true
		elif show_caret_during_typing and caret_blink_speed == 0 and full_text.length() > 0:
			caret_node.show()
			caret_node.text = caret_character
		elif show_caret_during_typing:
			caret_node.hide()

func is_currently_typing() -> bool:
	"""Returns true if the typing effect is currently active."""
	return is_typing

func skip_typing() -> void:
	"""Immediately finish the typing effect."""
	if is_typing:
		is_typing = false
		finish_typing()

# ==============================================================================
# --- Caret Handling ---
# ==============================================================================
func _update_caret(delta: float) -> void:
	if show_caret_during_typing:
		if caret_blink_speed > 0 and is_typing:
			caret_timer += delta
			if caret_timer >= caret_blink_speed:
				caret_timer = 0.0
				caret_visible = not caret_visible
				caret_node.text = "" if not caret_visible else caret_character
		elif caret_blink_speed > 0 and not is_typing and full_text.length() > 0:
			caret_node.text = caret_character
			caret_visible = true
		elif caret_blink_speed == 0 and show_caret_during_typing and full_text.length() > 0:
			caret_node.text = caret_character
			caret_visible = true
		else:
			caret_node.text = ""
			caret_visible = false

		_update_caret_position()
		if show_caret_during_typing and (is_typing or full_text.length() > 0):
			caret_node.show()
		else:
			caret_node.hide()

func _update_caret_position() -> void:
	"""Update the position of the caret based on the current text."""
	if show_caret_during_typing:
		var caret_offset = get_character_rect(visible_text.length()).position.x + get_character_rect(visible_text.length()).size.x
		var global_pos = global_position + Vector2(caret_offset, get_character_rect(0).size.y / 2.0)
		caret_node.global_position = global_pos

# ==============================================================================
# --- BBCode Handling ---
# ==============================================================================
func _parse_and_apply_bbcode(current_visible_text: String, time: float) -> String:
	var output_bbcode = ""
	var i = 0
	bbcode_stack.clear()
	current_typing_speed = base_typing_speed

	while i < current_visible_text.length():
		if current_visible_text[i] == "[" and use_bbcode_effects:
			var end_bracket = current_visible_text.find("]", i)
			if end_bracket != -1:
				var tag_info = current_visible_text.substr(i + 1, end_bracket - i - 1).split("=")
				var tag = tag_info[0]
				var value = tag_info.size() > 1 ? tag_info[1] : ""

				if tag.begins_with("/"): # Closing tag
					var closing_tag = tag.substr(1)
					if not bbcode_stack.is_empty() and bbcode_stack.back().tag == closing_tag:
						bbcode_stack.pop_back()
					i = end_bracket + 1
					continue
				else: # Opening tag
					bbcode_stack.append({"tag": tag, "value": value})
					i = end_bracket + 1
					continue
		output_bbcode += current_visible_text[i]
		i += 1

	var final_bbcode = ""
	for char_index in range(current_visible_text.length()):
		var char = current_visible_text[char_index]
		var char_bbcode = char
		for effect in bbcode_stack:
			match effect.tag:
				BBCODE_SHAKE:
					char_bbcode = _apply_shake_effect_char(char_bbcode, time + float(char_index) * 0.05) # Slight offset
				BBCODE_WAVE:
					char_bbcode = _apply_wave_effect_char(char_bbcode, time + float(char_index) * 0.1)
				BBCODE_JUMP:
					char_bbcode = _apply_jump_effect_char(char_bbcode, time + float(char_index) * 0.08)
				BBCODE_COLOR_WAVE:
					char_bbcode = _apply_color_wave_effect_char(char_bbcode, time + float(char_index) * 0.2)
				BBCODE_SIZE_PULSE:
					char_bbcode = _apply_size_pulse_effect_char(char_bbcode, time + float(char_index) * 0.15)
				BBCODE_SPEED:
					if is_typing:
						if not effect.value.is_empty() and string_to_float(effect.value) > 0:
							current_typing_speed = string_to_float(effect.value)
		final_bbcode += char_bbcode

	return final_bbcode

func _apply_shake_effect_char(char: String, time: float) -> String:
	var x_offset = sin(time * SHAKE_FREQUENCY * 2 + randf_range(-PI, PI)) * SHAKE_INTENSITY
	var y_offset = cos(time * SHAKE_FREQUENCY * 1.5 + randf_range(-PI, PI)) * SHAKE_INTENSITY
	return "[offset x=" + str(x_offset) + " y=" + str(y_offset) + "]" + char + "[/offset]"

func _apply_wave_effect_char(char: String, time: float) -> String:
	var y_offset = sin(time * WAVE_FREQUENCY + randf_range(0, PI * 2)) * WAVE_AMPLITUDE
	return "[offset y=" + str(y_offset) + "]" + char + "[/offset]"

func _apply_jump_effect_char(char: String, time: float) -> String:
	var y_offset = abs(sin(time * JUMP_FREQUENCY + randf_range(0, PI * 2))) * JUMP_STRENGTH * -1 # Negative for upward jump
	return "[offset y=" + str(y_offset) + "]" + char + "[/offset]"

func _apply_color_wave_effect_char(char: String, time: float) -> String:
	if color_wave_colors.is_empty():
		return char
	var color_index = fmod(time * COLOR_WAVE_SPEED, float(color_wave_colors.size()))
	var next_color_index = fmod(color_index + 1, float(color_wave_colors.size()))
	var blend_factor = fmod(time * COLOR_WAVE_SPEED, 1.0)
	var blended_color = color_wave_colors[int(color_index)].lerp(color_wave_colors[int(next_color_index)], blend_factor)
	return "[color=#" + blended_color.to_html() + "]" + char + "[/color]"

func _apply_size_pulse_effect_char(char: String, time: float) -> String:
	var size_multiplier = 1.0 + sin(time * SIZE_PULSE_SPEED) * SIZE_PULSE_AMOUNT
	return "[scale x=" + str(size_multiplier) + " y=" + str(size_multiplier) + "]" + char + "[/scale]"
