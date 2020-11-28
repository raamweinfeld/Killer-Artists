extends Node2D

var data
onready var game = get_node("../../../..")

func _draw():
	var default_font = Control.new().get_font("font")
	if(data && data.player_name):
		visible = game.is_dead || !data.is_dead
		var width = default_font.get_string_size(data.player_name).x
		draw_string(default_font, Vector2(-width/2, -64), data.player_name,Color(1,0,0) if data.is_impostor && (game.is_impostor || game.is_dead) else Color(1,1,1))
