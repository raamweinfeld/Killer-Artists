extends Control

onready var client = $Client

# Preload game scene
const GAME = preload("res://scenes/game.tscn")
var game_instance

func _ready():
	client.connect("lobby_joined", self, "_lobby_joined")
	client.connect("lobby_sealed", self, "_lobby_sealed")
	client.connect("connected", self, "_connected")
	client.connect("disconnected", self, "_disconnected")
	client.rtc_mp.connect("peer_connected", self, "_mp_peer_connected")
	client.rtc_mp.connect("peer_disconnected", self, "_mp_peer_disconnected")
	client.rtc_mp.connect("server_disconnected", self, "_mp_server_disconnect")
	client.rtc_mp.connect("connection_succeeded", self, "_mp_connected")

func _process(delta):
	client.rtc_mp.poll()
	while client.rtc_mp.get_available_packet_count() > 0:
		_log(client.rtc_mp.get_packet().get_string_from_utf8())


func _connected(id):
	_log("Signaling server connected with ID: %d" % id)

# Creates a game instance within the client text box
func instance_game():
		var text_edit = get_node("VBoxContainer/TextEdit")
		# Instance game if it doesn't exist
		if (!game_instance):
			game_instance = GAME.instance()
			text_edit.add_child(game_instance)
		# Set viewport size to text box size
		game_instance.get_node("ViewportContainer").rect_size = text_edit.rect_size
		# Stretch viewport resolution to project resolution
		game_instance.get_node("ViewportContainer/Viewport").size = Vector2(1024, 600)


func _disconnected():
	_log("Signaling server disconnected: %d - %s" % [client.code, client.reason])
	# Delete game instance (if it exists)
	if (game_instance):
		game_instance.queue_free()


func _lobby_joined(lobby):
	_log("Joined lobby %s" % lobby)
	# When hosting a new lobby while already being in one, the server
	# recognizes the peer disconnecting, deleting the lobby ('cause it's
	# empty) but the peer itself does not, since it technically hasn't 
	# "disconnected" - just moved to another lobby. I'll work on this
	# quirk later 
	instance_game()


func _lobby_sealed():
	_log("Lobby has been sealed")


func _mp_connected():
	_log("Multiplayer is connected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_server_disconnect():
	_log("Multiplayer is disconnected (I am %d)" % client.rtc_mp.get_unique_id())


func _mp_peer_connected(id: int):
	_log("Multiplayer peer %d connected" % id)


func _mp_peer_disconnected(id: int):
	_log("Multiplayer peer %d disconnected" % id)


func _log(msg):
	print(msg)
	$VBoxContainer/TextEdit.text += str(msg) + "\n"


func ping():
	_log(client.rtc_mp.put_packet("ping".to_utf8()))


func _on_Peers_pressed():
	var d = client.rtc_mp.get_peers()
	_log(d)
	for k in d:
		_log(client.rtc_mp.get_peer(k))


func start():
	client.start($VBoxContainer/Connect/Host.text, $VBoxContainer/Connect/RoomSecret.text)


func _on_Seal_pressed():
	client.seal_lobby()


func stop():
	client.stop()

func _on_Console_toggled(enabled):
	var text_edit = get_node("VBoxContainer/TextEdit")
	if game_instance:
		if enabled:
			text_edit.remove_child(game_instance)
		else:
			text_edit.add_child(game_instance)
