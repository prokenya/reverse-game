extends Test

func test():
	target_node = target_node as NPC
	target_node.random_movement = false
	target_node.state = target_node.states.TEST
	await target_node.go_to(Vector2(50,70))
	await target_node.go_to(Vector2(70,0))
	await get_tree().create_timer(5).timeout
	target_node.go_to(Vector2(-510,70))
	#target_node.reset_navigation()
	#target_node.go_to(Vector2(130,70))
	#await target_node.go_to(Vector2(0,0))
	return true
