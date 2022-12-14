extends Node

# D I A L O G U E   M A N A G E R --------------------|

# Nodo il cui scopo è gestire il dialogo in tutte le sue forme, dall'
# aggiornamento delle caselle di dialogo e scelta, alla gestione della posizione 
# dell'indicatore di inizio dialogo (Bubble)

# V A R I A B I L I --------------------|

# stati del dialogo
enum { NODDING, LISTENING, CHOOSING }
# dialogo
const DIALOGUE_SCENE := preload("res://UI/Dialogue/Dialogue.tscn")
# scelta
const CHOICE_SCENE := preload("res://UI/Dialogue/ChoiceBox.tscn")

# l'interlocutore del momento, indica se possiamo parlare con qualcuno
var _current_interlocutor: Node
# la casella di testo
var _dialogue_box: Node
# la casella che contiene le scelte
var _choice_box: Node
# la variabile che contiene l'indice della prossima scena
# temporanea per le scelte
var _next_section: int = -1
# indica se si può andare avanti
var _dialogue_status: int = NODDING
# la sezione corrente
var _section: Dictionary
# indica la frase a cui siamo arrivati
var _message_id: int = 0

# indica che è iniziato un dialogo
signal dialogue_started()
# indica che abbiamo finito con il dialogo
signal dialogue_ended()
# indica che dobbiamo cambiare una scelta
signal choice_changed(option)
# invia al main una variabile da controllare
signal check_vars(variables)
# imposta valore variabile in main
signal set_vars(var_data)

# F U N Z I O N I --------------------|

# inizializza la dialogue box
func initializeDialogue() -> void:
	# Invia il segnale di inizio dialogo 
	emit_signal("dialogue_started")
	# inizializza la variabile dialogo
	_dialogue_box = DIALOGUE_SCENE.instance()
	get_tree().get_root().get_node("main/HUD").add_child(_dialogue_box)
	_dialogue_box.connect("message_completed", self,"_on_message_completed")
	# inizializza la sezione del dialogo
	_section = _current_interlocutor._dialogue[_current_interlocutor.timeline_id]["start"]
	# mostra la dialogue box
	yield(create_tween().tween_property(_dialogue_box, "modulate", Color("ffffff"), 0.15), "finished")

# aggiorna il messaggio del dialogo e le variabili relative
func updateDialogue() -> void:
	_dialogue_box.update_message(_section["MESSAGES"][_message_id])
	_dialogue_status = LISTENING
	_message_id += 1

# conclude il dialogo
func endDialogue() -> void:
	# nasconde la dialogue box
	yield(create_tween().tween_property(_dialogue_box, "modulate", Color("00ffffff"), 0.15), "finished")
	# elimina la dialogue box
	_dialogue_box.disconnect("message_completed", self,"_on_message_completed")
	_dialogue_box.queue_free()
	_dialogue_box = null
	# resetta le variabili
	_dialogue_status = NODDING
	_message_id = 0
	# aggiorna la timeline dell'NPC se non vietato dal contenuto di END_DIALOGUE 
	# o se non va in overflow
	if _current_interlocutor.timeline_id < _current_interlocutor._dialogue.size() - 1 && _section["END_DIALOGUE"]:
		_current_interlocutor.timeline_id += 1
	# invia il segnale di fine dialogo
	emit_signal("dialogue_ended")

# inizializza la choice box
func initializeChoice() -> void:
	# creiamo una choicebox
	_choice_box = CHOICE_SCENE.instance()
	get_tree().get_root().get_node("main/HUD").add_child(_choice_box)
	self.connect("choice_changed", _choice_box, "_on_choice_changed")
	# impostiamo le possibili scelte
	_choice_box.set_choices(_section["CHOICE"])
	# impostiamo lo stato di scelta
	_dialogue_status = CHOOSING
	# mostriamo la choicebox
	yield(create_tween().tween_property(_choice_box, "modulate", Color("ffffff"), 0.1), "finished")

# conferma la scelta
func chooseOption() -> void:
	# impostiamo la prossima sezione
	_section = _current_interlocutor._dialogue[_current_interlocutor.timeline_id][_section["CHOICE"][_next_section]]
	# resettiamo le variabili
	_message_id = 0
	_next_section = -1
	# nascondiamo la choice box
	yield(create_tween().tween_property(_choice_box, "modulate", Color("00ffffff"), 0.1), "finished")
	# distruggiamo la choicebox
	self.disconnect("choice_changed", _choice_box, "_on_choice_changed")
	_choice_box.destroy()
	_choice_box = null
	# aggiorniamo il dialogo
	updateDialogue()

# S E G N A L I --------------------|

# permette al giocatore di andare avanti quando finisce il messaggio
func _on_message_completed() -> void:
	_dialogue_status = NODDING

# permettiamo l'inizio del dialogo
func _on_Player_can_talk(interlocutor: Node) -> void:
	# quando il giocatore è nei pressi di un NPC questi viene inviato
	# al dialogue manager e salvato. Funziona anche come bool per capire
	# se possiamo far partire un dialogo
	# mostriamo l'icona per parlare quando necessario
	if interlocutor:
		_current_interlocutor = interlocutor.get_parent()
		$TalkIcon.set_position(_current_interlocutor.position + _current_interlocutor.bubble_pos)
		create_tween().tween_property($TalkIcon, "modulate", Color("ffffff"), 0.15)
	else : 
		_current_interlocutor = interlocutor
		create_tween().tween_property($TalkIcon, "modulate", Color("00ffffff"), 0.15)

# cambiamo l'opzione attuale in una scelta
func _on_Player_change_choice(direction):
	if _dialogue_status == CHOOSING:
		# sposta opzione a sinistra
		if direction == "LEFT" &&_next_section > 0: 
			_next_section -= 1
			emit_signal("choice_changed", _next_section)
		elif direction == "LEFT" && _next_section == 0: 
			_next_section = _section["CHOICE"].size() - 1
			emit_signal("choice_changed", _next_section)
			# sposta opzione a destra
		elif direction == "RIGHT" && _next_section < _section["CHOICE"].size() - 1: 
			_next_section += 1
			emit_signal("choice_changed", _next_section)
		elif direction == "RIGHT" && _next_section >= _section["CHOICE"].size() - 1:
			_next_section = 0 
			emit_signal("choice_changed", _next_section)

# impostiamo il nuovo messaggio, sulla base delle variabili
func _on_Player_is_answering():
	# se il giocatore è nelle vicinanze di un NPC
	if _current_interlocutor:
		# se possiamo far andare avanti il dialogo
		if _dialogue_status == NODDING:
			# se non siamo in dialogo, lo facciamo partire
			if !_dialogue_box: 
				initializeDialogue()
			# se ci sono ulteriori frasi da mostrare, aggiorna il dialogo
			if _message_id < _section["MESSAGES"].size():
				updateDialogue()
			# se no, passiamo alla prossima sezione indicata
			else: 
				# salviamo una variabile in memoria
				if _section.has("SET_VARS"):
					emit_signal("set_vars", _section["SET_VARS"])
					
				# mostriamo una scelta
				if _section.has("CHOICE"):
					initializeChoice()
					
				# saltiamo ad un altra sezione
				elif _section.has("JUMP_TO"):
					_section = _current_interlocutor._dialogue[_current_interlocutor.timeline_id][_section["JUMP_TO"]]
					_message_id = 0
					updateDialogue()
					
				# Controlliamo una variabile nei salvataggi, e saltiamo a diverse sezioni in base al risultato
				elif _section.has("CHECK_VARS"):
					emit_signal("check_vars", _section["CHECK_VARS"][0])
					_dialogue_status = LISTENING
					
				# concludiamo il dialogo
				elif _section.has("END_DIALOGUE"):
					endDialogue()
					
		# se siamo in un bivio, confermiamo la nostra scelta
		elif _dialogue_status == CHOOSING && _next_section != -1:
			chooseOption()

# cambiamo sezione sulla base del risultato di un CHECK_VARS del dialogo
func _on_SaveManager_if_result(result):
	_section = _current_interlocutor._dialogue[_current_interlocutor.timeline_id][_section["CHECK_VARS"][1][result]]
	_dialogue_status = NODDING
	updateDialogue()
