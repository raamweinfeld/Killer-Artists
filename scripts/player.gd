extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()
var texture
var flipped_texture
var color = Color(1,1,1)

func _ready():
	update_texture()

func update_texture():
	texture = ImageTexture.new()
	flipped_texture = ImageTexture.new()
	var img : Image = get_node("Sprite").texture.get_data()
	img.lock()
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var brightness = img.get_pixel(x,y).r
			img.set_pixel(x,y,Color(color.r*brightness,color.g*brightness,color.b*brightness,img.get_pixel(x,y).a))

	img.unlock()
	texture.create_from_image(img)
	img.flip_x()
	flipped_texture.create_from_image(img)

func move(delta):
	velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() * MOVE_SPEED * delta
	velocity = move_and_slide(velocity)
	position += velocity

	if(velocity.x > 0): get_node("Sprite").texture = texture
	if(velocity.x < 0): get_node("Sprite").texture = flipped_texture

func update_draw_data(data):
	if(data.color != color):
		color = data.color
		update_texture()
	get_node("Sprite").data = data
	get_node("Sprite").update()