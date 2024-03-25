extends Control

@onready var inventoryButton = $PauseMenu/InventoryButton
@onready var questButton = $PauseMenu/QuestsButton
@onready var playerButton = $PauseMenu/PlayerButton
@onready var intelButton = $PauseMenu/IntelButton
@onready var spellsButton = $PauseMenu/SpellsButton
@onready var mapButton = $PauseMenu/MapButton
@onready var equipmentButton = $PauseMenu/EquipmentButton
@onready var settingsButton = $PauseMenu/SettingsButton

@onready var inventoryScreen = $InventoryScreen
@onready var settingsScreen = $SettingsScreen

var selected_button = null
var selected_screen = null

func _ready():
	pass

func set_active(new_button: Button, new_screen):
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	if selected_screen != null and selected_screen != new_screen:
		selected_screen.visible = false
	
	selected_button = new_button
	selected_screen = new_screen
	if new_button != null:
		new_button.set_pressed(true)
		
	if new_screen != null:
		new_screen.visible = true

func _on_inventory_button_pressed():
	set_active(inventoryButton, inventoryScreen)

func _on_quests_button_pressed():
	set_active(questButton, null)

func _on_player_button_pressed():
	set_active(playerButton, null)

func _on_intel_button_pressed():
	set_active(intelButton, null)

func _on_spells_button_pressed():
	set_active(spellsButton, null)

func _on_map_button_pressed():
	set_active(mapButton, null)

func _on_equipment_button_pressed():
	set_active(equipmentButton, null)

func _on_settings_button_pressed():
	set_active(settingsButton, settingsScreen)
