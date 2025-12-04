extends CharacterBody2D

@export var base_speed: float = 100.0

# set by terrain types
var speed_modifier: float = 1.0

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var current_speed := base_speed * speed_modifier
	velocity = input_vector * current_speed
	move_and_slide()
