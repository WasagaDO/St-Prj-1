extends SpecialCardEffect
class_name Feint


func _ready():
	behaviour_name = "feint"


func execute(_source: Combatant, _target: Combatant):
	# do nothing, this behaviour is managed in BattleManager directly
	pass
