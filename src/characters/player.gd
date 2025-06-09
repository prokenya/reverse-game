extends CharacterBody2D
class_name Player

const JUMP_VELOCITY = -400.0
const ACCELERATION = 2000
var speed = 100.0
var control:bool = false
@export var max_hp:int = 15
@export var hp:int = 15
@onready var weapons: Node2D = $weapons
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


func _ready() -> void:
	await G.camera.reparent_camera(self,1)
	G.main.gui.set_hp(max_hp,hp)
	control = true

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
	if G.plathorm == "PC":
		var mouse_pos = get_global_mouse_position()
		rotation = (mouse_pos - global_position).angle() + PI / 2
	else:
		mobile_rotate(event)


func _on_timer_timeout() -> void:
	for weapon in weapons.get_children():
		weapon.frame = 1
		Pool.shoot_arrow(weapon.global_position,weapon.global_rotation)
	await get_tree().create_timer(0.5).timeout
	for weapon in weapons.get_children():
		weapon.frame = 0

func add_hp(ahp:int):
	hp += ahp
	G.main.gui.set_hp(max_hp,hp)
	animate_flash(0.2)
	if hp <= 0:
		G.main.current_world_id += 1
		if G.main.current_world_id + 1 > G.main.worlds.size():
			G.main.gui.show_end()
			return
		G.main.gui.load_game(G.main.current_world_id)
	
var tween: Tween
func animate_flash(duration: float = 0.3, cycles: int = 1) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	var shader_material := tile_map_layer.material as ShaderMaterial
	if shader_material == null:
		push_warning("sprite.material is not a ShaderMaterial")
		return
	
	for i in range(cycles):
		tween.tween_property(shader_material, "shader_parameter/factor", 1.0, duration / 2)
		tween.tween_property(shader_material, "shader_parameter/factor", 0.0, duration / 2)
	await tween.finished


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
