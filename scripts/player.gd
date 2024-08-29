extends CharacterBody2D

@onready var player_sprite: FlippableSprite = $FlippableSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_collision: CollisionShape2D = $PlayerCollider
@onready var flippable_shape: FlippableShape = $HitboxComponent/FlippableShape

var SPEED = 140.0
var defaultSpeed = 140.0
const JUMP_VELOCITY = -300.0
var speedUpdated: bool = false
var lastFlippedValue = false
var ignoreIdle = ["kick", "kick_left", "punch",  "punch_left"]
var ignoreWalk = ["crouch", "crouch_kick", "crouch_kick_left"]
var ignoreCrouch = ["crouch_kick", "crouch_kick_left"]
var ignoreJump = ["flykick", "flykick_left"]

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
		
	
	if is_on_floor():
		if Input.is_action_just_released("kick"):
			animateDependingOnFlippedState("kick_left", "kick")
				
		if Input.is_action_just_released("punch"):
			animateDependingOnFlippedState("punch_left", "punch")

		if direction == 0:
			if Input.is_action_pressed("crouch"):			
				if Input.is_action_just_released("kick"):
					animateDependingOnFlippedState("crouch_kick_left", "crouch_kick")	
				else:
					if !animation_player.current_animation in ignoreCrouch:
						animation_player.play("crouch")
						if not(speedUpdated):
							SPEED += 100
							speedUpdated = true
					
			else:
				if !animation_player.current_animation in ignoreIdle:
					animation_player.play("idle")
		else:
			if Input.is_action_pressed("crouch"):	
				if Input.is_action_pressed("kick"):	
					animation_player.play("crouch_kick")	
				else:
					animation_player.play("crouch")
					if not(speedUpdated):
						SPEED += 100
						speedUpdated = true
			else:
				if !animation_player.current_animation in ignoreWalk:
					animation_player.play("walk")
	else:
		if Input.is_action_pressed("kick"):
			animateDependingOnFlippedState("flykick_left", "flykick")
		else:
			if !animation_player.current_animation in ignoreJump:
				animation_player.play("jump") 
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	
func animateDependingOnFlippedState(right, left):
	if player_sprite.flipped:
		animation_player.play(right)
	else:
		animation_player.play(left)
		
