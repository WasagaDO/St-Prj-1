extends Area2D
class_name Card
@export_range(2, 10) var number:int

var mouse_offset := Vector2.ZERO;
var dest_pos:Vector2;

var face_down = false;
var is_dragging_enabled:bool = false;
@onready var collider:CollisionShape2D = $CollisionShape2D;

signal reached_destination(card:Card)
signal card_picked_up(card:Card);
signal card_dropped(card:Card)
# just cuz button doesn't actually provide the button
# as an argument
signal card_down(card:Card)
signal raw_pressed(card:Card);
var state:Enums.CardState = Enums.CardState.AT_REST;
var move_speed = 0.15;
var default_move_speed = 0.15;
@onready var sprite:AnimatedSprite2D = $Sprite;
@onready var back_face:Sprite2D = $OtherFace;

# if the card being dragged is actually being played.
var can_be_played:bool = false;

var is_moused_over := false;
# Called when the node enters the scene tree for the first time.
func _ready():
	$Shadow.visible = false;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$Shadow.visible = false;
	# if we're moving to position, don't allow dragging
	if state == Enums.CardState.MOVING_TO_DEST:
		position = position.lerp(dest_pos, move_speed)
		if position.distance_to(dest_pos) < 2:
			position = dest_pos;
			change_state(Enums.CardState.AT_REST)
			emit_signal("reached_destination", self);
	if state == Enums.CardState.BEING_DRAGGED:
		$Shadow.visible = true;
		var mouse_pos = get_global_mouse_position();
		global_position = mouse_pos - mouse_offset;
		if Input.is_action_just_released("mouse_clicked"):
			# probably something will grab us from here.
			state = Enums.CardState.AT_REST;
			emit_signal("card_dropped", self)
			

func change_state(new_state:Enums.CardState):
	var old_state = state;
	state = new_state;

func flip(snap:bool):
	var speed = 5.0 if snap else 1.0
	if not face_down:
		$CardFlips.play("FlipDown", -1, speed);
	else:
		$CardFlips.play("FlipDown", -1, -speed, true)
	face_down = not face_down;
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
	change_state(Enums.CardState.MOVING_TO_DEST);
func set_sprite_rotation(rot_degrees:float):
	sprite.rotation_degrees = rot_degrees;
	back_face.rotation_degrees = rot_degrees;
			
func on_mouse_pressed():
	var mouse_pos:Vector2 = get_global_mouse_position()
	get_viewport().set_input_as_handled();
	emit_signal("card_down", self);
	if not is_dragging_enabled: return;
	emit_signal("card_picked_up", self)
	change_state(Enums.CardState.BEING_DRAGGED)
	mouse_offset =  mouse_pos - global_position;

func _on_mouse_entered():
	is_moused_over = true;


func _on_mouse_exited():
	is_moused_over = false;


func _on_input_event(viewport, event, shape_idx):
		if event is InputEventMouseButton:
			if event.button_index == 1 and event.pressed:
				emit_signal("raw_pressed", self)
