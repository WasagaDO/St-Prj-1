extends Label

var life_counter = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func trigger(new_text:String):
	life_counter = 1;
	text = new_text;

func _process(delta: float) -> void:
	life_counter -= delta;
	visible = life_counter > 0;


func _on_protagonist_not_enough_stamina() -> void:
	trigger("Out of stamina!");
