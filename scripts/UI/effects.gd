extends Node2D

@onready var sprite_nightmare: Sprite2D = $Sprite2D
@onready var sprite_hellbound: Sprite2D = $Sprite2D2

func refreshEffects():
	if !GameManager.activeEffects.is_empty():
		for effect in GameManager.activeEffects:
			var currentEffect = GameManager.activeEffects[effect]
			if currentEffect[0] == "nightmare":
				sprite_nightmare.texture = load(currentEffect[1])
			if currentEffect[0] == "hellbound":
				sprite_hellbound.texture = load(currentEffect[1])
