extends Control

var client
var connected:bool = false

var player:KinematicBody2D
var first_player:bool
var players = {}
var player_ids : Array = []
var players_node: Node
var logs:Array = []
var playing:bool = false
var ending:bool = false
var starting:bool = false
const settings = {
	impostors = 2,
	killLength=250,
	kill_cooldown=25,
	colors=[Color(1,0,0),Color(0,1,0),Color(1,1,0),Color(0,0,1),Color(1,0,1),Color(0,1,1),Color(1,1,1),Color(0,0,0),Color(0.5,0,0.5),Color(0.5,0.5,0.5),Color(0,0.5,0),Color(0.5,0.25,0)]
}
var is_impostor:bool = false
var killing:int
var kill_cooldown:float = 0
var is_dead:bool = false

var rand_generate:RandomNumberGenerator = RandomNumberGenerator.new()
var impostors:Array = []
var player_name: String = ""
var id:int
var code:String = ""
var vote:int = -1
var votes = []
var color:Color = Color(1,1,1)

var prev_pixel:Vector2
var draw_color:Color = settings.colors[0]
var lines_to_draw:Array = []
var img:Image = Image.new()
var drawing : Sprite
var new_texture = ImageTexture.new()

func _ready():
	client = $Client
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("connected", self, "_connected")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	client.rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	client.rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	client.rtc_mp.connect("connection_succeeded", self, "_mp_connected")

	player = get_node("Player")
	players_node = get_node("Players")
	drawing = get_node("Drawing")
	rand_generate.randomize()


	img.create($Background.texture.get_size().x, $Background.texture.get_size().y,false,Image.FORMAT_RGBA8)
	new_texture.create_from_image(img)
	
	
func init_client(name, ip, port, code):
	player_name = name
	client.start(ip + ":" + port, code)


func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("Multiplayer peer %d connected" % id)
	set_color()


func _mp_peer_disconnected(id: int):
	disconnect_peer(id)
	_log("Multiplayer peer %d disconnected" % id)
	set_color()

func _lobby_joined(lobby):
	_log("Joined lobby %s" % lobby)
	code = lobby

func _lobby_sealed():
	_log("Lobby has been sealed")


func _connected(ids):
	_log("Signaling server connected with ID: %d" % ids)
	connected = true
	id = ids

	first_player = client.rtc_mp.get_peers().size() == 0
	set_color()

func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [client.code, client.reason])

func set_color():
	var player_id_idx = client.rtc_mp.get_peers().keys()
	player_id_idx.append(id)
	player_id_idx.sort()
	color = settings.colors[player_id_idx.find(id)]

func _process(delta):
	kill_cooldown -= delta
	if(connected):
		client.rtc_mp.put_var(get_client_info(), true)
		for x in logs:
			_log(str(x))
		logs.clear()

		client.rtc_mp.poll()
		while client.rtc_mp.get_available_packet_count() > 0:
			var id = client.rtc_mp.get_packet_peer()
			var sent_data = client.rtc_mp.get_var(true)
			update_player(id,sent_data)

func _log(msg):
	print(msg)
	
func _physics_process(delta):
	player.move(delta)

func get_client_info():
	var mouse_pos : Vector2
	var mouse_pixel : Vector2

	var scale : Vector2 = player.get_node("Camera2D").zoom
	var mouse_screen_pos = player.get_local_mouse_position()
	mouse_pos = get_global_mouse_position()

	if(Input.get_action_strength("drawing") == 1):
		if(mouse_screen_pos.y > get_viewport().size.y*scale.y/2-60 && abs(mouse_screen_pos.x) < 60*floor(settings.colors.size()/2)+20 && (settings.colors.size()%2==1 || mouse_screen_pos.x < 60*floor((settings.colors.size()-1)/2)+20)):
			draw_color = settings.colors[round(mouse_screen_pos.x/60)+floor(settings.colors.size()/2)]
		else:
			var ray_cast = player.get_node("RayCast2D")
			ray_cast.cast_to = mouse_pos - player.position
			ray_cast.force_raycast_update()
			if(!ray_cast.is_colliding() && ray_cast.cast_to.length() < 500):
				mouse_pixel = mouse_pos / drawing.scale + img.get_size()/2
				if(!prev_pixel): prev_pixel = mouse_pixel
				lines_to_draw.append([prev_pixel,mouse_pixel,draw_color])
	
	if(lines_to_draw.size() > 0):
		img.lock()
		for line in lines_to_draw:
			var diff = line[0]-line[1]
			var length = diff.length()
			length = max(1,length)
			for i in range(0, length+1):
				var i_pix = line[1] + i/length*diff
				img.set_pixel(i_pix.x, i_pix.y, line[2])

		lines_to_draw = []
		img.unlock()

		new_texture.create_from_image(img)
		drawing.texture = new_texture
		drawing.update()

	var voting:Node2D = get_node("Background/Voting")
	voting.update()
	if(Input.is_action_just_pressed("vote")):
		var diff = mouse_pos-2*voting.position
		if(abs(diff.y) < 20):
			var idx = round(diff.x/60+int(players.size()/2))
			if(idx >= 0 && idx < players.size()):
				vote = player_ids[idx]
			else: vote = -1
	if(vote > 0 && players[vote].is_dead): vote = -1
			
	if(Input.get_action_strength("start") == 1 && !playing): start_game()
	if(is_impostor && !is_dead && Input.is_action_just_pressed("kill") && kill_cooldown < 0):
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
			add_child(body)
			player.position = players[killing].pos
			kill_cooldown = settings.kill_cooldown
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
		drawing=[prev_pixel,mouse_pixel,draw_color],
		color=color,
		vote=vote,
		ending=ending,
		starting=starting
	}
	prev_pixel = mouse_pixel
	killing = -1
	data.code = code
	data.kill_cooldown = kill_cooldown
	player.update_draw_data(data)
	return data

func set_id(client_id):
	id = client_id

func update_player(player_id, data):
	players[player_id] = data
	if(data.first_player):
		impostors = data.impostors
		is_impostor = impostors.has(id)
	if(data.starting && !playing && !starting):
		start_game()
	elif(data.starting && starting):
		starting = false
	if(data.ending && playing && !ending):
		end_game()
	elif(data.ending && ending):
		ending = false

	if(data.drawing[1]):
		lines_to_draw.append(data.drawing)
			
	if(!players_node.has_node(str(player_id))):
		player_ids.append(player_id)
		var new_player_node = Sprite.new()
		new_player_node.name = str(player_id)
		new_player_node.texture = load("res://assets/KillerArtist.png")
		new_player_node.light_mask = 2
		new_player_node.set_script(load("res://scripts/draw_player.gd"))
		players_node.add_child(new_player_node)
	
	if(data.killing != -1):
		var body:Sprite = Sprite.new()
		body.texture = load("res://assets/player_test.png")
		if(data.killing == id):
			is_dead = true
			body.position = player.position
		else:
			body.position = players[data.killing].pos
		body.light_mask = 2
		add_child(body)
	
	votes.erase(player_id)
	if(data.vote == id):
		votes.append(player_id)
		var alive_players = 1
		for player in players.values(): if(!player.is_dead): alive_players += 1
		if(2*votes.size()>alive_players):
			killing = id
			is_dead = true
			var body:Sprite = Sprite.new()
			body.texture = load("res://assets/player_test.png")
			body.light_mask = 2
			body.position = player.position
			add_child(body)

	var alive_players = 0
	var alive_impostors = 0
	if(!is_dead): 
		alive_players = 1
		if(is_impostor): alive_impostors = 1
	for player in players.values():
		if(!player.is_dead):
			alive_players += 1
			if(player.is_impostor): alive_impostors += 1
	if(alive_impostors*2 >= alive_players): end_game()
	var player_node:Sprite = players_node.get_node(str(player_id))
	player_node.position = data.pos
	player_node.data = data
	player_node.update()

func start_game():
	var rot = id%100
	var voting:Node2D = get_node("Background/Voting")
	player.position = voting.position+Vector2(0,50)+Vector2(rot-50,0)

	img.create($Background.texture.get_size().x, $Background.texture.get_size().y,false,Image.FORMAT_RGBA8)
	new_texture.create_from_image(img)
	drawing.texture = new_texture
	drawing.update()

	playing = true
	starting = true
	if(first_player):
		var l_players = player_ids
		l_players.append(id)
		impostors = []
		for _i in range(min(settings.impostors,ceil(l_players.size()/2)-1)):
			var idx = rand_generate.randi_range(0, l_players.size()-1)
			var id = l_players[idx]
			l_players.remove(idx)
			impostors.append(id)
		is_impostor = impostors.has(id)

func end_game():
	var rot = id%100
	var voting:Node2D = get_node("Background/Voting")
	player.position = voting.position+Vector2(0,50)+Vector2(rot-50,0)

	img.create($Background.texture.get_size().x, $Background.texture.get_size().y,false,Image.FORMAT_RGBA8)
	new_texture.create_from_image(img)
	drawing.texture = new_texture
	drawing.update()
	
	playing = false
	is_impostor = false
	impostors = []
	ending = true

func disconnect_peer(id):
	players_node.get_node(str(id)).remove_and_skip()
	player_ids.erase(id)
