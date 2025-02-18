extends Control
class_name StatusPopupManager
@export var stat_popup_scene:PackedScene;
@export var popup_push_amt:float = 70;

var popups:Array = [];
	
func stat_changed(amt:int, type:Combatant.DamageType):
	var stat_popup:StatusPopup = stat_popup_scene.instantiate();
	add_child(stat_popup);
	stat_popup.position += Vector2.DOWN * popup_push_amt
	stat_popup.setup(type, amt);

	var popup_tween = get_tree().create_tween();
	popup_tween.set_parallel();
	popups.append(stat_popup);
	for popup:StatusPopup in popups:
		popup_tween.tween_property(popup, "position", popup.position+Vector2.UP * popup_push_amt, 0.1);
	
	
	stat_popup.removed.connect(
		func(): popups.erase(stat_popup)
	)
