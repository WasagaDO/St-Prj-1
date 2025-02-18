extends Node

signal start_game();
signal new_turn(acting_combatant:Combatant);
signal damage_applied(source:Combatant, target:Combatant, amt:int, type:Combatant.DamageType);
signal healing_applied(source:Combatant, target:Combatant, amt:int);
signal armor_applied(source: Combatant, target:Combatant, amt:int, type:Combatant.DamageType);
signal buff_applied(source:Combatant, target:Combatant, amt:int, type:Combatant.Buff);
signal debuff_applied(source:Combatant, target:Combatant, amt:int, type:Combatant.Debuff);
signal armor_damage_applied(source:Combatant, target:Combatant, amt:int, type:Combatant.DamageType);
signal player_can_react(attack:CardData)

signal enemy_move_played(source:Combatant, target:Combatant, move:CardData)
signal card_played(source:Combatant, target:Combatant, card:Card);
signal card_resolved(source:Combatant, target:Combatant, card:Card);
# react signals
signal attack_dodged(attack_target:Combatant, attack_source:Combatant, attack:Card);
signal game_over(winner:Combatant);
