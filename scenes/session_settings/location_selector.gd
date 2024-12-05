extends Control

@export var locations:Array[LocationData]
@onready var location_cover: TextureRect = $LocationCover
@onready var location_title: Label = $Header/LocationTitle

## left to right
## this should have five arenas
@export var arenas:Array[Panel]

var arena_states:Array;
func _ready() -> void:
	# this will allow us to lay out the different arenas as we want, and then 
	# cycle them through those visual states
	
	# this says "the arena at this spot in the array now looks like this"
	await get_tree().process_frame
	for i in range(arenas.size()):
		var arena = arenas[i];
		arena.get_child(0).texture = locations[i].cover;
		arena_states.append({
			"position": arena.position,
			"scale": arena.scale,
			"alpha": arena.modulate.a,
			"index": i
		})
	shift_arenas(0);
	
	
func shift_arenas(amt:int):
	for state in arena_states:
		state.index += amt;
		if state.index < 0: state.index = arena_states.size()-1;
		if state.index > arena_states.size()-1: state.index = 0;
		
func _process(delta: float) -> void:
	for i in range(0, arenas.size()):
		var arena = arenas[i];
		for state in arena_states:
			if i == state.index:
				arena.position = arena.position.lerp(state.position, 0.1);
				arena.scale = arena.scale.lerp(state.scale, 0.1);
				arena.z_index = round(state.scale.length() * 20);
				arena.modulate.a = lerp(arena.modulate.a, state.alpha, 0.1);
				

func _on_left_arrow_pressed() -> void:
	shift_arenas(1)

func _on_right_arrow_pressed() -> void:
	shift_arenas(-1)
