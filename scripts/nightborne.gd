extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var collider: CollisionShape2D = $RigidBody2D/Collider
@onready var health_bar: ProgressBar = $HealthBar
@onready var enemy_controller: Enemy_controller = $"../EnemyController"
@onready var sprite: FlippableSprite = $RigidBody2D/Sprite2D

var ignoreIdle = ["attack", "attack_left", "run", "hurt, dead"]
var ignoreRun = ["attack", "attack_left","hurt, dead"]
var ignoreAttack = ["hurt,", "attack_left","dead"]
var timeout: float = 0.5


func _physics_process(delta: float) -> void:
	if not is_instance_valid(animation_player):
		return
	
	if enemy_controller.enemyHealth <= 0:
		# Ensure we don't overwrite the dead animation
		if animation_player.current_animation != "dead":
			animation_player.play("dead")
		return 
		
	if enemy_controller.body_entered_awareness_zone:
		enemy_controller.followPlayer(delta, self)
		sprite.flipped = enemy_controller.enemyFlipped
		
		if !animation_player.current_animation in ignoreRun:
			animation_player.play("run")
			
	if enemy_controller.body_entered_attack_zone:
		if !animation_player.current_animation in ignoreAttack:
			animateDependingOnFlippedState("attack_left", "attack")
			await get_tree().create_timer(timeout).timeout
	
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")

func animateDependingOnFlippedState(right, left):
	if sprite.flipped:
		animation_player.play(right)
	else:
		animation_player.play(left)

func _on_awareness_zone_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_awareness_zone = true
		enemy_controller.enemyFlipped = not(GameManager.playerFlipped)
		
func _on_awareness_zone_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_awareness_zone = false

func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_entered_attack_zone = true
		enemy_controller.body_exited_attack_zone = false
			
	
func _on_attack_zone_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.body_exited_attack_zone = true
		enemy_controller.body_entered_attack_zone = false

	
func _on_receive_hit_area_entered(area: Area2D) -> void:
	if area.name == GameManager.playerHitboxName:
		animation_player.play("hurt")
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "dead", self.owner, 1, global_position, self)
		
func _on_hitbox_component_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		GameManager.ReducePlayerHealth(enemy_controller.enemyDamage)
