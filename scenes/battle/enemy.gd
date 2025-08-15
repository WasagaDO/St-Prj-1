extends Combatant
class_name Enemy;

@export var enemy_data:EnemyData;

signal move_made(enemy:Enemy, move:CardData)
var completed_turn = false;
var turns:Array[EnemyTurnData]
var turn_index:int = -1;
var move_index:int = 0;

var player: Player = null;

var card_cooldowns:Dictionary = {};
func _ready():
	super._ready();
	load_data(enemy_data);
	trigger_custom_behaviours(EnemyCustomBehaviour.Trigger.ONLY_ONCE_ON_BATTLE_START)



func load_data(data:EnemyData):
	max_hp = data.max_hp;
	hp = data.max_hp;
	log_name = data.name;
	for armor_data:ArmorData in data.armor:
		armor[armor_data.type] = armor_data.amt;
	turns = data.moves;
	initialize_bars();


func act():
	move_made.emit(self, turns[turn_index].moves[move_index]);
	move_index += 1;
	if move_index == turns[turn_index].moves.size():
		completed_turn = true;
	trigger_custom_behaviours(EnemyCustomBehaviour.Trigger.ON_EACH_TURN_END)


func increment_turn():
	completed_turn = false;
	move_index = 0;
	# tick down any reactions on cooldown
	for card in card_cooldowns.keys():
		card_cooldowns[card] -= 1;
		if card_cooldowns[card] < 0: card_cooldowns[card] = 0;
	turn_index += 1;
	if turn_index >= turns.size():
		turn_index = 0;
	trigger_custom_behaviours(EnemyCustomBehaviour.Trigger.ON_EACH_TURN_START)
	

func try_get_valid_reaction(attack:CardData, attacker:Combatant):
	for reaction in enemy_data.reactions:
		var on_cooldown = card_cooldowns.has(reaction) and card_cooldowns[reaction] > 0
		if on_cooldown:
			continue
		if not BattleUtil.card_can_react(reaction, attack, attacker, self):
			continue
		
		
		# valid reaction
		card_cooldowns[reaction] = reaction.cooldown;
		return reaction;



# this function triggers the special behaviours of the enemy.
# (some enemies have some inherent special behaviours, this is not the effect of a card).
# Argument "trigger_type" : indicates the turn moment we are on. If a custom script
#     is not set to be triggered on this moment, it will not be triggered.
func trigger_custom_behaviours(trigger_type: EnemyCustomBehaviour.Trigger):
	for behaviour in enemy_data.behaviours:
		if behaviour.trigger == trigger_type:
			behaviour.execute(self, player)
