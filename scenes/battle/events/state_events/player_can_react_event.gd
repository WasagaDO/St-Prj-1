extends Event
var hand:Hand
var attack:CardData
var end_turn_button:Button
var darken_overlay:ColorRect
var attacker: Combatant
var reactor: Combatant


# expecting:
# - the hand of cards
# - the enemy's attack data
# - the end turn button
# - the darken color overlay
func initialize(data):
	hand = data.hand
	attack = data.attack
	end_turn_button = data.end_turn_button
	darken_overlay = data.darken_overlay
	attacker = data.attacker
	reactor  = data.reactor


func start():
	LogSignals.push_log.emit("Reactions available!");
	hand.set_enabled(true);
	var darken_tween = get_tree().create_tween()
	darken_tween.tween_property(darken_overlay, "modulate", Color(1, 1, 1, 0.3), 0.2);
	end_turn_button.disabled = false;
	end_turn_button.text = "No reactions"
	# disable all cards that aren't reactions
	for card in hand.cards:
		var reaction_card_data := card.data
		card.is_disabled = not BattleUtil.card_can_react(reaction_card_data, attack, reactor, attacker)

	await get_tree().create_timer(delay).timeout;
	finished.emit();
