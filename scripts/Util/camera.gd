extends Camera2D
class_name Camera

@onready var player: Player = get_parent()
@onready var camera_limit_manager: CameraLimitManager = $CameraLimitManager
