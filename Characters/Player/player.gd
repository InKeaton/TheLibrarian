extends CharacterBody2D

# movement speed
@export var _speed: int = 350

# object variables
@onready var speakbox = $Speakbox
@onready var animation_player = $Sprite/AnimationPlayer

# TO DO
# + implement a better fullscreen code
var is_fullscreen = false

signal has_interacted_with(interlocutor: Node)

# T O  D O
# * add support for:
#   - sprinting
#   - ...

# compute movement
func compute_movement() -> void:
	# reset velocity
	velocity = Vector2.ZERO
	
	# change value depending on input
	# TO CHECK -> make it so you can change direction while moving
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		speakbox.rotation_degrees = 270
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		speakbox.rotation_degrees = 90
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		speakbox.rotation_degrees = 0
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		speakbox.rotation_degrees = 180
	if Input.is_action_just_released("toggle_fullscreen"):
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			is_fullscreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			is_fullscreen = true
	
	# normalize movement
	if velocity.length() > 0: 
		velocity = velocity.normalized() * _speed

func set_animation() -> void:
	# decides if to play the animation
	if velocity.length() > 0: 
		animation_player.play()
	else: 
		animation_player.stop()
	
	# choose animation
	if velocity.x > 0:
		animation_player.current_animation = "walk_right"
	elif velocity.x < 0:
		animation_player.current_animation = "walk_left"
	elif velocity.y < 0:
		animation_player.current_animation = "walk_up"
	elif velocity.y > 0:
		animation_player.current_animation = "walk_down"

func check_possible_iterations() -> void:
	if (Input.is_action_just_released("accept") && speakbox.is_colliding()):
		var possible_interlocutor : Node = speakbox.get_collider()
		if possible_interlocutor.is_in_group("interlocutors"):
			emit_signal("has_interacted_with", possible_interlocutor)
			set_process(false)

# executed at scene startup
func _ready():
	# set default animation
	animation_player.stop()
	animation_player.current_animation = "walk_down"

# executed every frame
func _process(_delta):
	check_possible_iterations()
	compute_movement()
	set_animation()
	move_and_slide()
	# set_process(false) può essere utile!, idem _input

func _on_dialogue_manager_iteraction_ended():
	set_process(true)
