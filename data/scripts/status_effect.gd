extends Resource
class_name StatusEffectData


enum Timing {
	ON_APPLIED, ## this status will do it's effect when it's applied.
	ON_WORN_OFF, ## this status will do it's effect when it wears off.
	WHILE_ACTIVE, ## this status will do it's effect when it's applied, and remove it when it wears off.
}


enum SpecialEffectBehaviour {
	NONE,
	FRACTURE,
	STUN,
	SHOCK,
	DISORIENTATION
}

enum ApplyTo {
	SELF,
	TARGET
}

@export var log_name:String;
@export var timing:Timing;
@export var special_effect_behaviour:SpecialEffectBehaviour;
@export var apply_to:ApplyTo;
@export var apply_only_if_unarmored:bool;
@export var effect:CardData;
