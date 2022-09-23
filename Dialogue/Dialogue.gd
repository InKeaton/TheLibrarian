# casella di teso, ricevuto l'input mostra il messaggio, considerando anche eventuali pause e "voci"
class_name Dialogue
extends Control

# variabili "onready", inizializzate quando il nodo entra nell'albero
onready var pause_calculator := get_node("PauseCalculator") as PauseCalculator
onready var content := get_node("Content") as RichTextLabel
onready var voice_player := get_node("DialogueVoicePlayer") as AudioStreamPlayer
onready var type_timer := get_node("TypeTyper") as Timer
onready var pause_timer := get_node("PauseTimer") as Timer
onready var tween := create_tween()


var _playing_voice := false

signal message_completed()

func show():
	tween.tween_property(self, "modulate", Color("ffffff"), 0.15)


func hide():
	tween.tween_property(self, "modulate", Color("00ffffff"), 0.15)
# Cambia il messaggio con quello di adesso, e fa partire la scrittura a schermo
func update_message(message: String) -> void:
	$TalkIndicator.visible = false
	# Pause detection logic
	content.bbcode_text = pause_calculator.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	voice_player.play(0)

# Ritorna vero quando non ci somo più caratteri da mostrare
func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.text.length() - 1

# Chiamta quando ha finito di mostrare un carattere
func _on_TypeTyper_timeout() -> void:
	pause_calculator.check_at_position(content.visible_characters)
	if content.visible_characters < content.text.length():
		content.visible_characters += 1
	else:
		_playing_voice = false
		$TalkIndicator.visible = true
		type_timer.stop()
		emit_signal("message_completed")

# Chiamata quando la voce smette di suonare
func _on_DialogueVoicePlayer_finished() -> void:
	if _playing_voice:
		voice_player.play(0)

# Chiamata quando il pauseCalculator richiede una pausa
func _on_PauseCalculator_pause_requested(duration: float) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()

# Chiamata quando finisce una pausa
func _on_PauseTimer_timeout() -> void:
	_playing_voice = true
	voice_player.play(0)
	type_timer.start()

