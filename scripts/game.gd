extends Control

var focus = false
var player

func _ready():
	player = get_node("ViewportContainer/Viewport/Player")
	
	
func _process(delta):
	if (focus):
		player.move(delta)

# Button input inside viewports is broken, so "focus" is determined
# by hovering the mouse over the viewport
func _on_mouse_entered():
	focus = true

func _on_mouse_exited():
	focus = false
