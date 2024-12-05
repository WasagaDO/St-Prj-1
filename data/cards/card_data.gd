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

@export var buffs:Array[BuffData] = [];

@export var debuffs:Array[DebuffData] = [];

## Actions that relate to the attack coming in, and can't be represented in data.
@export var special_reactions:Array[Reaction] = [];

@export var healing:int;

## In turns. Only relevant for enemy reactions.
@export var cooldown:int = 0;
