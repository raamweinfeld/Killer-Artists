extends KinematicBody2D

const MOVE_SPEED = 300
var velocity = Vector2()

func move(delta):
	velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() * MOVE_SPEED * delta
	velocity = move_and_slide(velocity)
	position += velocity

	if(velocity.x > 0): get_node("Sprite").texture = load("res://assets/KillerArtist.png")
	if(velocity.x < 0): 
		var new_texture = ImageTexture.new()
		var img = load("res://assets/KillerArtist.png").get_data()
		img.flip_x()
		new_texture.create_from_image(img)
		get_node("Sprite").texture = new_texture

func update_draw_data(data):
	get_node("Sprite").data = data
	get_node("Sprite").update()