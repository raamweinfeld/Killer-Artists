extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()
var texture
var flipped_texture

func _ready():
	texture = get_node("Sprite").texture
	flipped_texture = ImageTexture.new()
	var img : Image = texture.get_data()
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
	get_node("Sprite").data = data
	get_node("Sprite").update()