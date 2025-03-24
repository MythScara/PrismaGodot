extends Control

# Node references
onready var name_label = $Name
onready var item_image = $ItemImage
onready var type_label = $ItemType
onready var tier_label = $ItemTier
onready var element_label = $ItemElement
onready var extra_label = $ItemExtra
onready var quality_label = $ItemQuality
onready var stats_grid = $Scroll/StatBar/StatsGrid
onready var description_label = $Scroll/StatBar/ItemDescription
onready var equip_button = $ButtonBar/EquipButton
onready var sell_button = $ButtonBar/SellButton
onready var drop_button = $ButtonBar/DropButton

# Set item data and optionally compare with an equipped item
func set_item(item, equipped_item = null):
    # Basic info
    name_label.text = item.name
    item_image.texture = load(item.image_path)
    type_label.text = item.type
    tier_label.text = item.tier
    element_label.text = item.element
    extra_label.text = item.extra
    quality_label.text = "Quality: %d" % item.quality
    
    # Color quality label based on value
    if item.quality >= 90:
        quality_label.add_color_override("font_color", Color.GREEN)
    elif item.quality >= 50:
        quality_label.add_color_override("font_color", Color.YELLOW)
    else:
        quality_label.add_color_override("font_color", Color.RED)
    
    # Clear existing stats
    for child in stats_grid.get_children():
        child.queue_free()
    
    # Collect all stats to display (current item + unique equipped item stats)
    var all_stats = item.stats.keys()
    if equipped_item:
        for stat in equipped_item.stats.keys():
            if not all_stats.has(stat):
                all_stats.append(stat)
    
    # Populate stats grid
    for stat in all_stats:
        var name_label = Label.new()
        name_label.text = stat.capitalize() + ":"
        stats_grid.add_child(name_label)
        
        var value_label = Label.new()
        value_label.bbcode_enabled = true
        var base_value = item.stats.get(stat, 0)
        var equipped_value = equipped_item.stats.get(stat, 0) if equipped_item else 0
        var diff = base_value - equipped_value
        var diff_text = ""
        if diff > 0:
            diff_text = " [color=green](+%d)[/color]" % diff
        elif diff < 0:
            diff_text = " [color=red](%d)[/color]" % diff
        value_label.text = str(base_value) + diff_text
        stats_grid.add_child(value_label)
    
    # Set description
    description_label.text = item.description

# Button signal handlers
func _on_EquipButton_pressed():
    # TODO: Implement equip logic (e.g., call inventory system)
    print("Equip pressed for: ", name_label.text)
    pass

func _on_SellButton_pressed():
    # TODO: Implement sell logic (e.g., add currency, remove item)
    print("Sell pressed for: ", name_label.text)
    pass

func _on_DropButton_pressed():
    # TODO: Implement drop logic (e.g., remove item from inventory)
    print("Drop pressed for: ", name_label.text)
    pass
