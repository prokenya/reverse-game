extends CharacterBody2D
class_name Arrow
var active:bool = false:
	set(value):
		active = value
		if active:
			play_sound(0)
const speed = 300
@export var streams:Array[AudioStream]
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !active:
		velocity = Vector2.ZERO
		return
	flight()
	if ray_cast.is_colliding():
		play_sound(1)
		var body = ray_cast.get_collider()
		if active and body is NPC:
			body.death()
		active = false

func flight():
	velocity = Vector2(cos(rotation - PI/2),sin(rotation - PI/2)).normalized() * speed
	move_and_slide()
	

func _on_body_entered(body: Node2D) -> void:
	if body is NPC:
		if active:
			body.add_enth(35)

func play_sound(id:int):
	audio_stream_player.pitch_scale = randf_range(0.7, 1.3)
	audio_stream_player.stream = streams[id]
	audio_stream_player.play()
