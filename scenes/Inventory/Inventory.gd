extends Control

# these will also be used from another script
#@onready var back_button: TextureButton = $Panel/BackButton/Pivot/BackButton
#@onready var menu_button: TextureButton = $Panel/MenuButton/Pivot/MenuButton

@onready var card_list: GridContainer = %CardList
@onready var description_card: TextureRect = %DescriptionCard
#@onready var filter_buttons: VBoxContainer = $Panel/MarginContainer/Book/BookContent/HBoxContainer/FilterButtons
#@onready var filter_buttons_2: HBoxContainer = $Panel/MarginContainer/Book/BookContent/MarginContainer/FilterButtons
#@onready var cards_scroll: VScrollBar = $Panel/MarginContainer/Book/BookContent/HBoxContainer/MarginContainer/HBoxContainer/Cardlist/MarginContainer/HBoxContainer/MarginContainer2/Control/TextureRect/MarginContainer/CardsScroll
#@onready var scroll_container: ScrollContainer = $Panel/MarginContainer/Book/BookContent/HBoxContainer/MarginContainer/HBoxContainer/Cardlist/MarginContainer/HBoxContainer/VBoxContainer/ScrollContainer
#@onready var st_switchers: VBoxContainer = $Panel/MarginContainer/Book/BookContent/PAGE_1_CARDS/MarginContainer/HBoxContainer/MarginContainer2/STSwitchers


# exporting those variables is a better practice than name referencing for scalability
@export var back_button: TextureButton
@export var menu_button: TextureButton
@export var filter_buttons: VBoxContainer
@export var filter_buttons_2: HBoxContainer
@export var cards_scroll: VScrollBar
@export var scroll_container: ScrollContainer
@export var st_switchers: VBoxContainer



func _ready() -> void:
	# show page 1
	switch_tab(1)
	#
	cards_scroll.max_value = scroll_container.get_child(0).size.y - scroll_container.size.y
	back_button.mouse_entered.connect(nav_buttons_hover.bind("BackButton","entered"))
	back_button.mouse_exited.connect(nav_buttons_hover.bind("BackButton","exited"))
	menu_button.mouse_entered.connect(nav_buttons_hover.bind("MenuButton","entered"))
	menu_button.mouse_exited.connect(nav_buttons_hover.bind("MenuButton","exited"))
	for card: InventoryCard in card_list.get_children():
		card.mouse_entered.connect(card_hover.bind(card))
		initial_card_order.append(card.duplicate())

func card_hover(card: InventoryCard):
	description_card.title = card.title
	description_card.card_pic.texture = card.get_node("CardPic").texture

	print("card.texture:", card.get_node("CardPic").texture)
	description_card.type = card.get_type_string(card.type)
	description_card.type2 = card.get_secondary_type_string(card.type2)
	description_card.level = str(card.level)
	description_card.update()



var filtered_type: InventoryCard.Types = InventoryCard.Types.NONE
var filtered_secondary_type: InventoryCard.SecondaryTypes = InventoryCard.SecondaryTypes.NONE

var search_bar_text: String
func update_card_list() -> void:
	for card: InventoryCard in card_list.get_children():
		card.visible = (card.type == filtered_type or filtered_type == InventoryCard.Types.NONE) and ((search_bar_text.to_lower() in card.title.to_lower()) or search_bar_text == "") and (card.type2 == filtered_secondary_type or filtered_secondary_type == InventoryCard.SecondaryTypes.NONE)
		
	
const FILTER_NORMAL = preload("res://scenes/Inventory/Hero_s Table/Filter/FilterNormal.png")
const FILTER_SELECTED = preload("res://scenes/Inventory/Hero_s Table/Filter/FilterSelected.png")

func filter(type: String) -> void:
	# button "All" is type NONE 
	filtered_type = InventoryCard.new().get_string_type(type)
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
	filtered_secondary_type = InventoryCard.new().get_string_secondary_type(type)
	update_card_list()
	for button: TextureButton in filter_buttons_2.get_children():
		var filter_normal: Resource = load("res://scenes/Inventory/Hero_s Table/Bookmark/" + str(button.name) + "Normal.png")
		var filter_selected: Resource = load("res://scenes/Inventory/Hero_s Table/Bookmark/" + str(button.name) + "Selected.png")
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

var initial_card_order: Array[InventoryCard]

func sort_pressed(sort: Sorts) -> void:
	match sort:
		Sorts.ALPHABET: # deletes all cards and make new ones ordered
			var card_names: Array[String] = []
			var cards: Array = card_list.get_children()
			for card: InventoryCard in card_list.get_children():
				card_names.append(card.title)
				card.queue_free()
			card_names.sort()
			for card_name: String in card_names:
				var card: InventoryCard = (func():
					for c: InventoryCard in cards:
						if c.title == card_name:
							return c.duplicate()).call()
				card_list.add_child(card)
				card.mouse_entered.connect(card_hover.bind(card))
		Sorts.LVL:
			var card_levels: Array[Array] = []
			var cards: Array = card_list.get_children()
			for card: InventoryCard in card_list.get_children():
				card_levels.append([card.level,card.title])
				card.queue_free()
			card_levels.sort_custom(func(a,b): return a[0] < b[0])
			for card_level: Array in card_levels:
				var card: InventoryCard = (func():
					for c: InventoryCard in cards:
						if c.title == card_level[1]:
							return c.duplicate()).call()
				card_list.add_child(card)
				card.mouse_entered.connect(card_hover.bind(card))
		Sorts.INITIAL_SORT:
			for card: InventoryCard in card_list.get_children():
				card.queue_free()
			for card: InventoryCard in initial_card_order:
				var card_: InventoryCard = card.duplicate()
				card_list.add_child(card_)
				card_.mouse_entered.connect(card_hover.bind(card_))
			update_card_list()




func scroll(value: float) -> void:
	scroll_container.scroll_vertical = value

func scroll_2(value:float) -> void:
	pass

func scroll_3(value:float) -> void:
	pass

func _process(delta: float) -> void:
	cards_scroll.value = scroll_container.scroll_vertical


@export var page1: Control
@export var page2: Control
@export var page3: Control

# Tabs Buttons
@export var page1_button: TextureButton
@export var page2_button: TextureButton
@export var page3_button: TextureButton

# Textures for normal/selected state of tabs buttons
@export var page1_normal: Texture2D
@export var page1_selected: Texture2D
@export var page2_normal: Texture2D
@export var page2_selected: Texture2D
@export var page3_normal: Texture2D
@export var page3_selected: Texture2D

func switch_tab(tab_index: int) -> void:
	# Hide all pages
	if page1: page1.visible = false
	if page2: page2.visible = false
	if page3: page3.visible = false

	# Reset all button visuals
	if page1_button:
		page1_button.texture_normal = page1_normal
		page1_button.z_index = 0
	if page2_button:
		page2_button.texture_normal = page2_normal
		page2_button.z_index = 0
	if page3_button:
		page3_button.texture_normal = page3_normal
		page3_button.z_index = 0

	# Activate selected tab and update visuals
	match tab_index:
		1:
			if page1: page1.visible = true
			if page1_button:
				page1_button.texture_normal = page1_selected
				page1_button.z_index = 1
		2:
			if page2: page2.visible = true
			if page2_button:
				page2_button.texture_normal = page2_selected
				page2_button.z_index = 1
		3:
			if page3: page3.visible = true
			if page3_button:
				page3_button.texture_normal = page3_selected
				page3_button.z_index = 1
		_:
			push_warning("Invalid tab index: " + str(tab_index))



func nav_buttons_hover(button: String, action: String) -> void:
	var tween:= create_tween()
	var button_node: TextureButton = back_button if button == "BackButton" else menu_button
	match action:
		"entered":
			tween.tween_property(button_node.get_parent(),"scale",Vector2(1.1,1.1),0.1)
		"exited":
			tween.tween_property(button_node.get_parent(),"scale",Vector2(1,1),0.1)
