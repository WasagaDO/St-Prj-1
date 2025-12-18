# res://comic/comic_image_view.gd
extends VBoxContainer
class_name ComicImageView

var _img := TextureRect.new()

func setup(data: ComicImage) -> void:
	add_child(_img)
	_img.texture = data.texture
	_img.expand_mode = TextureRect.EXPAND_FIT_WIDTH if data.expand else TextureRect.EXPAND_IGNORE_SIZE
	_img.stretch_mode = data.stretch_mode
	_img.custom_minimum_size = data.custom_min_size
	_img.size_flags_horizontal = Control.SIZE_EXPAND_FILL
