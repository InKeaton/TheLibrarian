extends StaticBody2D

# posizione bolla di dialogo
export var _bubble_pos = Vector2(-55, -80)
# dizionario, conterrà il dialogo
var _dialogue = {}
# indicatore di quante volte le abbiamo parlato, e a quale dialogo accedere
var _timeline_id = "0"
# percorso del dialogo
export var _dialogue_path = "res://_data/madonna.json"
# percorso dello sprite
export var sprite = "res://_sprites/chrctrs/MadonnaStill.png"



# Called when the node enters the scene tree for the first time.
func _ready():
	var jsonfile = File.new()
	jsonfile.open(_dialogue_path, File.READ)
	_dialogue = parse_json(jsonfile.get_as_text())  
