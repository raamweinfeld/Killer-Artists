extends Node2D

func _draw():
	var game = owner
	var players : Array = game.players.values()
	for i in range(0, players.size()):
		var rot = 2*PI*i/players.size()
		if(game.vote == players[i].id): 
			draw_circle(30*Vector2(cos(rot),sin(rot)), 12, Color(1,1,1))
		draw_circle(30*Vector2(cos(rot),sin(rot)), 10, players[i].color)
