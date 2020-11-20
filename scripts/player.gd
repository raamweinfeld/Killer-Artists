extends KinematicBody2D

const MOVE_SPEED = 5
var velocity = Vector2()

func move(delta):
	velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized() * MOVE_SPEED
	velocity = move_and_slide(velocity)
	position += velocity
