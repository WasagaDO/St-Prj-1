extends ConditionalEffect
class_name AgileManeuver



func execute(source: Combatant, target: Combatant):
	if source == null:
		push_warning("agile_maneuver : no source specified")
		return
	if source.last_card_played == null:
		print("agile_maneuver : no previous card played by the source")
		return
	source.increment_stamina(source.last_card_played.stamina_cost)
