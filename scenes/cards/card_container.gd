extends Node2D
class_name CardContainer
# something to note about this class: 
# it does not hold the cards as children.
var cards:Array[Card] = []

func add_card(card:Card):
	cards.append(card);
func on_cards_initialized():
	return;
