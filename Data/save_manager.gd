extends Node2D

const SAVE_DATA_PATH : String = "res://_resources/data/savedata.json"
var save_data : Dictionary

signal check_result(result : String)

# loads the save file
func _ready():
	save_data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_DATA_PATH))

# T O  D O
# + remove the creation of variables: they must be already defined in the file

# sets or updates a var value
func _set_vars(var_and_value):
	# var_and_value has:
	# 0 -> section
	# 1 -> var name
	# 2 -> value to assign/sum/remove
	# 3 -> flag
	
	# flag == 0 -> gives the value to the variable, creates it if needed
	if var_and_value[3] == 0:
		save_data[var_and_value[0]][var_and_value[1]] = var_and_value[2]
	
	# flag != 0 -> increment the value by adding value * flag
	else:
		if save_data[var_and_value[0]].has(var_and_value[1]):
			save_data[var_and_value[0]][var_and_value[1]] += (var_and_value[2] * (var_and_value[3]))
		else:
			# if not present, creates the incrementable variable
			save_data[var_and_value[0]][var_and_value[1]] = var_and_value[2] * (var_and_value[3])

# returns information on a variable
func _check_vars(variable):
	# variable has:
	# 0 -> section
	# 1 -> var name
	# 2 -> flag
	# 3 -> value or var name to compare to (optional)
	# 4 -> section of var to compare to (optional)
	
	# in cases where it is possible for the variable to not exist, create a 
	# "default" section to redirect the dialogue to
	if !save_data[variable[0]].has(variable[1]):
		emit_signal("check_result", "DEFAULT")
	
	# flag == 0 -> return variable value
	else: if variable[2] == 0:
		emit_signal("check_result", variable[1] + "_" + save_data[variable[0]][variable[1]])
	
	else: 	
		var tmp_to_compare_to
		# flag == 1 -> check variable value related to value passed
		if variable[2] == 1:
			tmp_to_compare_to = variable[3]
		# flag == 2 -> check variable value related to variable value passed
		else: if variable[2] == 2:
			tmp_to_compare_to = save_data[variable[4]][variable[3]]
		
		var tmp_string
		if save_data[variable[0]][variable[1]] < variable[3]:
			tmp_string = "_lesser_than_"
		else:
			tmp_string = "_greater_than_" # if equal, ends up here
		
		emit_signal("check_result", variable[1] + tmp_string + str(tmp_to_compare_to))

# T O  D O
# + Add the ability to save

func _save() -> void:
	pass

