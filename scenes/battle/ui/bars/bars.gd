extends Sprite2D
class_name Bars
@onready var hp_bar:Bar = $HpBar
@onready var stamina_bar:Bar = $StaminaBar
@onready var cutting_armor:Bar = $Armor/CuttingArmor
@onready var crushing_armor:Bar = $Armor/CrushingArmor
@onready var piercing_armor:Bar = $Armor/PiercingArmor

var armor:Dictionary;


func _ready() -> void:
	armor = {
		Combatant.DamageType.CUTTING: cutting_armor,
		Combatant.DamageType.PIERCING: piercing_armor,
		Combatant.DamageType.CRUSHING: crushing_armor
	};
	
func _process(delta: float) -> void:
	if get_parent() is Player:
		print("stam max: %d stam val: %d" % [stamina_bar.maximum, stamina_bar.value]);
