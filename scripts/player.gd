extends CharacterBody2D

@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var animation_player: AnimationPlayer = $PlayerSprite/AnimationPlayer
@onready var attack_area_collider: CollisionShape2D = $PlayerSprite/Attack_area/attack_area_collider

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
			pass
	
	if Input.is_action_just_released("crouch"):
		SPEED = defaultSpeed
		speedUpdated = false
	
	# Get the input direction
	var direction := Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		player_sprite.flip_h = false
	elif direction < 0:
		player_sprite.flip_h = true
		
		
	if is_on_floor():			
		if Input.is_action_just_released("punch"):
			pass
			
		if Input.is_action_just_released("kick"):
			animation_player.play("kick")
		
		if direction == 0:
			if Input.is_action_pressed("crouch"):
				if Input.is_action_just_pressed("kick"):
					pass
				else:
					pass
					# animated_sprite.play("crouch")
			else:
				pass
				# animation_player.play("idle") 
					
		else:
			if Input.is_action_pressed("punch"):
				pass
				# animated_sprite.play("punch")
			
			if Input.is_action_pressed("crouch"):
				if Input.is_action_just_pressed("kick"):
					pass
					# animated_sprite.play("crouch_kick")
				else:
					pass
					# animated_sprite.play("crouch")
			else:
				pass
				# animated_sprite.play("walk")
					
	else:
		if Input.is_action_just_pressed("kick"):
			pass
			# animated_sprite.play("flykick")
		else:
			pass
			# animated_sprite.play("jump")
				

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
		
