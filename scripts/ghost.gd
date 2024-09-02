extends CharacterBody2D
class_name Ghost

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var enemy_controller: Enemy_controller = $"../EnemyController"
@onready var flippable_sprite: FlippableSprite = $FlippableSprite
@onready var awareness_zone: Area2D = $AwarenessZone
@onready var health_bar: ProgressBar = $HealthBar

var ignoreIdle = ["shriek", "chase"]
var ignoreChase = ["shriek"]

func _ready() -> void:
	health_bar.initializeHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)

func _physics_process(delta: float) -> void:
	health_bar.updateHealthBar(enemy_controller.enemyHealth,enemy_controller.max_enemyHealth, enemy_controller.min_enemyHealth)
	
	if enemy_controller.body_entered_awareness_zone:
		enemy_controller.followPlayer(delta, self)
		flippable_sprite.flipped = not(enemy_controller.enemyFlipped)
		if !animation_player.current_animation in ignoreChase:
			animation_player.play("chase")
	
	if !animation_player.current_animation in ignoreIdle:
			animation_player.play("idle")	
		

# this enemy receives a hit from the player
func _on_hitbox_component_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == GameManager.playerHitboxName: 
		enemy_controller.handlePlayerHitOnEnemy(animation_player, "vanish", self.owner, 0.4, global_position, self)

# player enter awareness zone
func _on_awareness_zone_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.enemyFlipped = not(GameManager.playerFlipped)
		enemy_controller.body_entered_awareness_zone = true
		scarePlayer()
			
func scarePlayer():
	if GameManager.playerSpeed == GameManager.defaultPlayerSpeed:
		animation_player.play("shriek")
		GameManager.ReducePlayerSpeed(60)
		await get_tree().create_timer(2).timeout
		GameManager.ReturnPlayerSpeedToNormal()


func _on_awareness_zone_body_exited(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		enemy_controller.enemyFlipped = GameManager.playerFlipped
		enemy_controller.body_entered_awareness_zone = false
