extends Player

@export var uses_animation_player:bool = true

func _ready() -> void:
	super._ready()
	if uses_animation_player:
		%AnimationPlayer.play("Stand")
