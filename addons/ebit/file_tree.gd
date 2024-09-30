@tool
extends Tree

var popup_menu: PopupMenu

func _ready() -> void:
	create_item()
	if not Engine.is_editor_hint(): return
	

	item_mouse_selected.connect(_on_item_mouse_selected)
	item_activated.connect(_on_item_activated)
	
	var file_dock: FileSystemDock = EditorInterface.get_file_system_dock()
	file_dock.file_removed.connect(_on_file_removed)
	file_dock.files_moved.connect(_on_file_moved)

	popup_menu = PopupMenu.new()
	popup_menu.theme = EditorInterface.get_editor_theme()
	popup_menu.add_item("Rename...", -1, KEY_F2)
	popup_menu.add_icon_item(popup_menu.get_theme_icon(&"Duplicate", &"EditorIcons"), "Duplicate...", -1, KEY_CTRL | KEY_D)
	popup_menu.add_separator()
	popup_menu.add_icon_item(popup_menu.get_theme_icon(&"Remove", &"EditorIcons"), "Delete...", -1, KEY_DELETE)
	popup_menu.index_pressed.connect(_on_popup_menu_pressed)


func add_file(file: String) -> void:
	var item: TreeItem = create_file_item(file)
	item.set_editable(0, false)
	item.set_icon(0, EditorInterface.get_editor_theme().get_icon(&"BitMap", &"EditorIcons"))
	item.set_button_color(0, 0, Color.TRANSPARENT)

	
## Also will update an inputted
func create_file_item(file: String, item: TreeItem = create_item()) -> TreeItem:
	item.set_metadata(0, file)
	item.set_text(0, file.get_file().trim_suffix(".tres"))
	item.set_tooltip_text(0, "%s\nSize: %s" % [file.trim_prefix("res://"), String.humanize_size(FileAccess.open(file, FileAccess.READ).get_length())])
	return item


# func _gui_input(event: InputEvent) -> void:
# 	if event is InputEventMouseButton:
# 		var item: TreeItem = get_item_at_position(event.position)
# 		if not item: return


func _get_drag_data(at_position: Vector2) -> Variant:
	return get_item_at_position(at_position)


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if (data is String and is_valid_bitmap(data)) or (data is TreeItem): drop_mode_flags = DROP_MODE_INBETWEEN
	return drop_mode_flags


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is TreeItem:
		if not get_item_at_position(at_position): return
		var callable: Callable = data.move_after if get_drop_section_at_position(at_position) > 0 else data.move_after
		callable.call(get_item_at_position(at_position))
		return

	add_file(data)


func _on_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	if not (mouse_button_index & MOUSE_BUTTON_RIGHT): return
	get_item_at_position(mouse_position)
	get_custom_popup_rect()


func _on_item_activated() -> void:
	get_selected()


func delete_item(file: String) -> void:
	DirAccess.remove_absolute(file)


func _on_add_pressed() -> void:
	pass


func _on_load_pressed() -> void:
	pass


func _on_file_removed(file: String) -> void:
	var item: TreeItem = get_item(file)
	if item: get_root().remove_child(item)
	

func _on_popup_menu_pressed(index: int) -> void:
	match index:
		0: # Rename
			pass
		1: # Duplicate
			pass
		3:
			confirm_delete(get_selected())


func _on_file_moved(old_file: String, new_file: String) -> void:
	if not is_valid_bitmap(new_file): return
	var item: TreeItem = get_item(old_file)
	if item: create_file_item(new_file, item)
	

func confirm_delete(item: TreeItem) -> void:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.ok_button_text = "Remove"
	dialog.dialog_text = "Remove the selected files from the project? (Cannot be undone.)"
	dialog.confirmed.connect(delete_item.bind(item.get_metadata(0)))
	dialog.confirmed.connect(dialog.emit_signal.bind("close_requested"), CONNECT_DEFERRED)
	dialog.close_requested.connect(dialog.queue_free, CONNECT_DEFERRED)
	EditorInterface.popup_dialog_centered(dialog)


func is_valid_bitmap(file: String) -> bool:
	return FileAccess.file_exists(file) and EditorInterface.get_resource_filesystem().get_file_type(file) == &"BitMap"


func get_item(file: String) -> TreeItem:
	for item: TreeItem in get_root().get_children():
		if item.get_metadata(0) == file: return item
	return null


func build_list() -> void:
	clear()
	for file: String in get_bitmap_files(EditorInterface.get_resource_filesystem().get_filesystem()):
		add_file(file)


func get_bitmap_files(dir: EditorFileSystemDirectory) -> PackedStringArray:
	var files: PackedStringArray
	for i: int in dir.get_file_count():
		if dir.get_file_type(i) == &"BitMap": files.push_back(dir.get_file(i))
	for i: int in dir.get_subdir_count():
		files.append_array(get_bitmap_files(dir.get_subdir(i)))
	return files


func get_file_size(file_path: String) -> int:
	var file_access: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	return FileAccess.open(file_path, FileAccess.READ).get_length()
