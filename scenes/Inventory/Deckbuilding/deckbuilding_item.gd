@tool
extends Control

# Data with setters that refresh display when changed
@export var weapon_name: String = "Unnamed":
	set(value):
		weapon_name = value
		_refresh_display()

@export var weight: float = 1.0:
	set(value):
		weight = value
		_refresh_display()

@export var weapon_icon: Texture2D:
	set(value):
		weapon_icon = value
		_refresh_display()

@export var damage_type_icons: Array[Texture2D] = []:
	set(value):
		damage_type_icons = value
		_refresh_display()

@export var mini_card_count: int = 0:
	set(value):
		mini_card_count = value
		_refresh_display()

# UI references
@export var weapon_image: TextureRect
@export var value_text: RichTextLabel
@export var weapon_text: RichTextLabel
@export var damage_types_container: HBoxContainer
@export var mini_cards_container: HBoxContainer
@export var tick_button: TextureButton
@export var tick_image: TextureRect

# Prefabs
@export var damage_type_prefab: PackedScene
@export var mini_card_prefab: PackedScene

var parent_page: Node = null
var selected: bool = false

func _ready() -> void:
	if tick_button:
		tick_button.pressed.connect(_on_tick_pressed)
	if tick_image:
		tick_image.visible = selected
	_refresh_display()

func set_parent_page(page: Node) -> void:
	parent_page = page

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _refresh_display() -> void:
	if not is_inside_tree():
		return

	# Update texts
	if value_text:
		value_text.text = str(weight)
	if weapon_text:
		weapon_text.text = weapon_name

	# Update weapon image
	if weapon_image:
		weapon_image.texture = weapon_icon

	# Populate damage type icons
	if damage_types_container and damage_type_prefab:
		_clear_children(damage_types_container)
		for icon in damage_type_icons:
			var node = damage_type_prefab.instantiate()
			if node is TextureRect:
				node.texture = icon
			damage_types_container.add_child(node)

	# Populate mini-cards
	if mini_cards_container and mini_card_prefab:
		_clear_children(mini_cards_container)
		for i in range(mini_card_count):
			var node = mini_card_prefab.instantiate()
			mini_cards_container.add_child(node)

	# Tick visibility
	if tick_image:
		tick_image.visible = selected

func _on_tick_pressed() -> void:
	if not selected:
		if parent_page and parent_page.try_select(self, weight):
			selected = true
			if tick_image:
				tick_image.visible = true
			print("Button pressed → weapon activated:", weapon_name, "| weight =", weight)
		else:
			tick_button.button_pressed = false
			print("Activation denied for", weapon_name)
	else:
		if parent_page:
			parent_page.deselect(self, weight)
		selected = false
		if tick_image:
			tick_image.visible = false
		print("Button pressed → weapon deactivated:", weapon_name, "| weight =", weight)
