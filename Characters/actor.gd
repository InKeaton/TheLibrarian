extends Sprite2D

# Actor Name
@export var _name: String
# Dialogue file JSON
@export var _dialogue_path: String = "res://_resources/data/"
# Actual formatted dialogue
var _dialogue: Array = []
# Dialogue Progression
var _dialogue_progression: int = 0

func _ready():
	# set hitboxes
	$Body/Hitbox.shape.extents.x = self.texture.get_width() / 2
	$Body/Hitbox.shape.extents.y = self.texture.get_height() / 2
	# set dialogue
	_dialogue = JSON.parse_string(FileAccess.get_file_as_string(_dialogue_path))
	
