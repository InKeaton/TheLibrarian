extends Control

# dialogo
const DIALOGUE_SCENE := preload("res://UI/Dialogue/dialogue.tscn")
const CHOICE_SCENE := preload("res://UI/Dialogue/choice_box.tscn")

# Possible dialogue statuses
enum {LISTENING, THINKING}
# Act status
var _dialogue_status: int = LISTENING

# Object which we're talking with
var _interlocutor: Node

# Dialogue we're gonna act
var _dialogue: Dictionary
# section of dialogue we are in
var _section: String
# current message to display
var _message_id: int = 0
# object containing the actual dialogue box
var _dialogue_box: Node

# object containing the choice box
var _choice_box: Node

signal iteraction_ended
signal set_vars(var_and_value : Array)
signal check_vars(variable: String)

# T O  D O
# * add support for:
#   - choices -DONE-
#   - boolean checks

### MAIN FUNCTIONS

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match(_dialogue_status):
		LISTENING:
			if (Input.is_action_just_released("refuse")):
				_dialogue_box._on_message_completion_request()
		THINKING:
			if (Input.is_action_just_released("accept")):
				if(_message_id < _dialogue[_section]["MESSAGES"].size()):
					update_dialogue()
				else:
					if _dialogue[_section].has("SET_VARS"):
						emit_signal("set_vars", _dialogue[_section]["SET_VARS"])
						
					if _dialogue[_section].has("JUMP_TO"):
						_section = _dialogue[_section]["JUMP_TO"]
						_message_id = 0
						update_dialogue()
				
					elif _dialogue[_section].has("CHOICE"):
						init_choice(_dialogue[_section]["CHOICE"])
						
					elif _dialogue[_section].has("CHECK_VARS"):
						emit_signal("check_vars", _dialogue[_section]["CHECK_VARS"])
						
					elif _dialogue[_section].has("END_DIALOGUE"):
						end_dialogue()

#### DIALOGUE MANAGEMENT
func _on_player_has_interacted_with(interlocutor) -> void:
	# sets up the dialogue box
	_dialogue_box = DIALOGUE_SCENE.instantiate()
	get_tree().get_root().get_node("main/UI").add_child(_dialogue_box)
	_dialogue_box.connect("message_completed", Callable(self, "_on_message_updated"))
	# fetches the dialogue
	_interlocutor = interlocutor
	_dialogue = _interlocutor._dialogue[_interlocutor._dialogue_progression]
	_section = "BEGINNING"
	set_process(true)
	if _message_id < _dialogue[_section]["MESSAGES"].size():
		update_dialogue()
	elif _dialogue[_section].has("CHECK_VARS"):
		emit_signal("check_vars", _dialogue[_section]["CHECK_VARS"])
	else:
		end_dialogue()

func update_dialogue() -> void:
	_dialogue_status = LISTENING
	_dialogue_box.update_message(_dialogue[_section]["MESSAGES"][_message_id])

func _on_message_updated() -> void:
	_dialogue_status = THINKING
	_message_id += 1

func end_dialogue() -> void:
	set_process(false)
	# delete _dialogue_box
	_dialogue_box.disconnect("message_completed", Callable(self, "_on_message_updated"))
	_dialogue_box.queue_free()
	_dialogue_box = null
	# reset variables
	_dialogue_status = LISTENING
	_message_id = 0
	# update actor dialogue progression
	if (_interlocutor._dialogue_progression < _interlocutor._dialogue.size() - 1) && _dialogue[_section]["END_DIALOGUE"]:
		_interlocutor._dialogue_progression += 1
	# send signal to the player
	emit_signal("iteraction_ended")

### CHOICE MANAGEMENT
func init_choice(options:Array) -> void:
	_dialogue_box._on_choice_begun()
	# create choice_box
	_choice_box = CHOICE_SCENE.instantiate()
	get_tree().get_root().get_node("main/UI").add_child(_choice_box)
	_choice_box.connect("choice_ended", Callable(self, "_on_choice_ended"))
	_choice_box.init_choice(options)
	set_process(false)

func _on_choice_ended(choice : int) -> void:
	_dialogue_box._on_choice_ended()
	# set variables
	_section = _dialogue[_section]["CHOICE"][choice]
	_message_id = 0
	_dialogue_status = LISTENING
	set_process(true)
	update_dialogue()
	
#### VARIABLES CHECKS

func _on_save_manager_check_result(result):
	_section = result
	_message_id = 0
	update_dialogue()
	
func _on_check_vars(variable):
	pass # Replace with function body.
