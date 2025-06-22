extends BaseCharacter
class_name Player

const JUMP_VELOCITY = -400.0
const ACCELERATION = 2000
var speed = 100.0
var control:bool = false
@onready var weapons: Node2D = $weapons

@onready var shot_timer: Timer = Timer.new()
@export_range(0.2,10,0.1) var shot_delay:float = 0.7
var shot_pressed:bool = false

func _ready() -> void:
	add_timer()
	
	is_boss = true
	await G.camera.reparent_camera(self,1)
	G.main.gui.set_hp(max_hp,hp)
	control = true

func add_timer():
	add_child(shot_timer)
	shot_timer.wait_time = shot_delay
	shot_timer.one_shot = true
	shot_timer.name = "shot_timer"
	shot_timer.connect("timeout",_on_shot_timer_timeout)

func _physics_process(delta: float) -> void:
	if !control: return

	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("move_left", "move_right","move_up","move_down")
	if direction:
		velocity.x = move_toward(velocity.x, speed * direction.x, ACCELERATION * delta)
		velocity.y = move_toward(velocity.y, speed * direction.y, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()



func _input(event: InputEvent) -> void:
	if !control: return
	
	if Input.is_action_just_pressed("shot"):
		shot_pressed = true
		_on_shot_timer_timeout()
	if Input.is_action_just_released("shot"):
		shot_pressed = false
		
	if G.plathorm == "PC":
		var mouse_pos = get_global_mouse_position()
		rotation = (mouse_pos - global_position).angle() + PI / 2
	else:
		mobile_rotate(event)


func _on_shot_timer_timeout() -> void:
	if !shot_pressed or !shot_timer.is_stopped():
		return
	shot_timer.start()
	
	var weapon_list = weapons.get_children()
	
	for weapon in weapon_list:
		weapon.frame = 1
		Pool.shoot_arrow(weapon.global_position,weapon.global_rotation)
		
	await get_tree().create_timer(shot_timer.wait_time -0.1).timeout
	
	for weapon in weapon_list:
		weapon.frame = 0

#region mobile
var current_index := -1
func mobile_rotate(event: InputEvent) -> void:
	var joystick_area := G.main.gui.virtual_joystick_left.get_global_rect()
	#print(str(joystick_area) + " - " + str(event.position))
	if event is InputEventScreenTouch:
		if event.pressed:
			if !joystick_area.has_point(event.position):
				current_index = event.index
		elif event.index == current_index:
			current_index = -1

	elif event is InputEventScreenDrag:
		if event.index != current_index:
			return
		var touch_pos = event.position
		var screen_center = get_viewport_rect().size / 2.0
		rotation = (touch_pos - screen_center).angle() + PI / 2
#endregion
