extends GridContainer

var stats = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120]
var values = ["HP  ", "MP  ", "SHD ", "STM ", "ATK ", "DEF ", "MGA ", "MGD ", "SHR ", "STR ", "AG  ", "CAP "]  # Example stats

func _ready():
	for i in range(12):
		var label = Label.new()
		label.text = values[i] + str(stats[i])
		add_child(label)

func update_stats(new_stats):
	for i in range(min(new_stats.size(), get_child_count())):
		var label = get_child(i)
		label.text = values[i] + str(new_stats[i])
