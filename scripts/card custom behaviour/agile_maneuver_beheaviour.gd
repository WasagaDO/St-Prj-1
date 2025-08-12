extends SpecialCardEffect
class_name AgileManeuver

# behaviour for the Agile Maneuver card :
# add stamina to the combatant equal to the stamina cost of the last card played.
# if the last card played has a cost of zero (example : reactions), we add 0 stamina.

func execute(source: Combatant, target: Combatant):
	if source == null:
		push_warning("agile_maneuver : no source specified")
		return
	if source.last_card_played == null:
		print("agile_maneuver : no previous card played by the source")
		return
	var amt = source.last_card_played.stamina_cost
	print("agile maneuver : last card played is ", source.last_card_played.name, ", restoring stamina by ", amt)
	if source is Player:
		source.add_stamina(amt);






# hey, if you read this comment i wish you a nice day :)
