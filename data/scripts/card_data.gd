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

enum SpecialEffect {
	NONE,
	DOUBLE_STRIKE, # choose 2 attack cards to be played with a discount equal to the cheapest one
	INTERRUPT_ENEMY_MOVESET,
	FORCE_TRIGGER_ENEMY_REACTION,
	RESTORE_STAMINA_BY_PREVIOUS_CARD_COST, # restores stamina equal to the cost of your previous card
	DEAL_DAMAGE_TO_ALL_ENEMIES, # deals the damage of this card but to all enemies
	INCRAESE_SPEED_OF_NEXT_REACTION_BY_1,
	DOUBLE_DAMAGE_IF_ENEMY_HAS_STATUS_EFFECT,
	BLOCK_ALL_INCOMING_DAMAGE,
	# ... 
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
## Triggers a unique behaviour (coded in battle_manager.gd)
@export var special_effect: SpecialEffect = SpecialEffect.NONE



@export var healing:int = 0;

## Restores balance points
@export var balance_healing:int = 0;



## In turns. Only relevant for enemy reactions.
@export var cooldown:int = 0;

@export var needs_target:bool = true;
