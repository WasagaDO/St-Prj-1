extends Resource
class_name CardData

enum CardType {
	ATTACK,
	DEFENSE,
	STATUS,
	REACTION,
}

enum Reaction {
	DODGE
}

@export_multiline var description:String
@export var name:String;
@export var image:Texture2D;
@export_range(0, 100) var stamina_cost:int;
@export var card_type:CardType;
@export_range(-2, 2) var speed:int = 0;


@export var damage:Array[ArmorData]

@export var armor:Array[ArmorData] = [];

## Dictionary from status effect to stacks
@export var status_effects:Array[StatusEffectData] = [];
## Actions that relate to the attack coming in, and can't be represented in data.
@export var special_reactions:Array[Reaction] = [];

@export var healing:int = 0;

## Restores balance points
@export var balance_healing:int = 0;



## In turns. Only relevant for enemy reactions.
@export var cooldown:int = 0;

@export var needs_target:bool = true;
