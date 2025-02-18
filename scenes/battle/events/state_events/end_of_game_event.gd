extends Event

var endgame_overlay
var winner:Combatant
var end_scene_path:String
func initialize(data):
	endgame_overlay = data.endgame_overlay
	winner = data.winner;
	end_scene_path = data.end_scene_path;
func start():
	endgame_overlay.visible = true;
	var text = "You win!" if winner is Player else "You died!"
	endgame_overlay.get_node("Label").text = text;
	LogSignals.push_log.emit(text);
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(end_scene_path);
	finished.emit()
