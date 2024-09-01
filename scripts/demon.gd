extends CharacterBody2D

@onready var enemy_controller: Enemy_controller = %EnemyManager
@onready var sprite: FlippableSprite = $RigidBody2D/FlippableSprite
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar

var ignoreIdle = ["attack", "attack_left"]
var timeout = 0.5

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	
func _physics_process(delta: float) -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	
	if enemy_controller.body_entered_awareness_zone:
		enemy_controller.followPlayer(delta, self)
		sprite.flipped = enemy_controller.enemyFlipped
			
	if enemy_controller.body_entered_attack_zone:
		animateDependingOnFlippedState("attack", "attack_left")
		await get_tree().create_timer(timeout).timeout
			
	if !animation_player.current_animation in ignoreIdle:
		animateDependingOnFlippedState("idle", "idle_left")


func animateDependingOnFlippedState(right, left):
	if sprite.flipped:
		animation_player.play(right)
	else:
		animation_player.play(left)

func _on_awareness_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		print("player entered")
		enemy_controller.body_entered_awareness_zone = true
		enemy_controller.enemyFlipped = GameManager.playerFlipped

func _on_awareness_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_awareness_zone = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_attack_zone = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_attack_zone = false
	
func _on_receive_hit_area_entered(area: Area2D) -> void:
	if area.name == GameManager.playerHitboxName:
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "idle", self.owner, 0.2, global_position, self)

func _on_hitbox_component_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		GameManager.ReducePlayerHealth(enemy_controller.enemyDamage)
