extends BaseCharacter
class_name BaseNavigationBody

@export var navigation_agent: NavigationAgent2D

func _ready() -> void:
	navigation_agent.connect("velocity_computed",_velocity_computed)

func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():return
	var current_pos:Vector2 = global_position
	var next_pos:Vector2 = navigation_agent.get_next_path_position()
	var target_velocity:Vector2 = (next_pos - current_pos).normalized() * SPEED
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(target_velocity)
	else:
		_velocity_computed(target_velocity)

func go_to(pos:Vector2) -> bool:
	navigation_agent.target_position = pos
	await navigation_agent.navigation_finished
	return true

func reset_navigation():
	navigation_agent.set_target_position(global_position)
	velocity = Vector2.ZERO

func _velocity_computed(vel:Vector2):
	velocity = vel
	move_and_slide()
