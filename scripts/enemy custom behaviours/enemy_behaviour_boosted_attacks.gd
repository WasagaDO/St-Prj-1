extends EnemyCustomBehaviour
class_name BoostedAttacks

@export var bonus_amount: int = 5
@export var bonus_type: Combatant.DamageType = Combatant.DamageType.BALANCE

func execute(enemy: Enemy) -> void:
	if not enemy.is_inside_tree(): return
	if not enemy.battle_manager: return
	var target: Combatant = enemy.battle_manager.player

	if target and target.hp > 0:
		target.apply_damage(enemy, bonus_amount, bonus_type)
