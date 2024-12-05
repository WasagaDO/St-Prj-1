extends CanvasLayer
@onready var settings_menu: Panel = $SettingsMenu

@export var session_settings_scene:PackedScene;
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(session_settings_scene);


func _on_settings_button_pressed() -> void:
	settings_menu.visible = true;


func _on_about_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit();
