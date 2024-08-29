extends CharacterBody2D

@onready var player_sprite: FlippableSprite = $FlippableSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_collision: CollisionShape2D = $PlayerCollider

var SPEED = 140.0
var defaultSpeed = 140.0
const JUMP_VELOCITY = -300.0
var speedUpdated: bool = false

func d(h):
	print(h)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("crouch"):
		SPEED = defaultSpeed
		speedUpdated = false
	
	# Get the input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		player_sprite.flipped = false
	elif direction < 0:
		player_sprite.flipped = true
		
	if direction == 0:
		animation_player.play("idle")
		if Input.is_action_pressed("crouch"):			
			animation_player.play("crouch")
			if not(speedUpdated):
							SPEED += 100
							speedUpdated = true
	
	if is_on_floor():
		if direction == 0:
			pass
		else:
			animation_player.play("walk")
	else:
		animation_player.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		
