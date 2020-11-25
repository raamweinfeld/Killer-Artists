extends Control

var focus:bool = false
var player:KinematicBody2D
var first_player:bool
var players = {}
var player_ids : Array = []
var players_node: Node
var logs:Array = []
var playing:bool = false
const settings = {impostors = 2}
var is_impostor:bool = false

var rand_generate:RandomNumberGenerator = RandomNumberGenerator.new()
var impostors:Array = []
var player_name: String = "jeff"
var id:int

func _ready():
	player = get_node("ViewportContainer/Viewport/Player")
	players_node = get_node("ViewportContainer/Viewport/Players")
	rand_generate.randomize()
	
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
	if(Input.get_action_strength("start") == 1 && !playing): start_game()
	var data = {
		pos=player.position,
		first_player=first_player,
		playing=playing,
		is_impostor=is_impostor,
		impostors=impostors,
		player_name=player_name
	}
	player.update_draw_data(data)
	return data

func set_first_player(is_first):
	first_player = is_first

func set_id(client_id):
	id = client_id

func update_player(player_id, data):
	players[player_id] = data
	if(data.first_player): 
		impostors = data.impostors
		is_impostor = impostors.has(id)
	if(data.playing && !playing):
		start_game()
			
	if(!players_node.has_node(str(player_id))):
		player_ids.append(player_id)
		var new_player_node = Sprite.new()
		new_player_node.name = str(player_id)
		new_player_node.texture = load("res://assets/player_test.png")
		new_player_node.light_mask = 2
		new_player_node.set_script(load("res://scripts/draw_player.gd"))
		players_node.add_child(new_player_node)
	var player_node:Sprite = players_node.get_node(str(player_id))
	player_node.position = data.pos
	player_node.data = data
	player_node.update()

func start_game():
	var rot = id
	player.position = Vector2(300,-1000)+Vector2(cos(rot),sin(rot))*100
	playing = true
	if(first_player):
		var l_players = player_ids
		l_players.append(id)
		impostors = []
		for _i in range(settings.impostors):
			var idx = rand_generate.randi_range(0, l_players.size()-1)
			var id = l_players[idx]
			l_players.remove(idx)
			impostors.append(id)
		is_impostor = impostors.has(id)

func disconnect_peer(id):
	players_node.get_node(str(id)).remove_and_skip()
	player_ids.erase(id)
