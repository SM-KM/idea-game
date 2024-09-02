extends CharacterBody2D
class_name Player

@onready var player_sprite: FlippableSprite = $FlippableSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_collision: CollisionShape2D = $PlayerCollider
@onready var flippable_shape: FlippableShape = $PlayerHitbox/FlippableShape
@onready var regen_cooldown: Timer = $RegenCooldown
@onready var stamina_cooldown: Timer = $StaminaCooldown
@onready var camera: Camera = $Camera

var speedUpdated: bool = false
var lastFlippedValue = false

var ignoreIdle = ["kick", "kick_left", "punch",  "punch_left", "hurt"]
var ignoreWalk = ["crouch", "crouch_kick", "crouch_kick_left", "hurt"]
var ignoreCrouch = ["crouch_kick", "crouch_kick_left", "hurt"]
var ignoreJump = ["flykick", "flykick_left", "hurt"]

func _ready() -> void:
	GameManager.camera = camera
	# health_bar.initializeHealthBar(GameManager.player_health, GameManager.max_player_health, GameManager.min_player_health)

func _physics_process(delta: float) -> void:
	# health_bar.updateHealthBar(GameManager.player_health, GameManager.max_player_health, GameManager.min_player_health)
	if regen_cooldown.wait_time == GameManager.regeneration_cooldown_amount:
		if GameManager.player_health < GameManager.max_player_health and GameManager.playerDamaged and !GameManager.regenCooldownStarted:
			regen_cooldown.start(GameManager.regeneration_cooldown_amount)
			GameManager.regenCooldownStarted = true
	else:
		regen_cooldown.start(GameManager.regeneration_cooldown_amount)
		GameManager.regenCooldownStarted = true
	
	var JUMP_VELOCITY = GameManager.playerJumpVelocity
	var SPEED = GameManager.playerSpeed
	var defaultSpeed = GameManager.playerSpeed
	
	# track player position
	GameManager.playerPosition = global_position
	
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
		GameManager.playerFlipped = false
	elif direction < 0:
		player_sprite.flipped = true
		GameManager.playerFlipped = true
		
	
	if is_on_floor():
		if Input.is_action_just_released("kick") and GameManager.stamina >= GameManager.kickStaminaCost:
			GameManager.ReduceStamina(GameManager.kickStaminaCost)
			stamina_cooldown.start(GameManager.staminaCooldown)
			animateDependingOnFlippedState("kick_left", "kick")
				
		if Input.is_action_just_released("punch") and GameManager.stamina >= GameManager.punchStaminaCost:
			GameManager.ReduceStamina(GameManager.punchStaminaCost)
			stamina_cooldown.start(GameManager.staminaCooldown)
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
		
func animatePlayerHurt():	
	animation_player.play("hurt")
	await get_tree().create_timer(0.2).timeout
	animation_player.play("idle")

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var exp = area.collect()
		GameManager.calculateExperience(exp)
		area.queue_free()


func _on_regen_cooldown_timeout() -> void:
	GameManager.activateRegeneration()
	GameManager.regenCooldownStarted = false

func _on_stamina_cooldown_timeout() -> void:
	GameManager.restoreStamina()


func _on_interactions_area_entered(area: Area2D) -> void:
	if area is CameraLimiter:
		pass
		# camera.camera_limit_manager.set_limiter(area)
