extends Resource
class_name StatusEffectData

# status effects' death are checked twice : at the start of the round and at the end.
# that way, effects like Active Defense that are applied to ourselves during a round
# can die at the end of the round. But other effects (poison, etc) usually
# die at the start of the round, after doing its effect.
# To make a self-effect only last until the end of this round (like Active Defense), 
# just set the duration to 0 and revert_on_end=true


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
@export var revert_on_end:bool = false;
@export var effect:CardData;
