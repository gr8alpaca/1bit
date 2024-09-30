@tool
extends EditorPlugin


var main: Control


func _enter_tree() -> void:
	Engine.register_singleton(_get_plugin_name(), self)
	
	main = preload("main.tscn").instantiate()
	main.dock_button = add_control_to_bottom_panel(main, "eBit")


	EditorInterface.get_file_system_dock().files_moved.connect(_on_file_moved)
	resource_saved.connect(_on_resource_saved)


func _exit_tree() -> void:

	resource_saved.disconnect(_on_resource_saved)
	remove_control_from_bottom_panel(main)
	main.close()

	Engine.unregister_singleton(_get_plugin_name())


func _handles(object: Object) -> bool:
	return object is BitMap


func _edit(object: Object) -> void:
	make_bottom_panel_item_visible(main)


func _on_file_moved(old_file: String, new_file: String) -> void:
	pass

func _on_resource_saved(res: Resource) -> void:
	if res: print_rich("Resource Saved -> [color=pink]%s[/color] @ [color=pink]%s[/color]" % [res.resource_name, res.resource_path])


func _save_external_data() -> void:
	pass

func _apply_changes() -> void:
	pass


func _get_plugin_name() -> String:
	return "eBit"
func _get_plugin_icon() -> Texture2D:
	return preload("icon.svg")
