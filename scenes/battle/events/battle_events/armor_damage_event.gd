extends BattleEvent

func start():
	LogSignals.push_log.emit("%s blocked %d %s damage" % \
	[ 
		target.log_name, 
		amt, 
		BattleUtil.damage_type_info[combat_type].name,
	])
	status_popups.stat_changed(-amt, combat_type)
	await get_tree().create_timer(delay).timeout;
	finished.emit();
