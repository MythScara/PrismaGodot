extends Control

# Preloaded resources
var ItemInfo = preload("res://object/item_info.tscn")
var ButtonStyle = preload("res://object/standardbutton.tscn")

# Constants
const FONT_SIZE_DEFAULT = 20
const STAT_COLOR_BETTER = Color(0, 1, 0)  # Green for upgrades
const STAT_COLOR_WORSE = Color(1, 0, 0)   # Red for downgrades
const STAT_COLOR_NEUTRAL = Color(1, 1, 1) # White for no comparison

# Configurable item properties to display
const ITEM_PROPERTIES = ["Tier", "Quality", "Element", "Extra", "Description"]

# Signals
signal button_pressed(item_name)

# Instance variables
var current_info = null
var selected_button: Button = null

# Rarity-based name colors (example configuration)
const RARITY_COLORS = {
    "Common": Color(1, 1, 1),      # White
    "Rare": Color(0, 0.5, 1),      # Blue
    "Epic": Color(0.5, 0, 1),      # Purple
    "Legendary": Color(1, 0.5, 0)  # Orange
}

# Called when a button is pressed to select an item
func _on_button_pressed(new_button: Button) -> void:
    if selected_button != null and selected_button != new_button:
        selected_button.set_pressed(false)
    selected_button = new_button
    new_button.set_pressed(true)
    emit_signal("button_pressed", new_button.text)

# Replace an item in a slot and update stats
func replace_field(type: String, image: String, item_name: String, values: Dictionary, slot: int = 0) -> void:
    var current_item = PlayerInventory.current_inventory[type].get(slot, null)
    
    if current_item != null and not current_item.is_empty():
        var original = current_item.keys()[0]
        if original == item_name:
            _notify_player("This Item is Already Equipped")
            return
        _update_stats(current_item[original], "Sub")
    else:
        # Slot is empty; no stats to subtract
        pass
    
    PlayerInventory.current_inventory[type][slot] = {item_name: values}
    _update_stats(values, "Add")
    PlayerStats.emit_signal("value_change", type, slot)
    _notify_player("Equipped " + item_name)
    PlayerInterface.clear_selection()

# Unequip an item from a slot
func unequip_field(type: String, slot: int) -> void:
    var current_item = PlayerInventory.current_inventory[type].get(slot, null)
    if current_item != null and not current_item.is_empty():
        var original = current_item.keys()[0]
        _update_stats(current_item[original], "Sub")
        PlayerInventory.current_inventory[type][slot] = {}
        PlayerStats.emit_signal("value_change", type, slot)
        _notify_player("Unequipped item from " + type + " slot " + str(slot))
        PlayerInterface.clear_selection()

# Display available items for selection
func display_field(type: String, image: String, item_name: String, values: Dictionary, slot: int = 0) -> void:
    PlayerInterface.clear_selection()
    for key in PlayerInventory.equip_inventory[type].keys():
        var option = ButtonStyle.instantiate()
        var input = PlayerInventory.equip_inventory[type]
        option.text = key
        option.add_theme_font_size_override("font_size", FONT_SIZE_DEFAULT)
        option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        option.connect("pressed", Callable(self, "display_info").bind(type, image, key, input[key], slot))
        option.pressed.connect(_on_button_pressed.bind(option))
        PlayerInterface.selection_field.add_child(option)
        
        # Pre-select the currently equipped item
        var current_item = PlayerInventory.current_inventory[type].get(slot, null)
        if current_item != null and not current_item.is_empty() and key == current_item.keys()[0]:
            _on_button_pressed(option)
            display_info(type, image, key, input[key], slot)

# Display detailed information about an item
func display_info(type: String, image: String, item_name: String, values: Dictionary, slot: int = 0) -> void:
    if item_name == null or values == null:
        _notify_player("Error: Invalid item selected")
        return
    
    # Get current item for comparison
    var current_item = PlayerInventory.current_inventory[type].get(slot, null)
    var compare_info = null
    if current_item != null and not current_item.is_empty():
        var compare_tag = current_item.keys()[0]
        compare_info = current_item[compare_tag]
    
    # Clean up previous info
    if current_info != null:
        current_info.queue_free()
    
    # Instantiate and set up new info panel
    current_info = ItemInfo.instantiate()
    PlayerInterface.information_field.add_child(current_info)
    
    # Set item name with rarity color if applicable
    var name_label = current_info.get_node("Name")
    name_label.text = item_name
    if values.has("Rarity") and RARITY_COLORS.has(values["Rarity"]):
        name_label.add_theme_color_override("font_color", RARITY_COLORS[values["Rarity"]])
    
    current_info.get_node("ItemType").text = type
    
    # Populate item properties dynamically
    for prop in ITEM_PROPERTIES:
        var node_name = "Item" + prop if prop != "Description" else "Scroll/StatBar/ItemDescription"
        var node = current_info.get_node(node_name)
        if values.has(prop):
            if prop == "Description":
                node.visible = true
                node.text = values[prop]
            elif prop == "Quality":
                node.text = "Quality: " + str(values[prop])
            else:
                node.text = str(values[prop])
        else:
            node.text = "" if prop != "Description" else node.visible = false
    
    # Load item image with fallback
    var path = "res://asset/" + type.to_lower() + "/" + item_name.to_lower() + ".png"
    if not ResourceLoader.exists(path):
        path = "res://asset/hud_icons/locked_icon.png"
    current_info.get_node("ItemImage").texture = load(path)
    
    # Equip button
    var equip_button = current_info.get_node("EquipButton")
    equip_button.text = "EQUIP " + type.to_upper()
    equip_button.connect("pressed", Callable(self, "replace_field").bind(type, image, item_name, values, slot))
    
    # Unequip button (if slot is occupied)
    if compare_info != null:
        var unequip_button = Button.new()
        unequip_button.text = "UNEQUIP"
        unequip_button.connect("pressed", Callable(self, "unequip_field").bind(type, slot))
        current_info.add_child(unequip_button)
    
    # Display stats with comparison
    var stat_bar = current_info.get_node("Scroll/StatBar")
    for key in values.keys():
        if key not in PlayerStats.excluded and (typeof(values[key]) == TYPE_FLOAT or typeof(values[key]) == TYPE_INT):
            _create_stat_row(stat_bar, key, values, compare_info)

# Helper function to update player stats
func _update_stats(values: Dictionary, operation: String) -> void:
    if values.is_empty():
        return
    PlayerStats.player_stat_change(values, operation)
    PlayerStats.element_stat_change(values, operation)

# Helper function to create a stat display row
func _create_stat_row(parent: Node, key: String, values: Dictionary, compare_info: Dictionary) -> void:
    var hbox = HBoxContainer.new()
    parent.add_child(hbox)
    
    var key_text = Label.new()
    key_text.text = key
    key_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    key_text.add_theme_font_size_override("font_size", FONT_SIZE_DEFAULT)
    hbox.add_child(key_text)
    
    var key_value = Label.new()
    key_value.text = str(values[key])
    
    if compare_info != null and compare_info.has(key) and (typeof(compare_info[key]) == TYPE_FLOAT or typeof(compare_info[key]) == TYPE_INT):
        if values[key] > compare_info[key]:
            key_value.add_theme_color_override("font_color", STAT_COLOR_BETTER)
        elif values[key] < compare_info[key]:
            key_value.add_theme_color_override("font_color", STAT_COLOR_WORSE)
    else:
        key_value.add_theme_color_override("font_color", STAT_COLOR_NEUTRAL)
    
    key_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    key_value.add_theme_font_size_override("font_size", FONT_SIZE_DEFAULT)
    key_value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(key_value)

# Placeholder for player notification system
func _notify_player(message: String) -> void:
    print(message)  # Replace with actual UI notification (e.g., popup) in a full implementation
