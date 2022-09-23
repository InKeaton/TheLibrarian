extends Resource
class_name npc_data

# N P C   D A T A --------------------|

# Classe custom, costruita con lo scopo di facilitare la modifica delle informazioni dell' NPC
# Non certa, è possibile che le sue funzionalità vengano direttamente inglobate nell'NPC

# V A R I A B I L I --------------------|

# path della spritesheet
export (String) var spritesheet_path = "res://_sprites/chrctrs/"
# path del dialogo
export (String) var dialogue_path = "res://_data/"
# timeline, indicatore del progresso nel dialogo
export (String) var timeline_id = "0"
# posizione dell'indicatore di dialogo
export (Vector2) var bubble_pos = Vector2()
