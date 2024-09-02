extends RigidBody2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var enemy_controller: Node = $"../../EnemyController"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
