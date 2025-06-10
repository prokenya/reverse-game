extends CharacterBody2D
class_name Arrow

const SPEED = 300

@export var streams: Array[AudioStream]
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _physics_process(delta: float) -> void:
	if not ray_cast.enabled:
		velocity = Vector2.ZERO
		return

	flight()

	if ray_cast.is_colliding():
		play_sound(1)
		var body = ray_cast.get_collider()
		if body is NPC:
			body.add_hp(-1)
			hide_arrow()
		disable_arrow()

func flight():
	velocity = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2)).normalized() * SPEED
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if ray_cast.enabled and body is NPC:
		body.add_enth(15)

func play_sound(id: int):
	audio_stream_player.pitch_scale = randf_range(0.7, 1.3)
	audio_stream_player.stream = streams[id]
	audio_stream_player.play()

func enable_arrow():
	ray_cast.enabled = true
	play_sound(0)

func disable_arrow():
	ray_cast.enabled = false
	velocity = Vector2.ZERO
	#global_position = Vector2(1000, 0)

func hide_arrow():
	global_position = Vector2(1000, 0)
