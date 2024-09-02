extends CharacterBody2D
class_name BurningGhoul

@onready var enemy_controller: Node = $"../EnemyManager"
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var sprite: Sprite2D = $RigidBody2D/Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

var ignoreRun = ["explote"]
var timerTime = 0.3

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)

func _physics_process(delta: float) -> void:
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	if not is_instance_valid(sprite):
		return
	
	if enemy_controller.enemyHealth <= 0:
		animation_player.play("explote")
		await get_tree().create_timer(timerTime).timeout
		queue_free()
	
	if enemy_controller.body_entered_awareness_zone:
		sprite.flip_h = enemy_controller.enemyFlipped
		if !animation_player.current_animation in ignoreRun:	
			animation_player.play("run")
			
		enemy_controller.followPlayer(delta, self)
	
	
func _on_explosion_radius_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		animation_player.play("explote")
		await get_tree().create_timer(timerTime).timeout
		self.owner.queue_free()
		
func _on_explosion_radius_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		body.animatePlayerHurt()
		GameManager.ReducePlayerHealth(enemy_controller.enemyDamage)
		

func _on_awareness_zone_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.enemyFlipped = GameManager.playerFlipped
		enemy_controller.body_entered_awareness_zone = true

func _on_main_collider_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == GameManager.playerHitboxName: 
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "explote", self.owner, 0.4, global_position, self)
