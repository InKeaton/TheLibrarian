class_name DialogueParser
extends Node2D

# Tag per trovare le pause, in formato {p=.f}
const PAUSE_PATTERN := "({p=\\d([.]\\d+)?[}])"

# Tag in più
const FLOAT_PATTERN := "\\d+\\.\\d+"
const BBCODE_I_PATTERN := "\\[(?!\\/)(.*?)\\]"
const BBCODE_E_PATTERN := "\\[\\/(.*?)\\]"

# Tag che indica tutti i tag di formato {%s}
const CUSTOM_TAG_PATTERN := "({(.*?)})"

# Lista di pause
var _pauses := []

# Pause Regex
var _pause_regex := RegEx.new()

# Auxiliary Regexes
var _float_regex := RegEx.new()
var _bbcode_i_regex := RegEx.new()
var _bbcode_e_regex := RegEx.new()
var _custom_tag_regex := RegEx.new()

# segnale che indica che c'è una pausa
signal pause_requested(duration)

# ================================ Lifecycle ================================ #

func _ready() -> void:
	# nella ready, vengono inizializzate le RegEx
	# Tags
	_pause_regex.compile(PAUSE_PATTERN)

	# Auxiliary
	_float_regex.compile(FLOAT_PATTERN)
	_bbcode_i_regex.compile(BBCODE_I_PATTERN)
	_bbcode_e_regex.compile(BBCODE_E_PATTERN)
	_custom_tag_regex.compile(CUSTOM_TAG_PATTERN)

# ================================= Public ================================== #

# Estrae tutti i tag di tipo {p=f}, salva le pause nel pauses array, e ritorna la
# stringa pulita
func extract_pauses_from_string(source_string: String) -> String:
	_pauses = []
	find_pauses(source_string)
	return extract_pauses(source_string)

# Controlla se eseguire una pausa al momento
func check_at_position(pos: int) -> void:
	for _pause in _pauses:
		if _pause.pause_pos == pos:
			emit_signal("pause_requested", _pause.duration)
	
# ================================ Private ================================== #

# Trova tutte le pause della stringa e le salva nell'array _pauses, in formato Pause
# una classe custom che abbiamo creato
func find_pauses(from_string: String) -> void:

	var _found_pauses := _pause_regex.search_all(from_string)

	for _pause_regex_result in _found_pauses:
		var _tag_string := _pause_regex_result.get_string() as String
		var _tag_position := adjust_position(
			_pause_regex_result.get_start(),
			from_string
		)
		var _pause = Pause.new(_tag_position, _tag_string)
		_pauses.append(_pause)

# aggiusta la posizione delle pause, la quale può essere modificata dalla lunghezza
# dei tag bbcode e dalle pause
func adjust_position(pos: int, source_string: String) -> int:
	
	# Previous tags
	var _new_pos := pos
	var _left_of_pos := source_string.left(pos)

	var _all_prev_tags := _custom_tag_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_tags:
		_new_pos -= _tag_result.get_string().length()
	
	var _all_prev_start_bbcodes := _bbcode_i_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_start_bbcodes:
		_new_pos -= _tag_result.get_string().length()

	var _all_prev_end_bbcodes := _bbcode_e_regex.search_all(_left_of_pos)
	for _tag_result in _all_prev_end_bbcodes:
		_new_pos -= _tag_result.get_string().length()

	return _new_pos

# Rimuove i custom tag dalla stringa
func extract_pauses(from_string: String) -> String:
	return _custom_tag_regex.sub(from_string, "", true)
