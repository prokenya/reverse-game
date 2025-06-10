extends Node
class_name Main
@export var worlds:Array[PackedScene]
@export var players:Array[PackedScene]
@onready var world:Node2D
@onready var current_player:Player
@export var gui:GUI
@export var npc:NPC
@export var current_world_id:int = 0

func  _ready() -> void:
	G.main = self
	gui.set_levels(worlds)

func load_world(index:int = 0):
	get_tree().paused = true
	var instace = worlds[index].instantiate()
	if world:
		world.queue_free()
		await get_tree().process_frame
	world = instace
	add_child(world)
	get_tree().paused = false
	Pool.hide_arrows()

func spawn_player(pos:Vector2 = Vector2.ZERO,wait_time:float = 0,type:int = 0):
	if current_player:
		current_player.queue_free()
		await get_tree().process_frame
	current_player = players[type].instantiate()
	current_player.position = pos
	if wait_time != 0:
		await get_tree().create_timer(wait_time).timeout
	add_child(current_player)

#func dispawn():
	#if current_player:
		#current_player.queue_free()
		#await get_tree().process_frame
		#
	#if world:
		#world.queue_free()
		#await get_tree().process_frame
	#
	#Pool.hide_arrows()
