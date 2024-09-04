extends AudioStreamPlayer2D
const RECEIVE_HIT = preload("res://assets/audio/enemy/receive_hit.wav")

func playHurt():
	stream = RECEIVE_HIT
	volume_db = -10
	play()
