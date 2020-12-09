extends Node2D

func _draw():
	var game = owner
	var players : Array = game.players.values()
	for i in range(0, players.size()):
		var loc = i-int(players.size()/2.0)
		if(game.vote == players[i].id): 
			draw_circle(30*Vector2(loc,0), 12, Color(1,1,1))
		draw_circle(30*Vector2(loc,0), 10, players[i].color)
