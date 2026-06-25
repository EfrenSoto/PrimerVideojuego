extends CharacterBody2D

@export var speed: float = 20.0
@export var jump_velocity: float = -150.0
@export var gravity: float = 700.0

var is_crouching: bool = false
var idle_timer := 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var head_check: RayCast2D = $RayCast2D

const STAND_HEIGHT := 6
const STAND_Y := -3.0
const CROUCH_HEIGHT := 4.8
const CROUCH_Y := -2.45
const IDLE_DELAY := 0.4

func _physics_process(delta: float) -> void:
	var direction_x := Input.get_axis("move_left", "move_right")
	velocity.x = direction_x * speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity

	if abs(direction_x) > 0.01:
		idle_timer = 0.0;
	else:
		idle_timer += delta
	
	if direction_x > 0.0:
		animated_sprite.flip_h = false
	elif direction_x < 0.0:
		animated_sprite.flip_h = true

	if Input.is_action_pressed("move_down"):
		if not is_crouching and is_on_floor():
			crouch()
	else:
		if is_crouching and can_stand_up():
			stand_up()

	change_animation(direction_x)
	move_and_slide()

func change_animation(direction_x: float) -> void:
	if not is_on_floor():
		animation_player.stop()
		if velocity.y < 0.0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return

	if abs(direction_x) > 0.01:
		animated_sprite.stop()
		animation_player.play("walk")
	else:
		animation_player.stop()
		if idle_timer >= IDLE_DELAY:
			animated_sprite.play("idle" if not is_crouching else "crouch_idle")
		animated_sprite.rotation = 0.0

func crouch() -> void:
	is_crouching = true
	_set_collider(CROUCH_HEIGHT, CROUCH_Y)
	animated_sprite.animation = "crouch"
	animated_sprite.frame = 0
	idle_timer = 0.0

func stand_up() -> void:
	is_crouching = false
	_set_collider(STAND_HEIGHT, STAND_Y)
	animated_sprite.animation = "stand_up"
	animated_sprite.frame = 0
	idle_timer = 0.0

func can_stand_up() -> bool:
	return not head_check.is_colliding()

func _set_collider(new_height: float, new_y: float) -> void:
	var rect := collision_shape.shape as RectangleShape2D
	if rect:
		rect.size.y = new_height
	collision_shape.position.y = new_y
