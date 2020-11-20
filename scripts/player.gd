extends KinematicBody2D

const MOVE_SPEED = 5

func move(delta):
	# Not important, but the player tends to lurch in whatever direction
	# it's moving in. Dunno if it's the camera lagging behind or some
	# sprite shenanigans
	move_and_collide( Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	) * MOVE_SPEED)
