extends Node

@export var player_health = 100

func _ready() -> void:
	createDemon()

func ReducePlayerHealth(amount):
	player_health -= amount
	print(player_health)

func createDemon():
	var demon = load("res://scenes/demon.tscn")
	var demonInstance = demon.instantiate()
	add_child(demonInstance)
	demonInstance.position = Vector2(0, 0)
