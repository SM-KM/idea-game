extends AudioStreamPlayer2D
@onready var audio_controller: AudioStreamPlayer2D = %AudioController
const PUNCH_AUDIO = preload("res://assets/audio/player/punch_audio.wav")
const KICK_AUDIO = preload("res://assets/audio/player/kick_audio.wav")
const HURT = preload("res://assets/audio/player/hurt.ogg")

func playHurt():
	audio_controller.stream = HURT
	audio_controller.volume_db = -10
	audio_controller.play()

func playKickAudio():
	audio_controller.stream = PUNCH_AUDIO
	audio_controller.volume_db = -10
	audio_controller.play()
	
func playPunchAudio():
	audio_controller.stream = PUNCH_AUDIO
	audio_controller.volume_db = -10
	audio_controller.play()
