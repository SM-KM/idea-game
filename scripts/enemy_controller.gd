extends Node
class_name Enemy_controller

@export var enemyHealth = 100
@export var max_enemyHealth = 100
@export var min_enemyHealth = 0
@export var enemySpeed = 60
@export var enemyDirection = 1
@export var enemyDamage = 5
@export var enemyGlobalPosition = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

const damage_indicator = preload("res://scenes/UI/damage_indicator.tscn")
const parchment = preload("res://scenes/items/parchment.tscn")
const blood = preload("res://scenes/Util/drop_blood.tscn")

var body_entered_awareness_zone = false
var body_exited_attack_zone = false
var body_entered_attack_zone = false

var enemyFlipped: bool
var currentEnemyInstance: Node2D
var global_position_enemy: Vector2

func handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, enemy):
		if enemyHealth <= 0:
			body_entered_attack_zone = false
			body_entered_awareness_zone = false
			body_exited_attack_zone = false
			animation_player.play(animation)
			
			# Ensure animation is actually playing
			if not animation_player.is_playing():
				print("Animation is not playing!")
			
			# instance of parchment
			var instance = parchment.instantiate()
			var children = currentEnemyInstance.get_children()
			for c in children:
				if c is RigidBody2D:
					c.add_child(instance)
					
			instance.reparent(enemyParent.get_parent())
			await get_tree().create_timer(awaitTimeAnimation).timeout
			enemyParent.queue_free()
			
			

func handlePlayerHitOnEnemy(animation_player: AnimationPlayer, animation: String, enemyParent: Node2D, awaitTimeAnimation: float, global_position, enemy):
	if enemy:
		currentEnemyInstance = enemy

	if enemyHealth > min_enemyHealth:
		if GameManager.currentAttackType == GameManager.AttackType.Kick:
			reduceEnemyHealth(GameManager.kickDamage)
			handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, enemy)
		elif GameManager.currentAttackType == GameManager.AttackType.Punch:
			reduceEnemyHealth(GameManager.punchDamage)
			handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, enemy)


func reduceEnemyHealth(amount):
	if enemyHealth > 0:
		enemyHealth -= amount
		spawnDamageIndicator(amount)
		spawnBloodOnHit()
		
		if enemyHealth <= 0:
			if GameManager.playerSpeed != GameManager.defaultPlayerSpeed:
				GameManager.ReturnPlayerSpeedToNormal()
				
func spawnDamageIndicator(amount: int):
	var instance = damage_indicator.instantiate()
	instance.z_index = currentEnemyInstance.z_index + 1
	instance.text = str(amount)
	instance.global_position = global_position_enemy
	var children = currentEnemyInstance.get_children()
	for c in children:
		if c is RigidBody2D:
			c.add_child(instance)
	
func spawnBloodOnHit():
	var instance = blood.instantiate()
	var lowerY = Vector2(global_position_enemy.x, global_position_enemy.y)
	instance.z_index = currentEnemyInstance.z_index + 1
	instance.global_position = lowerY
	var children = currentEnemyInstance.get_children()
	for c in children:
		if c is RigidBody2D:
			c.add_child(instance)
	

func updateFollowSpeed(delta: float) -> void:
	enemySpeed += 2 * delta
	
func followPlayer(delta, enemy):
	#enemy.global_position = enemy.global_position.move_toward(GameManager.player.global_position, enemySpeed)
	#updateFollowSpeed(delta)
	
	if GameManager.player != null:
		enemyDirection = (player.global_position - enemy.global_position).normalized()
		enemy.velocity.y = GameManager.gravity * delta
		if abs(enemy.velocity.x) < abs(enemySpeed):
			enemy.velocity.x += (enemyDirection.x * enemySpeed) * delta
			
		enemy.move_and_slide()
		
		
	
	
	
		
