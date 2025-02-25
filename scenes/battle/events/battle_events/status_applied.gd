extends Event
var status:StatusEffectData
var target:Combatant;
func initialize(data):
	target = data.target;
	status = data.status;
func start():
	LogSignals.push_log.emit("%s gains 1 %s!" % \
	[ 
		target.log_name, 
		status.effect.name
	])
	await get_tree().create_timer(delay).timeout;
	finished.emit();
	
