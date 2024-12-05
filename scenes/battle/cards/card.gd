extends Area2D
class_name Card

enum CardState {
	MOVING_TO_DEST,
	BEING_DRAGGED,
	IN_HAND,
	# for when we're settled into a deck
	AT_REST,
	# completely uninteractable
	DISABLED,
	# for when we want to manage its behaviour from somewhere else
	CUSTOM
}


@export var disabled_color:Color;

var mouse_offset := Vector2.ZERO;
var dest_pos:Vector2;

var face_down = false;
var is_dragging_enabled:bool = false;
@onready var collider:CollisionShape2D = $CollisionShape2D;
@onready var description: Label = $FrontFace/MarginContainer/Description
@onready var title: Label = $FrontFace/Title
@onready var card_image: Sprite2D = $FrontFace/CardImage
@onready var stamina: Label = $FrontFace/Stamina
@onready var speed: Label = $FrontFace/Speed
@onready var front_face: Node2D = $FrontFace

signal reached_destination(card:Card)
signal card_picked_up(card:Card);
signal card_dropped(card:Card)
signal card_down(card:Card)
signal raw_pressed(card:Card);
var state:CardState = CardState.AT_REST;
var move_speed = 0.15;
var default_move_speed = 0.15;
var is_disabled:bool = false;
@onready var sprite:Sprite2D = $FrontFace/Sprite;
@onready var back_face:Sprite2D = $OtherFace;

var is_moused_over := false;

var data:CardData;

# basically if it's an attack or debuff
var needs_target:bool = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	$Shadow.visible = false;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	modulate = disabled_color if is_disabled else Color.WHITE;
	$Shadow.visible = false;
	# if we're moving to position, don't allow dragging
	if state == Card.CardState.MOVING_TO_DEST:
		position = position.lerp(dest_pos, move_speed)
		if position.distance_to(dest_pos) < 2:
			position = dest_pos;
			change_state(Card.CardState.AT_REST)
			reached_destination.emit(self);
	if state == Card.CardState.BEING_DRAGGED:
		$Shadow.visible = true;
		var mouse_pos = get_global_mouse_position();
		global_position = mouse_pos - mouse_offset;
		if Input.is_action_just_released("mouse_clicked"):
			# probably something will grab us from here.
			state = Card.CardState.AT_REST;
			card_dropped.emit(self);
			
func setup(new_data:CardData):
	self.data = new_data;
	
	title.text = data.name;
	description.text = data.description;
	card_image.texture = data.image;
	
	stamina.text = str(data.stamina_cost);
	speed.text = str(data.speed);
	
	# if we want to attack or debuff something, we need to know what that will be
	needs_target = data.damage.size() > 0 or data.debuffs.size() > 0;
func change_state(new_state:CardState):
	var old_state = state;
	state = new_state;

func flip(snap:bool):
	var speed = 5.0 if snap else 1.0
	face_down = not face_down;
	front_face.visible  = not face_down;
	back_face.visible = face_down;
func set_face_down(snap:bool):
	if face_down: return;
	flip(snap);
func set_face_up(snap:bool):
	if not face_down: return
	flip(snap);
func set_dest_position(new_dest_pos, snap_to_pos:bool = false):
	dest_pos = new_dest_pos;
	if snap_to_pos: move_speed = 1;
	else: move_speed = default_move_speed;
	change_state(Card.CardState.MOVING_TO_DEST);
func set_sprite_rotation(rot_degrees:float):
	sprite.rotation_degrees = rot_degrees;
	back_face.rotation_degrees = rot_degrees;
			
func on_mouse_pressed():
	if is_disabled: return
	var mouse_pos:Vector2 = get_global_mouse_position()
	get_viewport().set_input_as_handled();
	card_down.emit(self);
	if not is_dragging_enabled: return;
	card_picked_up.emit(self);
	change_state(Card.CardState.BEING_DRAGGED)
	mouse_offset =  mouse_pos - global_position;

func _on_mouse_entered():
	is_moused_over = true;


func _on_mouse_exited():
	is_moused_over = false;


func _on_input_event(_viewport, event, _shape_idx):
		if event is InputEventMouseButton:
			if event.button_index == 1 and event.pressed:
				raw_pressed.emit(self);
	
