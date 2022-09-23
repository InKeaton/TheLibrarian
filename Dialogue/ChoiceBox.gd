extends Control

const OPTION := preload("res://Dialogue/Button.tscn")
var buttons : Array

# imposta le scelte della choicebox
func set_choices(choices : Array) -> void:
	var id = 0
	for choice in choices:
		buttons.append(OPTION.instance())
		get_tree().get_root().get_node("main/HUD").add_child(buttons[id])
		buttons[id].set_position($Background.rect_position + Vector2((35 + (id*15)), (15 + (id*25))))
		buttons[id].set_text("[shake rate=3 level=10]%s[/shake]" % [choice])
		id += 1

# distrugge le opzioni e se stessa
func destroy() -> void:
	for choice in buttons:
		choice.queue_free()
	self.queue_free()

# cambia l'opzione selezionata
func _on_choice_changed(option : int) -> void:
	for choice in buttons:
		choice.pressed = false
	buttons[option].grab_focus()
	
		
