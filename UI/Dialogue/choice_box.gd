extends Control

const OPTION_SCENE := preload("res://UI/Dialogue/choice.tscn")
var buttons : Array
var _choice : int = -1

signal choice_ended(choice:int)

# T O  D O:
# * improve the synergy with the dialogue

func _process(_delta):
	if (Input.is_action_just_released("accept")) && _choice != -1:
		end_choice()
	elif (Input.is_action_just_released("ui_down")) && _choice < buttons.size() - 1:
		_choice += 1
		buttons[_choice].grab_focus()
	elif (Input.is_action_just_released("ui_up")) && _choice > 0:
		_choice -= 1
		buttons[_choice].grab_focus()

func init_choice(options : Array) -> void:
	var id = 0
	for option in options:
		buttons.append(OPTION_SCENE.instantiate())
		$Background.add_child(buttons[id])
		buttons[id].set_position(Vector2(35, (15 + (id*40))))
		buttons[id].set_text("[shake rate=3 level=10]%s[/shake]" % [option])
		id += 1

func end_choice() -> void:
	destroy()
	emit_signal("choice_ended", _choice)

# distrugge le opzioni e se stessa
func destroy() -> void:
	for option in buttons:
		option.queue_free()
	self.queue_free()
