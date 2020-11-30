extends Control

var viewport: Viewport

var focus:bool = false
var player:KinematicBody2D
var first_player:bool
var players = {}
var player_ids : Array = []
var players_node: Node
var logs:Array = []
var playing:bool = false
const settings = {impostors = 2,killLength=250}
var is_impostor:bool = false
var is_dead:bool = false

var rand_generate:RandomNumberGenerator = RandomNumberGenerator.new()
var impostors:Array = []
var player_name: String = "jeff"
var id:int

var prev_pixel:Vector2
var lines_to_draw:Array = []

func _ready():
	viewport = get_node("ViewportContainer/Viewport")
	player = viewport.get_node("Player")
	players_node = viewport.get_node("Players")
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
	var mouse_pos : Vector2
	var drawing : Sprite = viewport.get_node("Background")
	var img = drawing.texture.get_data()
	if(focus && Input.get_action_strength("drawing") == 1):
		var scale : Vector2 = player.get_node("Camera2D").zoom
		mouse_pos = get_local_mouse_position()
		mouse_pos -= get_parent_area_size()/2
		mouse_pos *= scale
		mouse_pos += player.position
		mouse_pos /= drawing.scale
		mouse_pos += img.get_size()/2
		if(!prev_pixel): prev_pixel = mouse_pos
		lines_to_draw.append([prev_pixel,mouse_pos])
	img.lock()

	for line in lines_to_draw:
		var diff = line[0]-line[1]
		var length = diff.length()
		length = max(1,length)
		for i in range(0, length):
			var i_pix = line[1] + i/length*diff
			img.set_pixel(i_pix.x, i_pix.y, Color(255, 0, 0))

	lines_to_draw = []
	img.unlock()
	var new_texture = ImageTexture.new()
	new_texture.create_from_image(img)
	drawing.texture = new_texture
	drawing.update()
	
	if(focus && Input.get_action_strength("start") == 1 && !playing): start_game()
	var killing = -1
	if(is_impostor && !is_dead && focus && Input.is_action_just_pressed("kill")):
		var minLength = 100000000000
		for player2 in players.values():
			var length = (player2.pos-player.position).length()
			if(length < minLength && !player2.is_impostor):
				minLength = length
				killing = player2.id
		if(minLength > settings.killLength): killing = -1
		if(killing != -1):
			var body:Sprite = Sprite.new()
			body.texture = load("res://assets/player_test.png")
			body.light_mask = 2
			body.position = players[killing].pos
			viewport.add_child(body)
			player.position = players[killing].pos
	var data = {
		pos=player.position,
		first_player=first_player,
		playing=playing,
		is_impostor=is_impostor,
		impostors=impostors,
		player_name=player_name,
		is_dead=is_dead,
		killing=killing,
		id=id,
		drawing=[prev_pixel,mouse_pos]
	}
	prev_pixel = mouse_pos
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

	if(data.drawing[1]):
		lines_to_draw.append(data.drawing)
			
	if(!players_node.has_node(str(player_id))):
		player_ids.append(player_id)
		var new_player_node = Sprite.new()
		new_player_node.name = str(player_id)
		new_player_node.texture = load("res://assets/player_test.png")
		new_player_node.light_mask = 2
		new_player_node.set_script(load("res://scripts/draw_player.gd"))
		players_node.add_child(new_player_node)
	if(data.killing == id):
		is_dead = true
		var body:Sprite = Sprite.new()
		body.texture = load("res://assets/player_test.png")
		body.light_mask = 2
		body.position = player.position
		viewport.add_child(body)
	elif(data.killing != -1):
		var body:Sprite = Sprite.new()
		body.texture = load("res://assets/player_test.png")
		body.light_mask = 2
		body.position = players[data.killing].pos
		viewport.add_child(body)
	var player_node:Sprite = players_node.get_node(str(player_id))
	player_node.position = data.pos
	player_node.data = data
	player_node.update()

func start_game():
	var rot = id
	player.position = Vector2(300,-1000)+Vector2(cos(rot),sin(rot))*200
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
