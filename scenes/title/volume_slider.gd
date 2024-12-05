extends HSlider
enum AudioType {
	Music,
	SFX
}

@export var type:AudioType


func _on_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Music" if type == AudioType.Music else "SFX")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
