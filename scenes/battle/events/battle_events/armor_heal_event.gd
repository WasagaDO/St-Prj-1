extends BattleEvent

func start():
	LogSignals.push_log.emit("%s gained %d %s armor" % \
	[ 
		target.log_name, 
		amt, 
		BattleUtil.damage_type_info[combat_type].name,
	])
	await get_tree().create_timer(0.3).timeout;
	finished.emit();
