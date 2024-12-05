extends Event

var endgame_overlay
var winner:Combatant
func initialize(data):
	endgame_overlay = data.endgame_overlay
	winner = data.winner;
func start():
	endgame_overlay.visible = true;
	var text = "You win!" if winner is Player else "You died!"
	endgame_overlay.get_node("Label").text = text;
	LogSignals.push_log.emit(text);
	finished.emit()
