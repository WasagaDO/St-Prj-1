class_name CombatantAnimator
extends Node

const DAMAGE_EFFECT_CURVE: Curve = preload("res://scenes/battle/damage_vibration_curve.tres")
const ATTACK_CURVE: Curve = preload("res://scenes/battle/attack_curve.tres")

@export var player:Player;

var x: float = 0.0


# animation of a combatant attacking
""" # old version
func combatant_attacked(combatant: Combatant, dash_distance: float = 250.0, dash_duration: float = 0.15):
	print("combatant_attacked()")
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
"""
"""
func combatant_attacked(combatant: Combatant, dash_distance: float = 300, dash_duration: float = 1) -> void:
	print("combatant_attacked()")
	_force_finish_previous_anim(combatant)
	var initial_x_pos: float = combatant.position.x
	var direction: int = -1 + 2 * int(combatant.position.x < window_width / 2)
	tween = create_tween()
	tween.tween_property(self, "x", 1.0, dash_duration)
	while true:
		if x >= 1.0:
			x = 0.0
			break
		combatant.position.x = initial_x_pos + ATTACK_CURVE.sample(x) * dash_distance * direction
		await get_tree().process_frame
	if is_instance_valid(self):
		queue_free()



# animation of a combatant taking damage
func combatant_damaged(combatant: Combatant, intensity: float = 30.0, animation_duration: float = 0.4) -> void:
	print("combatant_damaged()")
	_force_finish_previous_anim(combatant)
	var initial_x_pos: float = combatant.position.x
	tween = create_tween()
	tween.tween_property(self,"x",1.0,animation_duration)
	while true:
		if x >= 1:
			x = 0.0
			break
		combatant.position.x = initial_x_pos + DAMAGE_EFFECT_CURVE.sample(x) * intensity
		await get_tree().process_frame
	if is_instance_valid(self): queue_free()
"""


var current_tween: Tween = null
var window_width: float = ProjectSettings.get("display/window/size/viewport_width")


func combatant_attacked(combatant: Combatant, dash_distance := 300.0, dash_duration := 1.0) -> void:
	print("combatant_attacked()")

	# Reset combatant position to its true initial origin before anim starts
	combatant.position = combatant.initial_position

	# Stop any previous animation to avoid drift
	if current_tween:
		current_tween.kill()

	var base_x := combatant.initial_position.x
	var direction := -1 + 2 * int(base_x < window_width / 2)

	current_tween = create_tween()

	# Animate from 0 → 1 using tween_method
	current_tween.tween_method(
		func(t: float):
			# t ∈ [0,1] : apply curve-based offset
			var offset := ATTACK_CURVE.sample(t) * dash_distance * direction
			combatant.position.x = base_x + offset,
		0.0, 1.0, dash_duration
	)

	# At the end, force exact original position
	current_tween.finished.connect(func():
		combatant.position = combatant.initial_position
		current_tween = null
	)



func combatant_damaged(combatant: Combatant, intensity := 30.0, duration := 0.4) -> void:
	print("combatant_damaged()")

	# Ensure starting position is clean
	combatant.position = combatant.initial_position

	if current_tween:
		current_tween.kill()

	var base_x := combatant.initial_position.x

	current_tween = create_tween()

	# Animate vibration using curve
	current_tween.tween_method(
		func(t: float):
			var offset := DAMAGE_EFFECT_CURVE.sample(t) * intensity
			combatant.position.x = base_x + offset,
		0.0, 1.0, duration
	)

	# End: return exactly to origin
	current_tween.finished.connect(func():
		combatant.position = combatant.initial_position
		current_tween = null
	)
