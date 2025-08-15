extends EnemyCustomBehaviour
class_name BoostedAttacks

@export var bonus_amount: int = 5
@export var bonus_type: Combatant.DamageType = Combatant.DamageType.BALANCE

func execute(source:Combatant, target:Combatant) -> void:
	print("WARNING: boosted attack : no target")
	if target and target.hp > 0:
		target.apply_damage(source, bonus_amount, bonus_type)
