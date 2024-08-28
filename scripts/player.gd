extends CharacterBody2D

@onready var player_sprite: FlippableSprite = $FlippableSprite

var SPEED = 140.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		player_sprite.flipped = false
	elif direction < 0:
		player_sprite.flipped = true
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		
