extends Resource
class_name StatusEffectData
enum Timing {
	ON_APPLIED, ## this status will do it's effect when it's applied.
	ON_WORN_OFF, ## this status will do it's effect when it wears off.
	WHILE_ACTIVE, ## this status will do it's effect when it's applied, and remove it when it wears off.
}
@export var log_name:String;
@export var timing:Timing;
@export var effect:CardData;
