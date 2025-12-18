# res://comic/resources/comic_image.gd
extends ComicFrame
class_name ComicImage

@export var texture: Texture2D
@export var expand: bool = true
@export var stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
@export var custom_min_size: Vector2 = Vector2(0, 420)
