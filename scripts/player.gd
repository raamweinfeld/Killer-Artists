extends KinematicBody2D

const MOVE_SPEED = 5

func move(delta):
	var velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	# Player is getting stuck on polygon colliders no matter what 
	# collision shape it has - I NEED TO FIX THIS!!!
	position += move_and_slide(velocity.normalized()) * MOVE_SPEED
