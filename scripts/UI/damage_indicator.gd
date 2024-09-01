extends Node2D

@onready var label = $Label

@export var speed: int = 30
@export var friction: int = 15
var shift_direction: Vector2 = Vector2.ZERO
var text: String

func _ready() -> void:
	shift_direction = Vector2(randf_range(-2, 1), randf_range(-2, 1))
	label.text = text
	
func _process(delta: float) -> void:
	global_position += speed * shift_direction * delta
	speed = max(speed - friction * delta, 0)
