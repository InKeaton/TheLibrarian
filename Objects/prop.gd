extends Sprite2D

# Prop Name
@export var _name: String

func _ready():
	# set hitboxes
	$Body/Hitbox.shape.extents.x = self.texture.get_width() / 2
	$Body/Hitbox.shape.extents.y = self.texture.get_height() / 2
