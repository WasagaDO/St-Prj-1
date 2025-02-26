extends Node

signal start_game();
signal new_turn(acting_combatant:Combatant);
signal end_turn(acting_combatant:Combatant);
signal damage_applied(source, target:Combatant, amt:int, type:Combatant.DamageType);
signal healing_applied(source, target:Combatant, amt:int);
signal armor_applied(source, target:Combatant, amt:int, type:Combatant.DamageType);
signal armor_damage_applied(source, target:Combatant, amt:int, type:Combatant.DamageType);
signal player_can_react(attack:CardData)

signal enemy_move_played(source, target:Combatant, move:CardData)
signal card_played(source, target:Combatant, card:Card);
signal card_resolved(source, target:Combatant, card:Card);
# react signals
signal attack_dodged(attack_target:Combatant, attack_source, attack:Card);
signal game_over(winner:Combatant);
signal enemy_can_attack_again();
signal status_applied(target:Combatant, status_effect:StatusEffectData);
signal status_wore_off(target:Combatant, status_effect:StatusEffectData);
