extends Sprite

var data
onready var game = get_parent().get_parent()
var unflipped_texture : Texture
var flipped_texture : Texture
var color:Color = Color(0,0,0,0)
var prev_pos:Vector2
var artist = load("res://assets/KillerArtist.png")

var font = DynamicFont.new()
var name_font = DynamicFont.new()

func _ready():
	var data = DynamicFontData.new()
	data.font_path = "res://assets/UbuntuMono-B.ttf"
	font.font_data = data
	name_font.font_data = data
	font.size = 60
	name_font.size = 30
	
func _draw():
	if(data):
		if(color != data.color):
			color = data.color
			update_texture()
		if((data.pos-prev_pos).x > 0.1): texture = unflipped_texture
		if((data.pos-prev_pos).x < -0.1): texture = flipped_texture
		prev_pos = data.pos
		if(data.player_name):
			visible = game.is_dead || !data.is_dead
			var width = name_font.get_string_size(data.player_name).x
			draw_string(name_font, Vector2(-width/2, -64), data.player_name,Color(1,0,0) if data.is_impostor && (game.is_impostor || game.is_dead) else Color(1,1,1))
		if(data.id == game.id):
			if(!data.playing):
				var width = font.get_string_size(data.code).x
				draw_string(font, Vector2(-width/2, get_viewport().size.y*get_parent().get_node("Camera2D").zoom.y/2-80), data.code, Color(1,1,1))
			var i = int(-game.settings.colors.size()/2)
			for draw_color in game.settings.colors:
				draw_circle(Vector2(60*i,get_viewport().size.y*get_parent().get_node("Camera2D").zoom.y/2-40),20,draw_color)
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
