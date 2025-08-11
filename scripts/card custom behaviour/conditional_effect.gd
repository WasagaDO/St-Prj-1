extends Resource
class_name ConditionalEffect

@export var custom_logic_timing: CustomLogicTiming

enum CustomLogicTiming {
	ON_RESOLVE,
	NEVER
}


func execute(source: Combatant, target: Combatant):
	pass  # to override
