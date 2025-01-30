extends Control

const target_scene_path = "res://scene/species_menu.tscn"

func _ready() -> void:
	# Initialize loading
	ResourceLoader.load_threaded_request(target_scene_path)

func _process(delta : float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	$ProgressBar.value = progress[0]*100
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(packed_scene)
