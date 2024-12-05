@tool
extends Button
@export var normal_label_settings:LabelSettings;
@export var highlighted_label_settings:LabelSettings;

@export var hover_lift_amount:float = 5;
@export var press_lower_amount:float = 5;

@export var display_text:String:
	set(new_text):
		display_text = new_text;
		$Label.text = new_text
		
@export var highlighted:bool = false:
	set(is_highlighted):
		highlighted = is_highlighted;
		$Label.label_settings = highlighted_label_settings if highlighted else normal_label_settings

var original_position:Vector2;
var dest_position:Vector2;
var moused_over:bool = false;
func _ready() -> void:
	if not Engine.is_editor_hint():
		await get_tree().process_frame;
		original_position = position;
		dest_position = position;
		

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		position = position.lerp(dest_position, 0.2);
		$Flash.color.a -= 0.07;

func _on_mouse_entered() -> void:
	dest_position = original_position + Vector2.UP * hover_lift_amount

func _on_mouse_exited() -> void:
	dest_position = original_position;


func _on_pressed() -> void:
	$Flash.color.a = 1;
	dest_position = original_position + Vector2.UP * hover_lift_amount
	position = original_position + Vector2.DOWN * press_lower_amount;
