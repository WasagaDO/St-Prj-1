# res://comic/comic_choice_view.gd
extends VBoxContainer
class_name ComicChoiceView

signal choice_made(index: int)

@export var button_min_height: float = 56.0
@export var gap: float = 10.0

func setup(choice: ComicChoice) -> void:
	add_theme_constant_override("separation", int(gap))
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for i in range(choice.entries.size()):
		var entry := choice.entries[i]
		var b := Button.new()
		b.text = entry.label
		b.custom_minimum_size = Vector2(0, button_min_height)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(b)
		b.pressed.connect(func(): choice_made.emit(i))
