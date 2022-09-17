extends Node

enum {
	NODDING, LISTENING, CHOOSING
}

# dialogo
const DIALOGUE_SCENE := preload("res://Dialogue/Dialogue.tscn")
# scelta
const CHOICE_SCENE := preload("res://Dialogue/ChoiceBox.tscn")

# l'interlocutore del momento, indica se possiamo parlare con qualcuno
var _current_interlocutor
# la casella di testo
var _dialogue_box
# la casella che contiene le scelte
var _choice_box
# la variabile che contiene l'indice della prossima scena
# temporanea per le scelte
var _next_section = -1
# indica se si può andare avanti
var _dialogue_status = NODDING
# indica la sezione corrente
var _section_id = "start"
# indica la frase a cui siamo arrivati
var _message_id = 0

# indica che è iniziato un dialogo
signal dialogue_started()
# indica che abbiamo finito con il dialogo
signal dialogue_ended()
# indica che dobbiamo cambiare una scelta
signal choice_changed(option)
# invia al main una variabile da controllare
signal check_if(variables)
# imposta valore variabile in main
signal set_var(var_data)


func initializeDialogue() -> void:
	# Invia il seganle di inizio dialogo 
	emit_signal("dialogue_started")
	# inizializza la variabile dialogo
	_dialogue_box = DIALOGUE_SCENE.instance()
	get_tree().get_root().get_node("main/HUD").add_child(_dialogue_box)
	_dialogue_box.connect("message_completed", self,"_on_message_completed")

func updateDialogue() -> void:
	# aggiorna il messaggio del dialogo e le variabili relative
	_dialogue_box.update_message(_current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["MESSAGES"][_message_id])
	_dialogue_status = LISTENING
	_message_id += 1

func endDialogue() -> void:
	# elimina il dialogo
	_dialogue_box.disconnect("message_completed", self,"_on_message_completed")
	_dialogue_box.queue_free()
	_dialogue_box = null
	# resetta le variabili
	_dialogue_status = NODDING
	_section_id = "start"
	_message_id = 0
	# aggiorna la timeline dell'NPC
	if str2var(_current_interlocutor.data.timeline_id) < _current_interlocutor._dialogue.size() - 1:
		_current_interlocutor.data.timeline_id = var2str(1 + str2var(_current_interlocutor.data.timeline_id))
	# invia il segnale di fine dialogo
	emit_signal("dialogue_ended")

func initializeChoice() -> void:
	# creiamo una choicebox
	_choice_box = CHOICE_SCENE.instance()
	get_tree().get_root().get_node("main/HUD").add_child(_choice_box)
	self.connect("choice_changed", _choice_box, "_on_choice_changed")
	# impostiamo le possibili scelte
	_choice_box.set_choices(_current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["CHOICE"])
	# impostiamo lo stato di scelta
	_dialogue_status = CHOOSING
	
func chooseOption() -> void:
	# impostiamo la prossima sezione
	_section_id = _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["CHOICE"][_next_section]
	# resettiamo le variabili
	_message_id = 0
	_next_section = -1
	# distruggiamo la choicebox
	self.disconnect("choice_changed", _choice_box, "_on_choice_changed")
	_choice_box.destroy()
	_choice_box = null
	# aggiorniamo il dialogo
	updateDialogue()

func _on_message_completed() -> void:
	# quando un messagio ha finito di essere stato scritto,
	# permettiamo al giocatore di andare avanti
	_dialogue_status = NODDING

func _on_Player_can_talk(interlocutor):
	# quando il giocatore è nei pressi di un NPC questi viene inviato
	# al dialogue manager e salvato. Funziona anche come bool per capire
	# se possiamo far partire un dialogo
	_current_interlocutor = interlocutor
	# mostriamo l'icona per parlare quando necessario
	if interlocutor:
		$TalkIcon.set_position(interlocutor.position + interlocutor.data.bubble_pos)
		$TalkIcon/Icon.visible = true
	else : 
		$TalkIcon/Icon.visible = false

func _on_Player_change_choice(direction):
	if _dialogue_status == CHOOSING:
		# sposta opzione a sinistra
		if direction == "LEFT" &&_next_section > 0: 
			_next_section -= 1
			emit_signal("choice_changed", _next_section)
		elif direction == "LEFT" && _next_section > 0: 
			_next_section = 0 
			emit_signal("choice_changed", _next_section)
			# sposta opzione a destra
		elif direction == "RIGHT" && _next_section < _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["CHOICE"].size() - 1: 
			_next_section += 1
			emit_signal("choice_changed", _next_section)
		elif direction == "RIGHT" && _next_section >= _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["CHOICE"].size() - 1:
			_next_section = 0 
			emit_signal("choice_changed", _next_section)

func _on_Player_is_answering():
	# se il giocatore è nelle vicinanze di un NPC
	if _current_interlocutor:
		# se possiamo far andare avanti il dialogo
		if _dialogue_status == NODDING:
			# se non siamo in dialogo, lo facciamo partire
			if !_dialogue_box: 
				initializeDialogue()
			# se ci sono ulteriori frasi da mostrare, aggiorna il dialogo
			if _message_id < _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["MESSAGES"].size():
				updateDialogue()
			# se no, passiamo alla prossima sezione indicata
			else: 
				if _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id].has("SIGNAL"):
					emit_signal("set_var", _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["SIGNAL"])
				# mostriamo una scelta
				if _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id].has("CHOICE"):
					initializeChoice()
				# saltiamo ad un altra sezione
				elif _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id].has("JUMP_TO"):
					_section_id = _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["JUMP_TO"]
					_message_id = 0
					updateDialogue()
				# Controlliamo una variabile nei salvataggi, e saltaimo a diverse sezioni in base al risultato
				elif _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id].has("IF"):
					emit_signal("check_if", _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["IF"][0])
					_dialogue_status = LISTENING
				# concludiamo il dialogo
				elif _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id].has("END_DIALOGUE"):
					endDialogue()
		# se siamo in un bivio, confermiamo la nostra scelta
		elif _dialogue_status == CHOOSING && _next_section != -1:
			chooseOption()

func _on_main_if_result(result):
	_section_id = _current_interlocutor._dialogue[_current_interlocutor.data.timeline_id][_section_id]["IF"][1][result]
	_dialogue_status = NODDING
	updateDialogue()
