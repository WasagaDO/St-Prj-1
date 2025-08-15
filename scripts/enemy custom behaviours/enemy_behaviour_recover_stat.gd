extends EnemyCustomBehaviour
class_name RecoverStat

enum StatToRecover {
	HP,
	BALANCE
}

@export var stat: StatToRecover
@export var amount: int = 1

func execute(source: Combatant, target: Combatant):
	match stat:
		StatToRecover.HP:
			source.apply_healing(amount)
		StatToRecover.BALANCE:
			source.increment_balance(amount)
