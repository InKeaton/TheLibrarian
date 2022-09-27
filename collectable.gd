extends StaticBody2D

func on_body_collected():
	self.queue_free()
	
	
