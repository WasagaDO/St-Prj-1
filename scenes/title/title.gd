extends CanvasLayer
@onready var settings_menu: Panel = $SettingsMenu
@onready var about_menu:Panel = $AboutTheProject
@export var session_settings_scene:PackedScene;

@export var play_button:Button
@export var settings_button:Button
@export var about_button:Button
@export var exit_button:Button


func _ready() -> void:
	play_button.pressed.connect(play_click_sound)
	settings_button.pressed.connect(play_click_sound)
	about_button.pressed.connect(play_click_sound)
	exit_button.pressed.connect(play_click_sound)
	play_button.mouse_entered.connect(play_hover_sound)
	settings_button.mouse_entered.connect(play_hover_sound)
	about_button.mouse_entered.connect(play_hover_sound)
	exit_button.mouse_entered.connect(play_hover_sound)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(session_settings_scene);


func _on_settings_button_pressed() -> void:
	settings_menu.visible = true;


func _on_about_button_pressed() -> void:
	about_menu.visible = true;

func _on_exit_button_pressed() -> void:
	get_tree().quit();




func play_sfx(id: String, fade_in_duration:float = 0):
	AudioManager.play_sfx(id, fade_in_duration)


func play_hover_sound(volume_db:float=0.0):
	AudioManager.play_sfx("hover", 0, volume_db, 1, true)

func play_click_sound(volume_db:float=0.0):
	AudioManager.play_sfx("click", 0, volume_db, 1, true)
