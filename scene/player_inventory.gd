extends Node

# Signal to notify when the inventory changes
signal inventory_changed

# Inventory data structure (array of items)
var inventory = []
var max_slots = 5  # Matches the number of slots in the GridContainer

# References to UI nodes
@onready var grid_container = $CanvasLayer/InventoryUI/GridContainer
@onready var audio_player = $AudioStreamPlayer

func _ready():
    # Load inventory on startup
    load_inventory()
    update_ui()

func add_item(item):
    # Add an item if there's space
    if inventory.size() < max_slots:
        inventory.append(item)
        inventory_changed.emit()
        audio_player.play()
        update_ui()
        save_inventory()
        return true
    return false

func remove_item(item):
    # Remove an item if it exists
    if item in inventory:
        inventory.erase(item)
        inventory_changed.emit()
        audio_player.play()
        update_ui()
        save_inventory()

func use_item(item):
    # Example logic to "use" an item
    if item in inventory:
        print("Using item: ", item)
        remove_item(item)

func update_ui():
    # Update the GridContainer slots to reflect the inventory
    for i in range(grid_container.get_child_count()):
        var slot = grid_container.get_child(i)
        if i < inventory.size():
            # Set texture or other properties based on the item
            # For now, we'll just indicate the slot is filled
            slot.modulate = Color(1, 1, 1, 1)  # Full opacity
        else:
            slot.modulate = Color(1, 1, 1, 0.5)  # Half opacity for empty slots

func save_inventory():
    # Save inventory to a file
    var file = FileAccess.open("user://inventory.save", FileAccess.WRITE)
    if file:
        file.store_var(inventory)
        file.close()

func load_inventory():
    # Load inventory from a file
    var file = FileAccess.open("user://inventory.save", FileAccess.READ)
    if file and file.is_open():
        inventory = file.get_var()
        file.close()
