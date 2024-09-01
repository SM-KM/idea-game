extends Sprite2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var label: Label = $TextController/Label
@onready var stamina_bar: ProgressBar = $StaminaBar

func _process(delta: float) -> void:
	stamina_bar.value = GameManager.stamina
	label.text = str(GameManager.experience)
	health_bar.min_value = GameManager.min_player_health
	health_bar.max_value = GameManager.max_player_health
	health_bar.value = GameManager.player_health
