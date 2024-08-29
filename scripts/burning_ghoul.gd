extends Node2D
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer

func _on_explosion_radius_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		animation_player.play("explote")
		await get_tree().create_timer(0.3).timeout
		queue_free()
