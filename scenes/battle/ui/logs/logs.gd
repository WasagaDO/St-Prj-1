extends Control

@export var max_logs:int = 7;
@export var message_parent:Control;
@export var message_scene:PackedScene;
var logs:Array[Label] = [];
@onready var scroll_container: ScrollContainer = $ScrollContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LogSignals.push_log.connect(push_log);


func push_log(log:String):
	var new_log = message_scene.instantiate() as Label;
	message_parent.add_child(new_log);
	new_log.text = log;
	logs.append(new_log);
	if logs.size() > max_logs:
		var last_log:Label = logs.pop_front();
		last_log.queue_free();
	await get_tree().process_frame
	scroll_container.ensure_control_visible(new_log);
	scroll_container.scroll_vertical += 5;
