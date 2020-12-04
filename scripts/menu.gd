extends Node

var game_scene = load("res://scenes/game.tscn")
var game

func _ready():
	anchor($Title, 0.5, 0.4)
	anchor($Host, 0.5, 0.6)
	anchor($Join, 0.5, 0.7)
	anchor($CodeField, 0.55, 0.7)
	anchor($NameField, 0.5, 0.1)

func _on_host():
	game = game_scene.instance()
	add_child(game)
	game.init_client($NameField.text, "44.238.40.224", "9080", "")
	
func _on_join():
	game = game_scene.instance()
	add_child(game)
	game.init_client($NameField.text, "44.238.40.224", "9080", $CodeField.text)

func anchor(control, x, y):
	control.anchor_left = x
	control.anchor_right = x
	control.anchor_top = y
	control.anchor_bottom = y
	var size = control.get_rect().size
	control.margin_left = -size.x / 2
	control.margin_right = -size.x / 2
	control.margin_top = -size.y / 2
	control.margin_bottom = -size.y / 2
