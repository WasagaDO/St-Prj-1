extends Resource
class_name StatusEffectData


enum Timing {
	ON_APPLIED,                ## Apply immediately on application, do not store.
	ON_WORN_OFF,               ## Apply only when remaining reaches 0, then remove.
	WHILE_ACTIVE,              ## At start of each owner's turn, apply; then decrement; no reverse.
}


enum ApplyTo {
	SELF,
	TARGET
}

@export var log_name:String;
@export var timing:Timing;
@export var apply_to:ApplyTo;
@export var apply_only_if_unarmored:bool;
@export var duration:int=100000;
@export var effect:CardData;
