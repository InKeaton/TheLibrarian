extends CharacterBody2D

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
	# REMEBER TO SET AS UNIQUE IN EDITOR
	$Hitbox.shape.extents.x = $Sprite.texture.get_width() / 2
	$Hitbox.shape.extents.y = $Sprite.texture.get_height() / 2
	# set dialogue
	_dialogue = JSON.parse_string(FileAccess.get_file_as_string(_dialogue_path))
	
