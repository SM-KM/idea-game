extends Node

@export var player_health: int = 100
@export var default_player_health: int = 100
@export var max_player_health: int = 100
@export var min_player_health: int = 0
@export var stamina: int = 100
@export var default_stamina: int = 100
@export var staminaCooldown: int = 1
@export var kickStaminaCost: int = 20
@export var punchStaminaCost: int = 10
@export var kickDamage: int = 50
@export var defaultKickDamage: int = 50
@export var punchDamage: int = 20
@export var defaultPunchDamage: int = 20
@export var playerName = "Player"
@export var playerHitboxName = "PlayerHitbox"
@export var playerFlipped: bool
@export var knockbackPower = 500
@export var regeneration_cooldown_amount: int = 5

@onready var player = get_tree().get_first_node_in_group("player")
@onready var damage_indicator = preload("res://scenes/UI/damage_indicator.tscn")

enum AttackType { Kick, Punch, None, CrouchKick, FlyKick }

@export var playerSpeed: int  = 140.0
@export var playerJumpVelocity: float = -300.0
@export var experience: int = 0
@export var currentAttackType: AttackType = AttackType.None

var defaultPlayerSpeed = 140.0
var defaultJumpVelocity = -300.0
var playerPosition: Vector2
var playerDamaged: bool
var regenCooldownStarted: bool
var PowerUpActive: String

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("kick"):
		currentAttackType = AttackType.Kick
		
	if Input.is_action_just_pressed("punch"):
		currentAttackType = AttackType.Punch
		
# Player stats configuration
func ReducePlayerHealth(amount):
	if player_health > 0:
		player_health -= amount
		spawnDamageIndicator(amount)
		playerDamaged = true
		if player_health <= 0:
			print("player died")
			playerDamaged = false
			player = null
			get_tree().reload_current_scene()
			
	print(player_health)
	
func ReducePlayerSpeed(amount):
	if playerSpeed > 0:
		playerSpeed -= amount

func ReturnPlayerSpeedToNormal():
	playerSpeed = defaultPlayerSpeed
	
func ReduceStamina(amount):
	stamina -= amount
	
func spawnDamageIndicator(amount: int):
	var instance = damage_indicator.instantiate()
	print(player)
	instance.z_index = player.z_index + 1
	instance.text = str(amount)
	player.add_child(instance)
	
# experience
func calculateExperience(amount):
	experience += amount

func activateRegeneration():
	player_health = default_player_health

func restoreStamina():
	stamina = default_stamina
	
func activatePowerUp(powerUpName: String, duration: float):
	if powerUpName == "nightmare":
		PowerUpActive = powerUpName
		playerSpeed += 80
		playerJumpVelocity = -500.0
		await get_tree().create_timer(duration).timeout
		PowerUpActive = ""
		resetMovementValues()
		
	if powerUpName == "hellbound":
		PowerUpActive = powerUpName
		kickDamage = defaultKickDamage * 2
		punchDamage = defaultPunchDamage * 2
		await get_tree().create_timer(duration).timeout
		PowerUpActive = ""
		resetDamage()

func resetDamage():
	kickDamage = defaultKickDamage
	punchDamage = defaultPunchDamage
	
func resetMovementValues():
	playerSpeed = defaultPlayerSpeed
	playerJumpVelocity = defaultJumpVelocity
		
	
