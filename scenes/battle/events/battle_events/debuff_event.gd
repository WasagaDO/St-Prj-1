extends BattleEvent

func start():
	pass;
	#LogSignals.push_log.emit("%s gives %s %d %s points" % \
	#[
		#source.log_name,
		#target.log_name, 
		#amt,
		#BattleUtil.debuff_type_info[combat_type].name
	#])
	#await get_tree().create_timer(0.3).timeout;
	finished.emit();
	
