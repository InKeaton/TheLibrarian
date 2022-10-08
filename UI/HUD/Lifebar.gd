extends CanvasLayer

func _on_HUD_health_changed(new_health):
	create_tween().tween_property($Lifebar, "rect_size", Vector2(new_health, $Lifebar.rect_size.y), 0.5).set_trans(Tween.TRANS_ELASTIC)
	# $Lifebar.rect_size.x = new_health
