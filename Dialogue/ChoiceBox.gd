extends Control

const OPTION := preload("res://Dialogue/Button.tscn")
var buttons : Array
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# imposta le scelte della choicebox
func set_choices(choices : Array) -> void:
	var id = 0
	for choice in choices:
		buttons.append(OPTION.instance())
		get_tree().get_root().get_node("main/HUD").add_child(buttons[id])
		# yo
		buttons[id].set_position($Background.rect_position + Vector2((15 + (id*15)), (15 + (id*20))))
		buttons[id].text = choice
		id += 1

func destroy():
	for choice in buttons:
		choice.queue_free()
	self.queue_free()

func _on_choice_changed(option):
	for choice in buttons:
		choice.pressed = false
	buttons[option].pressed = true
	
		
