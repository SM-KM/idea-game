extends Node2D
class_name CheckPoint

@export var spawnpoint = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var activated = false

func activate():
	GameManager.current_checkpoint = self
	animation_player.play("activated")
	activated = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName and !activated:
		activate()
