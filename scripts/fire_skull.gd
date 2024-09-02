extends CharacterBody2D

@onready var enemy_controller: Enemy_controller = $"../EnemyController"
@onready var health_bar: ProgressBar = $HealthBar
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var sprite: FlippableSprite = $RigidBody2D/Sprite2D

var ignoreIdle = ["explote"]

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(animation_player):
		return
	
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")
		
	if enemy_controller.body_entered_awareness_zone:
		enemy_controller.followPlayer(delta, self)

func _on_awareness_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		sprite.flipped = GameManager.playerFlipped
		enemy_controller.enemyFlipped = GameManager.playerFlipped
		enemy_controller.body_entered_awareness_zone = true

func _on_awareness_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_awareness_zone = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_attack_zone = true
		animation_player.play("explote")
		await get_tree().create_timer(0.3).timeout
		self.owner.queue_free()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_attack_zone = true
		body.animatePlayerHurt()
		GameManager.ReducePlayerHealth(enemy_controller.enemyDamage)

func _on_receive_hit_area_entered(area: Area2D) -> void:
	if area.name == GameManager.playerHitboxName:
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "explote", self.owner, 0.3, global_position, self)
