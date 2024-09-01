extends CharacterBody2D

@export var speed = 100
var dir: float
var spawnPos: Vector2
var spawnRot: float
var zdex: int
var enemy_controller: Enemy_controller
var flipped: bool

func _ready() -> void:
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zdex

func _physics_process(delta: float) -> void:
	var sp = speed if flipped else -speed
	velocity = Vector2(sp, 0).rotated(dir)
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("player"):
		body.animatePlayerHurt()
		GameManager.ReducePlayerHealth(enemy_controller.enemyDamage)
		
	if !body.is_in_group("enemy"):
		queue_free()

func _on_life_timeout() -> void:
	queue_free()
