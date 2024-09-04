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
var is_attacking: bool = false
var audio_controller: AudioStreamPlayer2D

func _ready() -> void:
	audio_controller = get_tree().get_first_node_in_group("audio_controller")

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
					
			if enemy is Ghost:
				enemy.add_child(instance)
					
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
		audio_controller.playHurt()
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
	
func set_attacking_state():
	is_attacking = !is_attacking
	
func followPlayer(delta, enemy):
	if GameManager.player != null:
		enemyDirection = (player.global_position - enemy.global_position).normalized()
		
		if enemy is Ghost:
			enemy.velocity.y = sign(enemyDirection.y) * enemySpeed
		
		enemy.velocity.x = sign(enemyDirection.x) * enemySpeed	
		var tolerance = 0.5
		if enemyDirection.x < 0 and enemyDirection.x > -tolerance and is_attacking == false:
			enemyFlipped = true
		elif enemyDirection.x > 0 and enemyDirection.x > tolerance:
			enemyFlipped = false
			
		enemy.move_and_slide()
		
		
	
	
	
		
