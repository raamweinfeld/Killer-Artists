extends Control

var focus = false
var player
var players = {}
var players_node: Node

func _ready():
	player = get_node("ViewportContainer/Viewport/Player")
	players_node = get_node("ViewportContainer/Viewport/Players")
	
func _physics_process(delta):
	if (focus):
		player.move(delta)

# Button input inside viewports is broken, so "focus" is determined
# by hovering the mouse over the viewport
func _on_mouse_entered():
	focus = true

func _on_mouse_exited():
	focus = false

func get_client_info():
	return {pos=player.position}

func update_player(player_id, data):
	players[player_id] = data
	if(!players_node.has_node(str(player_id))):
		var new_player_node = Sprite.new()
		new_player_node.name = str(player_id)
		new_player_node.texture = load("res://assets/player_test.png")
		players_node.add_child(new_player_node)
	players_node.get_node(str(player_id)).position = data.pos

func disconnect_peer(id):
	players_node.get_node(str(id)).remove_and_skip()
	pass
