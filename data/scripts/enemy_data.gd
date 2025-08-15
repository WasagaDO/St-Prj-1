extends Resource
class_name EnemyData

@export var name:String;
@export var behaviour:BattleSettings.EnemyBehaviour

@export var moves:Array[EnemyTurnData]
@export var reactions:Array[CardData]
@export var max_hp:int = 36;
@export var armor:Array[ArmorData]


@export_category("Enemy's custom behaviours")
@export var behaviours: Array[EnemyCustomBehaviour] = []
