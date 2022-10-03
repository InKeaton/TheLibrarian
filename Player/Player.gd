extends KinematicBody2D

# P L A Y E R --------------------|

# player è sia il personaggio mosso sullo schermo, sia il modulo da cui
# gestire l'input del giocatore.
# In quanto tale, deve gestire il movimento del giocatore, le sue collisioni ed 
# animazioni, oltre a gestire l'inizio di eventi determinati dal giocatore, come
# dialoghi o menu

# V A R I A B I L I --------------------|

# velocità
export var speed = 400
# vita del giocatore
var _health = 500
# variabile che indica che stiamo sprintando
var _sprint = 0
# variabili temporanee per implementare il dialogo
var _is_in_dialogue = false
# testing
var _nearest_interlocutor
# segnale variazione salute
signal health_changed( new_health )
# segnale poter parlare
signal can_talk( interlocutor )
# segnale per indicare che abbiamo premuto il tasto
# d'iterazione
signal is_answering()
# segnale che indica il cambio di scelta in un bivio
signal change_choice(direction)
# segnale collezionabili
signal collect()

# F U N Z I O N I ----------------------|

# imposta le variabili iniziali
func _ready():
	# posizione iniziale
	position.x = 600
	position.y = 400
	# animazione di default
	$AnimatedSprite.animation = "down"
	# invia la salute iniziale
	emit_signal("health_changed", _health)

# calcola il moviemnto del giocatore, frame per frame
func computeMovement(velocity):
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	# determina se dobbiamo aumentare la velocità
	if Input.is_action_just_pressed("sprint"):
		_sprint += 1
	if Input.is_action_just_released("sprint"):
		_sprint -= 1
	# aumenta la velocità se sprintiamo
	speed = 400 + _sprint * 200
	# normalizza il movimento in caso di movimento diagonale
	if velocity.length() > 0: 
		velocity = velocity.normalized() * speed
	return velocity

# imposta l'animazione corrente
func setAnimation(velocity):
	# seleziona l'animazione corretta
	if velocity.x > 0:
		$AnimatedSprite.animation = "sideways"
		$AnimatedSprite.flip_h = true
	elif velocity.x < 0:
		$AnimatedSprite.animation = "sideways"
		$AnimatedSprite.flip_h = false
	elif velocity.y > 0:
		$AnimatedSprite.animation = "down"
		$AnimatedSprite.flip_h = false
	elif velocity.y < 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_h = false
	# riproduce l'animazione in caso di movimento
	if velocity.length() > 0: 
		$AnimatedSprite.play()
	else: 
		$AnimatedSprite.stop()

# calcola le reazioni alle collisioni fisiche
func computeCollisions():
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		# danni. Possono avvenire solo una volta per secondo
		if collision.collider.is_in_group("Damages") && ($EyeFrames.time_left == 0):
			# modifica la salute
			_health -= collision.collider.damage
			# invia la nuova salute all'HUD
			emit_signal("health_changed", _health)
			# fa partire gli eyeframes
			$EyeFrames.start()
			# rende trasparente lo sprite
			$AnimatedSprite.set_modulate(Color(1, 1, 1, 0.5))
			print(_health)

# trova la persona più vicina con cui parlare
func check_nearest_interlocutor():
	var areas: Array = $Speakbox.get_overlapping_bodies()
	var shortest_distance : float = INF
	var next_nearest_interlocutor : StaticBody2D = null
	
	for area in areas:
		var distance : float = area.global_position.distance_to(global_position)
		if area.is_in_group("collectable"):
			connect("collect", area, "on_body_collected")
			emit_signal("collect")
		if distance < shortest_distance && area.is_in_group("Character"):
			shortest_distance = distance
			next_nearest_interlocutor = area
	if next_nearest_interlocutor != _nearest_interlocutor or not is_instance_valid(next_nearest_interlocutor):
		_nearest_interlocutor = next_nearest_interlocutor
		emit_signal("can_talk", _nearest_interlocutor)

# funzione principale che avviene una volta a frame
func _process(_delta):
	# sezione dedicata al movimento	
	if !_is_in_dialogue:
		# velocity è un vettore che rappresenta la velocità attuale del giocatore
		var velocity = Vector2.ZERO
		# calcola il movimento
		velocity = computeMovement(velocity)
		# imposta l'animazione corrente
		setAnimation(velocity)
		# somma la posizione e gestisce le collisioni con StaticObject2D
		move_and_slide(velocity)
		# consideriamo ogni collisione
		computeCollisions()
		# testing: controlla quale è l'interlocutore più vicino
		check_nearest_interlocutor()
	# temporaneo: controlla se mettere a schermo intero
	if Input.is_action_pressed("toggle_fullscreen"): OS.window_fullscreen = !OS.window_fullscreen
	# comunichiamo al dialogue manager che vogliamo 
	# iniziare un dialogo, o continuarlo 
	if Input.is_action_just_released("talk"): emit_signal("is_answering")
	# comunichiamo al dialogue manager che vogliamo cambiare scelta
	if _is_in_dialogue:
		if Input.is_action_just_pressed("choice_left_up") : emit_signal("change_choice", "LEFT")
		if Input.is_action_just_pressed("choice_right_down") : emit_signal("change_choice", "RIGHT")

# S E G N A L I ----------------------|

# alla fine degli eyeframes, fa tornare lo sprite normale
func _on_EyeFrames_timeout():
	$AnimatedSprite.set_modulate(Color(1, 1, 1))

# quando iniza una dialogo, viene comunicato, bloccando il movimento
func _on_DialogueManager_dialogue_started():
	_is_in_dialogue = true
	$AnimatedSprite.stop()

# quanto un dialogo è finito, viene comunicato al giocatore, facendo ripartire 
	# il movimento 
func _on_DialogueManager_dialogue_ended():
	_is_in_dialogue = false

