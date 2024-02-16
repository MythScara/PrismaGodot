extends Node
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func save_game() -> void:
	var save_data = {
		"player_stats": PlayerStats.get_save_data(),
		"player_inventory": PlayerInventory.get_save_data()
	}
	
	var save_path = "user://save_game.json"
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	if save_file != null:
		var save_data_string = JSON.stringify(save_data, "\t", false, true)
		save_file.store_string(save_data_string)
		save_file.close()
		print_debug("Game Saved")
	else:
		print_debug("Game Save Failed")
		
func load_game() -> void:
	var save_path = "user://save_game.json"
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	if save_file != null:
		var json = JSON.new()
		var result = json.parse(save_file.get_as_text())
		if result == OK:
			var save_data = json.get_data()
			save_file.close()
			
			PlayerStats.set_data(save_data["player_stats"])
			PlayerInventory.set_data(save_data["player_inventory"])
			
			print_debug("Game Loaded")
		else:
			print_debug("Game Load Failed")
	else:
		print_debug("Game Load Failed")

func save_exists() -> bool:
	var save_path = "user://save_game.json"
	return FileAccess.file_exists(save_path)

func delete_save():
	var save_path = "user://save_game.json"
	var dir = DirAccess.open(save_path)
	if dir:
		DirAccess.remove_absolute(save_path)
