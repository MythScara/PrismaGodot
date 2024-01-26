extends Node

var active = false

var specialist_info = {
	"Name": "Mercenary",
	"Description": "Hired militant officer with training in all forms of modern warfare. Loyalty to the highest bidder and an aptitude for survival.",
	"Weapon": "Assault Rifle",
	"Passive 1": "Gain immunity to [b]Blaze[/b].",
	"Passive 2": "Increase [b]DMG[/b] by [b]5[/b] on [b]Ranged Weapons[/b].",
	"Passive 3": "Taking [b]Physical Damage[/b] restores [b]2% Overshield[/b]. Can only occur once every [b]5 [/b]seconds.",
	"Technique 1": {"TN": "Increase [b]RLD[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "TD": 10, "TC": 30},
	"Technique 2": {"TN": "Increase [b]INF[/b] by [b]20[/b] on [b]Ranged Weapons[/b].", "TD": 10, "TC": 40},
	"Technique 3": {"TN": "All [b]Ranged Weapon[/b] hits register as [b]Weakpoint[/b].", "TD": 15, "TC": 90}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
