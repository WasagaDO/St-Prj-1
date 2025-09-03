extends Panel

@export var exit_scene_name:String = "res://scenes/title/title.tscn"


func _ready():
	visible = false
	

func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed and not event.echo:
		if visible:
			close_menu()
		else:
			open_menu()

func open_menu():
	visible = true

func close_menu():
	visible = false

func go_to_title_menu():
	get_tree().change_scene_to_file(exit_scene_name)
