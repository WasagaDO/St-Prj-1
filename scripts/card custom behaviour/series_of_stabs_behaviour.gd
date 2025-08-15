extends SpecialCardEffect
class_name SeriesOfStab

# boosts the next "gladiator's stab" attack by 3


func execute(source: Combatant, target: Combatant):
	source.did_play_series_of_stabs = true
