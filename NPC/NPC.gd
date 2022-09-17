extends StaticBody2D

export (Resource) var data 
# dizionario, conterrà il dialogo
var _dialogue = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var jsonfile = File.new()
	jsonfile.open(data.dialogue_path, File.READ)
	_dialogue = parse_json(jsonfile.get_as_text())  
