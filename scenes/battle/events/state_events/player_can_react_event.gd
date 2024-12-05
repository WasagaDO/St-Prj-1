extends Event
var hand:Hand;
var attack:CardData;
var end_turn_button:Button;
func initialize(data):
	hand = data.hand;
	attack = data.attack;
	end_turn_button = data.end_turn_button;
func start():
	LogSignals.push_log.emit("Reactions available!");
	hand.set_enabled(true);
	end_turn_button.disabled = false;
	end_turn_button.text = "No reactions"
	# disable all cards that aren't reactions
	for card in hand.cards:
		if BattleUtil.card_can_react(card.data, attack):
			card.is_disabled = false;
		else:
			card.is_disabled = true;
	await get_tree().create_timer(0.1).timeout;
	finished.emit();
