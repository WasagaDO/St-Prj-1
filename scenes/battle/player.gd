extends Combatant
class_name Player;

signal not_enough_stamina
func _ready() -> void:
	super._ready();
	initialize_bars();

func recover_stamina(amt:int):
	bars.stamina_bar.value += amt;

func _on_hand_card_played(card: Card, target) -> void:
	bars.stamina_bar.value -= card.data.stamina_cost;


func _on_hand_card_can_be_played(card: Card) -> void:
	if card.data.stamina_cost > bars.stamina_bar.value:
		not_enough_stamina.emit();
		card.state = Card.CardState.IN_HAND
