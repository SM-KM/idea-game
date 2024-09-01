extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var sprite: FlippableSprite = $RigidBody2D/Sprite2D

@export var speed = 80
var awareness_entered: bool
var ignoreIdle = ["galloping", "powerUpfx"]
var ignoreGalloping = ["powerUpfx"]

func _physics_process(delta: float) -> void:
	if awareness_entered:
		if !animation_player.current_animation in ignoreGalloping:
			animation_player.play("galloping")
		if GameManager.player != null:
			var direction = global_position.direction_to(GameManager.player.global_position)
			velocity = direction * speed
			move_and_slide()
	
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")

func _on_activate_powe_up_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		speed = 0
		animation_player.play("powerUpfx")
		await get_tree().create_timer(0.5).timeout
		GameManager.activatePowerUp("nightmare", 5.0)
		self.owner.queue_free()

func _on_awareness_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		awareness_entered = true
		sprite.flipped = GameManager.playerFlipped
		

func _on_awareness_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		awareness_entered = false
