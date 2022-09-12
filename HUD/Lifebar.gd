extends CanvasLayer

func _on_HUD_health_changed(new_health):
	$Lifebar.rect_size.x = new_health
