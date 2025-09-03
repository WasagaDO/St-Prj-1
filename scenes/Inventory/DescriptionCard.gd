extends TextureRect
# DescriptionCard.gd (hover zoom using a single detection Control)
# - No overlay.
# - Detect area is NOT moved at start; it stays where you placed it in the editor.
# - When zooming, detect area is scaled around its center (same center).
# - When de-zooming, detect area returns to its original position and size.

var title: String = "Title"
var type: String
var type2: String
var level: String

@onready var card_pic: TextureRect = $CardPic
@onready var title_label: Label = $VBoxContainer/Title
@onready var type_label: Label = $VBoxContainer/HBoxContainer/Type
@onready var level_label: Label = $VBoxContainer/HBoxContainer/Level

# A single Control used to detect mouse enter/exit (assign in the inspector)
@export var detect_area: Control

# Tuning
@export_range(1.0, 3.0, 0.05) var ZOOM_SCALE: float = 1.6
@export_range(0.05, 0.5, 0.01) var TWEEN_TIME: float = 0.15
@export var DETECT_ZOOM_MULT: float = 1.2        # how much bigger the detect area becomes when zoomed
@export var DETECT_ZOOM_EXTRA_PX: int = 80       # extra pixels on each side when zoomed

# Internals
var _orig_scale: Vector2
var _tween: Tween
var _zoomed := false

# Original detect area rect (saved once on _ready)
var _detect_orig_pos: Vector2
var _detect_orig_size: Vector2

func _ready() -> void:
	# Ensure CardPic scales around its visual center
	_orig_scale = card_pic.scale
	card_pic.pivot_offset = card_pic.size * 0.5

	# DetectArea must receive mouse events; do NOT move/resize it here.
	if detect_area:
		detect_area.mouse_filter = Control.MOUSE_FILTER_STOP
		_detect_orig_pos = detect_area.position
		_detect_orig_size = detect_area.size
		detect_area.mouse_entered.connect(_on_detect_area_mouse_entered)
		detect_area.mouse_exited.connect(_on_detect_area_mouse_exited)
		print("DetectArea ready. pos=", _detect_orig_pos, " size=", _detect_orig_size)
	else:
		print("No detect_area assigned!")

func update() -> void:
	type_label.text = "Type: " + type + "/" + type2
	title_label.text = title
	level_label.text = "Lvl. " + level

# ---------------------------
# Mouse events on detect_area
# ---------------------------

func _on_detect_area_mouse_entered() -> void:
	print("Mouse entered DetectArea")
	if _zoomed:
		return
	_zoomed = true
	_resize_detect_area_zoomed()
	_tween_zoom(true)

func _on_detect_area_mouse_exited() -> void:
	print("Mouse exited DetectArea")
	if not _zoomed:
		return
	_zoomed = false
	_restore_detect_area_original()
	_tween_zoom(false)

# ---------------------------
# Helpers
# ---------------------------

# Smoothly tween the card scale (no overlay)
func _tween_zoom(zoom_in: bool) -> void:
	if is_instance_valid(_tween):
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var target_scale := _orig_scale * (ZOOM_SCALE if zoom_in else 1.0)
	print("Tween to card scale=", target_scale)
	_tween.tween_property(card_pic, "scale", target_scale, TWEEN_TIME)

# Enlarge detect_area by scaling its size around its center (same center)
func _resize_detect_area_zoomed() -> void:
	if detect_area == null:
		return
	var center := _detect_orig_pos + _detect_orig_size * 0.5
	var extra := Vector2(DETECT_ZOOM_EXTRA_PX, DETECT_ZOOM_EXTRA_PX) * 2.0
	var zoom_size := _detect_orig_size * DETECT_ZOOM_MULT + extra
	var zoom_pos := center - zoom_size * 0.5
	detect_area.size = zoom_size
	detect_area.position = zoom_pos
	print("DetectArea zoomed. pos=", detect_area.position, " size=", detect_area.size)

# Restore detect_area to the exact rect it had in the editor
func _restore_detect_area_original() -> void:
	if detect_area == null:
		return
	detect_area.position = _detect_orig_pos
	detect_area.size = _detect_orig_size
	print("DetectArea restored. pos=", detect_area.position, " size=", detect_area.size)
