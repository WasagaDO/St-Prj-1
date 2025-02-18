extends Resource
class_name DebuffData;
enum TriggerTime {
	START_TURN,
	END_TURN,
}
@export var type:Combatant.Debuff
@export var stacks:int;
@export var trigger_time:TriggerTime
