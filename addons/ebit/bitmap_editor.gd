@tool
class_name BitMapEditor extends Control


@export var bitmap: BitMap:
	set(val): bitmap = val
		

var grid_color: Color = Color(Color.WHITE, 0.15)


func _init() -> void:
	if not Engine.is_editor_hint(): return
	var edit_settings: EditorSettings = EditorInterface.get_editor_settings()
	grid_color = edit_settings.get("editors/2d/grid_color")
	edit_settings.settings_changed.connect(func() -> void: grid_color = EditorInterface.get_editor_settings().get("editors/2d/grid_color"))


func _gui_input(event: InputEvent) -> void:
	pass


func _draw() -> void:
	if bitmap == null: return
	draw_multiline(get_grid_lines(bitmap.get_size()), grid_color, )
	draw_rect(Rect2(0, 0, size.x, size.y), Color.MAGENTA, false, -1.0)
	
	var mp: Vector2 = get_local_mouse_position()
	if get_rect().has_point(mp):
		pass


func get_grid_lines(grid_size: Vector2i) -> PackedVector2Array:
	var grid_lines: PackedVector2Array

	for x: int in grid_size.x + 1:
		x = remap(x, 0, grid_size.x, 0, size.x)
		grid_lines.append(Vector2(x, 0))
		grid_lines.append(Vector2(x, size.y))
		
	for y: int in grid_size.y + 1:
		y = remap(y, 0, grid_size.y, 0, size.y)
		grid_lines.append(Vector2(0, y))
		grid_lines.append(Vector2(size.x, y))

	return grid_lines
