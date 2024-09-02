extends CharacterBody2D

@onready var projectiles = get_tree().get_first_node_in_group("projectiles")
@onready var projectile = load("res://scenes/projectile.tscn")
@onready var animation_player: AnimationPlayer = $RigidBody2D/AnimationPlayer
@onready var enemy_controller: Node = $"../EnemyController"
@onready var shoot_cooldown: Timer = $RigidBody2D/ShootCooldown
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: FlippableSprite = $RigidBody2D/FlippableSprite

var ignoreIdle = ["breath", "burn"]
var ignoreBreath = ["burn"]
var amountProjectiles: int

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	
func _process(delta: float) -> void:
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	
func _physics_process(delta: float) -> void:	
	if is_instance_valid(animation_player):
		if !animation_player.current_animation in ignoreIdle:
			animation_player.play("idle")
	
		
func shoot():
	var instance = projectile.instantiate()
	var x = -20 if enemy_controller.enemyFlipped else 20
	
	instance.dir = rotation
	instance.spawnPos = Vector2(global_position.x - x, global_position.y + 25)
	instance.spawnRot = rotation
	instance.flipped = enemy_controller.enemyFlipped
	instance.zdex = z_index
	instance.enemy_controller = enemy_controller
	projectiles.add_child.call_deferred(instance)
	amountProjectiles += 1

func _on_shoot_cooldown_timeout() -> void:
	if !animation_player.current_animation in ignoreBreath:
		animation_player.play("breath")
	shoot()

func _on_receive_hit_collider_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == GameManager.playerHitboxName:
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "burn", self.owner, 0.6, global_position, self)
		

func _on_awareness_zone_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		sprite.flipped = GameManager.playerFlipped
		enemy_controller.enemyFlipped = GameManager.playerFlipped
		if shoot_cooldown.is_stopped():
			shoot_cooldown.start()
			if !animation_player.current_animation in ignoreBreath:
				animation_player.play("breath")
			
			shoot()

func _on_awareness_zone_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		shoot_cooldown.stop()
