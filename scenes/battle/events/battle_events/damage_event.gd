extends BattleEvent

func start():
	LogSignals.push_log.emit("%s takes %d damage" % \
	[ 
		target.log_name, 
		amt
	])
	await get_tree().create_timer(0.3).timeout;
	finished.emit();
	
