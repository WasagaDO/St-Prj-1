extends Area2D
class_name CardDropArea
## Whether the card being dropped here can automatically be played
## (if this is set to false, you shoud listen to events from this node
## and determine whether the card can be played or not from elsewhere)
@export var let_card_be_played:bool = true;

var moused_over := false;
signal card_hovered_on(card:Card);
signal card_hovered_off(card:Card);
signal card_dropped(card:Card);

var card_being_hovered:Card;
func _ready():
	pass # Replace with function body.

func _on_area_entered(area):
	if area is Card:
		card_being_hovered = area;
		card_hovered_on.emit(area);

func _on_area_exited(area):
	if area == card_being_hovered:
		card_being_hovered = null;
		card_hovered_off.emit(area);

func _on_input_event(viewport, event, shape_idx):
	if not card_being_hovered: return
	if event is InputEventMouseButton:
		var mouse_btn_event = event as InputEventMouseButton
		if mouse_btn_event.is_released():
			card_dropped.emit(card_being_hovered)
