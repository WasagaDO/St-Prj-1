extends EnemyCustomBehaviour
class_name RecoverStat

enum StatToRecover {
	HP,
	BALANCE
}

@export var stat: StatToRecover
@export var amount: int = 1

func execute(enemy: Enemy):
	match stat:
		StatToRecover.HP:
			enemy.apply_healing(amount)
		StatToRecover.BALANCE:
			enemy.restore_balance(amount)
