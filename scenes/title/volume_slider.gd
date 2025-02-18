extends HSlider
enum AudioType {
	Music,
	SFX
}

@export var type:AudioType

func _ready() -> void:
	value_changed.connect(_on_value_changed);
func _on_value_changed(value: float) -> void:
	var bus_string = "Music" if type == AudioType.Music else "SFX"
	var bus_index = AudioServer.get_bus_index(bus_string)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
