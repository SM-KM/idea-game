extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta: float) -> void:
	sprite.flip_h = GameManager.playerFlipped
	if GameManager.PowerUpActive:
		match GameManager.PowerUpActive:
			"nightmare":
				sprite.visible = true
				animation_player.play("nightmare")
				
			"hellbound":
				sprite.visible = true
				animation_player.play("hellbound")
	else:
		sprite.visible = false
