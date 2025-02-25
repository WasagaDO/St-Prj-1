extends Node2D
class_name Combatant;
enum DamageType {
	CRUSHING,
	CUTTING,
	PIERCING,
	NONE,
}
## 0: Crushing 1: Cutting 2: Piercing
@export var armor = {
	DamageType.CRUSHING: 0,
	DamageType.CUTTING: 1,
	DamageType.PIERCING: 2
}



# status effect data
var status_effects = {}

@export var max_hp:int = 100;
var hp:int;

@export var max_stamina:int = 3;
var stamina:int;

@export var max_armor = 100;

@onready var bars:Bars = $Bars;

@export var log_name:String;

func _ready() -> void:
	hp = max_hp;
	stamina = max_stamina;
	initialize_bars();
func initialize_bars():
	bars.hp_bar.maximum = max_hp;
	bars.hp_bar.value = max_hp;
	
	bars.stamina_bar.maximum = max_stamina;
	bars.stamina_bar.value = max_stamina;

	for armor_type in bars.armor.keys():
		bars.armor[armor_type].maximum = max_armor;
		bars.armor[armor_type].value = armor[armor_type];

func apply_status_effects():
	for status:StatusEffectData in status_effects.keys():
		var effect:CardData = status.effect;
		if status.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			effect = BattleUtil.reverse_effect(effect);
		# TODO: communicate that the status is giving the effect.
		# maybe "source" can be a bit more lenient in BattleSignals.
		# or figure it out some other way.
		if 	status.timing == StatusEffectData.Timing.ON_WORN_OFF or \
			status.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			for i in range(0, status_effects[status]):
				apply_effect(self, effect);
		
		BattleSignals.status_wore_off.emit(self, status);
		status_effects[status]-=1;
		if status_effects[status] < 0: status_effects[status] = 0;
func apply_damage(source:Combatant, damage:int, type:DamageType):
	var armor_amt = 0 if not armor.has(type) else armor[type];
	var damage_to_armor = damage * 0.8;
	var damage_to_health = damage * 0.2 + max(0, damage_to_armor - armor_amt);
	hp -= damage_to_health;
	armor_amt -= damage_to_armor;
	
	if hp < 0: hp = 0;
	if armor_amt < 0: armor_amt = 0;
	
	bars.hp_bar.value = hp;
	if type != DamageType.NONE:
		bars.armor[type].value = armor_amt;
	
	if armor_amt > 0:
		BattleSignals.armor_damage_applied.emit(source, self, roundi(damage_to_armor), type);
	BattleSignals.damage_applied.emit(source, self, roundi(damage_to_health), DamageType.NONE);
	armor[type] = armor_amt;

func apply_healing(amt:int):
	hp += amt;
	if hp > max_hp: hp = max_hp;
	
	bars.hp_bar.value = hp;
	BattleSignals.healing_applied.emit(self, self, amt);
	

func apply_armor(type:DamageType, amt:int):
	armor[type] += amt;
	if armor[type] > max_armor: armor[type] = max_armor;
	bars.armor[type].value = armor[type];
	BattleSignals.armor_applied.emit(self, self, amt, type);

func apply_effect(source:Combatant, effect:CardData):
	for damage in effect.damage:
		if damage.amt > 0:
			apply_damage(source, damage.amt, damage.type)
	
	if effect.healing > 0:
		apply_healing(effect.healing);
	for armor:ArmorData in effect.armor:
		apply_armor(armor.type, armor.amt); 
	for status in effect.status_effects:
		BattleSignals.status_applied.emit(self, status);
		if status_effects.has(status): 
			status_effects[status] += 1;
		else: 
			status_effects[status] = 1;
		if status.timing == StatusEffectData.Timing.ON_APPLIED or \
			status.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			apply_effect(source, status.effect);
