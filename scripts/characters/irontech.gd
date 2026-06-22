extends CharacterBody2D

const SPEED = 20.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)
	velocity = direction * SPEED
	
	if velocity.x != 0:
		$AnimationPlayer.play("walk_right")
	else:
		$AnimationPlayer.stop()
		$AnimatedSprite2D.rotation = 0
	
	move_and_slide()
	
	
