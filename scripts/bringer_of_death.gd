extends CharacterBody2D

@onready var enemy_controller: Enemy_controller = $"../EnemyController"
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var sprite: FlippableSprite = $RigidBody2D/FlippableSprite

var ignoreIdle = []

func _physics_process(delta: float) -> void:
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")
