extends CanvasLayer
class_name SessionSettings


@export_file var title_scene:String
@export var battle_settings:Panel
@export var inventory: JournalInventory
@export_file var equipment_scene:String;
@export_file var battle_scene:String

func _ready():
	BattleSettings.enemy_data = enemy_datas[0]
	inventory.inventory_closed.connect(_on_inventory_closed)
	inventory.inventory_opened.connect(_on_inventory_opened)
	battle_settings.visible = false
	inventory.visible = false


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file(title_scene);
	pass # Replace with function body.


func _on_battle_settings_pressed() -> void:
	battle_settings.visible = true;
	pass # Replace with function body.


var is_inventory_open : bool = false
var inventory_audio: StandaloneAudioPlayer
var candle_sfx_fade_in_time: float = 0.5
var candle_sfx_fade_out_time: float = 0.7

func _on_equipment_pressed() -> void:
	inventory.toggle_inventory()
	inventory_audio = AudioManager.play_sfx("Candle Loop", candle_sfx_fade_in_time)


func _on_inventory_opened():
	pass

func _on_inventory_closed():
	if inventory_audio:
		inventory_audio.kill_audio(candle_sfx_fade_out_time)
		inventory_audio = null

func _on_to_battle_pressed() -> void:
	AudioManager.play_sfx("battle", 0, 0, 1, true)
	get_tree().change_scene_to_file(battle_scene);
	



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


func play_sfx(id: String, fade_in_duration:float = 0):
	AudioManager.play_sfx(id, fade_in_duration)


func play_hover_sound(volume_db:float=0.0):
	AudioManager.play_sfx("hover", 0, volume_db, 1, true)

func play_click_sound(volume_db:float=0.0):
	AudioManager.play_sfx("click", 0, volume_db, 1, true)
