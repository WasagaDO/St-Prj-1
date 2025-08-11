extends Node2D
class_name Combatant

enum DamageType {
	CRUSHING,
	CUTTING,
	PIERCING,
	BALANCE,  # TEMPORARY PLACEHOLDER, NOT IMPLEMENTED
	PURE,    # Pure damage, ignores armor
	NONE
}

## 0: Crushing 1: Cutting 2: Piercing
@export var armor = {
	DamageType.CRUSHING: 0,
	DamageType.CUTTING: 1,
	DamageType.PIERCING: 2,
	DamageType.BALANCE: 3   # TEMPORARY PLACEHOLDER, NOT IMPLEMENTED
}

var last_card_played: CardData = null # useful for Agile Maneuver

# Status storage: StatusEffectData -> int (remaining turns). No stacking of intensity.
var status_effects := {}

@export var max_hp:int = 100
var hp:int

@export var max_stamina:int = 3
var stamina:int

@export var max_armor = 100

@onready var bars:Bars = $Bars

@export var log_name:String

# boosts the speed of the (one) next reaction card by an amount. Used by Distant Control card
@export var next_reaction_speed_boost:int = 0


func _ready() -> void:
	hp = max_hp
	stamina = max_stamina
	initialize_bars()


func initialize_bars():
	bars.hp_bar.maximum = max_hp
	bars.hp_bar.value = max_hp
	
	bars.stamina_bar.maximum = max_stamina
	bars.stamina_bar.value = max_stamina

	for armor_type in bars.armor.keys():
		bars.armor[armor_type].maximum = max_armor
		bars.armor[armor_type].value = armor[armor_type]


# ---------- STATUS: APPLICATION & TICKS ----------

# adds a status effect to this combatant
func apply_new_status_effect(status: StatusEffectData, source: Combatant):
	if status == null:
		return
	
	
	# Fire immediately and do not store for ON_APPLIED
	if status.timing == StatusEffectData.Timing.ON_APPLIED:
		apply_one_status_effect(status, source)
		BattleSignals.status_applied.emit(self, status)
		return

	
	# Otherwise, store/refresh remaining duration
	var current : int = 0
	if status_effects.has(status):
		current = int(status_effects[status])
	var new_remaining : int = max(current, int(status.duration))
	status_effects[status] = new_remaining
	BattleSignals.status_applied.emit(self, status)




# Called at START of this combatant's turn to apply WHILE_ACTIVE payloads.
func apply_all_status_effects() -> void:
	if status_effects.is_empty():
		return
	for status: StatusEffectData in status_effects.keys():
		var remaining := int(status_effects[status])
		if remaining > 0 and status.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			apply_one_status_effect(status)


var skip_next_turn:bool = false # used by Stun status effect

# Applies ONE status effect's simple payload to THIS combatant.
# - Reads the effect's CardData
# - Applies: damage, healing, armor
# - Ignores: speed (handled elsewhere), nested status_effects (ignored)
func apply_one_status_effect(status: StatusEffectData, source: Combatant = null) -> void:
	if status == null or status.effect == null:
		return

	# STUN: one-shot, do not store
	if status.log_name.to_lower() == "stun":
		skip_next_turn = true
		BattleSignals.status_applied.emit(self, status)
		return
	var card := status.effect
	# Use self as source if none (tick effects have no external source)
	var src := source if source != null else self
	# Damage
	for dmg in card.damage:
		if dmg.amt > 0:
			apply_damage(src, dmg.amt, dmg.type)
	# Healing
	if card.healing > 0:
		apply_healing(card.healing)
	# Armor
	for a: ArmorData in card.armor:
		if a.amt != 0:
			apply_armor(a.type, a.amt)
	# Explicitly ignore:
	#    - card.speed (computed elsewhere)
	#    - other stuff







# ---------- CORE COMBAT ----------

func apply_damage(source:Combatant, damage:int, type:DamageType):
	if type == DamageType.PURE:
		# pure damage can't be multiplied (generally comes from a poison)
		hp -= damage
		BattleSignals.damage_applied.emit(source, self, damage, DamageType.PURE)
		return

	var damage_modifier := get_incoming_damage_multiplier()
	damage = int(round(damage * damage_modifier))

	var armor_amt = 0 if not armor.has(type) else armor[type]
	var damage_to_armor = damage * 0.8
	var damage_to_health = damage * 0.2 + max(0, damage_to_armor - armor_amt)
	hp -= damage_to_health
	armor_amt -= damage_to_armor
	
	if hp < 0: hp = 0
	if armor_amt < 0: armor_amt = 0
	
	armor[type] = armor_amt
	if armor_amt > 0:
		BattleSignals.armor_damage_applied.emit(source, self, roundi(damage_to_armor), type)
	BattleSignals.damage_applied.emit(source, self, roundi(damage_to_health), DamageType.PURE)
	
	if self is Enemy:
		var enemy := self as Enemy
		enemy.trigger_custom_behaviours(EnemyCustomBehaviour.Trigger.ON_DAMAGE_TAKEN)


func apply_healing(amt:int):
	hp += amt
	if hp > max_hp: hp = max_hp
	
	bars.hp_bar.value = hp
	BattleSignals.healing_applied.emit(self, self, amt)


func apply_balance_healing(amt:int):
	pass


func apply_armor(type:DamageType, amt:int):
	armor[type] += amt
	if armor[type] > max_armor: armor[type] = max_armor
	bars.armor[type].value = armor[type]
	BattleSignals.armor_applied.emit(self, self, amt, type)


func is_armored() -> bool:
	# Returns true if this combatant has any armor value > 0
	for t in armor.keys():
		if armor[t] > 0:
			return true
	return false


# Applies only immediate payloads (damage/heal/armor). Status effects are handled in BattleManager.resolve_card.
func apply_card_effect(source, effect:CardData):
	print("apply_card_effect()")
	print("source: ",source , " effect: ", effect.name)
	
	for damage in effect.damage:
		if damage.amt > 0:
			apply_damage(source, damage.amt, damage.type)
	
	if effect.healing > 0:
		apply_healing(effect.healing)
	
	for armor_:ArmorData in effect.armor:
		apply_armor(armor_.type, armor_.amt)


func has_status_effect() -> bool:
	for status in status_effects.keys():
		if int(status_effects[status]) > 0:
			return true
	return false


func increment_stamina(increment: int):
	stamina += increment
	if stamina < 0:
		stamina = 0
	if stamina > max_stamina:
		stamina = max_stamina



# ---------- UTILS ----------


func has_named_status(name_: String) -> bool:
	for status in status_effects.keys():
		if status.log_name.to_lower() == name_.to_lower() and int(status_effects[status]) > 0:
			return true
	return false

# Sum passive speed modifiers on THIS combatant
func get_speed_modifier_from_statuses() -> int:
	var m := 0
	if has_named_status("Fracture") or has_named_status("In nets"):
		m -= 1         # permanent
	return m

# Incoming damage multiplier for THIS combatant (defender-side)
func get_incoming_damage_multiplier() -> float:
	var mul := 1.0
	if has_named_status("In nets"):
		mul = 1.35
	elif has_named_status("Block"): 
		mul = 0.80
	return mul
