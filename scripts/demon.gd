extends AnimatedSprite2D

@onready var animated_sprite: AnimatedSprite2D = $"."
func _on_animation_finished() -> void:
	animated_sprite.play("idle")
