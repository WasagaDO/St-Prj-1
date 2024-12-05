# This class is essentially the frontend for the system.  It handles displaying
# anything the player needs to see, and managing interaction states.
extends Node
class_name Events

# this represents anything that can happen in-game that the player
# should be informed about in some way.
enum EventType {
	
	DAMAGE,
	HEALING,
	ARMOR_DAMAGE,
	ARMOR_HEALING,
	DEBUFF,
	BUFF,
	CARD_PLAYED,
	ENEMY_MOVE_PLAYED,
	NEW_TURN,
	PLAYER_CAN_REACT,
	ATTACK_DODGED,
	END_OF_GAME,
	START_OF_GAME
}


@export var hand:Hand;
@export var deck:Deck;
@export var discard_pile:Deck;
@export var state_overlay:Control;
@export var event_handlers:Array[PackedScene] = [];
@export var end_turn_button:Button;
var event_map:Dictionary = {};

var event_queue:Array[Event] = [];

var current_event:Event
func _ready() -> void:
	for handler in event_handlers:
		var temp_event = handler.instantiate();
		event_map[temp_event.event_type] = handler;
		temp_event.queue_free();
	
	BattleSignals.start_game.connect(func():
		push_event(EventType.START_OF_GAME, {"state_overlay": state_overlay})	
	)
	BattleSignals.damage_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.DAMAGE, src,trgt,amt,type)
	)
	BattleSignals.healing_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.HEALING, src,trgt,amt,type)
	)
	BattleSignals.armor_damage_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.ARMOR_DAMAGE, src,trgt,amt,type)
	)
	BattleSignals.armor_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.ARMOR_HEALING, src,trgt,amt,type)
	)
	BattleSignals.debuff_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.DEBUFF, src,trgt,amt,type)
	)
	BattleSignals.buff_applied.connect(func(src, trgt, amt, type): 
		push_battle_event(EventType.BUFF, src,trgt,amt,type)
	)
	
	BattleSignals.new_turn.connect(func(acting_combatant): 
		push_event(EventType.NEW_TURN, {
			"acting_combatant": acting_combatant, 
			"hand": hand, 
			"deck": deck,
			"end_turn_button": end_turn_button
		})
	)
	
	BattleSignals.card_played.connect(func(source, target, card): 
		push_event(EventType.CARD_PLAYED, {
			"card": card, 
			"source": source, 
			"target": target,
			"hand": hand,
			"discard_pile": discard_pile
		})
	)
	
	BattleSignals.enemy_move_played.connect(func(source, target, move):
		push_event(EventType.ENEMY_MOVE_PLAYED, {
			"move": move,
			"source": source,
			"target": target
		})
	)
	
	BattleSignals.player_can_react.connect(func(attack:CardData):
		push_event(EventType.PLAYER_CAN_REACT, {
			"attack": attack,
			"hand": hand,
			"end_turn_button": end_turn_button
		});	
	)
	
	BattleSignals.attack_dodged.connect(func(attack_target, attack_source, attack):
		push_event(EventType.ATTACK_DODGED, {
			"reactor": attack_source
		})
	)
	
	BattleSignals.game_over.connect(func(winner):
		push_event(EventType.END_OF_GAME, {
			"winner": winner,
			"endgame_overlay": state_overlay
		})
	)
	
func push_battle_event(event_type, source, target, amt, type):
	push_event(event_type, {
		"source": source,
		"target": target,
		"amt": amt,
		"type": type
	})
	
func push_event(event_type:EventType, data):
	if not event_map.has(event_type): return;
	
	var new_event = event_map[event_type].instantiate();
	add_child(new_event)

	# let's wait til the event has access to the tree
	await get_tree().process_frame;
	
	new_event.initialize(data);
	queue_event(new_event);
	
# by this point, the event is initialized with its data
# and its ready to go.
func queue_event(event:Event):
	event.finished.connect(serve_next_event);
	event_queue.push_back(event);
	
	# if we're not serving an event, serve this one.
	if not is_instance_valid(current_event):
		serve_next_event();

func serve_next_event():
	
	# the current event is finished, so we can remove it.
	if is_instance_valid(current_event): current_event.queue_free();
	
	if event_queue.size() == 0: return;
	current_event = event_queue.pop_front()
	current_event.start();
