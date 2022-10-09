extends Sprite

# C O L L E C T A B L E --------------------|

# collectable è un oggetto collezionabile
# quando il giocatore lo tocca, questi deve segnalarlo al giocatore
# od al save manager.
# si potrebbero implementare degli eventi speciali legati al collezionamento...

# V A R I A B I L I --------------------|

export var variable: Array
# segnale, indica che l'oggetto è stato raccolto
signal got_collected()

# F U N Z I O N I --------------------|

func _ready():
	$AnimationPlayer.play("idle")
	pass
	
# quando il collezionabile viene toccato dal giocatore, viene eliminato e segnalato al giocatore
func _on_Collectable_body_entered(body):
	if body.is_in_group("Player"):
		$AnimationPlayer.stop()
		# yield(create_tween().tween_property(self, "mod#ulate", Color("00ffffff"), 0.05), "finished")
		connect("got_collected", get_tree().get_root().get_node("main/SaveManager"), "setVariables")
		emit_signal("got_collected", variable)
		self.queue_free()
