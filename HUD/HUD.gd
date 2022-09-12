extends CanvasLayer

signal health_changed(new_health)

# quando il giocatore subisce danni, viene modificata
# la lunghezza della barra
func _on_Player_health_changed(new_health):
	emit_signal("health_changed", new_health)
