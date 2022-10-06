extends Area2D

# C O L L E C T A B L E --------------------|

# collectable è un oggetto collezionabile
# quando il giocatore lo tocca, questi deve segnalrlo al giocatore
# od al save manager.
# si potrebbero implementare degli eventi speciali legati al collezionamento...

# V A R I A B I L I --------------------|

signal got_collected()

# F U N Z I O N I --------------------|

func _ready():
	$AnimationPlayer.play("idle")
	
# quando il collezionabile viene toccato dal giocatore, viene eliminato e segnalato al giocatore
func _on_Collectable_body_entered(body):
	if body.is_in_group("Player"):
		$AnimationPlayer.stop()
		# yield(create_tween().tween_property(self, "modulate", Color("00ffffff"), 0.1), "finished")
		connect("got_collected", body, "_on_Collectable_acquired")
		emit_signal("got_collected")
		self.queue_free()
