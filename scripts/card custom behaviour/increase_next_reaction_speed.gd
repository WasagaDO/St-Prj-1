extends SpecialCardEffect
class_name IncreaseNextReactionSpeed

@export var amount: int = 1

func execute(source: Combatant, target: Combatant):
	source.next_reaction_speed_boost += amount
	print("[SPEED] %s gains +%d next reaction speed (now %d)" % [
		source.log_name, amount, source.next_reaction_speed_boost
	])
