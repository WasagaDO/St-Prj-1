extends Node2D
class_name CardContainer
# something to note about this class: 
# it does not hold the cards as children.
var cards:Array[Card] = []

var cards_are_interactive:bool = false;

func add_card(card:Card):
	card.is_disabled = not cards_are_interactive;
	cards.append(card);

func on_cards_initialized():
	return;

func find_card(card_data:CardData):
	for card in cards:
		if card.data == card_data:
			return card;
	return null;
