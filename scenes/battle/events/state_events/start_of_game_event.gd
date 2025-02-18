extends Event

var state_overlay

func initialize(data):
	state_overlay = data.state_overlay
func start():
	state_overlay.visible = true;
	state_overlay.get_node("Label").text = "Battle start!"
	LogSignals.push_log.emit("Game started!");
	await get_tree().create_timer(1).timeout;
	state_overlay.visible = false;
	await get_tree().create_timer(delay).timeout;
	finished.emit()
