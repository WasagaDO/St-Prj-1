# res://comic/comic_player.gd
extends Control
class_name ComicPlayer

@export var sequence: ComicSequence

@export var content_padding: Vector2 = Vector2(24, 24)
@export var vertical_gap: float = 24.0
@export var auto_scroll: bool = true
@export var scroll_lerp: float = 0.25

var _scroll := ScrollContainer.new()
var _content := VBoxContainer.new()

class SeqState:
	var seq: ComicSequence
	var index: int
	func _init(s: ComicSequence, i := 0) -> void:
		seq = s
		index = i

func _ready() -> void:
	_build_ui()
	if sequence != null:
		await play(sequence)

func _build_ui() -> void:
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1

	add_child(_scroll)
	_scroll.anchor_left = 0
	_scroll.anchor_top = 0
	_scroll.anchor_right = 1
	_scroll.anchor_bottom = 1
	_scroll.offset_left = 0
	_scroll.offset_top = 0
	_scroll.offset_right = 0
	_scroll.offset_bottom = 0
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	_scroll.add_child(_content)
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_content.add_theme_constant_override("separation", int(vertical_gap))
	_content.position = content_padding

func clear() -> void:
	for c in _content.get_children():
		c.queue_free()

func play(root: ComicSequence) -> void:
	await _execute(root)

func _fade_in(ci: CanvasItem, duration: float) -> void:
	ci.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(ci, "modulate:a", 1.0, max(0.001, duration)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished

func _scroll_to_bottom() -> void:
	if not auto_scroll:
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var target = max(0, _scroll.get_v_scroll_bar().max_value)
	var t := create_tween()
	t.tween_property(_scroll, "scroll_vertical", target, max(0.001, scroll_lerp)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _execute(root: ComicSequence) -> void:
	var stack: Array[SeqState] = [SeqState.new(root, 0)]

	while stack.size() > 0:
		var state := stack[-1]

		if state.seq == null or state.index >= state.seq.frames.size():
			stack.pop_back()
			continue

		var frame := state.seq.frames[state.index]
		state.index += 1

		if frame is ComicImage:
			var view := ComicImageView.new()
			view.setup(frame)
			_content.add_child(view)

			await _fade_in(view, frame.fade_duration)
			_scroll_to_bottom()
			await get_tree().create_timer(frame.wait_after).timeout

		elif frame is ComicChoice:
			var viewc := ComicChoiceView.new()
			viewc.setup(frame)
			_content.add_child(viewc)

			await _fade_in(viewc, frame.fade_duration)
			_scroll_to_bottom()

			var picked := await _await_choice(viewc)
			await get_tree().create_timer(frame.wait_after).timeout

			if picked >= 0 and picked < frame.entries.size():
				var next_seq = frame.entries[picked].sequence
				if next_seq != null:
					stack.append(SeqState.new(next_seq, 0))

func _await_choice(view: ComicChoiceView) -> int:
	var result := -1
	var done := false

	var callback := func(i: int):
		if done:
			return
		done = true
		result = i
	view.choice_made.connect(callback)
	while not done:
		await get_tree().process_frame
	view.choice_made.disconnect(callback)
	return result
