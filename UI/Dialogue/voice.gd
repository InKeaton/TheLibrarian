extends AudioStreamPlayer2D

var _random_number_gen := RandomNumberGenerator.new()

# Generate rando
func _ready() -> void:
	_random_number_gen.randomize()

# We're gonna select a random pitch for each time the voice is played
func pitched_play(from_position := 0.0) -> void:
	pitch_scale = _random_number_gen.randf_range(0.95, 1.08)
	play(from_position)
