extends Camera2D

var tween 

func _ready() -> void:
	G.camera = self

func reparent_camera(new_parent:Node,duration:float = 2):
	reparent(new_parent,true)
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self,"position",Vector2.ZERO,duration)
	await tween.finished
