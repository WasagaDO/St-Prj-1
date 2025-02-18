extends TextureRect
class_name Bar
@export var icon:Texture
@export var maximum:int = 100:
	get:
		return maximum;
	set(new_maximum):
		maximum = new_maximum;
		var sm = material as ShaderMaterial;
		sm.set_shader_parameter("fill_amt", remap(value, 0, maximum, 0, 1))
@export var value:int = 0: 
	get:
		return value;
	set(new_value):
		value = new_value;
		if new_value > maximum: value = maximum;
		if new_value < 0: value = 0;
		var sm = material as ShaderMaterial;
		sm.set_shader_parameter("fill_amt", remap(value, 0, maximum, 0, 1))

func _ready() -> void:
	$Info/Icon.texture = icon;

func _on_mouse_entered() -> void:
	$Info.visible = true;
	$Info/Label.text = "%d / %d" % [value, maximum]


func _on_mouse_exited() -> void:
	$Info.visible = false;
