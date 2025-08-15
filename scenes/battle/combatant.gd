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
	DamageType.BALANCE: 3	# not managed here /!\
}

var last_card_played: CardData = null # useful for Agile Maneuver

# Status storage: StatusEffectData -> int (remaining turns). No stacking of intensity.
var status_effects := {}

@export var max_hp:int = 100
var hp:int

@export var max_stamina:int = 3
var stamina:int

@export var max_balance:int = 100
var balance: int = 50


@export var max_armor = 100

@onready var bars:Bars = $Bars

@export var log_name:String

# boosts the speed of the (one) next reaction card by an amount. Used by Distant Control card
@export var next_reaction_speed_boost:int = 0

var did_play_series_of_stabs: bool = false




# debug text
@export var debug_text: RichTextLabel
var debug_overlay_enabled: bool = false

var incoming_damage_multiplier:float = 1.0
var outgoing_damage_multiplier:float = 1.0



func _ready() -> void:
	pass

# called by battle_manager
func initialize():
	hp = max_hp
	stamina = max_stamina
	initialize_bars()
	debug_text.visible = debug_overlay_enabled # debug text


func initialize_bars():
	bars.hp_bar.maximum = max_hp
	bars.hp_bar.value = max_hp
	
	bars.stamina_bar.maximum = max_stamina
	bars.stamina_bar.value = max_stamina
	
	bars.balance_bar.maximum = max_balance
	bars.balance_bar.value = randi_range(30, 70)

	for armor_type in bars.armor.keys():
		bars.armor[armor_type].maximum = max_armor
		bars.armor[armor_type].value = armor[armor_type]


# called when it's their turn to play
func update_status_effects_on_turn_start():
	# decrement all status effects
	for status in status_effects.keys():
		var duration := int(status_effects[status])
		duration -= 1
		# check if the status effect is on its end of life
		if duration == 0:
			# if the status effect should be fired when it wears off
			if status.timing == StatusEffectData.Timing.ON_WORN_OFF:
				apply_one_status_effect(status.effect)
				status_effects.erase(status)
			# if the status effect should be reverted at the end of the round
			elif status.revert_on_end:
				print("reverting status effect " + status.log_name + " on " + log_name)
				apply_one_status_effect_reversed(status)
				status_effects.erase(status)

	# apply all alive status effects
	apply_all_status_effects()




# ---------- STATUS: APPLICATION & TICKS ----------

# adds a status effect to this combatant
func apply_new_status_effect(status: StatusEffectData, source: Combatant):
	print("apply_new_status_effect() "+ status.log_name + " to " + log_name + " from " + source.log_name)
	if status == null:
		return
	
	# Fire immediately and do not store for ON_APPLIED
	if status.timing == StatusEffectData.Timing.ON_APPLIED:
		apply_one_status_effect(status, source)
	
	# Otherwise, store/refresh remaining duration
	var current : int = 0
	if status_effects.has(status):
		current = int(status_effects[status])
	var new_remaining : int = max(current, int(status.duration))
	status_effects[status] = new_remaining
	BattleSignals.status_applied.emit(self, status)
	print("status effects: " + str(status_effects.keys()) + " " + str(status_effects.values()))




# Called at START of this combatant's turn to apply WHILE_ACTIVE payloads.
func apply_all_status_effects() -> void:
	for status: StatusEffectData in status_effects.keys():
		var remaining := int(status_effects[status])
		if remaining > 0 and status.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			apply_one_status_effect(status)


var skip_next_turn:bool = false # used by Stun status effect

# Applies ONE status effect's simple payload to THIS combatant.
# - Reads the effect's CardData
# - Applies: damage, healing, armor
# - Ignores: speed (handled elsewhere), nested status_effects (ignored : nested effects should never be needed)
func apply_one_status_effect(status: StatusEffectData, source: Combatant = null) -> void:
	if status == null or status.effect == null:
		return
	var card := status.effect
	apply_one_status_effect_card(card, source)

# same for a card
func apply_one_status_effect_card(card: CardData, source: Combatant = null):
	if card == null:
		return
		
	# STUN: one-shot, do not store
	if card.name.to_lower() == "stun":
		skip_next_turn = true
		return
		
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

# reversed
func apply_one_status_effect_reversed(status: StatusEffectData, source: Combatant = null) -> void:
	if status == null or status.effect == null:
		return
	apply_one_status_effect_reversed_card(status.effect, source)
# same for a card
func apply_one_status_effect_reversed_card(card: CardData, _source: Combatant = null) -> void:
	if card == null:
		return

	# Reverse Damage: heal for the amount of damage in the card
	for dmg in card.damage:
		if dmg.amt > 0:
			apply_healing(dmg.amt)
	# Reverse Healing: undo healing by applying PURE damage
	if card.healing > 0:
		apply_damage(self, card.healing, DamageType.PURE)
	# Reverse Armor: remove the armor that was added (apply negative)
	for a: ArmorData in card.armor:
		if a.amt != 0:
			apply_armor(a.type, -a.amt)
	# Explicitly ignore:
	#    - card.speed (computed elsewhere)
	#    - other stuff






func get_damage_type_text(type:DamageType):
	match type:
		DamageType.CRUSHING:
			return "Crushing"
		DamageType.CUTTING:
			return "Cutting"
		DamageType.PURE:
			return "Pure"
		DamageType.PIERCING:
			return "Piercing"
		DamageType.BALANCE:
			return "Balance"
	return "None"



# ---------- CORE COMBAT ----------

func apply_damage(source:Combatant, damage:int, type:DamageType):
	print("apply_damage() to " + name + " by " + source.name + " : " + str(damage) + " " + get_damage_type_text(type))
	if type == DamageType.PURE:
		# pure damage can't be multiplied (generally comes from a poison)
		hp -= damage
		BattleSignals.damage_applied.emit(source, self, damage, type)
		return
	
	if type == DamageType.BALANCE:
		# same for balance ?
		decrement_balance(damage)
		BattleSignals.damage_applied.emit(source, self, damage, type)
		return

	var damage_modifier := get_incoming_damage_multiplier(source)
	damage = int(round(damage * damage_modifier))
	if damage_modifier != 1.0:
		print("damage_modifier: " + str(damage_modifier) + " -> damage=" + str(damage))

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


func on_balance_limit_reached():
	skip_next_turn = true # stun
	stamina /= 2 # lose 50% of stamina
	incoming_damage_multiplier *= 1.3 # +30% incoming damage


func set_balance(amt:int):
	balance = amt
	bars.balance_bar.value = amt
	if balance <= 0:
		on_balance_limit_reached()
		set_balance(30)
	if balance >= 100:
		on_balance_limit_reached()
		set_balance(70)



func increment_balance(amt:int):
	set_balance(balance + amt)

func decrement_balance(amt:int):
	set_balance(balance - amt)


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
func apply_card_effect(source:Combatant, effect:CardData):
	print("- apply_card_effect() : source: ",source , " effect: ", effect.name)
	
	for damage in effect.damage:
		if damage.amt > 0:
			var amt = damage.amt
			if source.did_play_series_of_stabs and effect.name.to_lower() == "gladiator's stab":
				amt += 3
				source.did_play_series_of_stabs = false
			apply_damage(source, amt, damage.type)
	
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


# Get the actual speed that the card will have when played.
# This takes into consideration the card's speed and all the speed modifiers
# that the combatant has (status effects and reaction speed boost (e.g. Distant Control)).
# If the card shall be used as a reaction, set 'as_reaction' to true
func get_own_effective_speed_for(card: CardData, as_reaction: bool) -> int:
	var s := card.speed + get_speed_modifier_from_statuses()
	if as_reaction:
		s += next_reaction_speed_boost
	return s



# Incoming damage multiplier for THIS combatant (defender-side)
func get_incoming_damage_multiplier(source:Combatant) -> float:
	var mul : float = 1.0
	if has_named_status("In nets"):
		mul *= 1.35
	if source != null:
		mul *= source.outgoing_damage_multiplier
	return mul * incoming_damage_multiplier




# ----- DEBUG TEXTS -----

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		debug_overlay_enabled = not debug_overlay_enabled
		if is_instance_valid(debug_text):
			debug_text.visible = debug_overlay_enabled
		# refresh once when enabled
		if debug_overlay_enabled:
			_refresh_debug_text()



func _process(_delta: float) -> void:
	# Only update when enabled and label is visible in tree
	if not debug_overlay_enabled:
		return
	if not is_instance_valid(debug_text):
		return
	if not debug_text.visible or not debug_text.is_visible_in_tree():
		return
	_refresh_debug_text()

func _refresh_debug_text() -> void:
	if not is_instance_valid(debug_text):
		return
	debug_text.bbcode_enabled = true
	debug_text.text = _build_debug_text()

func _build_debug_text() -> String:
	var lines: Array[String] = []

	# Header
	lines.append("[b]%s[/b]" % log_name)

	# Core resources
	lines.append("HP: %d / %d   STA: %d / %d" % [hp, max_hp, stamina, max_stamina])

	# Armor
	var cg: int = int(armor.get(DamageType.CRUSHING, 0))
	var ct: int = int(armor.get(DamageType.CUTTING, 0))
	var pi: int = int(armor.get(DamageType.PIERCING, 0))
	var ba: int = int(armor.get(DamageType.BALANCE, 0))
	lines.append("Armor  Cg:%d  Ct:%d  Pi:%d  Ba:%d" % [cg, ct, pi, ba])

	# Speed modifiers & next reaction boost (helpers exist in this class)
	var sp_mod: int = 0
	if has_method("get_speed_modifier_from_statuses"):
		sp_mod = get_speed_modifier_from_statuses()
	var next_rx: int = int(next_reaction_speed_boost)
	lines.append("Speed Mod: %d    Next Reaction +%d" % [sp_mod, next_rx])

	# Stun flag (if present)
	var stunned: bool = false
	if "skip_next_turn" in self:
		stunned = bool(self.skip_next_turn)
	if stunned:
		lines.append("[color=orange]Stunned: will skip next turn[/color]")

	# Statuses with remaining turns
	lines.append("Statuses: " + _statuses_line_compact())

	# damage multipliers
	lines.append("Incoming damage mult: " + str(incoming_damage_multiplier))
	lines.append("Outgoing damage mult: " + str(outgoing_damage_multiplier))

	return "\n".join(lines)

func _statuses_line_compact() -> String:
	if status_effects.is_empty():
		return "[i]none[/i]"
	var parts: Array[String] = []
	for s in status_effects.keys():
		var st: StatusEffectData = s
		var rem: int = int(status_effects[s])
		parts.append("%s(%d)" % [st.log_name, rem])
	return ", ".join(parts)
