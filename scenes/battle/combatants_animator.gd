class_name CombatantAnimator
extends Node

const DAMAGE_EFFECT_CURVE: Curve = preload("res://scenes/battle/damage_vibration_curve.tres")

@export var player:Player;

var window_width: float = ProjectSettings.get("display/window/size/viewport_width")
var x: float = 0.0

func combatant_damaged(combatant: Combatant, intensity: float = 30.0, animation_duration: float = 0.4) -> void:
	var initial_x_pos: float = combatant.position.x
	var tween:= create_tween()
	tween.tween_property(self,"x",1.0,animation_duration)
	while true:
		if x == 1:
			x = 0.0
			break
		combatant.position.x = initial_x_pos + DAMAGE_EFFECT_CURVE.sample(x) * intensity
		await get_tree().process_frame
	if is_instance_valid(self): queue_free()

func combatant_attacked(combatant: Combatant, dash_distance: float = 250.0, dash_duration: float = 0.15):
	var initial_x_pos: float = combatant.position.x
	var direction: int = -1 + 2 * int(combatant.position.x < window_width / 2)
	var tween:= create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"x",dash_distance * direction,dash_duration)
	while true:
		if x == dash_distance * direction:
			break
		combatant.position.x = initial_x_pos + x
		await get_tree().process_frame
	var t2 := create_tween()
	t2.tween_property(combatant,"position:x",initial_x_pos,0.5)
	t2.finished.connect(func():
		if is_instance_valid(self): queue_free())
