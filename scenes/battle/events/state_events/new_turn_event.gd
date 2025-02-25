extends Event

var acting_combatant:Combatant;
var dealer:Dealer
var hand:Hand
var end_turn_button:Button;
func initialize(data):
	acting_combatant = data.acting_combatant;
	dealer = data.dealer;
	hand = data.hand;
	end_turn_button = data.end_turn_button;
func start():
	LogSignals.push_log.emit("%s's turn!" % acting_combatant.log_name);
	end_turn_button.text = "End turn"
	end_turn_button.disabled = not acting_combatant is Player;
	hand.set_enabled(acting_combatant is Player);
	if acting_combatant is Player:

		acting_combatant.add_stamina(2);
		dealer.deal_cards(BattleSettings.hand_size-hand.cards.size());
		
		# we literally just dealt cards to them up to their hand size
		# so if they're not there, they're on the way and we shld wait
		if hand.cards.size() < BattleSettings.hand_size: await hand.cards_settled
		
		for card in hand.cards:
			card.is_disabled = card.data.card_type == CardData.CardType.REACTION

	acting_combatant.apply_status_effects();
	await get_tree().create_timer(delay).timeout;
	finished.emit();
	
