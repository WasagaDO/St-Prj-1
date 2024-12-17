extends Node
enum EnemyBehaviour {
	Aggressive,
	Balanced,
	Passive,
	Random
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
@export var time_of_day:TimeOfDay
@export var items_enabled:bool;
@export var first_turn:WhoGoesFirst

var hand_size:int = 5;
