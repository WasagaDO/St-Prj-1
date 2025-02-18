extends CanvasLayer

@onready var backround: ColorRect = $Backround
@onready var inventory: Control = $Inventory

@export var blur_value: float = 4.0

func _ready() -> void:
	inventory.hide()
	inventory.back_button.pressed.connect(toggle_inventory)
	inventory.menu_button.pressed.connect(get_parent()._on_back_to_menu_pressed)

func toggle_inventory() -> void:
	match backround.material.get_shader_parameter("lod"):
		0.0:
			show_inventory()
		blur_value:
			hide_inventory()

func show_inventory() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(backround,"material:shader_parameter/lod",blur_value,0.5)
	tween.finished.connect(func():
		inventory.show())

func hide_inventory() -> void:
	inventory.hide()
	var tween := create_tween()
	tween.tween_property(backround,"material:shader_parameter/lod",0.0,0.5)
	tween.finished.connect(func():
		hide())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and backround.material.get_shader_parameter("lod") == blur_value:
		toggle_inventory()
