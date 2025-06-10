extends CharacterBody2D
class_name BaseCharacter

@export_group("nodes")
@export var sprite:Node2D
@export_group("stats")
@export var is_boss:bool = false
@export var SPEED:int = 100.0
@export var hp:int = 5
@export var max_hp:int = 5

var is_dead:bool = false

var tween: Tween
signal added_hp(hp:int)


func add_hp(ahp:int) -> int:
	if is_dead:return 0
	hp += ahp
	if hp <= 0:
		is_dead = true
		death()
	else:
		animate_flash()
	if is_boss:
		G.main.gui.set_hp(max_hp,hp)
	emit_signal("added_hp",hp)
	return hp


func animate_flash(duration: float = 0.3, cycles: int = 1,color:Color = Color.WHITE) -> void:
	if !sprite: return
	if tween:
		tween.kill()
	tween = create_tween()
	var shader_material := sprite.material as ShaderMaterial
	if shader_material == null:
		push_warning("sprite.material is not a ShaderMaterial")
		return
	shader_material["shader_parameter/flash_color"] = color
	for i in range(cycles):
		tween.tween_property(shader_material, "shader_parameter/factor", 1.0, duration / 2)
		tween.tween_property(shader_material, "shader_parameter/factor", 0.0, duration / 2)
	await tween.finished



func death():
	if G.main.npc.is_dead:return
	await animate_flash(0.2,5,Color.RED)
	G.main.current_world_id += 1
	if 	G.main.current_world_id > G.main.worlds.size() -1:
		G.main.gui.show_end()
		return
	G.main.gui.set_enthusiasm(100)
	G.main.gui.load_game(G.main.current_world_id)
