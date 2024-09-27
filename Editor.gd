@tool
extends EditorScript

const BIT_MAP = preload("res://BitMap.tres")


func _run() -> void:
	print("\nRunning Editor Script...")
	var bar: GraphEdit = get_scene().get_node("%GraphEdit")
	if bar.get_menu_hbox(): print(bar.get_menu_hbox().get_children(true))
	#button.icon = EditorInterface.get_editor_theme().get_icon("MakeFloating", "EditorIcons")
	
