extends Resource
class_name SpecialCardEffect

# special effects of cards

@export var timing: Timing
@export var revert_on_end_of_turn: bool = false

enum Timing {
	ON_RESOLVE,
	NEVER
}

func execute(source: Combatant, target: Combatant):
	pass  # always overridden

func revert(source: Combatant, target: Combatant):
	pass # sometimes overridden
