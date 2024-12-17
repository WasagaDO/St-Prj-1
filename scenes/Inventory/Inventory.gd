extends Control

@onready var card_list: GridContainer = %CardList
@onready var description_card: TextureRect = %DescriptionCard
@onready var filter_buttons: VBoxContainer = $Panel/MarginContainer/Book/BookContent/HBoxContainer/FilterButtons
@onready var filter_buttons_2: HBoxContainer = $Panel/MarginContainer/Book/BookContent/MarginContainer/FilterButtons

func _ready() -> void:
	cards_scroll.max_value = scroll_container.get_child(0).size.y - scroll_container.size.y
	for card: Card in card_list.get_children():
		card.mouse_entered.connect(card_hover.bind(card))
		initial_card_order.append(card.duplicate())

func card_hover(card: Card):
	description_card.title = card.title
	description_card.type = card.get_type_string(card.type)
	description_card.type2 = card.get_secondary_type_string(card.type2)
	description_card.level = str(card.level)

var filtered_type: Card.Types = Card.Types.NONE
var filtered_secondary_type: Card.SecondaryTypes = Card.SecondaryTypes.NONE

var search_bar_text: String
func update_card_list() -> void:
	for card: Card in card_list.get_children():
		card.visible = (card.type == filtered_type or filtered_type == Card.Types.NONE) and ((search_bar_text.to_lower() in card.title.to_lower()) or search_bar_text == "") and (card.type2 == filtered_secondary_type or filtered_secondary_type == Card.SecondaryTypes.NONE)
		
	
const FILTER_NORMAL = preload("res://Inventory/Hero_s Table/Filter/FilterNormal.png")
const FILTER_SELECTED = preload("res://Inventory/Hero_s Table/Filter/FilterSelected.png")

func filter(type: String) -> void:
	# button "All" is type NONE 
	filtered_type = Card.new().get_string_type(type)
	update_card_list()
	for button: TextureButton in filter_buttons.get_children():
		button.texture_normal = FILTER_NORMAL
		button.get_node("MarginContainer/Label").set("theme_override_colors/font_color",Color.SADDLE_BROWN)
		if type != "NONE" and button.name == type:
			button.texture_normal = FILTER_SELECTED
			button.get_node("MarginContainer/Label").set("theme_override_colors/font_color",Color.WHITE)
		elif type == "NONE" and button.name == "All":
			button.texture_normal = FILTER_SELECTED
			button.get_node("MarginContainer/Label").set("theme_override_colors/font_color",Color.WHITE)

func secondary_filter(type: String) -> void:
	# button "All" is type NONE 
	filtered_secondary_type = Card.new().get_string_secondary_type(type)
	update_card_list()
	for button: TextureButton in filter_buttons_2.get_children():
		var filter_normal: Resource = load("res://Inventory/Hero_s Table/Bookmark/" + str(button.name) + "Normal.png")
		var filter_selected: Resource = load("res://Inventory/Hero_s Table/Bookmark/" + str(button.name) + "Selected.png")
		button.texture_normal = filter_normal
		button.z_index = 0
		if type != "NONE" and button.name.to_lower() == type.to_lower():
			button.texture_normal = filter_selected
			button.z_index = 1
		elif type == "NONE" and button.name == "All":
			button.texture_normal = filter_selected
			button.z_index = 1

func searched(new_text: String) -> void:
	search_bar_text = new_text
	update_card_list()

enum Sorts {
	ALPHABET,
	LVL,
	INITIAL_SORT
}

var initial_card_order: Array[Card]

func sort_pressed(sort: Sorts) -> void:
	match sort:
		Sorts.ALPHABET: # deletes all cards and make new ones ordered
			var card_names: Array[String] = []
			var cards: Array = card_list.get_children()
			for card: Card in card_list.get_children():
				card_names.append(card.title)
				card.queue_free()
			card_names.sort()
			for card_name: String in card_names:
				var card: Card = (func():
					for c: Card in cards:
						if c.title == card_name:
							return c.duplicate()).call()
				card_list.add_child(card)
				card.mouse_entered.connect(card_hover.bind(card))
		Sorts.LVL:
			var card_levels: Array[Array] = []
			var cards: Array = card_list.get_children()
			for card: Card in card_list.get_children():
				card_levels.append([card.level,card.title])
				card.queue_free()
			card_levels.sort_custom(func(a,b): return a[0] < b[0])
			for card_level: Array in card_levels:
				var card: Card = (func():
					for c: Card in cards:
						if c.title == card_level[1]:
							return c.duplicate()).call()
				card_list.add_child(card)
				card.mouse_entered.connect(card_hover.bind(card))
		Sorts.INITIAL_SORT:
			for card: Card in card_list.get_children():
				card.queue_free()
			for card: Card in initial_card_order:
				var card_: Card = card.duplicate()
				card_list.add_child(card_)
				card_.mouse_entered.connect(card_hover.bind(card_))
			update_card_list()

@onready var cards_scroll: VScrollBar = $Panel/MarginContainer/Book/BookContent/HBoxContainer/MarginContainer/HBoxContainer/Cardlist/MarginContainer/HBoxContainer/MarginContainer2/Control/TextureRect/MarginContainer/CardsScroll
@onready var scroll_container: ScrollContainer = $Panel/MarginContainer/Book/BookContent/HBoxContainer/MarginContainer/HBoxContainer/Cardlist/MarginContainer/HBoxContainer/VBoxContainer/ScrollContainer

func scroll(value: float) -> void:
	scroll_container.scroll_vertical = value

func _process(delta: float) -> void:
	cards_scroll.value = scroll_container.scroll_vertical

@onready var st_switchers: VBoxContainer = $Panel/MarginContainer/Book/BookContent/HBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/STSwitchers

func switch_tab(tab: String) -> void:
	for button: TextureButton in st_switchers.get_children():
		if button.name.to_lower() == tab:
			button.texture_normal = FILTER_SELECTED
			button.get_node("MarginContainer/Label").set("theme_override_colors/font_color",Color.WHITE)

		else:
			button.texture_normal = FILTER_NORMAL
			button.get_node("MarginContainer/Label").set("theme_override_colors/font_color",Color.SADDLE_BROWN)
	match tab:
		"info":
			%DescriptionTab.visible = true
			%PlayerDeckTab.visible = false
		"deck":
			%PlayerDeckTab.visible = true
			%DescriptionTab.visible = false
