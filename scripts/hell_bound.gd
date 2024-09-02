extends CharacterBody2D

@onready var sprite: Sprite2D = $RigidBody2D/Sprite2D
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@export var speed = 200
var awareness_entered: bool

var ignoreRun = ["powerUpfx"]
var ignoreIdle = ["run", "powerUpfx"]

func _physics_process(delta: float) -> void:
	if not is_instance_valid(animation_player):
		return
	
	if awareness_entered:
		if !animation_player.current_animation in ignoreRun:
			animation_player.play("run")
		if GameManager.player != null:
			var direction = global_position.direction_to(GameManager.player.global_position)
			velocity = direction * speed
			move_and_slide()
	
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")


func _on_activate_power_ups_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		speed = 0
		animation_player.play("powerUpfx")
		GameManager.activatePowerUp("hellbound", 5.0)

func _on_awareness_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		awareness_entered = true
		sprite.flipped = GameManager.playerFlipped

func _on_awareness_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		awareness_entered = false
		sprite.flipped = GameManager.playerFlipped
