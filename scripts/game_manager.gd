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

@export var camera_limit_max_value: int = 100000
@export var camera: Camera

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var damage_indicator = preload("res://scenes/UI/damage_indicator.tscn")

enum AttackType { Kick, Punch, None, CrouchKick, FlyKick }
enum EnemyType { BurningGhoul, BringerOfDeath, Demon, Ghost, FireSkull, HellBeast, HellBound, NightBorne, NightMare, Striker }

@onready var BurningGhoulWaveSpawnPoints = get_tree().get_nodes_in_group("burningGhoul_wsp")
@onready var BurningGhoulSpawnPoints = get_tree().get_nodes_in_group("burningGhoul_sp")
var BurningGhoulWaveSpawnPointsAmount: int
var BurningGhoulSpawnPointsAmount: int

@onready var NightBorneWaveSpawnPoints = get_tree().get_nodes_in_group("nightborne_wsp")
@onready var NightBorneSpawnPoints = get_tree().get_nodes_in_group("nightborne_sp")
var NightBorneWaveSpawnPointsAmount: int
var NightBorneSpawnPointsAmount: int

@onready var BringerOfDeathWaveSpawnPoints = get_tree().get_nodes_in_group("bringerOfDeath_wsp")
@onready var BringerOfDeathSpawnPoints = get_tree().get_nodes_in_group("bringerOfDeath_sp")
var BringerOfDeathWaveSpawnPointsAmount: int
var BringerOfDeathSpawnPointsAmount: int

@onready var DemonWaveSpawnPoints = get_tree().get_nodes_in_group("demon_wsp")
@onready var DemonSpawnPoints = get_tree().get_nodes_in_group("demon_sp")
var DemonWaveSpawnPointsAmount: int
var DemonSpawnPointsAmount: int

@onready var GhostWaveSpawnPoints = get_tree().get_nodes_in_group("ghost_wsp")
@onready var GhostSpawnPoints = get_tree().get_nodes_in_group("ghost_sp")
var GhostWaveSpawnPointsAmount: int
var GhostSpawnPointsAmount: int

@onready var FireSkullWaveSpawnPoints = get_tree().get_nodes_in_group("fire_skull_wsp")
@onready var FireSkullSpawnPoints = get_tree().get_nodes_in_group("fire_skull_sp")
var FireSkullWaveSpawnPointsAmount: int
var FireSkullSpawnPointsAmount: int

@onready var HellBeastWaveSpawnPoints = get_tree().get_nodes_in_group("hell_beast_wsp")
@onready var HellBeastSpawnPoints = get_tree().get_nodes_in_group("hell_beast_sp")
var HellBeastWaveSpawnPointsAmount: int
var HellBeastSpawnPointsAmount: int

@onready var HellBoundWaveSpawnPoints = get_tree().get_nodes_in_group("hell_bound_wsp")
@onready var HellBoundSpawnPoints = get_tree().get_nodes_in_group("hell_bound_sp")
var HellBoundWaveSpawnPointsAmount: int
var HellBoundSpawnPointsAmount: int

@onready var NightMareWaveSpawnPoints = get_tree().get_nodes_in_group("nightmare_wsp")
@onready var NightMareSpawnPoints = get_tree().get_nodes_in_group("nightmare_sp")
var NightMareWaveSpawnPointsAmount: int
var NightMareSpawnPointsAmount: int

@onready var StrikerWaveSpawnPoints = get_tree().get_nodes_in_group("striker_wsp")
@onready var StrikerSpawnPoints = get_tree().get_nodes_in_group("striker_sp")
var StrikerWaveSpawnPointsAmount: int
var StrikerSpawnPointsAmount: int


@export var playerSpeed: int  = 140.0
@export var playerJumpVelocity: float = -300.0
@export var experience: int = 0
@export var currentAttackType: AttackType = AttackType.None
@export var gravity: int = 1500

var defaultPlayerSpeed = 140.0
var defaultJumpVelocity = -300.0
var playerPosition: Vector2
var playerDamaged: bool
var regenCooldownStarted: bool
var PowerUpActive: String
var activeEffects: Dictionary

# Spawn points and waves system
var current_wave: int

# enemies
@onready var burningGhoulScene: PackedScene = preload("res://scenes/burning_ghoul.tscn")
@onready var nightBorneScene: PackedScene = preload("res://scenes/nightborne.tscn")
@onready var bringerOfDeathScene: PackedScene = preload("res://scenes/bringer_of_death.tscn")
@onready var demonScene: PackedScene = preload("res://scenes/demon.tscn")
@onready var ghostScene: PackedScene = preload("res://scenes/ghost.tscn")
@onready var fireSkullScene: PackedScene = preload("res://scenes/fire_skull.tscn")
@onready var hellBeastScene: PackedScene = preload("res://scenes/hell_beast.tscn")
@onready var hellBoundScene: PackedScene = preload("res://scenes/hell_bound.tscn")
@onready var nightmareScene: PackedScene = preload("res://scenes/nightmare.tscn")
@onready var strikerScene: PackedScene = preload("res://scenes/striker.tscn")

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended: bool = false
var moving_to_next_wave: bool
var nodes: Array[Node]
var nodes_children = 0
var spawnersAvailable: bool
var wait_time_between_mobs: float = 2.0

# checkpoints 
@export var current_checkpoint: CheckPoint

func _ready() -> void:
	# initializeSpawners
	# BurningGhoul
	BurningGhoulWaveSpawnPointsAmount = BurningGhoulWaveSpawnPoints.size()
	BurningGhoulSpawnPointsAmount = BurningGhoulSpawnPoints.size()

	# NightBorne
	NightBorneWaveSpawnPointsAmount = NightBorneWaveSpawnPoints.size()
	NightBorneSpawnPointsAmount = NightBorneSpawnPoints.size()
	
	# Bringer of the Death
	BringerOfDeathWaveSpawnPointsAmount = BringerOfDeathWaveSpawnPoints.size()
	BringerOfDeathSpawnPointsAmount = BringerOfDeathSpawnPoints.size()
	
	# Demon
	DemonWaveSpawnPointsAmount = DemonWaveSpawnPoints.size()
	DemonSpawnPointsAmount = DemonSpawnPoints.size()
	
	# Ghost
	GhostWaveSpawnPointsAmount = GhostWaveSpawnPoints.size()
	GhostSpawnPointsAmount = GhostSpawnPoints.size()
	
	# FireSkull
	FireSkullWaveSpawnPointsAmount = FireSkullWaveSpawnPoints.size()
	FireSkullSpawnPointsAmount = FireSkullSpawnPoints.size()
	
	# Hell Beast
	HellBeastWaveSpawnPointsAmount = HellBeastWaveSpawnPoints.size()
	HellBeastSpawnPointsAmount = HellBeastSpawnPoints.size()
	
	# Hell Bound
	HellBoundWaveSpawnPointsAmount = HellBoundWaveSpawnPoints.size()
	HellBoundSpawnPointsAmount = HellBoundSpawnPoints.size()
	
	# NightMare
	NightMareWaveSpawnPointsAmount = NightMareWaveSpawnPoints.size()
	NightMareSpawnPointsAmount = NightMareSpawnPoints.size()
	
	# Striker
	StrikerWaveSpawnPointsAmount = StrikerWaveSpawnPoints.size()
	StrikerSpawnPointsAmount = StrikerSpawnPoints.size()
	
	nodes = get_tree().get_nodes_in_group("enemy_waves")
	var count = 0
	for node in nodes[0].get_children():
		count += node.get_child_count()
	spawnersAvailable = false if count == 0 else true
	
	current_wave = 0
	starting_nodes = get_tree().get_first_node_in_group("enemy_waves").get_child_count() + nodes_children
	current_nodes = get_tree().get_first_node_in_group("enemy_waves").get_child_count() + nodes_children
	position_to_next_wave()
	
	respawn_player()

func position_to_next_wave():
	if current_nodes == starting_nodes and spawnersAvailable:
		if current_wave != 0:
			moving_to_next_wave = true
		wave_spawn_ended = false
		current_wave += 1
		print(current_wave)
		prepare_spawn(EnemyType.BurningGhoul, 0, BurningGhoulWaveSpawnPointsAmount)
		prepare_spawn(EnemyType.NightBorne, 0, NightBorneWaveSpawnPointsAmount)

func prepare_spawn(type: EnemyType, multiplier: float, mob_spawns: int):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = wait_time_between_mobs
	var mob_spawn_rounds = mob_amount / mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)

func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == EnemyType.BurningGhoul:	
		if mob_spawn_rounds >= 1 and BurningGhoulWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, BurningGhoulWaveSpawnPointsAmount):
					var burningGhoul = burningGhoulScene.instantiate()
					burningGhoul.global_position = BurningGhoulWaveSpawnPoints[spawnIndex].global_position
					BurningGhoulWaveSpawnPoints[spawnIndex].add_child(burningGhoul)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	
	if type == EnemyType.NightBorne:
		if mob_spawn_rounds >= 1 and NightBorneWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, NightBorneWaveSpawnPointsAmount):
					var nightBorne = nightBorneScene.instantiate()
					nightBorne.global_position = NightBorneWaveSpawnPoints[spawnIndex].global_position
					NightBorneWaveSpawnPoints[spawnIndex].add_child(nightBorne)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.BringerOfDeath:
		if mob_spawn_rounds >= 1 and BringerOfDeathWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, BringerOfDeathWaveSpawnPointsAmount):
					var bringerOfDeath = bringerOfDeathScene.instantiate()
					bringerOfDeath.global_position = BringerOfDeathWaveSpawnPoints[spawnIndex].global_position
					BringerOfDeathWaveSpawnPoints[spawnIndex].add_child(bringerOfDeath)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.Demon:
		if mob_spawn_rounds >= 1 and DemonWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, DemonWaveSpawnPointsAmount):
					var demon = demonScene.instantiate()
					demon.global_position = DemonWaveSpawnPoints[spawnIndex].global_position
					DemonWaveSpawnPoints[spawnIndex].add_child(demon)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.FireSkull:
		if mob_spawn_rounds >= 1 and FireSkullWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, FireSkullWaveSpawnPointsAmount):
					var fireSkull = demonScene.instantiate()
					fireSkull.global_position = FireSkullWaveSpawnPoints[spawnIndex].global_position
					FireSkullWaveSpawnPoints[spawnIndex].add_child(fireSkull)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.HellBeast:
		if mob_spawn_rounds >= 1 and HellBeastWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, HellBeastWaveSpawnPointsAmount):
					var hellBeast = demonScene.instantiate()
					hellBeast.global_position = HellBeastWaveSpawnPoints[spawnIndex].global_position
					HellBeastWaveSpawnPoints[spawnIndex].add_child(hellBeast)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.HellBound:
		if mob_spawn_rounds >= 1 and HellBoundWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, HellBoundWaveSpawnPointsAmount):
					var hellBound = demonScene.instantiate()
					hellBound.global_position = HellBoundWaveSpawnPoints[spawnIndex].global_position
					HellBoundWaveSpawnPoints[spawnIndex].add_child(hellBound)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	
	if type == EnemyType.NightMare:
		if mob_spawn_rounds >= 1 and NightMareWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, NightMareWaveSpawnPointsAmount):
					var nightMare = demonScene.instantiate()
					nightMare.global_position = NightMareWaveSpawnPoints[spawnIndex].global_position
					NightMareWaveSpawnPoints[spawnIndex].add_child(nightMare)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.Striker:
		if mob_spawn_rounds >= 1 and StrikerWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, StrikerWaveSpawnPointsAmount):
					var striker = demonScene.instantiate()
					striker.global_position = StrikerWaveSpawnPoints[spawnIndex].global_position
					StrikerWaveSpawnPoints[spawnIndex].add_child(striker)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout

	wave_spawn_ended = true

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
	
func _process(delta: float) -> void:		
	if wave_spawn_ended and spawnersAvailable:
		nodes = get_tree().get_nodes_in_group("enemy_waves")
		var count = 0
		for node in nodes[0].get_children():
			for n in node.get_children():
				count += n.get_child_count()
		
		# print(starting_nodes, current_nodes, count)
		current_nodes = get_tree().get_first_node_in_group("enemy_waves").get_child_count() + count
		position_to_next_wave()
		
		
	
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
			# check the way of reloading the scene
			playerDamaged = false
			player_health = default_player_health
			respawn_player()
	
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
func addActiveEffect(effectName: String, texture: String):
	if !effectName in activeEffects:
			activeEffects[effectName] = [effectName, texture]
			
			
func activatePowerUp(powerUpName: String, duration: float):
	if powerUpName == "nightmare":
		var texture = "res://assets/FX/[VerArc Stash] Basic_Skills_and_Buffs/Buffs/swiftness.png"
		addActiveEffect(powerUpName, texture)
		PowerUpActive = powerUpName
		playerSpeed += 80
		playerJumpVelocity = -500.0
		await get_tree().create_timer(duration).timeout
		PowerUpActive = ""
		resetMovementValues()
		removeFromActiveEffects(powerUpName)
		
	if powerUpName == "hellbound":
		var texture = "res://assets/FX/[VerArc Stash] Basic_Skills_and_Buffs/Buffs/attack_boost.png"
		addActiveEffect(powerUpName, texture)
		PowerUpActive = powerUpName
		kickDamage = defaultKickDamage * 2
		punchDamage = defaultPunchDamage * 2
		await get_tree().create_timer(duration).timeout
		PowerUpActive = ""
		resetDamage()
		removeFromActiveEffects(powerUpName)

func resetDamage():
	kickDamage = defaultKickDamage
	punchDamage = defaultPunchDamage

func resetMovementValues():
	playerSpeed = defaultPlayerSpeed
	playerJumpVelocity = defaultJumpVelocity
	
func removeFromActiveEffects(powerUpName: String):
	activeEffects.erase(powerUpName)
	var effectSprites = get_tree().get_nodes_in_group("buff")
	print(effectSprites)
	

func _on_killzone_body_entered(body: Node2D) -> void:
	if body is Player:
		respawn_player()
	else:
		body.call_deferred("queue_free")
		
	
