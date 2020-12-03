extends Sprite

var data
onready var game = get_node("../../../..")
var unflipped_texture : Texture
var flipped_texture : Texture
var color:Color = Color(1,1,1)
var prev_pos:Vector2
var artist = load("res://assets/KillerArtist.png")

func _draw():
	var default_font = Control.new().get_font("font")
	if(data):
		if(color != data.color):
			color = data.color
			update_texture()
		if((data.pos-prev_pos).x > 0): texture = unflipped_texture
		if((data.pos-prev_pos).x < 0): texture = flipped_texture
		prev_pos = data.pos
		if(data.player_name):
			visible = game.is_dead || !data.is_dead
			var width = default_font.get_string_size(data.player_name).x
			draw_string(default_font, Vector2(-width/2, -64), data.player_name,Color(1,0,0) if data.is_impostor && (game.is_impostor || game.is_dead) else Color(1,1,1))
		if(data.id == game.id):
			var i = int(-game.settings.colors.size()/2)
			for color in game.settings.colors:
				draw_circle(Vector2(60*i,game.viewport.size.y*get_parent().get_node("Camera2D").zoom.y/2-40),20,color)
				i += 1

func update_texture():
	unflipped_texture = ImageTexture.new()
	flipped_texture = ImageTexture.new()
	var img : Image = artist.get_data()
	img.lock()
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var brightness = img.get_pixel(x,y).r
			img.set_pixel(x,y,Color(color.r*brightness,color.g*brightness,color.b*brightness,img.get_pixel(x,y).a))

	img.unlock()
	unflipped_texture.create_from_image(img)
	img.flip_x()
	flipped_texture.create_from_image(img)
