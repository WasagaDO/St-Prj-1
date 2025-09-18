extends Control

@export var max_weight: float = 2.0
@export var max_items: int = 2   # max number of selectable weapons

# UI references
@export var items_container: VBoxContainer   # container holding all weapon items
@export var weight_label: RichTextLabel              # optional label to show current weight (can be null)

var current_weight: float = 0.0
var selected_items: Array = []

func _ready():
	# Connect each item to this page as its parent
	if items_container:
		for item in items_container.get_children():
			if item.has_method("set_parent_page"):
				item.set_parent_page(self)
	_update_weight_label()

# Called by an item when trying to activate
func try_select(item: Node, weight: float) -> bool:
	if selected_items.size() >= max_items:
		print("Selection denied → already", max_items, "items selected")
		return false
	if current_weight + weight > max_weight:
		print("Selection denied → would exceed max weight (", max_weight, ")")
		return false

	selected_items.append(item)
	current_weight += weight
	print("Selection accepted →", item.weapon_name, "| total weight =", current_weight, "| items =", selected_items.size())
	_update_weight_label()
	return true

# Called by an item when deactivated
func deselect(item: Node, weight: float) -> void:
	if item in selected_items:
		selected_items.erase(item)
		current_weight -= weight
		print("Deselection →", item.weapon_name, "| total weight =", current_weight, "| items =", selected_items.size())
		_update_weight_label()

func get_current_weight() -> float:
	return current_weight

func _update_weight_label() -> void:
	if weight_label:
		weight_label.text = str(current_weight) + " / " + str(max_weight)
