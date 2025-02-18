extends Event
class_name BattleEvent
var source:Combatant
var target:Combatant
var amt:int
var combat_type
var status_popups:StatusPopupManager;
# type can be a bunch of different enums
func initialize(data):
	self.source = data.source;
	self.target = data.target;
	self.amt = data.amt;
	self.combat_type = data.type;
	self.status_popups = data.status_popups;
	
