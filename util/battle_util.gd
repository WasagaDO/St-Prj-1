extends Node

# will throw in some useful info here.
var damage_type_info = {
	Combatant.DamageType.CRUSHING: {
		"name": "crushing"
	},
	Combatant.DamageType.PIERCING: {
		"name": "piercing"
	},
	Combatant.DamageType.CUTTING: {
		"name": "slashing"
	}
}


func card_can_react(reaction_card:CardData, attack_card:CardData):
	return 	reaction_card.card_type == CardData.CardType.REACTION and \
			attack_card.card_type == CardData.CardType.ATTACK and \
			reaction_card.speed >= attack_card.speed

func reverse_effect(effect:CardData):
	var reversed_effect:CardData = effect.duplicate(true);
	for armor in reversed_effect.armor:
		armor.amt *= -1;
	reversed_effect.healing *= -1;
	for damage in reversed_effect.damage:
		damage.amt *= -1;
	return reversed_effect
