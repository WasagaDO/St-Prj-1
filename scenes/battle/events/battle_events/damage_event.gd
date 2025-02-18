extends BattleEvent

func start():
	var damage_animation: CombatantAnimator = CombatantAnimator.new()
	target.add_child(damage_animation)
	damage_animation.combatant_damaged(target)
	LogSignals.push_log.emit("%s takes %d damage" % \
	[ 
		target.log_name, 
		amt
	])
	status_popups.stat_changed(-amt, combat_type)
	await get_tree().create_timer(delay).timeout;
	finished.emit();
	
