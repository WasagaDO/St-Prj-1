@tool
class_name InventoryCard
extends TextureRect

enum Types {
	NONE,
	PHY,
	MAG
}

enum SecondaryTypes {
	NONE,
	SWORD,
	RING
}

@export var title: String
@export var type: Types = Types.PHY
@export var type2: SecondaryTypes
@export var level: int
@onready var title_label: Label = $VBoxContainer/Title
@onready var type_label: Label = $VBoxContainer/Type
@onready var level_label: Label = $"VBoxContainer/Lvl"

func _ready() -> void:
	mouse_entered.connect(on_hover.bind(self,"entered"))
	mouse_exited.connect(on_hover.bind(self,"exited"))

func _process(delta: float) -> void:
	type_label.text = "Type: " + get_type_string(type) + "/" + get_secondary_type_string(type2)
	title_label.text = title
	level_label.text = "Lv: " + str(level)

const CARD_HOLDER_NORMAL = preload("res://scenes/Inventory/Hero_s Table/CardHolder/CardHolderNormal.png")
const CARD_HOLDER_SELECTED = preload("res://scenes/Inventory/Hero_s Table/CardHolder/CardHolderSelected.png")

func on_hover(card: InventoryCard, hover: String) -> void:
	match hover:
		"entered":
			card.texture = CARD_HOLDER_SELECTED
		"exited":
			card.texture = CARD_HOLDER_NORMAL

func get_type_string(type: Types) -> String:
	return Types.find_key(type)

func get_string_type(type: String) -> int:
	return Types[type]

func get_secondary_type_string(type: SecondaryTypes) -> String:
	return SecondaryTypes.find_key(type)

func get_string_secondary_type(type: String) -> int:
	return SecondaryTypes[type]
