extends ConditionalEffect
class_name DamageIfOpponentHasEffect

@export var armor_data: ArmorData
@export var required_status: String

func execute(source: Combatant, target: Combatant):
	if target.has_named_status(required_status):
		target.apply_damage(source, armor_data.damage_amount, armor_data.damage_type)
