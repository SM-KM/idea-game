extends Area2D
@onready var animated_sprite: AnimatedSprite2D = $"../.."

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animated_sprite.play("attack")
