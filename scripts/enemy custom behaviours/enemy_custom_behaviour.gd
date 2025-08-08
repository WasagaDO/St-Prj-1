extends Resource
class_name EnemyCustomBehaviour

enum Trigger {
	ONLY_ONCE_ON_BATTLE_START,
	ON_EACH_TURN_START,
	ON_EACH_TURN_END,
	ON_ATTACK_SUCCESS,
	ON_DAMAGE_TAKEN,
	NEVER
}

@export var trigger: Trigger

# function made to be overwritten by subclasses
func execute(enemy: Enemy):
	pass
