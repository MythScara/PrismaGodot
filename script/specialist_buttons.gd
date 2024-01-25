extends VBoxContainer

var selected_button = null

func _ready():
	for i in range(get_child_count()):
		var button = get_child(i)
		if button is Button:
			#button.connect("pressed", Callable(self, "_on_Button_pressed"))
			button.pressed.connect(_on_Button_pressed.bind(button))

func _on_Button_pressed(new_button : Button):
	# Find the pressed button
	if selected_button != null and selected_button != new_button:
		selected_button.set_pressed(false)
	
	selected_button = new_button
	new_button.set_pressed(true)
	handle_button_press(new_button)

func handle_button_press(button: Button):
	match button.text:
		"Mercenary":
			print("Mercenary button pressed")
		"Cavalier":
			print("Cavalier button pressed")
		# ... add cases for other buttons




