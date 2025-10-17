extends Enemy

func _ready() -> void:
	super._ready()
	if not use_new_animation_type:
		$"Old Visual/AnimationPlayer".play("Stand")
