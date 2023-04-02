extends Node2D

const SAVE_DATA_PATH : String = "res://_resources/data/savedata.json"
var save_data : Dictionary

signal check_result(result : String)

# T O  D O
# * Add different kinds of variable checking
#	- Is the value lower/bigger than this?
#	- Is it bigger/lower than another variable?
# * Add the ability to save

# loads the save file
func _ready():
	save_data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_DATA_PATH))

func _on_dialogue_manager_set_vars(var_and_value):
	save_data["DIALOGUE_VARS"][var_and_value[0]] = var_and_value[1]

func _on_dialogue_manager_check_vars(variable):
	if save_data["DIALOGUE_VARS"].has(variable):
		emit_signal("check_result", save_data["DIALOGUE_VARS"][variable])
	else:
		# in cases where it is possible for the variable to not exist, create a 
		# "default" section to redirect the dialogue to
		emit_signal("check_result", "DEFAULT")

func save() -> void:
	pass
