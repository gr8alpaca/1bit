@tool
extends EditorScript


const BIT_MAP = preload("res://BitMap.tres")
 

func _run() -> void:
	print("\nRunning Editor Script...")
	
	
	#var list: ItemList = get_scene().find_child("BitMapList")
	#list.set_item_icon(0, EditorInterface.get_editor_theme().get_icon("BitMap", "EditorIcons"))
	#print(EditorInterface.get_resource_filesystem().get_file_type("res://BitMap.tres"))
	#var draw: Button = get_scene().get_node("%DotsButton")
	#draw.icon = EditorInterface.get_editor_theme().get_icon("GuiTabMenuHl", "EditorIcons")
