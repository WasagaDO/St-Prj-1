
extends Node2D

class_name CardManager;
# we're gonna generate this programmatically
var all_cards:Array[Card] = []
@export var card_scene:PackedScene;
@export var cards_base_layer:int = 100;
var decks:Array[Deck]
var cards_moused_over:Array[Card]

@onready var game_height = ProjectSettings.get_setting("display/window/size/viewport_height")

func register_card(card:Card):
	all_cards.append(card);
	card.connect("raw_pressed", _on_card_pressed)
		
func _process(_delta):
		# the idea here: we get all the cards moused over, sorted by
	# z index.
	cards_moused_over = [];

	for card in all_cards:
		# the hand object manages the cards z_index differently
		if card.state != Card.CardState.IN_HAND:
			# we do this because we want to be able to move the card in 0.5 increments,
			# but the z index is an integer
			card.z_index = remap(-card.position.y, 0, -game_height, game_height*2 + cards_base_layer, cards_base_layer)
		if card.state == Card.CardState.MOVING_TO_DEST:
			card.z_index += 100;
			
		if card.is_moused_over:
			cards_moused_over.append(card);
	
	cards_moused_over.sort_custom(func(a, b):
		return a.z_index > b.z_index
	)
func _on_card_pressed(card):
	if cards_moused_over.size() > 0 and card == cards_moused_over[0]:
		card.on_mouse_pressed();
