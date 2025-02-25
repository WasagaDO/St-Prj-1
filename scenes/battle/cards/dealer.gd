extends Node2D
class_name Dealer;
	
	
@export var hand:Hand;
@export var deck:Deck;

var card_weights:Dictionary;

var dealt_opening_hand:bool = false;

func _ready() -> void:
	await get_tree().process_frame
	for card in deck.cards:
		card_weights[card] = 1;
	deck.card_dealt.connect(_on_card_dealt)
func _on_card_dealt(card:Card, location:CardContainer):
	# this card isn't in the deck any more, so remove it from weights
	card_weights.erase(card);
	
	for other_card in deck.cards:
		if other_card.data != card.data:
			card_weights[other_card] += 0.25;
		else:
			card_weights[other_card] = 1;
func deal_cards(amt:int):
	# if this is our first hand, throw a reaction card in there.
	if not dealt_opening_hand:
		
		dealt_opening_hand = true;
		var reaction_cards:Array[Card]
		for card:Card in deck.cards:
			if card.data.card_type == CardData.CardType.REACTION:
				reaction_cards.append(card);
		deck.deal_card(reaction_cards.pick_random(), hand);
		# we just dealt a card, so reduce the amt we deal
		amt -= 1;
	for i in range(0, amt):
		deal_random_card()
	
func deal_random_card():
	deck.deal_card(pick_weighted(), hand);
func pick_weighted() -> Card:
	# Reset total_weight to make sure it holds the correct value after initialization
	var total_weight = 0.0
	var acc_weights:Array = [];
	# Iterate through the objects
	for weight in card_weights.values():
		# Take current object weight and accumulate it
		total_weight += weight
		# Take current sum and assign to the object.
		acc_weights.append(total_weight)
	# Roll the number
	var roll: float = randf_range(0.0, total_weight)
	# Now search for the first with acc_weight > roll
	for i in range(0, acc_weights.size()):
		if (acc_weights[i] > roll):
			return card_weights.keys()[i]

	# If here, something weird happened, but the function has to return a dictionary.
	printerr("Dealer's weighted pick went wrong");
	return null;
