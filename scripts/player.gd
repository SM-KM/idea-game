extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var speedUpdated = false
var SPEED = 140.0

const defaultSpeed = 140.0
const JUMP_VELOCITY = -300.0

var ignoreIdle = ["punch", "kick"]
var ignoreWalk = ["punch", "kick"]
var ignoreJump = ["flykick"]
var ignoreCrouch = ["crouch_kick"]

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if Input.is_action_just_pressed("kick"):
			animated_sprite.play("flykick")
	
	if Input.is_action_just_released("crouch"):
		SPEED = defaultSpeed
		speedUpdated = false
	
	# Get the input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
		
	if is_on_floor():			
		if Input.is_action_just_released("punch"):
			animated_sprite.play("punch")
			
		if Input.is_action_just_released("kick"):
			animated_sprite.play("kick")
		
		if direction == 0:
			if Input.is_action_pressed("crouch"):
				if Input.is_action_just_pressed("kick"):
					animated_sprite.play("crouch_kick")
				else:
					if !animated_sprite.animation in ignoreCrouch:
						animated_sprite.play("crouch")
						if not(speedUpdated):
							SPEED += 100
							speedUpdated = true
			else:
				if !animated_sprite.animation in ignoreIdle:
					animated_sprite.play("idle") 
					
		else:
			if Input.is_action_pressed("punch"):
				animated_sprite.play("punch")
			
			if Input.is_action_pressed("crouch"):
				if Input.is_action_just_pressed("kick"):
					animated_sprite.play("crouch_kick")
				else:
					if !animated_sprite.animation in ignoreCrouch:
						animated_sprite.play("crouch")
						if not(speedUpdated):
							SPEED += 100
							speedUpdated = true
			else:
				if !animated_sprite.animation in ignoreWalk:
					animated_sprite.play("walk")
	else:
		if Input.is_action_just_pressed("kick"):
			animated_sprite.play("flykick")
		else:
			if !animated_sprite.animation in ignoreJump:
				animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite.play("idle")
		
