@tool
extends EditorPlugin


var main: Control


func _enter_tree() -> void:
	if not Engine.has_singleton(_get_plugin_name()): 
		Engine.register_singleton(_get_plugin_name(), self)

	main = preload("main.tscn").instantiate()
	var margin:= MarginContainer.new()
	main.parent_container = margin
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.set_anchors_preset(Control.PRESET_FULL_RECT,)
	margin.add_child(main)

	margin.add_theme_constant_override("margin_right", 0)
	margin.add_theme_constant_override("margin_left", 0)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 0)

	main.dock_button = add_control_to_bottom_panel(margin, "eBit")

	resource_saved.connect(_on_resource_saved)


func _exit_tree() -> void:

	if resource_saved.is_connected(_on_resource_saved): 
		resource_saved.disconnect(_on_resource_saved)

	remove_control_from_bottom_panel(main.parent_container)
	main.close()

	Engine.unregister_singleton(_get_plugin_name())


func _handles(object: Object) -> bool:
	return object is BitMap


func _edit(object: Object) -> void:
	make_bottom_panel_item_visible(main)


func _on_resource_saved(res: Resource) -> void:
	if res: 
		print_rich("Resource Saved -> [color=pink]%s[/color] @ [color=pink]%s[/color]" % [res.resource_name, res.resource_path])


func _save_external_data() -> void:
	pass


func _apply_changes() -> void:
	pass


func _get_plugin_name() -> String:
	return "eBit"
	
func _get_plugin_icon() -> Texture2D:
	return preload("icon.svg")
