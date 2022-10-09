extends Node

# dizionario contenente le variabili
var save_data
# variabile contenente il file json di salvataggio
var jsonfile
# posizione del file di salvataggio
const SAVE_PATH = "res://_data/savedata.json"
# segnale che invia il risultato di un IF di dialogo
signal if_result(result)


# carica il file di salvataggio, e lo conserva come dizionario
func _ready():
	jsonfile = File.new()
	jsonfile.open(SAVE_PATH, File.READ_WRITE)
	save_data = parse_json(jsonfile.get_as_text())


# imposta il valore di una variabile booleana
func setVariables(var_data):
	save_data["DIALOGUE_VARS"][var_data[0]] = var_data[1]
	print(save_data)

# controlla il valore di una o più variabili booleane
func checkVariables(variables):
	for var_name in variables:
		if !save_data["DIALOGUE_VARS"].has(var_name) || !str2var(save_data["DIALOGUE_VARS"][var_name]):
			emit_signal("if_result", 0)
			return
	emit_signal("if_result", 1)
