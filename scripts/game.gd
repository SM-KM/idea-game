extends Node2D

@onready var initial_camera_limiter: CameraLimiter = $CameraLimiters/CameraLimiter

func _ready() -> void:
	pass
	#GameManager.player.camera.camera_limit_manager.set_limiter(initial_camera_limiter, true)
