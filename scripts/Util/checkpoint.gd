extends Node2D
class_name CheckPoint

@export var spawnpoint = false
var activated = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func activate():
	GameManager.current_checkpoint = self
	activated = true
	animation_player.play("activated")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName and !activated:
		activate()
