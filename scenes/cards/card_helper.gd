extends Node

func find_card(card_to_find:CardData, list:Array[Card]):
	for card in list:
		if 	card.face == card_to_find.face and \
			card.suit == card_to_find.suit and \
			card.number == card_to_find.number:
			return card;
	return null;
	
# keeping this loosey goosey so we can pass in the data 
# or the card itself
func print_card(card):
	var string = "______"
	string += "\nFace: " + Enums.Face.find_key(card.face);
	string += "\nSuit: " + Enums.Suit.find_key(card.suit);
	string += "\nNumber: " + str(card.number)
	string += "\n______"
	print(string);
