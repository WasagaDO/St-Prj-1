extends ReactEvent

func start():
	LogSignals.push_log.emit("%s dodged attack!" % reactor.log_name);
	await get_tree().create_timer(delay).timeout;
	finished.emit();
