extends Node

@export var player_health = 100

func _ready() -> void:
	createDemon(Vector2(0, 0), 5)

# enemies instances
func createDemon(pos: Vector2, zIndex: int):
	var demon = load("res://scenes/demon.tscn")
	var demonInstance = demon.instantiate()
	add_child(demonInstance)
	demonInstance.position = pos
	demonInstance.z_index = zIndex
	
# Player stats configuration
func ReducePlayerHealth(amount):
	player_health -= amount
	print(player_health)
