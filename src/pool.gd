extends Node

var instances_count: int = 100
@export var arrow: PackedScene = load("res://src/projectiles/arrow.tscn")
@onready var arrows: Array[Arrow] = []

func _ready() -> void:
	create_arrow_pool()

func create_arrow_pool():
	for i in range(instances_count):
		var instance: Arrow = arrow.instantiate()
		arrows.append(instance)
		add_child(instance)
	hide_arrows()

func shoot_arrow(pos: Vector2, rot: float):
	var arr: Arrow = arrows.pop_front()
	arr.global_position = pos
	arr.global_rotation = rot
	await get_tree().process_frame
	arr.enable_arrow()
	arrows.push_back(arr)

func hide_arrows():
	for arr in arrows:
		arr.disable_arrow()
		arr.global_position = Vector2(1000,0)
