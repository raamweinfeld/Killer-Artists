extends Node2D

var host;
var join;
var quit;

func _ready():
	host = get_node("canvas/title/host_button");
	join = get_node("canvas/title/join_button");
	quit = get_node("canvas/title/quit_button");
	# Connecting button signals
	host.connect("pressed", self , "on_host");
	join.connect("pressed", self, "on_join");
	quit.connect("pressed", self, "on_quit");
	pass
	
func on_host():
	print("hosting...");
	pass
	
func on_join():
	print("joining...");
	pass	

# Quit game
func on_quit():
	get_tree().quit();
	pass
