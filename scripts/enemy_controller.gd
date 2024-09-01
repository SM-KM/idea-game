extends Node
class_name Enemy_controller

@export var enemyHealth = 100
@export var max_enemyHealth = 100
@export var min_enemyHealth = 0
@export var enemySpeed = 60
@export var enemyDirection = 1
@export var enemyDamage = 5

@onready var player = get_tree().get_first_node_in_group("player")
signal playerHit(damageAmount)

const damage_indicator = preload("res://scenes/UI/damage_indicator.tscn")
const parchment = preload("res://scenes/items/parchment.tscn")
const blood = preload("res://scenes/Util/drop_blood.tscn")

var body_entered_awareness_zone = false
var body_exited_attack_zone = false
var body_entered_attack_zone = false

var enemyFlipped: bool
var currentEnemyInstance: Node2D
var global_position_enemy: Vector2

func handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, global_position):
		if enemyHealth <= 0:
			body_entered_attack_zone = false
			body_entered_awareness_zone = false
			body_exited_attack_zone = false
			
			var parent = enemyParent.get_parent()
			var instance = parchment.instantiate()
			instance.global_position = global_position
			animation_player.play(animation)
			
			# Ensure animation is actually playing
			if not animation_player.is_playing():
				print("Animation is not playing!")
			
			await get_tree().create_timer(awaitTimeAnimation).timeout
			enemyParent.queue_free()
			
			# instance of parchment
			parent.add_child(instance)
			

func handlePlayerHitOnEnemy(animation_player: AnimationPlayer, animation: String, enemyParent: Node2D, awaitTimeAnimation: float, global_position, enemy):
	if enemy:
		currentEnemyInstance = enemy

	if enemyHealth > min_enemyHealth:
		if GameManager.currentAttackType == GameManager.AttackType.Kick:
			reduceEnemyHealth(GameManager.kickDamage)
			handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, global_position)
		elif GameManager.currentAttackType == GameManager.AttackType.Punch:
			reduceEnemyHealth(GameManager.punchDamage)
			handleEnemyDead(animation_player, awaitTimeAnimation, enemyParent, animation, global_position)


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
	currentEnemyInstance.add_child(instance)
	
func spawnBloodOnHit():
	var instance = blood.instantiate()
	var lowerY = Vector2(global_position_enemy.x, global_position_enemy.y + 20)
	instance.z_index = currentEnemyInstance.z_index + 1
	instance.global_position = lowerY
	currentEnemyInstance.add_child(instance)

func updateFollowSpeed(delta: float) -> void:
	enemySpeed += 2 * delta
	
func followPlayer(delta, enemy):
	#enemy.global_position = enemy.global_position.move_toward(GameManager.player.global_position, enemySpeed)
	#updateFollowSpeed(delta)
	if GameManager.player != null:
		var direction = enemy.global_position.direction_to(GameManager.player.global_position)
		enemy.velocity = direction * enemySpeed
		enemy.move_and_slide()
		
	
	
	
		
