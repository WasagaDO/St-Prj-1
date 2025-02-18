extends Event

var move:CardData;
var source:Combatant;
var target:Combatant;
func initialize(data):
	move = data.move;
	source = data.source;
	target = data.target;
func start():
	var action_text = "reacted with" if move.card_type == CardData.CardType.REACTION else "played"
	LogSignals.push_log.emit("%s %s %s!" % [source.log_name, action_text, move.name]);
	await get_tree().create_timer(delay).timeout;
	finished.emit()
