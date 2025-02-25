extends Resource
class_name EnemyReactionData
enum CardOwner {
	SELF,
	OTHER_ENEMY,
	PLAYER
}
## What kind of card triggers this reaction.
@export var triggered_card_type:CardData.CardType
## Who needs to own the card to trigger this reaction.
@export var triggered_card_owner:CardOwner
## In turns.
@export var cooldown:int = 0;

## What card to perform with this reaction.
@export var card:CardData
