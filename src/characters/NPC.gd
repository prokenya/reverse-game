extends BaseNavigationBody
class_name NPC


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_anim: AnimatedSprite2D = $Node2D/hit_anim


@onready var random_timer: Timer = $RandomTimer

var random_movement:bool = true
@onready var player = G.main.current_player
@onready var collide_with_player: Area2D = $"collide with player"

@export var streams:Array[AudioStream]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hit_delay: Timer = $hit_delay




enum states {
	IDLE,
	FOLLOW_PLAYER,
	GOTO,
	HITS,
	TEST
}
@export var state:states = states.GOTO

func _ready() -> void:
	play_sound(0)
	G.main.gui.set_NPC_status(true)

func change_state(next_state:states):
	reset_navigation()
	state = next_state
	match state:
		states.HITS:
			random_movement = false
			if (player.global_position - navigation_agent.get_final_position()).length() > 10:
				await go_to(Vector2(global_position - player.global_position) * 5)
			random_movement = true
				

func  _physics_process(delta: float) -> void:
	super._physics_process(delta)
	match state:
		states.IDLE:
			reset_navigation()
		states.FOLLOW_PLAYER:
			if (player.global_position - navigation_agent.get_final_position()).length() > 10:
				go_to(player.global_position)
		states.GOTO:
			if navigation_agent.is_navigation_finished():
				var random_offset = Vector2(randf() * 2 - 1, randf() * 2 - 1) * 150
				go_to(position + random_offset)
	if navigation_agent.is_navigation_finished():
		sprite.play("default")
	else:
		sprite.play("walk")
			

	#look_at(navigation_agent.get_next_path_position())
	
func _on_random_timer_timeout() -> void:
	random_timer.start([1, 2, 3, 4, 5].pick_random() * 2)
	if !random_movement:return

	var enum_values = states.values()
	enum_values.pop_front()
	enum_values.pop_back()
	enum_values.pop_back()
	var random_state = enum_values.pick_random()
	change_state(random_state)
	#print(random_state)


func _on_collide_with_player_body_entered(body: Node2D) -> void:
	change_state(states.HITS)
	current_body = body
	play_hit_anim()


var current_body:Node2D
func play_hit_anim():
	if !hit_delay.is_stopped():return
	hit_anim.get_parent().look_at(current_body.global_position)
	hit_anim.visible = true
	hit_anim.play()
	play_sound(3)
	if current_body is Player:
		current_body.add_hp(-1)
	await hit_anim.animation_finished
	hit_anim.visible = false
	hit_delay.start()


func _on_collide_with_player_body_exited(body: Node2D) -> void:
	current_body = null
	
func _on_hit_delay_timeout() -> void:
	if current_body:
		play_hit_anim()
		hit_delay.start()

func play_sound(id:int,rando_pitch:bool = false):
	if id == 3:
		audio_stream_player.pitch_scale = get_random_pitch_scale(0.7,1.3)
	else: audio_stream_player.pitch_scale = 1
	audio_stream_player.stream = streams[id]
	audio_stream_player.play()

func get_random_pitch_scale(min_pitch: float = 0.9, max_pitch: float = 1.1) -> float:
	return randf_range(min_pitch, max_pitch)

var tween: Tween
func animate_flash(duration: float = 0.3, cycles: int = 1) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	var shader_material := sprite.material as ShaderMaterial
	if shader_material == null:
		push_warning("sprite.material is not a ShaderMaterial")
		return
	
	for i in range(cycles):
		tween.tween_property(shader_material, "shader_parameter/factor", 1.0, duration / 2)
		tween.tween_property(shader_material, "shader_parameter/factor", 0.0, duration / 2)
	
	await tween.finished


var in_death:bool = false
func death():
	if in_death:return
	
	in_death = true
	current_body = null
	random_movement = false
	change_state(states.IDLE)
	
	play_sound(2)
	await animate_flash(0.2,5)
	leave()

func leave():
	play_sound(1)
	sprite.visible = false
	await G.main.gui.set_NPC_status(false)
	G.main.gui._on_main_menu_pressed()



#region enthusiasm
var current_enthusiasm: int = 100
		
func add_enth(enthusiasm: int) -> void:
	current_enthusiasm += enthusiasm
	current_enthusiasm = min(current_enthusiasm,100)
	
	G.main.gui.set_enthusiasm(current_enthusiasm)
	
	if 	current_enthusiasm <= 0:
		G.main.gui.set_NPC_status(false)
		leave()
		

func _on_enth_taker_timeout() -> void:
	add_enth(-20)
#endregion
