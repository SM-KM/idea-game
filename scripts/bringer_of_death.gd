extends CharacterBody2D

@onready var sprite: FlippableSprite = $FlippableSprite
@onready var enemy_controller: Enemy_controller = $"../EnemyController"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar

var ignoreIdle = []

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)

func _physics_process(delta: float) -> void:
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 
	move_and_slide()
	
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")


func _on_receive_hit_area_entered(area: Area2D) -> void:
	if area.name == GameManager.playerHitboxName:
		animation_player.play("hurt")
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "dead", self.owner, 1, global_position, self)
