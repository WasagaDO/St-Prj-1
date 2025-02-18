@tool
extends CardContainer
class_name Deck;

@export var card_manager:CardManager;
## Whether cards in this deck are face up or down by default.
@export var face_down:bool

## How each card in the deck is offset. 
## This is commonly used to create a stack of cards vertically,
## but they can be offset on the x axis as well.
@export var card_offset:Vector2 = Vector2(0, -0.5);

## This is so we can configure what cards a deck should contain.
@export var starting_cards:Array[CardSlot] = [];

## We are instantiating our starting cards ourselves, so we need this
@export var card_scene:PackedScene;

## (Optional) If this deck runs out of cards,
## it will take all the cards from this deck and shuffle.
@export var refill_deck:Deck

## Whether cards dealt to this deck move smoothly to their positions, 
## or snap directly to them.
@export var snap_cards_in_place:bool = false;

## This just determines what outline sprite will be displayed.
@export var is_pile:bool = false;

## If this is set to true, the cards dealt to this deck will be given
## a random rotation between 0 and the "Messy rotation offset"
@export var is_messy:bool = false:
	set(value):
		is_messy = value;
		notify_property_list_changed();

## The range of rotation cards in this deck will have.
## Only valid if "Is messy" is true.
@export var messy_rotation_offset = 30

## A convenience boolean for debugging only.
@export var enable_logging:bool = false;


var card_queue:Array[Card]
signal card_dealt(card:Card, location:CardContainer)
signal starting_cards_dealt(deck:Deck);
signal cards_settled(deck:Deck);
signal ran_out_of_cards(deck:Deck);
func _validate_property(property:Dictionary):
	if property.name in ["messy_rotation_offset"] and not is_messy:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _ready():
	if not Engine.is_editor_hint():
		$Deck_BG.visible = false;
	$Pile_Outline.visible = is_pile;
	
	if starting_cards.size() > 0 and not Engine.is_editor_hint():
		await get_tree().process_frame;
		# if we're generating our starting cards, no matter what we wanna snap them in place.
		snap_cards_in_place = true;
		for slot in starting_cards:
			for i in slot.copies:
				var new_card:Card = card_scene.instantiate();
				get_parent().add_child(new_card);
				new_card.setup(slot.card);
				if face_down: new_card.set_face_down(true);
				add_card(new_card);
				card_manager.register_card(new_card);
		snap_cards_in_place = false;
		cards.shuffle();
			
func add_card(card:Card):
	super.add_card(card);
	card_queue.append(card);
	if card.face_down != face_down: 
		card.flip(snap_cards_in_place);

	var dest_position = \
		global_position + (cards.size() * card_offset);
	if not snap_cards_in_place:
		await get_tree().create_timer(0.05 * card_queue.size()).timeout
	card.scale = scale;
	if is_messy:
		var rot = remap(randf(), 0, 1, -messy_rotation_offset, messy_rotation_offset);
		card.rotation_degrees = rot;
	else:
		card.set_sprite_rotation(0)
	# we connect this before setting the dest position
	# because if the card snaps, it triggers it IN the function
	card.connect("reached_destination", on_card_reached_dest)
	card.set_dest_position(dest_position, snap_cards_in_place);


func on_card_reached_dest(c:Card):
	card_queue.erase(c);
	var all_cards_at_rest:bool = true;
	for card in cards:
		if card.state == Card.CardState.MOVING_TO_DEST:
			all_cards_at_rest = false;
	if all_cards_at_rest:
		cards_settled.emit(self);

# only do this if adding to another container.
func _remove_card(card:Card):
	cards.erase(card);

func deal_to(amount:int, container:CardContainer):
	for i in range(0, amount):
		var top_card = cards.pop_back()
		deal_card(top_card, container)

func deal_card(card:Card, container:CardContainer):
	if cards.size() == 1:
		ran_out_of_cards.emit(self);
		if refill_deck:
			await refill_deck.deal_to(refill_deck.cards.size(), self);
			await get_tree().create_timer(0.5).timeout;
	_remove_card(card)
	container.add_card(card);
	card_dealt.emit(card, container);
	
