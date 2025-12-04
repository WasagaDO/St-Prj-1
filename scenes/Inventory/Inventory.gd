extends Control

@export var card_list: GridContainer
@export var description_card: TextureRect
@export var card_description_text: RichTextLabel


@export var back_button: TextureButton
@export var menu_button: TextureButton
@export var filter_buttons: VBoxContainer
@export var filter_buttons_2: HBoxContainer

@export var cards_scroll: VScrollBar
@export var scroll_container: ScrollContainer
@export var scrollbar_2: VScrollBar
@export var scroll_2_container: ScrollContainer
@export var scrollbar_3: VScrollBar
@export var scroll_3_container: ScrollContainer
@export var st_switchers: VBoxContainer




func _ready() -> void:
	# show page 1
	switch_tab(1)
	update_scroll_bar_distance(0)
	update_scroll_bar_distance(1)
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

	description_card.type = card.get_type_string(card.type)
	description_card.type2 = card.get_secondary_type_string(card.type2)
	description_card.level = str(card.level)
	description_card.update()
	card_description_text.text = card.description

"""
# updates the travel height of a scroll bar
func update_scroll_bar_distance(page:int):
	await get_tree().process_frame
	await get_tree().process_frame
	var scroll_bar = cards_scroll
	var container = scroll_container
	if page == 1:
		scroll_bar = scrollbar_2
		container = scroll_2_container
	elif page == 2:
		scroll_bar = scrollbar_3
		container = scroll_3_container
	#await container.get_child(0).resized
	var max_scroll_value = container.get_child(0).size.y - container.size.y
	if max_scroll_value <= 1:
		max_scroll_value = 1
	scroll_bar.max_value = max_scroll_value
	if scroll_bar.value > max_scroll_value:
		scroll_bar.value = max_scroll_value
	if scroll_bar.value < 0:
		scroll_bar.value = 0
	print("update_scroll_bar_distance(", str(page), ") to ", str(max_scroll_value))
"""

func update_scroll_bar_distance(page:int) -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	var scroll_bar: VScrollBar = cards_scroll
	var container: ScrollContainer = scroll_container
	if page == 1:
		scroll_bar = scrollbar_2
		container = scroll_2_container
	elif page == 2:
		scroll_bar = scrollbar_3
		container = scroll_3_container

	var content := container.get_child(0)
	if content == null:
		return

	var max_scroll_value = max(0.0, content.size.y - container.size.y)

	scroll_bar.min_value = 0.0
	scroll_bar.max_value = max_scroll_value
	scroll_bar.page = 0.0  # IMPORTANT : on laisse à 0 pour garder un grabber constant

	if scroll_bar.value > max_scroll_value:
		scroll_bar.value = max_scroll_value
	if scroll_bar.value < 0.0:
		scroll_bar.value = 0.0

	print("update_scroll_bar_distance(", str(page), ") to ", str(max_scroll_value))



var filtered_type: InventoryCard.Types = InventoryCard.Types.OTHER
var filtered_secondary_type: InventoryCard.SecondaryTypes = InventoryCard.SecondaryTypes.NONE

var search_bar_text: String

func update_card_list() -> void:
	for card: InventoryCard in card_list.get_children():
		card.visible = (
				(card.type == filtered_type or filtered_type == InventoryCard.Types.OTHER)
				and ((search_bar_text.to_lower() in card.title.to_lower()) or search_bar_text == "")
				and (card.type2 == filtered_secondary_type or filtered_secondary_type == InventoryCard.SecondaryTypes.NONE)
				and (not show_only_active_from_weapon or card.is_active_from_weapon)
			)
	update_scroll_bar_distance(0)


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
	COST,
	TYPE,
	INITIAL_SORT
}

var initial_card_order: Array[InventoryCard]
var current_sort: Sorts = Sorts.INITIAL_SORT
var sort_ascending: bool = true


func sort_pressed(sort: Sorts) -> void:
	# flip the sort order if the button gets re-clicked
	if sort == current_sort:
		sort_ascending = !sort_ascending
	else:
		sort_ascending = true
		current_sort = sort
	match sort:
		Sorts.ALPHABET:
			var cards := card_list.get_children()
			cards.sort_custom(func(a, b):
				return a.title < b.title if sort_ascending else a.title > b.title)
			for card in card_list.get_children():
				card.queue_free()
			for card in cards:
				var dup := card.duplicate()
				card_list.add_child(dup)
				dup.mouse_entered.connect(card_hover.bind(dup))
		Sorts.COST:
			var cards := card_list.get_children()
			cards.sort_custom(func(a, b):
				return a.level < b.level if sort_ascending else a.level > b.level
			)
			for card in card_list.get_children():
				card.queue_free()
			for card in cards:
				var dup := card.duplicate()
				card_list.add_child(dup)
				dup.mouse_entered.connect(card_hover.bind(dup))
		Sorts.TYPE:
			var cards := card_list.get_children()
			cards.sort_custom(func(a, b):
				# ordre : Physical < Action < Magic
				var order = {"Attack": 0, "Action": 1, "Reaction": 2, "Other": 3}
				if sort_ascending:
					return order.get(a.get_type_string(a.type), 99) < order.get(b.get_type_string(b.type), 99)
				else:
					return order.get(a.get_type_string(a.type), 99) > order.get(b.get_type_string(b.type), 99)
			)
			for card in card_list.get_children():
				card.queue_free()
			for card in cards:
				var dup := card.duplicate()
				card_list.add_child(dup)
				dup.mouse_entered.connect(card_hover.bind(dup))
			""" # Old sorting algorithm
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
			
			Sorts.COST:
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
				"""
		Sorts.INITIAL_SORT:
			for card: InventoryCard in card_list.get_children():
				card.queue_free()
			for card: InventoryCard in initial_card_order:
				var card_: InventoryCard = card.duplicate()
				card_list.add_child(card_)
				card_.mouse_entered.connect(card_hover.bind(card_))
			update_card_list()



func scroll(value: float) -> void:
	scroll_container.scroll_vertical = int(value)
	if visible:
		AudioManager.notify_inventory_scroll_moved()

func scroll_2(value:float) -> void:
	scroll_2_container.scroll_vertical = int(value)
	if visible:
		AudioManager.notify_inventory_scroll_moved()

func scroll_3(value:float) -> void:
	scroll_3_container.scroll_vertical = int(value)
	if visible:
		AudioManager.notify_inventory_scroll_moved()


func _process(delta: float) -> void:
	cards_scroll.value = scroll_container.scroll_vertical
	scrollbar_2.value = scroll_2_container.scroll_vertical


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


var current_tab_index = 1

func switch_tab(tab_index: int) -> void:
	if current_tab_index != tab_index:
		AudioManager.play_sfx("page flip")
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
	current_tab_index = tab_index


func nav_buttons_hover(button: String, action: String) -> void:
	var tween:= create_tween()
	var button_node: TextureButton = back_button if button == "BackButton" else menu_button
	match action:
		"entered":
			tween.tween_property(button_node.get_parent(),"scale",Vector2(1.1,1.1),0.1)
		"exited":
			tween.tween_property(button_node.get_parent(),"scale",Vector2(1,1),0.1)


var show_only_active_from_weapon := false
@export var show_all_button: TextureButton
@export var show_active_button: TextureButton
@export var filter_texture_normal: Texture2D
@export var filter_texture_selected: Texture2D
var filter_button_label_color_normal: Color = Color.SADDLE_BROWN
var filter_button_label_color_selected: Color = Color.WHITE


func show_all_cards() -> void:
	print("show_all_cards()")
	show_only_active_from_weapon = false
	update_card_list()
	_update_filter_buttons_visual(show_all_button)

	

func show_only_active_cards() -> void:
	print("show_only_active_cards()")
	show_only_active_from_weapon = true
	update_card_list()
	_update_filter_buttons_visual(show_active_button)


func _update_filter_buttons_visual(selected_button: TextureButton) -> void:
	for button in [show_all_button, show_active_button]:
		if button == null:
			continue
		var label = button.get_node("MarginContainer/Label") if button.has_node("MarginContainer/Label") else null
		if button == selected_button:
			button.texture_normal = filter_texture_selected
			if label: label.set("theme_override_colors/font_color", filter_button_label_color_selected)
		else:
			button.texture_normal = filter_texture_normal
			if label: label.set("theme_override_colors/font_color", filter_button_label_color_normal)





func play_sfx(id: String, fade_in_duration:float = 0):
	AudioManager.play_sfx(id, fade_in_duration)


func play_hover_sound(volume_db:float=0.0):
	AudioManager.play_sfx("hover", 0, volume_db, 1, true)

func play_click_sound(volume_db:float=0.0):
	AudioManager.play_sfx("click", 0, volume_db, 1, true)
