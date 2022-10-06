extends Sprite

# N P C --------------------|

# l'NPC è un personaggio non giocante
# Deve contenere tutti dati relativi al personaggio, come dialoghi e sprite, 
# oltre al personaggio fisicamente presente
# deve essere sviluppato tenendo in mente la logica della scalarità

# V A R I A B I L I --------------------|

# dizionario, conterrà il dialogo
var _dialogue = {}

# path del dialogo
export (String) var dialogue_path = "res://_data/"
# timeline, indicatore del progresso nel dialogo
export (int) var timeline_id = 0
# posizione dell'indicatore di dialogo
export (Vector2) var bubble_pos = Vector2()

# F U N Z I O N I --------------------|

# carica i dati del personaggio
func _ready():
	# crea hitbox
	$Hitbox/CollisionShape2D.shape = RectangleShape2D.new()
	# imposta dimensioni
	$Hitbox/CollisionShape2D.shape.extents.x = self.texture.get_width() / 2
	$Hitbox/CollisionShape2D.shape.extents.y = self.texture.get_height() / 2
	# carica dialogo
	var jsonfile = File.new()
	jsonfile.open(dialogue_path, File.READ)
	_dialogue = parse_json(jsonfile.get_as_text())  
	
