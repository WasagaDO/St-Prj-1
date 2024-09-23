class_name CardData
extends Resource

enum CardType {
	ATTACK,
	DEFENSE,
	STATUS,
	REACTION
}

@export_multiline var description:String
@export var image:Texture2D;
@export_range(0, 100) var stamina_cost:int;
@export var card_type:CardType;
@export_range(-2, 2) var speed:int = 0;
