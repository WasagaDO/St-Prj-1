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

# store any info you need to access about debuffs hered
var debuff_type_info = {
	
}

# store any info you need to access about buffs here
var buff_type_info = {
	
}

func card_can_react(reaction_card:CardData, attack_card:CardData):
	return 	reaction_card.card_type == CardData.CardType.REACTION and \
			attack_card.card_type == CardData.CardType.ATTACK and \
			reaction_card.speed >= attack_card.speed
