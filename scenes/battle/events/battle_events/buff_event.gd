extends BattleEvent

func start():
	pass;
	#LogSignals.push_log.emit("%s gains %d %s points" % \
	#[
		#target.log_name, 
		#amt,
		#BattleUtil.buff_type_info[combat_type].name
	#])
	#await get_tree().create_timer(0.3).timeout;
	finished.emit();
	
