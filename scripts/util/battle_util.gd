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
	},
	Combatant.DamageType.BALANCE: {
		"name": "balance"
	},
	Combatant.DamageType.PURE: {
		"name": "pure"
	}
}

# undoes a card's effect on a combatant
# DEPRECATED : it doesn't seem to actually do a deep copy.
# You can use apply_status_effect_reversed() instead
# func reverse_effect(effect:CardData) -> CardData: 
#	# /!\
#	var reversed_effect:CardData = effect.duplicate(true);
#	# /!\
#
#	reversed_effect.name = "REVERSED " + effect.name
#	for armor in reversed_effect.armor:
#		armor.amt *= -1;
#	reversed_effect.healing *= -1;
#	for damage in reversed_effect.damage:
#		damage.amt *= -1;
#	return reversed_effect


# Returns true if the reaction card can be played as a reaction to the attack card.
# DEPRECATED. Doesn't check speed modifiers on combatants.
'''
func card_can_react(reaction_card:CardData, attack_card:CardData):
	return 	reaction_card.card_type == CardData.CardType.REACTION and \
			attack_card.card_type == CardData.CardType.ATTACK and \
			reaction_card.speed >= attack_card.speed'''


# Returns true if the reaction card can be played as a reaction to the attack card.
func card_can_react(reaction_card: CardData, attack_card: CardData, target: Combatant, source: Combatant) -> bool:
	# 1) Must be a valid counter
	if not (reaction_card.card_type == CardData.CardType.REACTION and \
			attack_card.card_type == CardData.CardType.ATTACK):
		# reaction_card is not a reaction or attack_card is not an attack
		return false

	# 2) Speed gate: reactor must be fast enough
	#    - source: attacker playing attack_card
	#    - target: reactor playing reaction_card
	var attack_speed := source.get_own_effective_speed_for(attack_card, false)
	var react_speed  := target.get_own_effective_speed_for(reaction_card, true)
	var result : bool = (react_speed >= attack_speed)
	# Rule: reaction must be at least as fast as the attack
	return result
