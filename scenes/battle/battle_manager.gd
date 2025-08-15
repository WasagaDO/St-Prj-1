extends Node2D
class_name BattleManager;
enum Turn {
	Enemy,
	Player,
}
@export var player:Player;
@export var deck:Deck;
@export var hand:Hand;
@export var discard_pile:Deck;

# holding on to this for reaction
var queued_attack;

@export var enemies:Array[Enemy];
var acting_combatant:Combatant;

var turn_order = -1;
var move_reacted_to = false; # tells if the last move has been reacted to
var waiting_for_player_reaction:bool = false;
var game_over:bool = false;


@export var enemy_datas:Array[EnemyData]
@export var enemy_data_labels:Array[BattleSettings.EnemyType]


# Called when the node enters the scene tree for the first time.
func _ready():
	# set the correct enemy(es) that we selected.
	# this system may change later.
	var i = enemy_data_labels.find(BattleSettings.enemy_type)
	for enemy in enemies:
		var data = enemy_datas[i]
		enemy.enemy_data = data
		enemy.log_name = data.name
		enemy.max_hp = data.max_hp
		enemy.initialize()
		enemy.player = player
	player.initialize()
	
	# wait a sec before we get started
	# for the events system to connect all its events
	await get_tree().process_frame
	BattleSignals.start_game.emit();
	
	increment_turn_order();

func increment_turn_order():
	if game_over: return
	# END of previous actor's turn
	var prev := acting_combatant
	BattleSignals.end_turn.emit(prev)
	
	move_reacted_to = false
	turn_order += 1

	# pick next actor
	if turn_order == 0:
		acting_combatant = player
	else:
		acting_combatant = enemies[turn_order - 1]
		acting_combatant.increment_turn()

	# loop back after last enemy
	if turn_order == enemies.size():
		turn_order = -1
	# START of new actor's turn. We call this even if the player is stunned,
	# so status effects are updated
	if acting_combatant != null:
			acting_combatant.update_status_effects_on_turn_start()
	
	# STUN: skip turn if flagged
	if acting_combatant.skip_next_turn:
		print("[STUN] %s skips this turn." % acting_combatant.log_name)
		acting_combatant.skip_next_turn = false
		if acting_combatant is Enemy:
			(acting_combatant as Enemy).completed_turn = true
		increment_turn_order()
		return
	BattleSignals.new_turn.emit(acting_combatant)


func on_card_played(card:CardData, source:Combatant, target:Combatant):
	var card_can_be_resolved:bool = true;
	# remove some stamina from the player
	if source is Player:
		source.add_stamina(-card.stamina_cost);
	# player or enemy plays a reaction card
	if card.card_type == CardData.CardType.REACTION:
		waiting_for_player_reaction = false;
		move_reacted_to = true;
	# player or enemy plays an attack card
	if card.card_type == CardData.CardType.ATTACK and not move_reacted_to:
		# let's put this away for now
		queued_attack = {"card": card, "source": source, "target": target}
		if target is Enemy:
			# enemy reacts immediately if possible
			var reaction = target.try_get_valid_reaction(card, source); 
			if reaction:
				_on_enemy_move_made(target, reaction)
				# inside of the above resolve trigger, the attack also
				# resolves if its not dodged.  so we don't need to resolve
				# it here.
				card_can_be_resolved = false;
		else: # target is player
			var player_can_react:bool = false;
			# now, everything that ISN'T a valid reaction gets disabled
			for hand_card in hand.cards:
				if BattleUtil.card_can_react(hand_card.data, card, target, source):
					print("player can react to attact "+ card.name + " with " + hand_card.data.name)
					player_can_react = true;
			if player_can_react: # player has at least one playable reaction card 
				waiting_for_player_reaction = true;
				BattleSignals.player_can_react.emit(card, source, target)
				# it's reaction time, so don't resolve the attack yet.
				# wait for the player.
				card_can_be_resolved = false;
		var attack_animation: CombatantAnimator = CombatantAnimator.new()
		source.add_child(attack_animation)
		attack_animation.combatant_attacked(source)
	
	
	# either this is not an attack, or there wasn't any reactions possible.
	# so we just resolve it.
	if card_can_be_resolved:
		resolve_card(card, source, target);





func resolve_card(card:CardData, source:Combatant, target:Combatant, _finish_turn:bool = false, special_card_effects:bool = true):
	print("resolving card ", card.name, " played by ", source.name, " onto ", target.name)
	BattleSignals.card_resolved.emit(source, target, card)
	
	# if the card is a reaction, we need to change the target because the target 
	# was still the attacked player. Now, the target of the reaction card must be
	# the initial attacker who played the attack card
	if card.card_type == CardData.CardType.REACTION:
		# set the right target
		if source is Player:
			target = queued_attack.source
		elif source is Enemy:
			target = queued_attack.source
	
	# special reactions (dodge, block, ...)
	if card.card_type == CardData.CardType.REACTION:
		for special:CardData.SpecialReaction in card.special_reactions:
			if special == CardData.SpecialReaction.DODGE:
				BattleSignals.attack_dodged.emit(target, source, card)
				queued_attack = null
			elif special == CardData.SpecialReaction.BLOCK:
				if queued_attack and queued_attack.card:
					var incoming_damage = 0 # the sum of incoming damage
					for ad:ArmorData in queued_attack.card.damage:
						incoming_damage += ad.amt
					var min_stamina = int(ceil(incoming_damage * 0.2))
					print("[BLOCK] %s blocked '%s' from %s (damage: %d, min stamina: %d)" % [source.log_name, queued_attack.card.name, queued_attack.source.log_name, incoming_damage, min_stamina])
					if source.stamina >= min_stamina:
						BattleSignals.attack_dodged.emit(target, source, card)
						# Block: allow only special damage types or effects to pass through.
						# You may want to handle phantom damage or other effects here.
						# For now, we just block normal damage and negative effects.
						queued_attack = null
					else:
						# Not enough stamina to block, so resolve the attack as normal.
						continue


	# applies the base effects of the card to the target
	target.apply_card_effect(source, card)

	# status effects
	for status:StatusEffectData in card.status_effects:
		var receiver:Combatant = target
		if status.apply_to == StatusEffectData.ApplyTo.SELF:
			receiver = source
		if status.apply_only_if_unarmored and receiver.is_armored():
			continue # don't apply status if the receiver is armored
		
		receiver.apply_new_status_effect(status, source)

	# custom card effect
	for effect:SpecialCardEffect in card.special_effects:
		if effect.timing == SpecialCardEffect.Timing.ON_RESOLVE:
			effect.execute(source, target)

	# custom enemy behaviour that happen on an attack
	if card.card_type == CardData.CardType.ATTACK:
		if source is Enemy:
			source.trigger_custom_behaviours(EnemyCustomBehaviour.Trigger.ON_ATTACK_SUCCESS)

	# reset the source combatant's next_reaction_speed_boost if this card is a reaction
	if card.card_type == CardData.CardType.REACTION:
		source.next_reaction_speed_boost = 0


	# we've just resolved whatever this card was,
	# so it's possible the player or the targeted enemy is dead.
	# if so, we can't resolve the queued attack, so we gotta check.
	# we're also checking that we're not currently resolving the queued_attack.
	# otherwise this loops
	if attack_can_resolve(queued_attack) and card != queued_attack.card:
		resolve_card(queued_attack.card, queued_attack.source, queued_attack.target)
	else:
		queued_attack = null;
	
	# update 
	source.last_card_played = card
	
	# it's possible the last enemy died from this,
	# or the player did.
	check_for_end_of_battle();
	if game_over: return;





func attack_can_resolve(attack):
	if attack == null: return false;
	var source_is_dead = attack.source.hp <= 0;
	var target_is_dead = attack.target.hp <= 0;
	return not source_is_dead and not target_is_dead;
	
func check_for_end_of_battle():
	if player.hp <= 0:
		game_over = true;
		BattleSignals.game_over.emit(enemies[0]);
		return;
		
	var won_battle = true;
	for enemy in enemies:
		if enemy.hp > 0:
			won_battle = false;
	if won_battle:
		game_over = true;
		BattleSignals.game_over.emit(player);
		

func _on_hand_card_played(card:Card, target):
	if target == null: target = player; # /!\ this is a source of bugs with reaction cards /!\
	BattleSignals.card_played.emit(player, target, card);
	on_card_played(card.data, player, target);

func _on_enemy_move_made(enemy, move):
	BattleSignals.enemy_move_played.emit(enemy, player, move);
	on_card_played(move, enemy, player);


func _on_end_turn_button_pressed():
	# if this button is pressed while waiting for player reaction,
	# it indicates that the player declined to react.
	if waiting_for_player_reaction:
		waiting_for_player_reaction = false;
		resolve_card(queued_attack.card, queued_attack.source, queued_attack.target);
	else:
		increment_turn_order();



func _on_events_queue_empty() -> void:
	if waiting_for_player_reaction or game_over: return;
	if acting_combatant is Enemy:
		if acting_combatant.completed_turn:
			increment_turn_order();
		else:
			move_reacted_to = false;
			acting_combatant.act();
