extends Node

@onready var main:Main
@onready var data = Data.load_or_create()
@onready var camera:Camera2D
var plathorm:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Android":
		plathorm = "touchscreen"
	else:
		plathorm = "PC"
	print("platform> " + plathorm)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
