extends TextureButton

func _ready(): 
	$Sprite.visible = false
	

func set_text(text):
	$RichTextLabel.bbcode_text = text

# called when the button gains focus
func _on_Option_focus_entered():
	$Sprite.visible = true
	$RichTextLabel.set_modulate(Color("edaf73"))

# called when the button loses focus
func _on_Option_focus_exited():
	$Sprite.visible = false
	$RichTextLabel.set_modulate(Color("ffffff"))
