extends BaseNavigationBody
class_name NPC


@onready var hit_anim: AnimatedSprite2D = $Node2D/hit_anim


@onready var random_timer: Timer = $RandomTimer

var random_movement:bool = true
@onready var player = G.main.current_player
@onready var collide_with_player: Area2D = $"collide with player"

@export var streams:Array[AudioStream]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_delay: Timer = $hit_delay

@onready var progress_bar: ProgressBar = %ProgressBar

enum states {
	IDLE,
	FOLLOW_PLAYER,
	GOTO,
	HITS,
	TEST
}
@export var state:states = states.GOTO
			#if !navigation_agent.is_target_reachable():
				#go_to(-player.global_position)
func _ready() -> void:
	G.main.npc = self
	connect("added_hp",_added_hp)
	
	progress_bar.max_value = max_hp
	
	play_sound(0)
	G.main.gui.set_NPC_status(true)
	go_to(position) # for is_navigation_finished()
	

func change_state(next_state:states):
	reset_navigation()
	state = next_state
	match state:
		states.HITS:
			#random_movement = false
			var pos = Vector2(global_position - player.global_position).normalized() * 100
			await  go_to(pos)
			if !navigation_agent.is_target_reachable():
				await go_to(-player.global_position)
			change_state(states.FOLLOW_PLAYER)
			
			#random_movement = true
				

func  _physics_process(delta: float) -> void:
	if is_dead:return
	super._physics_process(delta)
	match state:
		states.IDLE:
			reset_navigation()
		states.FOLLOW_PLAYER:
			if (player.global_position - navigation_agent.get_final_position()).length() > 10:
				if navigation_agent.is_navigation_finished():
					change_state(states.HITS)
				go_to(player.global_position)
		states.GOTO:
			if navigation_agent.is_navigation_finished():
				var random_offset = Vector2(randf() * 2 - 1, randf() * 2 - 1) * 150
				await go_to(position + random_offset)
				if player.is_inside_tree():
					change_state(states.FOLLOW_PLAYER)
					if $enth_taker.is_stopped():
						$enth_taker.start()
	if navigation_agent.is_navigation_finished():
		sprite.play("default")
	else:
		sprite.play("walk")
			



func _on_collide_with_player_body_entered(body: Node2D) -> void:
	if body is not Player or body is NPC: return
	if is_dead:return
	
	current_body = body
	play_hit_anim()


var current_body:BaseCharacter
func play_hit_anim():
	if current_body.is_dead or self.is_dead:return
	
	if !hit_delay.is_stopped():return
	hit_delay.start()
	change_state(states.HITS)
	
	hit_anim.get_parent().look_at(current_body.global_position)
	hit_anim.visible = true
	hit_anim.play()
	
	current_body.add_hp(-1)
	play_sound(3)
	
	await hit_anim.animation_finished
	
	hit_anim.visible = false

func _on_collide_with_player_body_exited(body: Node2D) -> void:
	current_body = null

func _on_hit_delay_timeout() -> void:
	if is_dead:return
	
	change_state(states.FOLLOW_PLAYER)
	
	if current_body:
		play_hit_anim()
		hit_delay.start()
		
	#add_enth(clampi(-2 * hit_streak,2,30))

func play_sound(id:int,rando_pitch:bool = false):
	if id == 3:
		audio_stream_player.pitch_scale = get_random_pitch_scale(0.7,1.3)
	else: audio_stream_player.pitch_scale = 1
	audio_stream_player.stream = streams[id]
	audio_stream_player.play()
	await audio_stream_player.finished

func get_random_pitch_scale(min_pitch: float = 0.9, max_pitch: float = 1.1) -> float:
	return randf_range(min_pitch, max_pitch)


func death():
	collision_shape.disabled = true
	G.main.gui.set_enthusiasm(0)
	
	change_state(states.IDLE)
	play_sound(2)
	await animate_flash(0.2,5,Color.RED)
	
	leave()

func leave():
	collision_shape.disabled = true
	is_dead = true
	play_sound(1)
	sprite.visible = false
	await G.main.gui.set_NPC_status(false)
	G.main.gui._on_main_menu_pressed()



func _added_hp(hp:int):
	progress_bar.value = hp

#region enthusiasm
var current_enthusiasm: int = 100
		
func add_enth(enthusiasm: int) -> void:
	if is_dead:return
	current_enthusiasm += enthusiasm
	current_enthusiasm = min(current_enthusiasm,100)
	
	await  G.main.gui.set_enthusiasm(current_enthusiasm)
	
	if 	current_enthusiasm <= 0:
		G.main.gui.set_NPC_status(false)
		leave()
		

func _on_enth_taker_timeout() -> void:
	add_enth(-20)
#endregion
