extends BattleEvent

func start():
	LogSignals.push_log.emit("%s heals %d points" % \
	[
		target.log_name, 
		amt
	])
	status_popups.stat_changed(amt, combat_type)
	await get_tree().create_timer(delay).timeout;
	finished.emit();
	
