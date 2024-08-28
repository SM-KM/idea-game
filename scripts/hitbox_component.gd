extends Area2D
class_name HitboxComponent

@export var flippableSprite: FlippableSprite

func _ready() -> void:
	if flippableSprite != null:
		for child in get_children():
			flippableSprite.sprite_flipped.connect(child._on_sprite_flip)
			child.disabled = true
