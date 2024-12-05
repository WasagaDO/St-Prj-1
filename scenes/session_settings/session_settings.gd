extends CanvasLayer

@export_file var title_scene:String

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file(title_scene);
	pass # Replace with function body.
