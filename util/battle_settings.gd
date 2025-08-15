extends Node
enum EnemyBehaviour {
	Aggressive,
	Balanced,
	Passive,
	Random
}

enum EnemyType {
	Goatman,
	FreakSpear,
	FreakCrossbow,
	FreakNetSword,
	Freak3Swords,
	GladoatorDualWeapons,
	GladiatorShield,
	GladiatorSword
}

enum TimeOfDay {
	Day,
	Night,
	Random
}

enum ItemsEnabled {
	True,
	False,
	Random
}

enum WhoGoesFirst {
	Player,
	Enemy
}
@export var location:LocationData
@export var enemy_behavioural_model:EnemyBehaviour
@export var enemy_type: EnemyType
@export var time_of_day:TimeOfDay
@export var items_enabled:bool;
@export var first_turn:WhoGoesFirst

var hand_size:int = 5;
