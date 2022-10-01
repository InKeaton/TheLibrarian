extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")

func on_body_collected():
	$AnimationPlayer.stop()
	# yield(create_tween().tween_property(self, "modulate", Color("00ffffff"), 0.1), "finished")
	self.queue_free()
