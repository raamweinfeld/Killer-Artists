extends Node2D

var data
onready var game = get_node("../../../..")

func _draw():
	var default_font = Control.new().get_font("font")
	if(data):
		if(data.player_name):
			visible = game.is_dead || !data.is_dead
			var width = default_font.get_string_size(data.player_name).x
			draw_string(default_font, Vector2(-width/2, -64), data.player_name,Color(1,0,0) if data.is_impostor && (game.is_impostor || game.is_dead) else Color(1,1,1))
		if(data.id == game.id):
			var i = int(-game.settings.colors.size()/2)
			for color in game.settings.colors:
				draw_circle(Vector2(60*i,game.viewport.size.y*get_parent().get_node("Camera2D").zoom.y/2-40),20,color)
				i += 1