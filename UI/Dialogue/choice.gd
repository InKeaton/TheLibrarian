extends TextureButton

#@onready var content := get_node("Choice/Text") as RichTextLabel

func set_text(text):
	$Text.text = text

# called when the button gains focus
func _on_Option_focus_entered():
	$Text.set_modulate(Color("edaf73"))

# called when the button loses focus
func _on_Option_focus_exited():
	$Text.set_modulate(Color("ffffff"))


