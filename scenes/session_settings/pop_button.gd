extends TextureButton

var original_scale:Vector2;
var dest_scale:Vector2;

func _ready() -> void:
	original_scale = scale;
	dest_scale = scale;
	pressed.connect(_on_pressed);
	mouse_entered.connect(_on_mouse_entered);
	mouse_exited.connect(_on_mouse_exited);
	
func _process(delta: float) -> void:
	scale = scale.lerp(dest_scale, 0.2);
	$Flash.color.a -= 0.075;

func _on_mouse_entered() -> void:
	dest_scale = Vector2.ONE * 1.1;
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	dest_scale = original_scale;
	pass # Replace with function body.


func _on_pressed() -> void:
	scale = Vector2.ONE * 0.7;
	$Flash.color.a = 1;
	dest_scale = original_scale;
