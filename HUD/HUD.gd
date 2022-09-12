extends CanvasLayer

signal health_changed(new_health)

# quando il giocatore può parlare, viene mostrata un icona vicino ad esso
func _on_Player_can_talk(interlocutor):
	if interlocutor:
		$TalkIcon.set_position(interlocutor.position + interlocutor._bubble_pos)
		$TalkIcon/Icon.visible = true
	else : 
		$TalkIcon/Icon.visible = false
		
# quando il giocatore subisce danni, viene modificata
# la lunghezza della barra
func _on_Player_health_changed(new_health):
	emit_signal("health_changed", new_health)
