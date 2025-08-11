extends HBoxContainer
class_name StatusPopup

@export var crushing_icon:Texture;
@export var piericng_icon:Texture;
@export var slashing_icon:Texture
@export var health_icon:Texture;
@onready var icon: TextureRect = $Icon
@onready var amount: Label = $Amount

var icons:Dictionary = {};

@export var lifetime:float = 2;

var timer:float;

signal removed()

func _process(delta: float) -> void:
	timer += delta;
	if timer >= lifetime:
		# fadeout
		modulate.a -= 0.05;
		if modulate.a <= 0: 
			removed.emit()
			queue_free();
			
func setup(damage_type:Combatant.DamageType, amt:int):
	icons[Combatant.DamageType.PIERCING] = piericng_icon;
	icons[Combatant.DamageType.CRUSHING] = crushing_icon;
	icons[Combatant.DamageType.CUTTING] = slashing_icon;
	icons[Combatant.DamageType.PURE] = null;
	icons[Combatant.DamageType.BALANCE] = null;
	icons[Combatant.DamageType.NONE] = health_icon;
	icon.texture = icons[damage_type]
	amount.text = "%s%d" % ["+" if amt > 0 else "", amt];
	
