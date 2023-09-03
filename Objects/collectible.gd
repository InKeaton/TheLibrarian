extends Area2D

@export var _type : String
signal collected(var_and_values : Array)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	emit_signal("collected", ["COLLECTIBLES", _type, 1, 1])
	self.queue_free()
