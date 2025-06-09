extends Node
class_name Test

@export var testing:bool = true:
	set(value):
		if value: 
			_ready()
			testing = true
		else:testing = false
	get():
		return testing
@export var target_node:Node = null


func _ready() -> void:
	if !testing:return
	if !target_node:
		target_node = get_parent()
	if await test():
		print_rich("[color=green]passed[/color]")
	else:
		print_rich("[color=red]failed[/color]")
	testing = false


func test():
	pass
