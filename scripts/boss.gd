extends CharacterBody2D
class_name Boss

var death_wave = 3
var isDead = false

const BOSS_AUDIO = preload("res://assets/audio/boss_audio.mp3")
const BOSS_DROP = preload("res://scenes/items/boss_drop.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var ignoreIdle = ["dead"]

func _ready() -> void:
	pass

func _process(delta: float) -> void:	
	if !animation_player.current_animation in ignoreIdle:
		animation_player.play("idle")
	
	if GameManager.current_wave == death_wave and isDead == false:
		GameManager.finishedFight = true
		animation_player.play("dead")
		var instance = BOSS_DROP.instantiate()
		add_child(instance)
		instance.reparent(get_parent())
		isDead = true
		

func _on_awareness_area_body_entered(body: Node2D) -> void:
	if body.name == GameManager.playerName:
		GameManager.position_to_next_wave()
		MainMusic.stream = BOSS_AUDIO
		MainMusic.autoplay = true
		MainMusic.volume_db = 0
		MainMusic.play()
