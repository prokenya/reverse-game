extends Area2D

@export var hp_amount: int = 2
var body_timers: Dictionary = {} # body -> Timer

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body == get_parent(): #exclude_parent
		return
	if not body.has_method("add_hp"):
		return

	if body in body_timers:
		return # already has a timer

	var timer := Timer.new()
	timer.wait_time = 0.7
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)

	timer.connect("timeout", func():
		if body in body_timers:
			body.add_hp(-hp_amount)
	)

	body_timers[body] = timer

func _on_body_exited(body: Node2D) -> void:
	if body in body_timers:
		var timer: Timer = body_timers[body]
		timer.queue_free()
		body_timers.erase(body)
