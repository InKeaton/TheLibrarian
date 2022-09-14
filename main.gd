extends Node

var save_data
var jsonfile
const SAVE_PATH = "res://_data/savedata.json"
signal if_result(result)

func _ready():
	jsonfile = File.new()
	jsonfile.open(SAVE_PATH, File.READ_WRITE)
	save_data = parse_json(jsonfile.get_as_text())

func _on_DialogueManager_check_if(variables):
	var result = 1
	for var_name in variables:
		print(var_name)
		if !str2var(save_data["DIALOGUE_VARS"][var_name]):
			result = 0
	emit_signal("if_result", result)


func _on_DialogueManager_set_var(var_data):
	save_data["DIALOGUE_VARS"][var_data[0]] = var_data[1]
