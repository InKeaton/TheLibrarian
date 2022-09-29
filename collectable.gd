extends StaticBody2D

export  (String) var sprite_path

# dovrò impostare sprite, dimensione hitbox, segnale da inviare alla distruzione
func ready():
	pass

func on_body_collected():
	self.queue_free()
	
	
