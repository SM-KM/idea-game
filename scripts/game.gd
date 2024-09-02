extends Node2D

@onready var initial_camera_limiter: CameraLimiter = $CameraLimiters/CameraLimiter

func _ready() -> void:
	GameManager.instantiateAllInitialSpawnPoints()
