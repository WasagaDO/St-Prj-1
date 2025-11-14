extends CanvasLayer
class_name SessionSettings


@export_file var title_scene:String
@onready var battle_settings:Panel = $BattleSettings;
@onready var inventory: CanvasLayer = $Inventory
@export_file var equipment_scene:String;
@export_file var battle_scene:String

func _ready():
	BattleSettings.enemy_data = enemy_datas[0]


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file(title_scene);
	pass # Replace with function body.


func _on_battle_settings_pressed() -> void:
	battle_settings.visible = true;
	pass # Replace with function body.


func _on_equipment_pressed() -> void:
	inventory.toggle_inventory()


func _on_to_battle_pressed() -> void:
	get_tree().change_scene_to_file(battle_scene);
	pass # Replace with function body.
	



# doing this slightly weirdly so we can handle everything
# as an enum
func _on_enemy_behaviour_option_button_item_selected(index: int) -> void:
	BattleSettings.enemy_behavioural_model = index;


func _on_timeof_day_option_button_item_selected(index: int) -> void:
	BattleSettings.time_of_day = index;


func _on_items_option_button_item_selected(index: int) -> void:
	BattleSettings.items_enabled = index;


func _on_first_turn_option_button_item_selected(index: int) -> void:
	BattleSettings.first_turn = index;


@export var enemy_datas: Array[EnemyData]


func _on_enemy_button_item_selected(index: int) -> void:
	var enemy_data = enemy_datas[index]
	BattleSettings.enemy_data = enemy_data
	print("selected enemy " + str(index) + " : " + enemy_data.name)
