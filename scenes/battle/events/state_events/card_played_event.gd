extends Event

var card:Card;
var source:Combatant;
var target:Combatant;
var hand:Hand;
var discard_pile:Deck;
func initialize(data):
	hand = data.hand;
	discard_pile = data.discard_pile
	card = data.card;
	source = data.source;
	target = data.target;
func start():
	if source is Player:
		hand.give_card(card, discard_pile);
	var action_text = "reacted with" if card.data.card_type == CardData.CardType.REACTION else "played"
	LogSignals.push_log.emit("%s %s %s!" % [source.log_name, action_text, card.data.name]);
	await get_tree().create_timer(0.2).timeout;
	finished.emit()
