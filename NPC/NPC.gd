extends StaticBody2D

# N P C --------------------|

# l'NPC è un personaggio non giocante
# Deve contenere tutti dati relativi al personaggio, come dialoghi e sprite, 
# oltre al personaggio fisicamente presente
# deve essere sviluppato tenendo in mente la logica della scalarità

# V A R I A B I L I --------------------|

# la risorsa NPC_Data che contiene i dati del personaggio
export (Resource) var data 
# dizionario, conterrà il dialogo
var _dialogue = {}

# F U N Z I O N I --------------------|

# carica i dati del personaggio nel suo NPC_Data
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
	
