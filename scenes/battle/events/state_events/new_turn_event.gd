extends Event

var acting_combatant:Combatant;
var hand:Hand
var deck:Deck;
var end_turn_button:Button;
func initialize(data):
	acting_combatant = data.acting_combatant;
	hand = data.hand;
	deck = data.deck;
	end_turn_button = data.end_turn_button;
func start():
	LogSignals.push_log.emit("%s's turn!" % acting_combatant.log_name);
	end_turn_button.text = "End turn"
	end_turn_button.disabled = not acting_combatant is Player;
	hand.set_enabled(acting_combatant is Player);
	if acting_combatant is Player:
		acting_combatant.recover_stamina(2);
		deck.deal_to(BattleOptions.hand_size-hand.cards.size(), hand);
		
		# we literally just dealt cards to them up to their hand size
		# so if they're not there, they're on the way and we shld wait
		if hand.cards.size() < BattleOptions.hand_size: await hand.cards_settled
		
		for card in hand.cards:
			card.is_disabled = card.data.card_type == CardData.CardType.REACTION
	else:
		acting_combatant.act();

	
	await get_tree().create_timer(0.3).timeout;
	finished.emit();
	
