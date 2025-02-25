extends Control

@export var locations:Array[LocationData]
@onready var location_title: Label = $Header/LocationTitle

var location_index:int = 0;

@export var frames:Array[Panel]

var arena_states:Array;
func _ready() -> void:
	# this will allow us to lay out the different frames as we want, and then 
	# cycle them through those visual states
	
	# this says "the arena at this spot in the array now looks like this"
	await get_tree().process_frame
	for i in range(frames.size()):
		var arena = frames[i];
		arena.get_child(0).texture = locations[i].cover;
		arena_states.append({
			"position": arena.position,
			"scale": arena.scale,
			"alpha": arena.modulate.a,
			"index": i
		})
	shift_frames(0);
	
	
func shift_frames(amt:int):
	location_index += amt
	location_index = posmod(location_index, locations.size());
	location_title.text = locations[location_index].name;
	BattleSettings.location = locations[location_index];
	for state in arena_states:
		state.index += amt
		# basically so the state index can "loop" around
		# if it goes below 0 or above array size
		state.index = posmod(state.index, frames.size());
		
	var middle_frame_location = floor(frames.size()/2.0)
	for i in arena_states.size():
		var dist_from_middle = i - middle_frame_location
		var index = posmod(location_index + dist_from_middle, locations.size())
		frames[arena_states[i].index].get_child(0).texture = locations[index].cover

func _process(delta: float) -> void:
	for i in range(0, frames.size()):
		var arena = frames[i];
		for state in arena_states:
			if i == state.index:
				arena.position = arena.position.lerp(state.position, 0.15);
				arena.scale = arena.scale.lerp(state.scale, 0.1);
				arena.z_index = round(state.scale.length() * 20);
				arena.modulate.a = lerp(arena.modulate.a, state.alpha, 0.2);
				

func _on_left_arrow_pressed() -> void:
	shift_frames(1)

func _on_right_arrow_pressed() -> void:
	shift_frames(-1)
