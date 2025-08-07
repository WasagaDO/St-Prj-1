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

# Called when the node enters the scene tree for the first time.
func _ready():
	# wait a sec before we get started
	# for the events system to connect all its events
	await get_tree().process_frame
	BattleSignals.start_game.emit();
	increment_turn_order();

func increment_turn_order():
	if game_over: return;
	BattleSignals.end_turn.emit(acting_combatant);
	move_reacted_to = false;
	turn_order += 1;
	if turn_order == 0:
		acting_combatant = player;
	else:
		acting_combatant = enemies[turn_order-1]
		acting_combatant.increment_turn();
	# this would mean we've gone through the player and all the enemies.
	if turn_order == enemies.size():
		turn_order = -1;

	BattleSignals.new_turn.emit(acting_combatant);





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
			var reaction = target.try_get_valid_reaction(card); 
			if reaction:
				_on_enemy_move_made(target, reaction)
				# inside of the above resolve trigger, the attack also
				# resolves if its not dodged.  so we don't need to resolve
				# it here.
				card_can_be_resolved = false;
		else: # if target is player
			var player_can_react:bool = false;
			# now, everything that ISN'T a valid reaction gets disabled
			for hand_card in hand.cards:
				if BattleUtil.card_can_react(hand_card.data, card):
					player_can_react = true;
			if player_can_react: # player has at least one playable reaction card 
				waiting_for_player_reaction = true;
				BattleSignals.player_can_react.emit(card);
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





func resolve_card(card:CardData, source:Combatant, target:Combatant, finish_turn:bool = false):
	print("resolving card ", card.name, " played by ", source.name)
	BattleSignals.card_resolved.emit(source, target, card)
	
	# special reactions
	if card.card_type == CardData.CardType.REACTION:
		for special:CardData.SpecialReaction in card.special_reactions:
			if special == CardData.SpecialReaction.DODGE:
				BattleSignals.attack_dodged.emit(target, source, card);
				# the attack that was incoming has been dodged,
				# so it can no longer be resolved.
				queued_attack = null;

	# special actions
	for special_action:CardData.SpecialReaction in card.special_reactions:
		match special_action:
			CardData.SpecialAction.DOUBLE_STRIKE:
				# TODO : starting a double strike sequence shoudn't be a card resolution and should have its own system
				start_double_strike(source)
			CardData.SpecialAction.INTERRUPT_ENEMY_MOVESET:
				# Not used. The card that was planned to use this effect (Kick) now
				# gives Shock.
				# We could implement it like this : target.interrupt_moveset()
				pass
			CardData.SpecialAction.FORCE_TRIGGER_ENEMY_REACTION:
				# TODO
				# target.force_trigger_reaction()
				pass
			CardData.SpecialAction.RESTORE_STAMINA_BY_PREVIOUS_CARD_COST:
				if source.last_card_played != null:
					source.increment_stamina(source.last_card_played.stamina_cost)
			CardData.SpecialAction.DEAL_DAMAGE_TO_ALL_ENEMIES:
				# TODO
				pass
			CardData.SpecialAction.INCRAESE_SPEED_OF_NEXT_REACTION_BY_1:
				source.next_reaction_speed_boost = 1
			CardData.SpecialAction.DOUBLE_DAMAGE_IF_ENEMY_HAS_STATUS_EFFECT:
				if target.has_status_effect():
					# Applies double damage.
					# We only need to apply damage once here because it's already done once below
					for dmg in card.damage:
						target.apply_damage(source, dmg.amt, dmg.type)


	source.last_card_played = card
	target.apply_card_effect(source, card)
	for effect in card.status_effects:
		var combatant = source
		if effect.apply_to == StatusEffectData.ApplyTo.SELF:
			combatant = target
		combatant.add_status_effect(effect)
		if effect.timing == StatusEffectData.Timing.ON_APPLIED or \
			effect.timing == StatusEffectData.Timing.WHILE_ACTIVE:
			combatant.apply_card_effect(source, effect.effect);


	# we've just resolved whatever this card was,
	# so it's possible the player or the targeted enemy is dead.
	# if so, we can't resolve the queued attack, so we gotta check.
	# we're also checking that we're not currently resolving the queued_attack.
	# otherwise this loops
	if attack_can_resolve(queued_attack) and card != queued_attack.card:
		resolve_card(queued_attack.card, queued_attack.source, queued_attack.target)
	else:
		queued_attack = null;
	
	
	# it's possible the last enemy died from this,
	# or the player did.
	check_for_end_of_battle();
	if game_over: return;




#### special effects


func start_double_strike(source:Combatant):
	print("Double strike")


####











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
	if target == null: target = player;
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
