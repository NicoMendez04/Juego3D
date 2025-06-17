extends CanvasLayer

func _ready():
	var label = $Label
	await get_tree().process_frame  # Esperar un frame para que todo esté cargado
	label.position = get_viewport().get_visible_rect().size / 2 - label.size / 2
