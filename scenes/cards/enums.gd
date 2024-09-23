extends Node


enum CardState {
	MOVING_TO_DEST,
	BEING_DRAGGED,
	IN_HAND,
	# for when we're settled into a deck
	AT_REST,
	# for when we want to manage its behaviour from somewhere else
	CUSTOM
}
