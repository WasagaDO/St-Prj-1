extends Area2D

enum TerrainType { NORMAL, FOREST, DENSE_FOREST }

@export var terrain_type: TerrainType = TerrainType.FOREST


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _get_modifier() -> float:
	match terrain_type:
		TerrainType.FOREST:
			return 0.8
		TerrainType.DENSE_FOREST:
			return 0.5
		_:
			return 1.0

func _on_body_entered(body: Node) -> void:
	print("entered forest")
	if body is CharacterBody2D:
		body.speed_modifier = _get_modifier()

func _on_body_exited(body: Node) -> void:
	print("exited forest")
	if body is CharacterBody2D:
		body.speed_modifier = 1.0
