extends OptionButton

@export var resolutions:Array[String]
@export var full_screen_toggle:CheckButton
func _ready() -> void:
	# 1920x1080 is there as placeholder, remove that.
	remove_item(0);
	for i in range(0, resolutions.size()):
		add_item(resolutions[i], i);
	update_minimum_size();
	get_popup()


func _on_item_selected(index: int) -> void:
	var window = get_window();
	var screen_size = DisplayServer.screen_get_size(window.current_screen);
	
	
	var new_res:PackedStringArray = resolutions[index].split("x");
	var new_size = Vector2(new_res[0].to_int(), new_res[1].to_int())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	window.size = new_size;
	var centered = Vector2(screen_size.x / 2 - window.size.x / 2, screen_size.y / 2 - window.size.y / 2)
	window.position = centered
	full_screen_toggle.button_pressed = false;
	
