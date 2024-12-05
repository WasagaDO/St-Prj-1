extends Node2D
class_name TargetSelector;
var current_card:Card = null;
var line:Curve2D = Curve2D.new()
@onready var arrow = $Arrow;

@export var node_scene:PackedScene;
@export var nodes_to_generate:int = 30;
var target:Node2D;
var nodes:Array[Node2D] = [];

signal target_selected(target);
signal cancelled;
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false;
	line.add_point(Vector2.ZERO);
	line.add_point(Vector2.ZERO);
	for i in nodes_to_generate:
		var new_node = node_scene.instantiate();
		new_node.visible = false;
		add_child(new_node);
		nodes.append(new_node);


func _process(_delta):
	if visible:
		var mouse_pos = get_global_mouse_position();
		line.set_point_position(0, current_card.global_position);
		line.set_point_position(1, mouse_pos);
		
		var control_vec = Vector2(current_card.global_position.x, mouse_pos.y)
		# the controls points are relative to the point itself, so we need to subtract the point's position here.
		line.set_point_in(1, control_vec - mouse_pos);
		
		position_nodes_along_line();
		
		arrow.global_position = mouse_pos;
		arrow.rotation = line.sample_baked_with_rotation(mouse_pos.distance_to(current_card.global_position) - 10).get_rotation() + PI/2
		
		if Input.is_action_just_released("mouse_clicked"):
			var potential_targets:Array = arrow.get_overlapping_areas();
			if potential_targets.size() > 0: target = potential_targets[0];
			if target:
				target_selected.emit(target);
			else:
				cancelled.emit();
			current_card = null;
			visible = false;
			
		if current_card and current_card.state != Card.CardState.AT_REST:
			# we got canceled by something else
			visible = false;
			current_card = null;
				
func position_nodes_along_line():
	var distance = 0;
	var max_distance = line.get_point_position(1).distance_to(line.get_point_position(0));
	var step = 50;
	for node in nodes:
		if distance <= max_distance + step:
			node.visible = true;
			node.global_position = line.sample_baked(distance);
			distance += step;
		else:
			node.visible = false;
			

func set_current_card(card:Card):
	visible = true;
	current_card = card;
