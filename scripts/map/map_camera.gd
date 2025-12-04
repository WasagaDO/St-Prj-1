extends Camera2D

@export var drag_button: MouseButton = MOUSE_BUTTON_LEFT
@export var smooth_speed: float = 12.0
@export var drag_sensitivity: float = 1.2   # ← sensi augmentée

@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_step: float = 0.15
@export var zoom_smooth_speed: float = 10.0

@export var limit_min: Vector2 = Vector2(-2000, -2000)
@export var limit_max: Vector2 = Vector2(2000, 2000)

var dragging: bool = false
var last_mouse_world: Vector2

var target_pos: Vector2
var target_zoom: Vector2


func _ready() -> void:
	target_pos = global_position
	target_zoom = zoom


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_towards_mouse(zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_towards_mouse(-zoom_step)

		if event.button_index == drag_button and event.pressed:
			dragging = true
			last_mouse_world = get_global_mouse_position()

		if event.button_index == drag_button and not event.pressed:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		update_drag()


func update_drag() -> void:
	var mouse_world_now := get_global_mouse_position()
	var delta_world := (last_mouse_world - mouse_world_now) * drag_sensitivity
	target_pos += delta_world
	last_mouse_world = mouse_world_now


func zoom_towards_mouse(amount: float) -> void:
	var new_zoom_value = clamp(target_zoom.x + amount, min_zoom, max_zoom)

	var mouse_before := get_global_mouse_position()
	target_zoom = Vector2(new_zoom_value, new_zoom_value)
	var mouse_after := get_global_mouse_position()

	var offset := mouse_before - mouse_after
	target_pos += offset


func _process(delta: float) -> void:
	target_pos.x = clamp(target_pos.x, limit_min.x, limit_max.x)
	target_pos.y = clamp(target_pos.y, limit_min.y, limit_max.y)

	global_position = global_position.lerp(target_pos, delta * smooth_speed)
	zoom = zoom.lerp(target_zoom, delta * zoom_smooth_speed)
