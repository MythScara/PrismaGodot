# SCRIPT: ElementAllocationScreen.gd
# PURPOSE: Allows players to allocate points to different elemental stats.
# VERSION: 2.0 (Enhanced)

extends Control

## Configuration ##
# Scene to transition to after allocation is complete.
@export var continue_screen: PackedScene
# Path to the container where element selection buttons will be added.
@export var element_button_container_path: NodePath
# Path to the GridContainer displaying the allocated stats.
@export var element_stats_grid_path: NodePath
# Path to the label showing remaining points.
@export var points_label_path: NodePath
# Path to the GridContainer displaying element reactions.
@export var reactions_grid_path: NodePath
# Path to the RichTextLabel for the element description.
@export var description_label_path: NodePath
# Path to the RichTextLabel for element strengths.
@export var strength_label_path: NodePath
# Path to the RichTextLabel for element weaknesses.
@export var weakness_label_path: NodePath
# Path to the TextureRect displaying the element's image.
@export var element_image_path: NodePath
# Path to the warning panel (shown when trying to continue with points left).
@export var warning_panel_path: NodePath
# Path to the "Continue" button.
@export var continue_button_path: NodePath
# Path to the "Add Point" button.
@export var add_button_path: NodePath
# Path to the "Subtract Point" button.
@export var minus_button_path: NodePath
# Path to the "Reset Points" button.
@export var reset_button_path: NodePath

# Template scene for an element selection button (Optional, but good practice)
@export var element_button_template: PackedScene
# Template scene for a stat row (HBoxContainer with two Labels) (Optional)
@export var stat_row_template: PackedScene

@export_category("Game Balance")
# Total points available for allocation.
@export var total_points: int = 60
# The amount each press of +/- changes a stat.
@export var stat_increment: int = 400
# The minimum value an element stat can have (usually the base value).
@export var min_stat_value: int = 2000
# The maximum value an element stat can reach.
@export var max_stat_value: int = 10000
# Default base value if not specified in GameInfo.
@export var default_base_stat: int = 2000

## Constants ##
const STAT_LABEL_NAME := "StatLabel"
const VALUE_LABEL_NAME := "ValueLabel"
const BUTTON_KEY_META := "element_key"

## State Variables ##
# Holds the current value of each element stat. Key: Element ID (String), Value: Stat Value (int)
var current_stats: Dictionary = {}
# Holds the initial base value for resetting. Key: Element ID, Value: Base Stat Value
var initial_stats: Dictionary = {}
# List of available element keys/IDs.
var element_keys: Array = []
# Currently available points.
var points_remaining: int = 0
# The key (String) of the currently selected element for modification.
var selected_element_key: String = ""
# Reference to the currently active element selection button.
var selected_button: Button = null
# Cache for loaded element images. Key: Element ID, Value: Texture2D
var image_cache: Dictionary = {}
# Cache for created stat value labels. Key: Element ID, Value: Label node
var stat_value_labels: Dictionary = {}

## UI Node References ##
@onready var element_button_container: BoxContainer = get_node_or_null(element_button_container_path)
@onready var element_stats_grid: GridContainer = get_node_or_null(element_stats_grid_path)
@onready var points_label: Label = get_node_or_null(points_label_path)
@onready var reactions_grid: GridContainer = get_node_or_null(reactions_grid_path)
@onready var description_label: RichTextLabel = get_node_or_null(description_label_path)
@onready var strength_label: RichTextLabel = get_node_or_null(strength_label_path)
@onready var weakness_label: RichTextLabel = get_node_or_null(weakness_label_path)
@onready var element_image: TextureRect = get_node_or_null(element_image_path)
@onready var warning_panel: Panel = get_node_or_null(warning_panel_path)
@onready var continue_button: Button = get_node_or_null(continue_button_path)
@onready var add_button: Button = get_node_or_null(add_button_path)
@onready var minus_button: Button = get_node_or_null(minus_button_path)
@onready var reset_button: Button = get_node_or_null(reset_button_path)


func _ready() -> void:
	# --- Validation ---
	if not _validate_setup():
		return # Stop if setup is invalid

	# --- Initialization ---
	points_remaining = total_points
	_load_element_data()
	_preload_images()
	_initialize_ui()
	_update_point_label()
	_update_stats_grid() # Initial display

	# Select the first element by default if available
	if not element_keys.is_empty():
		var first_key = element_keys[0]
		# Find the first button and simulate press
		for child in element_button_container.get_children():
			if child is Button and child.get_meta(BUTTON_KEY_META, "") == first_key:
				_on_element_button_pressed(child, first_key)
				break
	else:
		# Disable interaction if no elements are loaded
		add_button.disabled = true
		minus_button.disabled = true
		reset_button.disabled = true
		continue_button.disabled = true


#region Initialization and Setup
# ============================================================================ #

func _validate_setup() -> bool:
	var valid = true
	if not GameInfo:
		printerr("ElementAllocationScreen: Autoload 'GameInfo' not found!")
		valid = false
	if not PlayerStats:
		printerr("ElementAllocationScreen: Autoload 'PlayerStats' not found!")
		valid = false
	if not element_button_container:
		printerr("ElementAllocationScreen: Element Button Container node not found at path: ", element_button_container_path)
		valid = false
	if not element_stats_grid:
		printerr("ElementAllocationScreen: Element Stats Grid node not found at path: ", element_stats_grid_path)
		valid = false
	# ... Add checks for all other essential NodePaths ...
	if not description_label: # Example
		printerr("ElementAllocationScreen: Description Label node not found at path: ", description_label_path)
		valid = false
	if not continue_screen:
		printerr("ElementAllocationScreen: 'continue_screen' PackedScene is not set!")
		# valid = false # Maybe not fatal, just disable continue button?

	if not valid:
		push_error("ElementAllocationScreen validation failed. Disabling functionality.")
		# Optionally disable the whole control
		set_process(false)
		set_physics_process(false)
	return valid


func _load_element_data() -> void:
	# Assume GameInfo.get_element_data() returns a Dictionary like:
	# { "SLR": { "name": "Solar", "description": "...", "base_value": 2000, ... }, ... }
	if not GameInfo.has_method("get_element_data"):
		printerr("ElementAllocationScreen: GameInfo lacks 'get_element_data()' method.")
		return

	var all_elements_data: Dictionary = GameInfo.get_element_data()
	if all_elements_data.is_empty():
		printerr("ElementAllocationScreen: No element data loaded from GameInfo.")
		return

	element_keys = all_elements_data.keys()
	element_keys.sort() # Ensure consistent order

	for key in element_keys:
		var data = all_elements_data[key]
		var base_value = data.get("base_value", default_base_stat)
		# Ensure base value respects limits (optional, could also validate in GameInfo)
		base_value = clamp(base_value, min_stat_value, max_stat_value)

		initial_stats[key] = base_value
		current_stats[key] = base_value


func _preload_images() -> void:
	if not GameInfo or not GameInfo.has_method("get_element_data"): return

	image_cache.clear()
	var all_elements_data: Dictionary = GameInfo.get_element_data()

	for key in all_elements_data:
		var data = all_elements_data[key]
		var image_path = data.get("image_path", "") # Expect "image_path": "res://..." in data
		if image_path.is_empty():
			printerr("ElementAllocationScreen: Missing 'image_path' for element: ", key)
			continue

		if ResourceLoader.exists(image_path):
			image_cache[key] = load(image_path)
		else:
			printerr("ElementAllocationScreen: Image not found at path: ", image_path, " for element: ", key)


func _initialize_ui() -> void:
	# --- Generate Element Buttons ---
	# Clear any placeholders
	for child in element_button_container.get_children():
		child.queue_free()

	if not GameInfo or not GameInfo.has_method("get_element_data"): return
	var all_elements_data: Dictionary = GameInfo.get_element_data()

	for key in element_keys: # Use the sorted keys
		var data = all_elements_data[key]
		var button: Button

		# Instantiate button (from template or new)
		if element_button_template:
			button = element_button_template.instantiate() as Button
		else:
			button = Button.new()

		if not button:
			printerr("Failed to create button for element: ", key)
			continue

		button.name = key + "Button" # Optional: Set node name
		button.text = data.get("name", key) # Use name, fallback to key
		button.tooltip_text = data.get("tooltip", "") # Add tooltip from data
		button.set_meta(BUTTON_KEY_META, key) # Store the key for the handler
		button.toggle_mode = true # Allows visual pressed state
		button.focus_mode = Control.FOCUS_NONE # Prevent default focus behavior if desired
		# Connect signal to the unified handler
		button.pressed.connect(_on_element_button_pressed.bind(button, key))

		element_button_container.add_child(button)

	# --- Generate Stat Grid Rows (once) ---
	for child in element_stats_grid.get_children():
		child.queue_free() # Clear placeholders

	stat_value_labels.clear()

	for key in element_keys: # Use the sorted keys
		var data = all_elements_data.get(key, {})
		var hbox: HBoxContainer

		# Instantiate row (from template or new)
		if stat_row_template:
			hbox = stat_row_template.instantiate() as HBoxContainer
		else:
			hbox = HBoxContainer.new()
			# Create labels manually if no template
			var stat_label = Label.new()
			stat_label.name = STAT_LABEL_NAME
			stat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			hbox.add_child(stat_label)

			var value_label = Label.new()
			value_label.name = VALUE_LABEL_NAME
			value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			hbox.add_child(value_label)

		if not hbox:
			printerr("Failed to create stat row for element: ", key)
			continue

		var stat_label_node = hbox.find_child(STAT_LABEL_NAME, false) as Label # Find by name, non-recursive
		var value_label_node = hbox.find_child(VALUE_LABEL_NAME, false) as Label

		if not stat_label_node or not value_label_node:
			printerr("Stat row template/creation error for element: ", key, ". Missing labels named '", STAT_LABEL_NAME, "' or '", VALUE_LABEL_NAME, "'.")
			continue

		stat_label_node.text = data.get("name", key)
		stat_label_node.tooltip_text = data.get("tooltip", "") # Add tooltip
		value_label_node.text = "..." # Placeholder until first update

		# Store reference to the value label for efficient updates
		stat_value_labels[key] = value_label_node

		element_stats_grid.add_child(hbox)

#endregion


#region UI Update Functions
# ============================================================================ #

# Consolidated button press handler
func _on_element_button_pressed(button_node: Button, element_key: String) -> void:
	if selected_button != button_node:
		_set_active_button(button_node)
		_update_information_panel(element_key)


func _set_active_button(new_button: Button) -> void:
	# Deselect the previous button visually
	if selected_button != null and is_instance_valid(selected_button) and selected_button != new_button:
		selected_button.button_pressed = false # Use button_pressed for toggle_mode

	selected_button = new_button
	if is_instance_valid(selected_button):
		selected_button.button_pressed = true

	# Update +/- button states based on selection and limits
	_update_modify_button_states()


func _update_information_panel(element_key: String) -> void:
	selected_element_key = element_key

	if not GameInfo or not GameInfo.has_method("get_element_data"): return
	var all_elements_data: Dictionary = GameInfo.get_element_data()
	if not all_elements_data.has(element_key):
		printerr("ElementAllocationScreen: Data not found for key: ", element_key)
		_clear_information_panel()
		return

	var data = all_elements_data[element_key]

	# Update Text Labels (Check if nodes exist)
	if description_label:
		description_label.bbcode_text = data.get("description", "[i]No description available.[/i]")
	if strength_label:
		strength_label.bbcode_text = "[b]Strength:[/b] " + data.get("strength", "N/A")
	if weakness_label:
		weakness_label.bbcode_text = "[b]Weakness:[/b] " + data.get("weakness", "N/A")

	# Update Reactions Grid
	if reactions_grid:
		_update_reactions_grid(data.get("reactions", {})) # Pass reactions dict

	# Update Image (Check if node exists)
	if element_image:
		if image_cache.has(element_key):
			element_image.texture = image_cache[element_key]
		else:
			element_image.texture = null # Set to null if image wasn't loaded
			# print_debug("Image cache miss for key: ", element_key) # Already logged in preload

	# Update +/- button states based on new selection's limits
	_update_modify_button_states()


func _clear_information_panel() -> void:
	selected_element_key = ""
	if description_label: description_label.text = ""
	if strength_label: strength_label.text = ""
	if weakness_label: weakness_label.text = ""
	if reactions_grid:
		for child in reactions_grid.get_children():
			child.queue_free()
	if element_image: element_image.texture = null


func _update_reactions_grid(reactions: Dictionary) -> void:
	# Clear existing reaction labels
	for child in reactions_grid.get_children():
		child.queue_free()

	if reactions.is_empty():
		var no_reactions_label = Label.new()
		no_reactions_label.text = "No special reactions."
		no_reactions_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		reactions_grid.add_child(no_reactions_label)
		return

	var sorted_keys = reactions.keys()
	sorted_keys.sort() # Optional: Sort reactions alphabetically

	for reaction_key in sorted_keys:
		var reaction_desc = reactions[reaction_key]
		var reaction_label = RichTextLabel.new()
		reaction_label.bbcode_enabled = true
		reaction_label.fit_content = true # Adjust height automatically
		reaction_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		# Maybe use different formatting (bold key)
		reaction_label.bbcode_text = "[b]%s:[/b] %s" % [reaction_key, reaction_desc]
		reaction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		reactions_grid.add_child(reaction_label)

	# reactions_grid.queue_sort() # queue_sort is for Node order, not visual sorting within GridContainer


# Efficiently updates only the text of the value labels in the stats grid.
func _update_stats_grid() -> void:
	if stat_value_labels.is_empty():
		push_warning("Stat value labels dictionary is empty, cannot update grid.")
		return

	for key in current_stats:
		if stat_value_labels.has(key):
			var label_node = stat_value_labels[key] as Label
			if is_instance_valid(label_node):
				label_node.text = str(current_stats[key])
				# Optional: Add visual feedback for changes (e.g., brief color tween)
				# _animate_label_update(label_node)
			else:
				printerr("Invalid label node found in cache for key: ", key)
		else:
			push_warning("No value label found in cache for stat key: ", key)


func _update_point_label() -> void:
	if points_label:
		points_label.text = str(points_remaining)
		# Optional: Change color if points reach 0 or go negative (shouldn't happen)
		if points_remaining == 0:
			points_label.modulate = Color.GOLD
		elif points_remaining < 0: # Error state
			points_label.modulate = Color.RED
		else:
			points_label.modulate = Color.WHITE


func _update_modify_button_states() -> void:
	var can_add = false
	var can_subtract = false

	if not selected_element_key.is_empty():
		var current_val = current_stats.get(selected_element_key, -1)
		can_add = points_remaining > 0 and current_val < max_stat_value
		can_subtract = current_val > initial_stats.get(selected_element_key, min_stat_value) # Can subtract down to initial value

	if add_button:
		add_button.disabled = not can_add
	if minus_button:
		minus_button.disabled = not can_subtract

#endregion


#region Stat Modification Logic
# ============================================================================ #

func _modify_stat(element_key: String, change: int) -> void:
	if not current_stats.has(element_key):
		printerr("Attempted to modify unknown element: ", element_key)
		return

	var current_val: int = current_stats[element_key]
	var initial_val: int = initial_stats.get(element_key, min_stat_value)
	var points_change: int = change / stat_increment # Calculate points cost/refund

	# --- Check Limits BEFORE applying changes ---
	# Adding points
	if change > 0:
		if points_remaining <= 0:
			print_debug("No points left to add.")
			# Optional: Add visual shake or sound effect
			return
		if current_val >= max_stat_value:
			print_debug("Stat already at maximum.")
			return
		# Ensure we don't overshoot max value if increment is large
		change = min(change, max_stat_value - current_val)
		# Recalculate points cost based on actual change (if cost scaling was added)
		points_change = change / stat_increment # Simple for now
		if points_change > points_remaining:
			# This case might happen if max_stat_value isn't a multiple of stat_increment
			# Or if points_remaining is low. Decide how to handle - maybe only allow full increments?
			# For now, just prevent the change.
			print_debug("Not enough points for this increment.")
			return

	# Subtracting points
	elif change < 0:
		if current_val <= initial_val: # Use initial_val as the floor
			print_debug("Stat already at minimum/initial value.")
			return
		# Ensure we don't go below initial value
		change = max(change, initial_val - current_val)
		# Recalculate points refund based on actual change
		points_change = change / stat_increment # Will be negative

	# --- Apply Changes ---
	current_stats[element_key] += change
	points_remaining -= points_change # Subtract cost or Add refund

	# --- Update UI ---
	_update_stats_grid() # Update the specific label efficiently
	_update_point_label()
	_update_modify_button_states() # Update +/- buttons based on new state


func _reset_stats() -> void:
	# Restore points
	points_remaining = total_points

	# Restore stats from the initial values stored at the start
	current_stats = initial_stats.duplicate() # Create a fresh copy

	# Update UI
	_update_stats_grid()
	_update_point_label()
	_update_modify_button_states()


#endregion


#region Signal Handlers
# ============================================================================ #

func _on_add_button_pressed() -> void:
	if not selected_element_key.is_empty():
		# Play sound effect
		# SoundManager.play_sfx("ui_increase")
		_modify_stat(selected_element_key, stat_increment)


func _on_minus_button_pressed() -> void:
	if not selected_element_key.is_empty():
		# Play sound effect
		# SoundManager.play_sfx("ui_decrease")
		_modify_stat(selected_element_key, -stat_increment)


func _on_reset_button_pressed() -> void:
	# Optional: Add a confirmation dialog first
	print_debug("Resetting stats.")
	# Play sound effect
	# SoundManager.play_sfx("ui_reset")
	_reset_stats()
	# Optionally deselect current element/button
	if selected_button:
		selected_button.button_pressed = false
	selected_button = null
	_clear_information_panel()
	_update_modify_button_states()


func _on_continue_button_pressed() -> void:
	if not continue_screen:
		printerr("No Continue Scene Set!")
		return

	if points_remaining == 0:
		_proceed_to_next_scene()
	else:
		# Show warning panel instead of just printing
		if warning_panel:
			warning_panel.visible = true
		else:
			printerr("Warning panel node not found, cannot show warning.")
			# Fallback: just print
			print("Cannot continue, points remaining: ", points_remaining)


func _on_warning_cancel_button_pressed() -> void: # Assuming button name inside warning panel
	if warning_panel:
		warning_panel.visible = false


func _on_warning_confirm_button_pressed() -> void: # Assuming button name inside warning panel
	if warning_panel:
		warning_panel.visible = false
	_proceed_to_next_scene()


func _proceed_to_next_scene() -> void:
	print("Saving stats and changing scene...")
	if not PlayerStats:
		printerr("PlayerStats autoload not found, cannot save stats!")
		return
	if not continue_screen:
		printerr("No Continue Scene Set!")
		return

	# Save the allocated stats
	PlayerStats.set_element_stats(current_stats) # Assume PlayerStats has a method like this

	# Optionally: Disable further interaction on this screen
	set_process(false)

	# Transition
	get_tree().change_scene_to_packed(continue_screen)

#endregion


# Optional: Animation Helper
# func _animate_label_update(label: Label) -> void:
# 	var tween = create_tween()
# 	tween.set_parallel(true)
# 	tween.tween_property(label, "modulate", Color.YELLOW, 0.1)
# 	tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
# 	tween.chain()
# 	tween.tween_property(label, "modulate", Color.WHITE, 0.2)
# 	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
