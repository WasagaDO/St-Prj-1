extends BasicMenu

class_name SettingsMenu

@export var music_slider:HSlider;
@export var sound_slider:HSlider;
@export var language_dropdown:OptionButton
@export var resolution_dropdown:OptionButton
@export var fullscreen_toggle:CheckButton

var music_key:String = "music";
var sound_key:String = "sound";
var language_key:String = "language";
var resolution_key:String = "resolution";
var fullscreen_key:String = "fullscreen";

var config_file:ConfigFile;

func _ready() -> void:

	config_file = ConfigFile.new();
	var err = config_file.load("user://settings.cfg");
	if err == OK:
		await get_tree().process_frame
		music_slider.value = config_file.get_value("settings", music_key, 1);
		sound_slider.value = config_file.get_value("settings", sound_key, 1)
		var resolution_index = config_file.get_value("settings", resolution_key, 0)
		resolution_dropdown.select(resolution_index)
		resolution_dropdown.item_selected.emit(resolution_index);
		var language_index = config_file.get_value("settings", language_key, 0)
		language_dropdown.select(language_index);
		language_dropdown.item_selected.emit(language_index);
		fullscreen_toggle.button_pressed = config_file.get_value("settings", fullscreen_key, false)

func save_value(key, value):
	config_file.set_value("settings", key, value);
	config_file.save("user://settings.cfg");
func _on_music_value_changed(value: float) -> void:
	save_value(music_key, value);
func _on_sound_value_changed(value: float) -> void:
	save_value(sound_key, value);
func _on_language_item_selected(index: int) -> void:
	save_value(language_key, index);
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	save_value(fullscreen_key, toggled_on);
func _on_resolution_item_selected(index: int) -> void:
	save_value(resolution_key, index);


func _on_close_button_pressed() -> void:
	visible = false;
