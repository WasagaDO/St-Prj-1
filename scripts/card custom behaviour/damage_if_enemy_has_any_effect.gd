extends ConditionalEffect
class_name DamageIfEnemyHasAnyEffect

@export var damage:Array[ArmorData] = [];

func execute(source: Combatant, target: Combatant):
	if target.has_status_effect():
		for d in damage:
			if d.amt > 0:
				target.apply_damage(source, d.amt, d.type)
