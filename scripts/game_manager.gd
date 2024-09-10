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

var allInitialSpawnPoints: Dictionary = {}

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

# bosses
@export var boss: Boss
var finishedFight: bool = false

# ui events
var teleport_to_game_start: bool = false

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
@export var start_game_checkpoint: CheckPoint

func _ready() -> void:
	
	# initializeSpawners
	# BurningGhoul
	BurningGhoulWaveSpawnPointsAmount = BurningGhoulWaveSpawnPoints.size()
	BurningGhoulSpawnPointsAmount = BurningGhoulSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.BurningGhoul] = [BurningGhoulSpawnPoints, burningGhoulScene]

	# NightBorne
	NightBorneWaveSpawnPointsAmount = NightBorneWaveSpawnPoints.size()
	NightBorneSpawnPointsAmount = NightBorneSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.NightBorne] = [NightBorneSpawnPoints, nightBorneScene]
	
	# Bringer of the Death
	BringerOfDeathWaveSpawnPointsAmount = BringerOfDeathWaveSpawnPoints.size()
	BringerOfDeathSpawnPointsAmount = BringerOfDeathSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.BringerOfDeath] = [BringerOfDeathSpawnPoints, bringerOfDeathScene]
	
	# Demon
	DemonWaveSpawnPointsAmount = DemonWaveSpawnPoints.size()
	DemonSpawnPointsAmount = DemonSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.Demon] = [DemonSpawnPoints, demonScene]
	
	# Ghost
	GhostWaveSpawnPointsAmount = GhostWaveSpawnPoints.size()
	GhostSpawnPointsAmount = GhostSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.Ghost] = [GhostSpawnPoints, ghostScene]
	
	# FireSkull
	FireSkullWaveSpawnPointsAmount = FireSkullWaveSpawnPoints.size()
	FireSkullSpawnPointsAmount = FireSkullSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.FireSkull] = [FireSkullSpawnPoints, fireSkullScene]
	
	# Hell Beast
	HellBeastWaveSpawnPointsAmount = HellBeastWaveSpawnPoints.size()
	HellBeastSpawnPointsAmount = HellBeastSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.HellBeast] = [HellBeastSpawnPoints, hellBeastScene]
	
	# Hell Bound
	HellBoundWaveSpawnPointsAmount = HellBoundWaveSpawnPoints.size()
	HellBoundSpawnPointsAmount = HellBoundSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.HellBound] = [HellBoundSpawnPoints, hellBoundScene]
	
	# NightMare
	NightMareWaveSpawnPointsAmount = NightMareWaveSpawnPoints.size()
	NightMareSpawnPointsAmount = NightMareSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.NightMare] = [NightMareSpawnPoints, nightBorneScene]
	
	# Striker
	StrikerWaveSpawnPointsAmount = StrikerWaveSpawnPoints.size()
	StrikerSpawnPointsAmount = StrikerSpawnPoints.size()
	allInitialSpawnPoints[EnemyType.Striker] = [StrikerSpawnPoints, strikerScene]
	
	
	nodes = get_tree().get_nodes_in_group("enemy_waves")
	var count = 0
	for node in nodes[0].get_children():
		count += node.get_child_count()
	spawnersAvailable = false if count == 0 else true
	
	current_wave = 0
	starting_nodes = get_tree().get_first_node_in_group("enemy_waves").get_child_count() + nodes_children
	current_nodes = get_tree().get_first_node_in_group("enemy_waves").get_child_count() + nodes_children
	respawn_player()

func finishFight():
	var waveSpawnersParent = get_tree().get_first_node_in_group("enemy_waves")
	for c in waveSpawnersParent.get_children():
		for spawn in c.get_children():
			for enemy in c.get_children():
				enemy.visible = false

func position_to_next_wave():	
	if current_nodes == starting_nodes and spawnersAvailable and finishedFight == false: 	
		if finishedFight:
			return
		
		if current_wave != 0:
			moving_to_next_wave = true
		wave_spawn_ended = false
		current_wave += 1
		print(current_wave)
		prepare_spawn(EnemyType.NightBorne, 1, NightBorneWaveSpawnPointsAmount)
		prepare_spawn(EnemyType.BurningGhoul, 4, BurningGhoulWaveSpawnPointsAmount)
		prepare_spawn(EnemyType.Ghost, 2, GhostWaveSpawnPointsAmount)
		prepare_spawn(EnemyType.Demon, 1, DemonWaveSpawnPointsAmount)
		prepare_spawn(EnemyType.NightMare, 1, NightMareWaveSpawnPointsAmount)

func prepare_spawn(type: EnemyType, multiplier: float, mob_spawns: int):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = wait_time_between_mobs
	var mob_spawn_rounds = mob_amount / mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)

func spawn_type(type, mob_spawn_rounds, mob_wait_time):	
	if type == EnemyType.Ghost:	
		if mob_spawn_rounds >= 1 and GhostWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, GhostWaveSpawnPointsAmount):
					var ghost = ghostScene.instantiate()
					GhostWaveSpawnPoints[spawnIndex].add_child(ghost)
					ghost.global_position = GhostWaveSpawnPoints[spawnIndex].global_position
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	
	if type == EnemyType.BurningGhoul:	
		if mob_spawn_rounds >= 1 and BurningGhoulWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, BurningGhoulWaveSpawnPointsAmount):
					var burningGhoul = burningGhoulScene.instantiate()
					BurningGhoulWaveSpawnPoints[spawnIndex].add_child(burningGhoul)
					burningGhoul.global_position = BurningGhoulWaveSpawnPoints[spawnIndex].global_position
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	
	if type == EnemyType.NightBorne:
		if mob_spawn_rounds >= 1 and NightBorneWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, NightBorneWaveSpawnPointsAmount):
					var nightBorne = nightBorneScene.instantiate()
					NightBorneWaveSpawnPoints[spawnIndex].add_child(nightBorne)
					nightBorne.global_position = NightBorneWaveSpawnPoints[spawnIndex].global_position
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
					DemonWaveSpawnPoints[spawnIndex].add_child(demon)
					demon.global_position = DemonWaveSpawnPoints[spawnIndex].global_position
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.FireSkull:
		if mob_spawn_rounds >= 1 and FireSkullWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, FireSkullWaveSpawnPointsAmount):
					var fireSkull = fireSkullScene.instantiate()
					fireSkull.global_position = FireSkullWaveSpawnPoints[spawnIndex].global_position
					FireSkullWaveSpawnPoints[spawnIndex].add_child(fireSkull)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.HellBeast:
		if mob_spawn_rounds >= 1 and HellBeastWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, HellBeastWaveSpawnPointsAmount):
					var hellBeast = hellBeastScene.instantiate()
					hellBeast.global_position = HellBeastWaveSpawnPoints[spawnIndex].global_position
					HellBeastWaveSpawnPoints[spawnIndex].add_child(hellBeast)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.HellBound:
		if mob_spawn_rounds >= 1 and HellBoundWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, HellBoundWaveSpawnPointsAmount):
					var hellBound = hellBoundScene.instantiate()
					hellBound.global_position = HellBoundWaveSpawnPoints[spawnIndex].global_position
					HellBoundWaveSpawnPoints[spawnIndex].add_child(hellBound)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	
	if type == EnemyType.NightMare:
		if mob_spawn_rounds >= 1 and NightMareWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, NightMareWaveSpawnPointsAmount):
					var nightMare = nightmareScene.instantiate()
					NightMareWaveSpawnPoints[spawnIndex].add_child(nightMare)
					nightMare.global_position = NightMareWaveSpawnPoints[spawnIndex].global_position
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
				
	if type == EnemyType.Striker:
		if mob_spawn_rounds >= 1 and StrikerWaveSpawnPointsAmount > 0:
			for i in mob_spawn_rounds:
				for spawnIndex in range(0, StrikerWaveSpawnPointsAmount):
					var striker = strikerScene.instantiate()
					striker.global_position = StrikerWaveSpawnPoints[spawnIndex].global_position
					StrikerWaveSpawnPoints[spawnIndex].add_child(striker)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout

	wave_spawn_ended = true

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
		
func instantiateAllInitialSpawnPoints():
	for type in allInitialSpawnPoints.keys():
		if allInitialSpawnPoints[type][0].size() > 0:
			for spawnPoint in allInitialSpawnPoints[type][0]:
				if spawnPoint is Marker2D:
					var instance = allInitialSpawnPoints[type][1].instantiate()
					instance.global_position = spawnPoint.global_position
					instance.z_index = 5
					spawnPoint.get_parent().add_child(instance)
			
			
func _process(delta: float) -> void:		
	if Input.is_action_just_pressed("start_game"):
		if teleport_to_game_start == false and start_game_checkpoint != null:
			teleport_to_game_start = true
			current_checkpoint = start_game_checkpoint
			respawn_player()
			
	
	# control wave spawn if in the area of the spawn waves
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
		playerJumpVelocity = -410.0
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
	

		
	
