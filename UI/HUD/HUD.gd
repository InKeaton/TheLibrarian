extends CanvasLayer

# H U D --------------------|

# Heads Up Display, nodo contenente elementi dell'UI
# Su di esso vengono innestati altri nodi figli a runtime, i quali facenti parte
# della UI, come le caselle di dialogo

# V A R I A B I L I --------------------|

# segnale che indica il cambio della salute, inviato alla Lifebar
signal health_changed(new_health)

# S E G N A L I --------------------|

# quando il giocatore subisce danni, viene modificata
# la lunghezza della barra
func _on_Player_health_changed(new_health):
	emit_signal("health_changed", new_health)
