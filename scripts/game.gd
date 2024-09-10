extends Node2D

@onready var initial_camera_limiter: CameraLimiter = $CameraLimiters/CameraLimiter
@onready var wave_counter: Label = %wave_counter

func _ready() -> void:
	GameManager.instantiateAllInitialSpawnPoints()
	
func _process(delta: float) -> void:
	wave_counter.text = "Wave " + str(GameManager.current_wave)
	
func _on_killzone_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.respawn_player()
	else:
		for child in body.get_children():
			if child is Enemy_controller:
				body.call_deferred("queue_free")
