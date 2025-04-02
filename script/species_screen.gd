## SpeciesSelectionScreen.gd
## Massively enhanced control for selecting a player species.
## Features: Resource-based data, tabs (Desc/Stats/Lore), stat bars & diff,
## variants, dynamic background, async loading, state persistence, etc.

extends Control

#region Exported Variables - Configuration
@export var species_data_list: Array[SpeciesData] # Assign your .tres files here!
@export var continue_screen: PackedScene
@export var default_background: Texture2D
@export var stat_bar_progress_texture: Texture2D # Texture for the stat bars
@export var stat_bar_under_texture: Texture2D  # Background texture for stat bars

@export var stat_colors: Dictionary = {
	"higher": Color(0.2, 1, 0.2, 1),  # Green
	"lower": Color(1, 0.2, 0.2, 1),   # Red
	"neutral": Color(0.9, 0.9, 0.9, 1), # Off-white
	"difference_pos": Color(0.5, 1, 0.5, 1), # Light Green for positive diff
	"difference_neg": Color(1, 0.5, 0.5, 1)  # Light Red for negative diff
}

@export_group("Sound Effects")
@export var select_sound: AudioStream
@export var hover_sound: AudioStream
@export var confirm_sound: AudioStream
@export var cancel_sound: AudioStream
@export var transition_sound: AudioStream
@export var variant_change_sound: AudioStream

@export_group("Animation & Timing")
@export var info_fade_duration: float = 0.3
@export var background_fade_duration: float = 0.5
@export var max_stat_value: int = 50000 # Used to normalize stat bars (adjust as needed)

#endregion

#region Constants
const STAT_KEYS: Array[String] = ["HP", "MP", "SHD", "STM", "ATK", "DEF", "MGA", "MGD", "SHR", "STR", "AG", "CAP"]
const BASE_STATS: Array[int] = [40000, 40000, 8000, 8000, 4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000] # Still needed for diff calc
const STAT_DESCRIPTIONS: Dictionary = { # (Keep these updated)
	"HP": "Health Points...", "MP": "Mana Points...", "SHD": "Shield Durability...", # etc.
	"STM": "Stamina...", "ATK": "Physical Attack...", "DEF": "Physical Defense...",
	"MGA": "Magical Attack...", "MGD": "Magical Defense...", "SHR": "Shield Recharge...",
	"STR": "Strength...", "AG": "Agility...", "CAP": "Capacity..."
}

const ANIM_SELECT_FEEDBACK: StringName = &"select_feedback"
const ANIM_CONTINUE_READY: StringName = &"continue_ready_pulse"
# Define keys for async loading tracking
const PORTRAIT_LOAD_KEY_PREFIX = "portrait_"
#endregion

#region Node References (Using Scene Unique Names %)
# Main Structure
@onready var background_rect: TextureRect = %BackgroundRect
@onready var background_rect_fade: TextureRect = %BackgroundRectFade # Duplicate for cross-fade
@onready var species_buttons_container: HBoxContainer = %SpeciesButtonsContainer
@onready var random_button: Button = %RandomButton
@onready var continue_button: Button = %ContinueButton
@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog

# Info Display Area
@onready var info_tabs: TabContainer = %InfoTabs # Main container for tabs
@onready var description_label: RichTextLabel = %DescriptionLabel # Inside Tab 1
@onready var bonuses_container: VBoxContainer = %BonusesContainer # Inside Tab 1
@onready var stat_grid: GridContainer = %SpeciesStatGrid # Inside Tab 2
@onready var lore_label: RichTextLabel = %LoreLabel # Inside Tab 3
@onready var playstyle_hints_container: HBoxContainer = %PlaystyleHintsContainer # Somewhere visible

# Preview Area
@onready var emblem_sprite: Sprite2D = %EmblemSprite
@onready var character_preview: TextureRect = %CharacterPreview
@onready var variant_buttons_container: HBoxContainer = %VariantButtonsContainer # For Male/Female etc. buttons
@onready var loading_spinner: AnimationPlayer = %LoadingSpinner # Optional spinner for async load

# Utility Nodes
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var ui_tween: Tween # General purpose UI tween
#endregion

#region State Variables
var species_map: Dictionary = {} # Maps species name (String) to SpeciesData resource
var species_buttons: Dictionary = {} # Maps species name (String) to Button node
var selected_species_data: SpeciesData = null # The currently selected SpeciesData resource
var current_variant_key: String = "" # e.g., "Default", "Male", "Female"

var is_initialized: bool = false
var last_selected_species_name: String = "" # Persist selection within session

# Async loading state
var active_load_requests: Dictionary = {} # { key: [TextureRect, uid] }
#endregion

#region Initialization
func _ready() -> void:
	# --- Pre-Initialization Checks ---
	# No longer checking GameInfo for data, but PlayerStats is still needed
	if not PlayerStats:
		push_error("FATAL: PlayerStats singleton not found.")
		get_tree().quit()
		return
	if species_data_list.is_empty():
		push_error("FATAL: No SpeciesData resources assigned to 'species_data_list' in the Inspector!")
		get_tree().quit()
		return

	# --- Basic Setup ---
	_validate_species_data()
	_populate_species_map_and_buttons()
	_setup_button_signals()
	_setup_ui_elements()

	# --- Initial UI State ---
	info_tabs.modulate.a = 0.0 # Start invisible for fade-in
	emblem_sprite.visible = true
	character_preview.visible = true
	continue_button.disabled = true
	confirmation_dialog.visible = false
	loading_spinner.stop()
	loading_spinner.visible = false
	background_rect_fade.modulate.a = 0.0 # Fade layer starts transparent

	# --- Reset / Initial Display ---
	_reset_to_default(false) # Use default background, clear info

	# --- Finalize ---
	is_initialized = true

	# --- Restore Last Selection or Focus First ---
	if not last_selected_species_name.is_empty() and species_map.has(last_selected_species_name):
		_select_species(last_selected_species_name) # Reselect last viewed
		# Ensure the corresponding button has focus if needed
		if species_buttons.has(last_selected_species_name):
			species_buttons[last_selected_species_name].grab_focus()
	elif not species_map.is_empty():
		# Set focus to the first species button for keyboard navigation
		var first_species_name = species_map.keys()[0]
		if species_buttons.has(first_species_name):
			species_buttons[first_species_name].grab_focus()

# Validate assigned SpeciesData resources
func _validate_species_data() -> void:
	for data: SpeciesData in species_data_list:
		if not data:
			push_error("Null resource found in species_data_list!")
			continue
		if not data._validate_stats(STAT_KEYS.size()):
			push_error("Species '%s' has invalid stat data. Check Inspector." % data.species_name)
			# Optionally remove invalid data from list or handle error
		if data.species_name.is_empty():
			push_error("SpeciesData resource has empty species_name!")


# Populate internal map and setup buttons based on exported resources
func _populate_species_map_and_buttons() -> void:
	# Sort data list by name for consistent button order
	species_data_list.sort_custom(func(a, b): return a.species_name < b.species_name)

	species_map.clear()
	species_buttons.clear()

	var button_nodes = species_buttons_container.get_children()
	var button_idx := 0
	for data: SpeciesData in species_data_list:
		if not data or data.species_name.is_empty(): continue # Skip invalid entries

		species_map[data.species_name] = data

		if button_idx < button_nodes.size():
			var button = button_nodes[button_idx] as Button
			if button:
				button.text = data.species_name
				species_buttons[data.species_name] = button
				# Setup focus neighbours (simplified, assumes linear layout)
				if button_idx > 0:
					button.focus_neighbor_left = button_nodes[button_idx - 1].get_path()
				if button_idx < button_nodes.size() - 1:
					button.focus_neighbor_right = button_nodes[button_idx + 1].get_path()
				button_idx += 1
			else:
				push_warning("Child %d in SpeciesButtonsContainer is not a Button." % button_idx)
		else:
			push_warning("Not enough Button nodes in SpeciesButtonsContainer for species '%s'." % data.species_name)

	# Link last species button to Random button, Random to Continue, etc.
	_link_nav_buttons(button_nodes, button_idx)

	# Hide unused buttons
	for i in range(button_idx, button_nodes.size()):
		push_warning("Extra button node found: %s. Hiding." % button_nodes[i].name)
		button_nodes[i].visible = false
		button_nodes[i].disabled = true

# Helper to link focus for navigation buttons (species -> random -> continue)
func _link_nav_buttons(button_nodes: Array, last_species_button_idx: int) -> void:
	var last_nav_element = null
	if last_species_button_idx > 0:
		last_nav_element = button_nodes[last_species_button_idx - 1]

	if random_button:
		if last_nav_element:
			last_nav_element.focus_neighbor_right = random_button.get_path()
		random_button.focus_neighbor_left = last_nav_element.get_path() if last_nav_element else NodePath()
		last_nav_element = random_button

	if continue_button:
		if last_nav_element:
			last_nav_element.focus_neighbor_right = continue_button.get_path()
		continue_button.focus_neighbor_left = last_nav_element.get_path() if last_nav_element else NodePath()
		# Continue button often loops back or goes to next screen, right neighbor might be null or first species button

# Connect signals for all interactive elements
func _setup_button_signals() -> void:
	for species_name in species_buttons.keys():
		var button: Button = species_buttons[species_name]
		button.pressed.connect(_on_species_button_pressed.bind(species_name))
		# Connect hover/focus signals if not handled by theme/AnimationPlayer
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))

	random_button.pressed.connect(_on_random_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	confirmation_dialog.confirmed.connect(_on_confirmation_confirmed)
	confirmation_dialog.canceled.connect(_on_confirmation_canceled)
	info_tabs.tab_changed.connect(_on_tab_changed)

# Initial setup for UI elements like stat bars
func _setup_ui_elements() -> void:
	# Pre-configure stat bars if needed (e.g., setting textures)
	# This might be better done in _update_stats_grid if creating bars dynamically
	pass

#endregion

#region Process Loop
func _process(delta: float) -> void:
	# Process asynchronous loading requests
	_check_async_loads()
#endregion

#region Event Handlers
func _on_species_button_pressed(species_name: String) -> void:
	if selected_species_data and selected_species_data.species_name == species_name:
		return # Already selected
	_play_sound(select_sound)
	_select_species(species_name)

func _on_random_button_pressed() -> void:
	if species_map.is_empty(): return
	_play_sound(select_sound)
	var species_names = species_map.keys()
	var random_species_name = species_names.pick_random()

	if species_names.size() > 1 and selected_species_data and random_species_name == selected_species_data.species_name:
		var available_species = species_names.filter(func(s): return s != selected_species_data.species_name)
		random_species_name = available_species.pick_random()

	_select_species(random_species_name)

func _on_continue_button_pressed() -> void:
	if continue_button.disabled or not selected_species_data: return
	_play_sound(confirm_sound)
	confirmation_dialog.dialog_text = "Proceed with %s as your chosen species?" % selected_species_data.species_name.capitalize()
	confirmation_dialog.popup_centered()

func _on_confirmation_confirmed() -> void:
	_play_sound(transition_sound)
	if continue_screen and selected_species_data:
		# Update PlayerStats one last time before leaving
		_update_player_stats(selected_species_data)
		print("Species confirmed: ", selected_species_data.species_name)
		# Store last selection for session persistence
		last_selected_species_name = selected_species_data.species_name
		get_tree().change_scene_to_packed(continue_screen)
	else:
		push_error("Continue failed: Missing continue_screen or no species selected!")
		confirmation_dialog.hide()

func _on_confirmation_canceled() -> void:
	_play_sound(cancel_sound)
	confirmation_dialog.hide()
	continue_button.grab_focus()

func _on_variant_button_pressed(variant_key: String) -> void:
	if not selected_species_data or current_variant_key == variant_key: return
	_play_sound(variant_change_sound)
	current_variant_key = variant_key
	_update_character_preview(selected_species_data) # Update preview with new variant

func _on_tab_changed(tab_idx: int) -> void:
	# Optional: Play a sound or trigger animation when tabs change
	pass

# --- Hover and Focus Effects (Keep simple or integrate with AnimationPlayer) ---
func _on_button_mouse_entered(button: Button) -> void:
	_play_sound(hover_sound)
	_animate_button_hover(button, true)
func _on_button_mouse_exited(button: Button) -> void:
	_animate_button_hover(button, false)
func _on_button_focus_entered(button: Button) -> void:
	_play_sound(hover_sound)
	_animate_button_hover(button, true)
func _on_button_focus_exited(button: Button) -> void:
	_animate_button_hover(button, false)

func _animate_button_hover(button: Button, is_hovering: bool) -> void:
	if ui_tween and ui_tween.is_running(): ui_tween.kill() # Kill previous tween on this button
	ui_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT if is_hovering else Tween.EASE_IN)
	var target_scale = Vector2(1.1, 1.1) if is_hovering else Vector2(1.0, 1.0)
	var duration = 0.1 if is_hovering else 0.15
	ui_tween.tween_property(button, "scale", target_scale, duration)

#endregion

#region Core Logic - Selecting Species, Updating UI
# Central function to handle species selection changes
func _select_species(species_name: String) -> void:
	if not species_map.has(species_name):
		push_error("Attempted to select invalid species: %s" % species_name)
		return

	var new_data = species_map[species_name]
	if new_data == selected_species_data: return # No change

	selected_species_data = new_data
	current_variant_key = "Default" # Reset variant selection

	# Update button states visually
	_set_active_button(species_buttons[species_name])

	# Update all information displays with animation
	_update_information(selected_species_data)

	# Enable continue button
	if continue_button.disabled:
		continue_button.disabled = false
		if animation_player.has_animation(ANIM_CONTINUE_READY):
			animation_player.play(ANIM_CONTINUE_READY)

# Main UI Update Function
func _update_information(data: SpeciesData) -> void:
	if not is_initialized: return

	# --- Animate Out Old Info ---
	var fade_out_tween = create_tween().set_parallel(true)
	if info_tabs.modulate.a > 0.0:
		fade_out_tween.tween_property(info_tabs, "modulate:a", 0.0, info_fade_duration)
	# Fade out playstyle hints too
	if playstyle_hints_container.modulate.a > 0.0:
		fade_out_tween.tween_property(playstyle_hints_container, "modulate:a", 0.0, info_fade_duration)

	await fade_out_tween.finished

	# --- Update Content (while invisible) ---
	# Tabs
	description_label.bbcode_text = data.description
	lore_label.bbcode_text = data.lore
	_update_bonuses(data.bonuses)
	_update_stats_grid(data.stats)

	# Playstyle Hints
	_update_playstyle_hints(data.playstyle_hints)

	# Emblem
	emblem_sprite.texture = data.emblem_texture if data.emblem_texture else null # Handle missing texture

	# Character Preview & Variants
	_update_variant_buttons(data)
	_update_character_preview(data) # Starts async load if needed

	# Background
	_update_background(data.background_texture)

	# Player Stats (can be deferred until confirmation if preferred)
	# _update_player_stats(data)

	# --- Animate In New Info ---
	var fade_in_tween = create_tween().set_parallel(true)
	fade_in_tween.tween_property(info_tabs, "modulate:a", 1.0, info_fade_duration)
	fade_in_tween.tween_property(playstyle_hints_container, "modulate:a", 1.0, info_fade_duration)

	if animation_player.has_animation(ANIM_SELECT_FEEDBACK):
		animation_player.play(ANIM_SELECT_FEEDBACK)


# Update the Bonuses Tab
func _update_bonuses(bonuses_data: Array) -> void:
	# Clear existing
	for child in bonuses_container.get_children():
		bonuses_container.remove_child(child)
		child.queue_free()
	# Add new
	for bonus_dict in bonuses_data:
		var name = bonus_dict.get("name", "Unknown Bonus")
		var desc = bonus_dict.get("desc", "No description.")
		var bonus_label = RichTextLabel.new()
		bonus_label.bbcode_enabled = true
		bonus_label.fit_content = true
		bonus_label.bbcode_text = "[b]%s:[/b] %s" % [name, desc]
		bonuses_container.add_child(bonus_label)

# Update the Stats Tab (Grid) with Bars and Differences
func _update_stats_grid(stats: Array) -> void:
	stat_grid.columns = 4 # StatName | Bar | Value | Difference

	for child in stat_grid.get_children():
		child.queue_free()

	if stats.size() != STAT_KEYS.size():
		push_error("Stats array size mismatch!")
		return

	for i in range(stats.size()):
		var stat_key: String = STAT_KEYS[i]
		var stat_value: int = stats[i]
		var base_value: int = BASE_STATS[i]
		var difference = stat_value - base_value

		# Stat Name
		var name_label = Label.new()
		name_label.text = stat_key
		name_label.tooltip_text = STAT_DESCRIPTIONS.get(stat_key, "")
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stat_grid.add_child(name_label)

		# Stat Bar
		var bar = TextureProgressBar.new()
		bar.value = float(stat_value) / max_stat_value * 100.0 # Normalize
		bar.texture_under = stat_bar_under_texture
		bar.texture_progress = stat_bar_progress_texture
		bar.tint_progress = _get_stat_color(stat_value, base_value) # Color the bar itself
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stat_grid.add_child(bar)

		# Stat Value
		var value_label = Label.new()
		value_label.text = str(stat_value)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stat_grid.add_child(value_label)

		# Stat Difference
		var diff_label = Label.new()
		var diff_text = ""
		if difference > 0:
			diff_text = "(+%d)" % difference
			diff_label.modulate = stat_colors["difference_pos"]
		elif difference < 0:
			diff_text = "(%d)" % difference # Negative sign included
			diff_label.modulate = stat_colors["difference_neg"]
		else:
			diff_text = "(-)" # Or ""
			diff_label.modulate = stat_colors["neutral"]
		diff_label.text = diff_text
		diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT # Position next to value
		diff_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stat_grid.add_child(diff_label)

# Update Playstyle Hints display
func _update_playstyle_hints(hints: Array) -> void:
	for child in playstyle_hints_container.get_children():
		playstyle_hints_container.remove_child(child)
		child.queue_free()

	for hint_text in hints:
		var hint_label = Label.new()
		hint_label.text = hint_text
		# Optional: Style hint labels (e.g., background panel, icon)
		playstyle_hints_container.add_child(hint_label)


# Update Character Preview - Handles Async Loading
func _update_character_preview(data: SpeciesData) -> void:
	var texture_to_load: Texture2D = null

	# Determine which texture based on current_variant_key
	if current_variant_key == "Default":
		texture_to_load = data.default_portrait
	elif data.alternate_portraits.has(current_variant_key):
		texture_to_load = data.alternate_portraits[current_variant_key]
	else: # Fallback to default if variant key is invalid
		texture_to_load = data.default_portrait
		current_variant_key = "Default" # Correct the state

	if not texture_to_load:
		character_preview.texture = null # Or a placeholder 'missing texture' image
		push_warning("No portrait texture found for species '%s', variant '%s'" % [data.species_name, current_variant_key])
		return

	# --- Asynchronous Loading ---
	var load_key = PORTRAIT_LOAD_KEY_PREFIX + data.species_name + "_" + current_variant_key
	# Cancel previous load request for the same preview slot if any
	_cancel_async_load(load_key)

	# Check if already loaded
	if texture_to_load.resource_path and ResourceLoader.has_cached(texture_to_load.resource_path):
		character_preview.texture = texture_to_load
		loading_spinner.visible = false
		#print("Portrait cache hit: ", texture_to_load.resource_path)
	else:
		# Start loading
		character_preview.texture = null # Clear current texture
		loading_spinner.visible = true
		loading_spinner.play() # Play loading animation
		var uid = ResourceLoader.load_threaded_request(texture_to_load.resource_path)
		if uid == ERR_INVALID_PARAMETER:
			push_error("Failed to start threaded load for: ", texture_to_load.resource_path)
			loading_spinner.visible = false
		else:
			active_load_requests[load_key] = [character_preview, uid]
			#print("Started async load: ", texture_to_load.resource_path)

# Check status of ongoing async loads
func _check_async_loads() -> void:
	if active_load_requests.is_empty(): return

	var completed_keys: Array[String] = []
	for key in active_load_requests.keys():
		var target_node = active_load_requests[key][0] as TextureRect
		var uid = active_load_requests[key][1]
		var status = ResourceLoader.load_threaded_get_status(uid) # Check path with uid? Use path.

		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# Optional: Update progress bar
				# var progress = ResourceLoader.load_threaded_get_progress(uid)
				pass
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource = ResourceLoader.load_threaded_get(uid)
				if resource is Texture2D:
					# Check if this is still the relevant texture to display
					if target_node == character_preview and key == (PORTRAIT_LOAD_KEY_PREFIX + selected_species_data.species_name + "_" + current_variant_key):
						target_node.texture = resource
						loading_spinner.visible = false
						loading_spinner.stop()
						#print("Async load finished: ", resource.resource_path)
				else:
					push_error("Async loaded resource is not Texture2D: ", resource)
				completed_keys.append(key)
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Async load failed for UID: ", uid)
				if target_node == character_preview and key == (PORTRAIT_LOAD_KEY_PREFIX + selected_species_data.species_name + "_" + current_variant_key):
					loading_spinner.visible = false # Hide spinner on fail
				completed_keys.append(key)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("Async load invalid resource for UID: ", uid)
				if target_node == character_preview and key == (PORTRAIT_LOAD_KEY_PREFIX + selected_species_data.species_name + "_" + current_variant_key):
					loading_spinner.visible = false
				completed_keys.append(key)

	# Clean up completed requests
	for key in completed_keys:
		active_load_requests.erase(key)

# Cancel a specific async load if it's in progress
func _cancel_async_load(key_to_cancel: String) -> void:
	if active_load_requests.has(key_to_cancel):
		# Note: Godot currently doesn't have a direct way to *cancel* a threaded load.
		# We just remove it from our tracking dictionary. The load might finish in the background uselessly.
		# If the user selects something else quickly, the _check_async_loads logic will
		# prevent the old texture from being applied incorrectly.
		active_load_requests.erase(key_to_cancel)
		loading_spinner.visible = false # Ensure spinner hides if we cancel its load
		#print("Cancelled tracking for async load key: ", key_to_cancel)


# Update Variant Buttons
func _update_variant_buttons(data: SpeciesData) -> void:
	for child in variant_buttons_container.get_children():
		variant_buttons_container.remove_child(child)
		child.queue_free()

	var variants = data.alternate_portraits.keys()
	if variants.is_empty(): return # No variants to show

	# Add "Default" button first
	var default_button = Button.new()
	default_button.text = "Default"
	default_button.pressed.connect(_on_variant_button_pressed.bind("Default"))
	default_button.toggle_mode = true
	default_button.button_pressed = (current_variant_key == "Default")
	variant_buttons_container.add_child(default_button)

	# Add buttons for alternate portraits
	variants.sort() # Consistent order
	for variant_name in variants:
		var button = Button.new()
		button.text = variant_name
		button.pressed.connect(_on_variant_button_pressed.bind(variant_name))
		button.toggle_mode = true
		button.button_pressed = (current_variant_key == variant_name)
		variant_buttons_container.add_child(button)

# Update Background with Cross-Fade
func _update_background(new_texture: Texture2D) -> void:
	var target_texture = new_texture if new_texture else default_background
	if not target_texture: return # Cannot update if no texture available

	if background_rect.texture == target_texture: return # Already showing correct texture

	# Start cross-fade
	background_rect_fade.texture = target_texture
	background_rect_fade.modulate.a = 0.0 # Start transparent

	var bg_tween = create_tween().set_parallel()
	bg_tween.tween_property(background_rect_fade, "modulate:a", 1.0, background_fade_duration)
	# Optional: Fade out the old background if it wasn't fully opaque
	# bg_tween.tween_property(background_rect, "modulate:a", 0.0, background_fade_duration)

	await bg_tween.finished

	# Swap textures and reset fade layer
	background_rect.texture = target_texture
	background_rect.modulate.a = 1.0 # Ensure main layer is opaque
	background_rect_fade.modulate.a = 0.0 # Reset fade layer


# Determine stat color based on comparison to base value
func _get_stat_color(value: int, base: int) -> Color:
	if value > base: return stat_colors["higher"]
	elif value < base: return stat_colors["lower"]
	else: return stat_colors["neutral"]

# Update the PlayerStats singleton
func _update_player_stats(data: SpeciesData) -> void:
	if not PlayerStats or not data: return

	var stats_dict: Dictionary = {}
	for i in range(min(STAT_KEYS.size(), data.stats.size())):
		stats_dict[STAT_KEYS[i]] = data.stats[i]
	PlayerStats.set_stats(stats_dict)
	PlayerStats.species = data.species_name

	var bonuses_dict: Dictionary = {}
	for i in range(data.bonuses.size()):
		# Store bonus name, assuming "Bonus i+1" structure if needed elsewhere
		bonuses_dict["Bonus %d" % (i + 1)] = data.bonuses[i].get("name", "Unnamed Bonus")
	PlayerStats.set_bonuses(bonuses_dict)

# Manage active button visual state
func _set_active_button(new_button: Button) -> void:
	if not is_initialized: return

	for species_name in species_buttons.keys():
		var button = species_buttons[species_name]
		button.button_pressed = (button == new_button) # Assumes toggle_mode = true


#endregion

#region Utility Functions
# Helper to play sounds safely
func _play_sound(stream: AudioStream) -> void:
	if audio_player and stream:
		audio_player.stream = stream
		audio_player.play()

# Reset the UI to its initial, unselected state
func _reset_to_default(play_anim: bool = true) -> void:
	# --- Animate out ---
	if play_anim and info_tabs.modulate.a > 0.0:
		var fade_out_tween = create_tween().set_parallel()
		fade_out_tween.tween_property(info_tabs, "modulate:a", 0.0, info_fade_duration)
		fade_out_tween.tween_property(playstyle_hints_container, "modulate:a", 0.0, info_fade_duration)
		await fade_out_tween.finished
		_play_sound(cancel_sound)

	# --- Reset State ---
	selected_species_data = null
	current_variant_key = "Default"
	continue_button.disabled = true

	# --- Reset UI Content ---
	description_label.bbcode_text = "[center]Select a species to begin[/center]"
	lore_label.bbcode_text = ""
	_update_bonuses([])
	_update_stats_grid(BASE_STATS) # Show base stats (or empty)
	_update_playstyle_hints([])
	_update_variant_buttons(null) # Clears variant buttons

	# Reset visuals
	emblem_sprite.texture = null # Or a default placeholder
	character_preview.texture = null # Or default placeholder
	_update_background(default_background) # Reset to default background

	# Deselect all species buttons
	for button in species_buttons.values():
		button.button_pressed = false

	# Reset PlayerStats (optional)
	# PlayerStats.reset()

# Optional: Connect to a Back button
# func _on_back_button_pressed() -> void:
# 	# Decide whether to reset or go to previous scene
#	  _reset_to_default()
# 	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

#endregion
