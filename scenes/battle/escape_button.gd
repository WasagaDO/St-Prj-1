extends Button

func _ready():
	# Connecte le signal pressed pour libérer le focus après le clic
	pressed.connect(_on_pressed)

func _on_pressed():
	# Libère le focus du bouton après qu'il soit pressé
	release_focus()
