extends OptionButton

@export var full_screen_toggle:CheckButton

func _ready() -> void:
	item_selected.connect(_on_item_selected);

func _on_item_selected(index: int) -> void:
	var window = get_window();
	var screen_size = DisplayServer.screen_get_size(window.current_screen);
	
	
	var new_res:PackedStringArray = get_item_text(index).split("x");
	var new_size = Vector2(new_res[0].to_int(), new_res[1].to_int())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	window.size = new_size;
	var centered = Vector2(screen_size.x / 2 - window.size.x / 2, screen_size.y / 2 - window.size.y / 2)
	window.position = centered
	full_screen_toggle.button_pressed = false;
	


# we can't change the resolution of the game if fullscreen
# godot prohibits it.  so we display that here.
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		disabled = true;
	else:
		disabled = false;
