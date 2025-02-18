class_name Player;
extends Combatant

signal not_enough_stamina

@export var hand:Hand
func _ready() -> void:
	super._ready();
	initialize_bars();
	hand.card_can_be_played.connect(_on_hand_card_can_be_played)
func add_stamina(amt:int):
	bars.stamina_bar.value += amt;
func _on_hand_card_played(card: Card, target) -> void:
	bars.stamina_bar.value -= card.data.stamina_cost;


func _on_hand_card_can_be_played(card: Card) -> void:
	if card.data.stamina_cost > bars.stamina_bar.value:
		not_enough_stamina.emit();
		card.state = Card.CardState.IN_HAND
