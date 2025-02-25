extends Event

var acting_combatant:Combatant;
func initialize(data):
	acting_combatant = data.acting_combatant;
func start():
	# do any end of turn stuff here
	await get_tree().create_timer(delay).timeout;
	finished.emit();
	
