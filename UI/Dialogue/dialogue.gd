# casella di teso, ricevuto l'input mostra il messaggio, considerando anche eventuali pause e "voci"
class_name Dialogue
extends Control

# variabili "onready", inizializzate quando il nodo entra nell'albero
@onready var dialogue_parser := get_node("DialogueParser") as DialogueParser
@onready var content := get_node("Background/Text") as RichTextLabel
@onready var voice_player := get_node("Voice") as AudioStreamPlayer2D
@onready var type_timer := get_node("TypeTimer") as Timer
@onready var pause_timer := get_node("PauseTimer") as Timer

# T O  D O:
# * add other functions other than pause in the dialogue parser
#   examples:
#	  - different typing speed
#	  - etc
# * improve the synergy with the choice

var _playing_voice: bool = false

signal message_completed()

# Cambia il messaggio con quello di adesso, e fa partire la scrittura a schermo
func update_message(message: String) -> void:
	# Pause detection logic
	content.text = dialogue_parser.extract_pauses_from_string(message)
	content.visible_characters = 0
	
	type_timer.start()
	
	_playing_voice = true
	voice_player.play(0)

# Ritorna vero quando non ci sono più caratteri da mostrare
func message_is_fully_visible() -> bool:
	return content.visible_characters >= content.get_total_character_count()

# Chiamata quando ha finito di mostrare un carattere
func _on_type_timer_timeout()-> void:
	dialogue_parser.check_at_position(content.visible_characters)
	if !message_is_fully_visible():
		content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()
		emit_signal("message_completed")
		
# Chiamata quando la voce smette di suonare
func _on_voice_finished() -> void:
	if _playing_voice:
		voice_player.play(0)
	
# Chiamata quando il DialogueParser richiede una pausa
func _on_dialogue_parser_pause_requested(duration: float) -> void:
	_playing_voice = false
	type_timer.stop()
	pause_timer.wait_time = duration
	pause_timer.start()

# Chiamata quando finisce una pausa
func _on_pause_timer_timeout() -> void:
	_playing_voice = true
	voice_player.play(0)
	type_timer.start()

func _on_message_completion_request() -> void:
	content.visible_characters = -1
	_playing_voice = false
	type_timer.stop()
	pause_timer.stop()
	emit_signal("message_completed")

func _on_choice_begun() -> void:
	$Background.size.x -= 300

func _on_choice_ended() -> void:
	$Background.size.x += 300









