@tool
extends Tree

var popup_menu: PopupMenu

func _ready() -> void:
	if not Engine.is_editor_hint(): return

	clear()
	
	create_item().set_text(0, "Root")

	for file: String in get_bitmap_files():
		add_file(file)

	item_selected.connect(_on_item_selected)
	item_mouse_selected.connect(_on_item_mouse_selected)
	item_activated.connect(_on_item_activated)
	
	var file_dock: FileSystemDock = EditorInterface.get_file_system_dock()
	file_dock.file_removed.connect(_on_file_removed)
	file_dock.files_moved.connect(_on_file_moved)
	

	popup_menu = PopupMenu.new()
	popup_menu.name = &"FileTreePopupMenu"
	popup_menu.theme = EditorInterface.get_editor_theme()
	popup_menu.add_item("Rename...", -1, KEY_F2)
	popup_menu.add_icon_item(popup_menu.get_theme_icon(&"Duplicate", &"EditorIcons"), "Duplicate...", -1, KEY_MASK_CTRL | KEY_D) # KEY_MASK_CTRL
	popup_menu.add_separator()
	popup_menu.add_icon_item(popup_menu.get_theme_icon(&"Remove", &"EditorIcons"), "Delete...", -1, KEY_DELETE)
	popup_menu.index_pressed.connect(_on_popup_menu_pressed)
	popup_menu.id_pressed.connect(_on_id_pressed)
	add_child(popup_menu)

	item_edited.connect(_on_item_edited)


func _on_id_pressed(id: int) -> void:
	printt("ID PRESSED -> ", id )

func add_file(file: String) -> void:
	var item: TreeItem = bind_file_item(file)
	item.set_editable(0, false)
	item.set_icon(0, EditorInterface.get_editor_theme().get_icon(&"BitMap", &"EditorIcons"))
	print("Added file:\t%s" % file)


## Updates tree item to input [param file]
func bind_file_item(file: String, item: TreeItem = create_item(get_root(), -1)) -> TreeItem:
	item.set_metadata(0, file)
	item.set_text(0, file.get_file().trim_suffix(".tres"))
	item.set_tooltip_text(0, "%s\nSize: %s" % [file.trim_prefix("res://"), String.humanize_size(FileAccess.open(file, FileAccess.READ).get_length())])
	return item


func _get_drag_data(at_position: Vector2) -> Variant:
	var item: TreeItem = get_item_at_position(at_position)
	if not item: return null
	return {"type": "files", "files": [item.get_metadata(0)], "from": self}


# { "type": "files", "files": ["res://BitMap.tres"], "from": @Tree@5673:<Tree#495833867875> }
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		for file in data.get("files", []):
			if is_valid_bitmap(file): return true
		return false
				

	if data is TreeItem:
		drop_mode_flags = DROP_MODE_INBETWEEN


	return drop_mode_flags


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is TreeItem:
		if not get_item_at_position(at_position): return
		var callable: Callable = data.move_after if get_drop_section_at_position(at_position) > 0 else data.move_after
		callable.call(get_item_at_position(at_position))
		return

	if data is Dictionary:
		for file in data.get("files", []):
			if is_valid_bitmap(file): add_file(file)


func _on_item_selected() -> void:
	pass
	# printt("Item Selected(Gen..) -> ", get_selected().get_text(0) if get_selected() else "None selected...")


func _on_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	printt("Item Selected(Mouse) -> ", get_selected().get_text(0) if get_selected() else "None selected...")

	if (mouse_button_index & MOUSE_BUTTON_RIGHT):
		popup_menu.position = DisplayServer.mouse_get_position()
		popup_menu.show()

	elif mouse_button_index & MOUSE_BUTTON_LEFT:
		if has_meta(&"selected") and get_meta(&"selected") == get_selected():
			edit_selected(true)
	
func _shortcut_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F2):
		pass

func _on_item_activated() -> void:
	var item: TreeItem = get_selected()
	print("Item Activated..." + item.get_text(0))
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if not get_selected() or event.double_click: return
			if get_item_at_position(event.position) == get_selected():
				edit_selected(true)


func delete_item(file: String) -> void:
	if not is_inside_tree(): return

	DirAccess.remove_absolute(file)
	EditorInterface.get_resource_filesystem().update_file(file)


func _on_add_pressed() -> void:
	print("Add pressed...")
	if not get_root():
		print("NO Root!")
		return
	for child in get_root().get_children():
		printt("%s - cell_mode: %s,  editable: %s" % [child, child.get_cell_mode(0), child.is_editable(0), ])
	

func _on_load_pressed() -> void:
	print("Load pressed...")


func _on_file_removed(file: String) -> void:
	var item: TreeItem = get_item(file)
	if item: get_root().remove_child(item)
	

func _on_popup_menu_pressed(index: int) -> void:
	printt(popup_menu.get_item_text(index), " pressed!")
	match index:
		0: # Rename
			edit_selected(true)

			
		1: # Duplicate
			pass
		3:
			confirm_delete(get_selected())


func _on_item_edited() -> void:
	var item: TreeItem = get_edited()
	var new_file: String = item.get_text(0)
	printt("Item Edited ->", new_file)
	item.set_editable(0, false)

	var old_file: String = item.get_metadata(0).get_file().trim_suffix(".tres")
	if old_file != new_file :
		print("FILE CHANGED: %s -> %s" % [old_file, new_file])
		var bitmap: BitMap = load(item.get_metadata(0))
		bitmap.resource_path = item.get_metadata(0).get_base_dir().path_join()


func is_valid_rename(dir: String, new_file: String) -> bool:
	assert(dir, "Empty param 'dir' entered in func 'is_valid_filename'")
	if not new_file.is_valid_filename(): 
		return false

	var new_path: String = dir.path_join(new_file + ".tres")


	if FileAccess.file_exists(new_path): 
		return false

	return true

func _on_file_moved(old_file: String, new_file: String) -> void:
	if not is_valid_bitmap(new_file): return
	var item: TreeItem = get_item(old_file)
	if item: bind_file_item(new_file, item)


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


func get_bitmap_files(dir: EditorFileSystemDirectory = EditorInterface.get_resource_filesystem().get_filesystem()) -> PackedStringArray:
	var files: PackedStringArray
	for i: int in dir.get_file_count():
		if dir.get_file_type(i) == &"BitMap": files.push_back(dir.get_file(i))
	for i: int in dir.get_subdir_count():
		files.append_array(get_bitmap_files(dir.get_subdir(i)))
	return files


func get_file_size(file_path: String) -> int:
	var file_access: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	return FileAccess.open(file_path, FileAccess.READ).get_length()
