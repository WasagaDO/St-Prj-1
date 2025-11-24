extends AudioStreamPlayer
class_name StandaloneAudioPlayer

@export var destroy_on_finish: bool = true

func _ready() -> void:
	if destroy_on_finish:
		finished.connect(_on_finished)

func _on_finished() -> void:
	queue_free()


func kill_audio(fade_duration: float = 0.0) -> void:
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -80.0, fade_duration)
	tween.tween_callback(func() -> void:
		stop()
		queue_free())
