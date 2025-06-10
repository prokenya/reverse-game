extends Control
class_name GUI
@onready var chat_animation: AnimationPlayer = %"chat animation"
@onready var gui_animations: AnimationPlayer = $guianimation

@onready var transition: ColorRect = %transition

@onready var sfx_spin_box: SpinBox = %SFXSpinBox
@onready var music_spin_box: SpinBox = %music_spin_box
@onready var main_menu_button: Button = $HBoxContainer/ui/NinePatchRect/menu/main_menu_button
@onready var play: Button = %Play

@onready var resume_button: Button = $"HBoxContainer/ui/NinePatchRect/menu/resume button"
@onready var mobile_menu: Button = $"mobile menu"
@onready var mobile_togle: CheckButton = %"mobile togle"

@onready var virtual_joystick_left: VirtualJoystick = $"VBoxContainer/Virtual joystick left"



var is_in_ui:bool = true
var is_in_guide:bool = false

var hp_tween:Tween
var enthusiasm_tween:Tween


@onready var hp_progress: ProgressBar = %hp
@onready var enthusiasm_progress: ProgressBar = %enthusiasm
@onready var stats: PanelContainer = $stats

@onready var levels_c: VBoxContainer = %levels
@onready var end: PanelContainer = $"../end/end"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_audio()
	mobile_togle.button_pressed = G.plathorm == "touchscreen"


#region set
func set_NPC_status(status:bool):
	if status:
		chat_animation.play("player connected")
	else:
		chat_animation.play("player disconnected")
	await chat_animation.animation_finished
	return

func set_hp(max_hp:int,hp:int):
	if hp_tween:
		hp_tween.kill()
	hp_progress.max_value = max_hp
	hp_tween = create_tween()
	hp_tween.tween_property(hp_progress,"value",hp,1)

func set_enthusiasm(enthusiasm:int):
	if enthusiasm_tween:
		enthusiasm_tween.kill()
	enthusiasm_tween = create_tween()
	enthusiasm_tween.tween_property(enthusiasm_progress,"value",enthusiasm,1)
	await  enthusiasm_tween.finished
	return

func set_audio(data:Data = G.data):
	var bus_index = AudioServer.get_bus_index("sfx")
	var bus_index1 = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(data.sfx)
	)
	AudioServer.set_bus_volume_db(
		bus_index1,
		linear_to_db(data.music)
	)
	sfx_spin_box.value = data.sfx *100
	music_spin_box.value = data.music *100

func set_levels(levels:Array):
	for i in range(levels.size()):
		var button = Button.new()
		button.text = "level: " + str(i+1)
		button.focus_mode = Control.FOCUS_NONE
		#button.size_flags_horizontal  = Control.SIZE_EXPAND
		
		button.set_meta("level_id",i)
		button.connect("pressed",_on_play_pressed.bind(i))
		levels_c.add_child(button)
		set_buttons_status({"active_buttons":G.data.active_buttons})

func set_buttons_status(data:Dictionary):
	var active_buttons = data.get("active_buttons")
	#print(active_buttons)
	for button in levels_c.get_children():
		if button.get_meta("level_id") in active_buttons:
			button.disabled = false
		else:
			button.disabled = true

#endregion
#region main
func _on_play_pressed(id:int = 0) -> void:
	open_close_menu()
	load_game(id)

func load_game(id:int = 0):
	await set_transition()
	G.main.spawn_player(Vector2(-340,0),3,id)
	G.main.load_world(id)
	G.main.current_world_id = id
	hide_buttons()
	if G.plathorm != "PC":
		virtual_joystick_left.visible = true
	await set_transition(false)
	if id not in G.data.active_buttons:
		G.data.active_buttons.append(id)
		G.data.save()
		set_buttons_status({"active_buttons":G.data.active_buttons})

func hide_buttons():
	main_menu_button.visible = true
	stats.visible = true
	
	resume_button.visible = true
	mobile_togle.visible = false
	
	play.visible = false

func _on_main_menu_pressed() -> void:
	await set_transition()
	G.main.current_world_id = 0
	Pool.hide_arrows()
	get_tree().change_scene_to_file("res://src/main.tscn")
	#main_menu_button.visible = false
	#gui_animations.play("show menu")
	#is_in_ui = true
	#enthusiasm_progress.value = 100
	#hp_progress.value = 100
	#stats.visible = false
	await set_transition(false)

func _on_how_to_play_pressed() -> void:
	if is_in_guide:
		gui_animations.play_backwards("show guide")
	else:
		gui_animations.play("show guide")
	is_in_guide = !is_in_guide
		

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Menu"):
		open_close_menu()

func open_close_menu():
	if gui_animations.is_playing():
		return
	if is_in_ui:
		if is_in_guide:
			gui_animations.play_backwards("show guide")
			await gui_animations.animation_finished
			is_in_guide = false
		gui_animations.play_backwards("show menu")
		await gui_animations.animation_finished
	else:
		gui_animations.play("show menu")
		get_tree().paused = !is_in_ui
		await gui_animations.animation_finished
		
	if G.plathorm != "PC":
		mobile_menu.visible = is_in_ui
	
	is_in_ui = !is_in_ui
	get_tree().paused = is_in_ui

var transition_tween
func set_transition(start:bool = true,color:Color = Color.BLACK) -> void:
	if transition_tween:
		transition_tween.kill()
	transition_tween = create_tween()
	if start:
		transition.visible = true
		transition_tween.tween_property(transition,"color",color,1)
		await transition_tween.finished
	else:
		transition_tween.tween_property(transition,"color",Color("#00000000"),1)
		await transition_tween.finished
		transition.visible = false
	return
#endregion



func _on_spinsfx_value_changed(value: float) -> void:
	G.data.sfx = value/100
	G.data.save()
	set_audio()


func _on_spinmusic_value_changed(value: float) -> void:
	G.data.music = value/100
	G.data.save()
	set_audio()

func show_end():
	get_tree().paused = true
	end.show()
	await  get_tree().create_timer(5).timeout
	_on_main_menu_pressed()


func _on_mobile_togle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		G.plathorm = "touchscreen"
	else:
		G.plathorm = "PC"
