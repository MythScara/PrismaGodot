extends Node

# Signals for inventory events
signal item_added(item_name: String, slot_index: int)
signal item_removed(item_name: String, slot_index: int)
signal inventory_full()

# Inventory configuration
const MAX_SLOTS: int = 5
var inventory_slots: Array = []  # Array to hold items (null for empty slots)

# Preload item scene for instantiation
@onready var item_icon_scene: PackedScene = preload("res://scenes/item_icon.tscn")
@onready var grid_container: GridContainer = $InventoryUI/GridContainer

func _ready() -> void:
    # Initialize inventory slots
    inventory_slots.resize(MAX_SLOTS)
    inventory_slots.fill(null)
    
    # Connect UI slots to input handling
    for i in range(grid_container.get_child_count()):
        var slot = grid_container.get_child(i)
        slot.gui_input.connect(_on_slot_gui_input.bind(i))

func add_item(item_name: String, item_texture: Texture2D = null) -> bool:
    # Find first empty slot
    var empty_slot = inventory_slots.find(null)
    if empty_slot == -1:
        inventory_full.emit()
        return false
    
    # Add item to inventory
    inventory_slots[empty_slot] = item_name
    
    # Update UI
    var slot_node = grid_container.get_child(empty_slot)
    var item_icon = item_icon_scene.instantiate()
    item_icon.texture = item_texture if item_texture else preload("res://assets/default_item.png")
    slot_node.add_child(item_icon)
    
    item_added.emit(item_name, empty_slot)
    return true

func remove_item(slot_index: int) -> bool:
    if slot_index < 0 or slot_index >= MAX_SLOTS or inventory_slots[slot_index] == null:
        return false
    
    # Remove item from inventory
    var item_name = inventory_slots[slot_index]
    inventory_slots[slot_index] = null
    
    # Update UI
    var slot_node = grid_container.get_child(slot_index)
    for child in slot_node.get_children():
        child.queue_free()
    
    item_removed.emit(item_name, slot_index)
    return true

func get_item(slot_index: int) -> String:
    if slot_index >= 0 and slot_index < MAX_SLOTS:
        return inventory_slots[slot_index]
    return ""

func is_full() -> bool:
    return inventory_slots.find(null) == -1

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
        if inventory_slots[slot_index] != null:
            remove_item(slot_index)

# Example usage function
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):  # For testing, e.g., pressing Enter
        add_item("Sword", preload("res://assets/sword_icon.png"))
