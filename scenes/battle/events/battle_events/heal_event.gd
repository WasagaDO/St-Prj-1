extends BattleEvent

func start():
	LogSignals.push_log.emit("%s heals %d points" % \
	[
		target.log_name, 
		amt
	])
	await get_tree().create_timer(0.3).timeout;
	finished.emit();
	
