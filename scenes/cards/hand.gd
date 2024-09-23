@tool
extends CardContainer
class_name Hand;
@export var card_manager:CardManager;
@export var card_separation:float = 50;
@export var card_rotation_increment = 3;
@export var card_y_offset:float = 5;
var card_queue:Array[Card]
var all_cards_settled:bool = false;
@export var initial_hand_size = 5;
@export var card_line_color:Color = Color.RED:
	set(value):
		card_line_color = value;
		queue_redraw();

## this determines how far above the hand the card must be 
## until it's considered to be played
@export var card_y_max:float = 50 : 
	set(value): 
		card_y_max = value;
		queue_redraw();
@export var card_scale:float = 1;

## if a card is being hovered, how much of a y offset should it be given.
@export var card_hovered_y_offset:float = -20;
@export var card_selected_y_offset:float = -30
var card_being_dragged:Card;

var game_width = 1920

signal card_played(card:Card);
signal card_given(card:Card,container:CardContainer);

var card_being_played:Card = null;

var enabled:bool = true;

var in_selection_mode:bool = false;

var cards_selected:Array = [];

func _draw():
	if not Engine.is_editor_hint(): return
	var from = Vector2(-position.x, - card_y_max)
	var to = Vector2(game_width - position.x, - card_y_max)
	draw_line(from, to, card_line_color, 4)

func _process(delta):
	if not Engine.is_editor_hint():
		cards.sort_custom(func(a, b):
			return a.position.x < b.position.x;
		)
		
		card_being_played = null;
		
		for i in range(0, cards.size()):
			var card:Card = cards[i];
			if card_being_dragged and \
				card_being_dragged.position.y < \
				position.y - card_y_max:
				card_being_played = card_being_dragged;
			position_card(card, i, card_being_played != null);
	else:
		queue_redraw();

func position_card(card:Card, i:int, card_in_play:bool):
	card.z_index = z_index + i;
	if card in card_queue:
		if abs(card.position.y - position.y) < 1:
			card_queue.erase(card); 
	if card.state == Enums.CardState.IN_HAND or card.state == Enums.CardState.MOVING_TO_DEST:
		var card_is_hovered = false;
		
		if 	card_manager.cards_moused_over.size() > 0 \
		and card_manager.cards_moused_over[0] == card \
		and card_being_dragged == null:
			print("Card hovered");
			card_is_hovered = true;
	
		var y_offset = sin(Time.get_ticks_msec()/200 + i*150) * 5;
		if in_selection_mode:
			if card in cards_selected:
				y_offset = card_selected_y_offset;
			else:
				y_offset = 0;
		if card_is_hovered and not (card in cards_selected): 
			y_offset = card_hovered_y_offset;

		card.position.y = lerp(card.position.y, get_card_y(i) + y_offset, 0.15);
		

		var card_rot = get_card_rot(card, i);
		if in_selection_mode: 
			card_rot = 0.0;
		card.rotation_degrees = lerp(
			card.rotation_degrees, 
			card_rot, 
			0.1
		);
		if not card_in_play:
			card.position.x = lerp(card.position.x, get_card_x(card, i), 0.15);
		

func add_card(card:Card):
	card_queue.append(card);
	await get_tree().create_timer(0.1 * (card_queue.size()-1)).timeout;
	super.add_card(card);
	if card.face_down: card.flip(false);
	card.scale = Vector2(card_scale, card_scale);
	card.state = Enums.CardState.IN_HAND;
	card.is_dragging_enabled = true;
	card.connect("card_picked_up", _on_card_picked_up)
	card.connect("card_dropped", _on_card_dropped)

func _on_card_reached_dest(card:Card):
	if enabled:
		card.is_dragging_enabled = true;
	if card in card_queue:
		card_queue.erase(card);
	card.change_state(Enums.CardState.IN_HAND)

func _on_card_picked_up(card:Card):
	if not card in cards: return;
	card.rotation_degrees = 0;
	card_being_dragged = card;

func _on_card_dropped(card:Card):
	card_being_dragged = null;
	if card.position.y < position.y - card_y_max and card.can_be_played:
		emit_signal("card_played", card)
	else:
		var card_index = cards.find(card);
		var card_pos = Vector2(
			get_card_x(card, card_index),
			get_card_y(card_index)
		);
		card.change_state(Enums.CardState.IN_HAND)

func get_card_x(card:Card, index, hand_size_override = -1):
	var card_amt_ref = cards.size()
	if hand_size_override > 0: card_amt_ref = hand_size_override;
	var full_width = card_separation * (card_amt_ref-1);
	return game_width/2 + index * card_separation - full_width/2;

func get_card_rot(card:Card, index, hand_size_override = -1):
	var card_amt_ref = cards.size()
	if hand_size_override > 0: card_amt_ref = hand_size_override;
	var full_rot:float = card_rotation_increment * card_amt_ref-1;
	return -full_rot/2 + index * card_rotation_increment

func get_card_y(card_i, hand_size_override = -1):
	if in_selection_mode: return position.y;
	var card_amt_ref = cards.size()
	if hand_size_override > 0: card_amt_ref = hand_size_override;
	return remap (
		abs(card_i - card_amt_ref/2), \
		0, card_amt_ref, \
		position.y - card_y_offset, position.y \
	)

func give_card(card:Card, container:CardContainer):
	_remove_card(card)
	container.add_card(card);
	emit_signal("card_given", card, container);

# only do this if adding to another container.
func _remove_card(card:Card):
	print(cards.size());
	cards.erase(card);
	print(cards.size());

func set_enabled(enabled:bool):
	self.enabled = enabled;
	for card:Card in cards:
		card.is_dragging_enabled = enabled;
		if not enabled and card == card_being_dragged:
			card.change_state(Enums.CardState.IN_HAND);

func set_selection_mode_enabled(selection_enabled:bool):
	in_selection_mode = selection_enabled;
	if not in_selection_mode: cards_selected = [];
	for card in cards:
		if selection_enabled:
			card.connect("card_down", _on_card_selected)
		else:
			card.disconnect("card_down", _on_card_selected)
		card.is_dragging_enabled = not selection_enabled;
		if selection_enabled and card == card_being_dragged:
			card.change_state(Enums.CardState.IN_HAND);
func _on_card_selected(card:Card):
	if not in_selection_mode: return;
	if card in cards_selected:
		cards_selected.erase(card);
	else:
		cards_selected.append(card);
