extends StaticBody2D

export (Resource) var data 
# dizionario, conterrà il dialogo
var _dialogue = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	# carica spritesheet
	$Sprite.texture = load(data.spritesheet_path)
	# crea hitbox
	$Hitbox.shape = RectangleShape2D.new()
	# imposta dimensioni
	$Hitbox.shape.extents.x = $Sprite.texture.get_width() / 2
	$Hitbox.shape.extents.y = $Sprite.texture.get_height() / 2
	# carica dialogo
	var jsonfile = File.new()
	jsonfile.open(data.dialogue_path, File.READ)
	_dialogue = parse_json(jsonfile.get_as_text())  
	
