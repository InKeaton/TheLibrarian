extends KinematicBody2D

# TO DO
# - ~collisioni~
# - iterazione fra oggetti e speakbox

# V A R I A B I L I --------------------|

# velocità
export var speed = 400
# vita del giocatore
var _health = 500
# variabili temporanee per implementare il dialogo
var _is_in_dialogue = false
# segnale variazione salute
signal health_changed( new_health )
# segnale poter parlare
signal can_talk( interlocutor )
# segnale per indicare che abbiamo premuto il tasto
# d'iterazione
signal is_answering()
# segnale che indica il cambio di scelta in un bivio
signal change_choice(direction)

# F U N Z I O N I ----------------------|

# Called when the node enters the scene tree for the first time.
func _ready():
	# posizione iniziale
	position.x = 600
	position.y = 400
	# animazione di default
	$AnimatedSprite.animation = "down"
	# invia la salute iniziale
	emit_signal("health_changed", _health)
	
func computeMovement(velocity):
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		# $Speakbox.rotation_degrees = 270
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		# $Speakbox.rotation_degrees = 90
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		# $Speakbox.rotation_degrees = 0
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		# $Speakbox.rotation_degrees = 180
	# normalizza il movimento in caso di movimento diagonale
	if velocity.length() > 0: 
		velocity = velocity.normalized() * speed
	return velocity

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	# temporaneo: controlla se mettere a schermo intero
	if Input.is_action_pressed("toggle_fullscreen"): OS.window_fullscreen = !OS.window_fullscreen
	# comunichiamo al dialogue manager che vogliamo 
	# iniziare un dialogo, o continuarlo 
	if Input.is_action_just_released("talk"): emit_signal("is_answering")
	# comunichiamo al dialogue manager che vogliamo cambiare scelta
	if _is_in_dialogue:
		if Input.is_action_just_pressed("choice_left_up") : emit_signal("change_choice", "LEFT")
		if Input.is_action_just_pressed("choice_right_down") : emit_signal("change_choice", "RIGHT")

func _on_EyeFrames_timeout():
	# alla fine degli eyeframes, fa tornare lo sprite normale
	$AnimatedSprite.set_modulate(Color(1, 1, 1))

func _on_Speakbox_body_entered(body):
	# in caso si possa parlare, invia l'interlocutore al DialogueManager
	if body.is_in_group("Character"):
		print(body.name)
		emit_signal("can_talk", body)

func _on_Speakbox_body_exited(body):
	# in caso non si possa più parlare, invia null al DialogueManager
	if body.is_in_group("Character"):
		emit_signal("can_talk", null)

func _on_DialogueManager_dialogue_started():
	# quando iniza una dialogo, viene comunicato bloccando il movimento
	_is_in_dialogue = true

func _on_DialogueManager_dialogue_ended():
	# quanto un dialogo è finito, viene comunicato al giocatore, facendo ripartire 
	# il movimento 
	_is_in_dialogue = false

#puzzi

