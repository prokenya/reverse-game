extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()
	
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func play():
	emitting = true
	audio_stream_player.play()
	await finished
	visible = false
