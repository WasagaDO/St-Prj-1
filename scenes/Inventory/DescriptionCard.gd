extends TextureRect

var title: String = "Title"
var type: String
var type2: String
var level: String

@onready var card_pic: TextureRect = $CardPic
@onready var title_label: Label = $VBoxContainer/Title
@onready var type_label: Label = $VBoxContainer/HBoxContainer/Type
@onready var level_label: Label = $VBoxContainer/HBoxContainer/Level

#func _process(delta: float) -> void:
#	update()

func update():
	print("updating DescriptionCard : title: ", title, " type: ", type, " type2: ", type2, " level: ", level)
	type_label.text = "Type: " + type + "/" + type2
	title_label.text = title
	level_label.text = "Lvl. " + level
