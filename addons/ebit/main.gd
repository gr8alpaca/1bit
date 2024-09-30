@tool
extends PanelContainer

signal nest_in_bottom_dock(is_nested: bool)


@export var files: Tree
@export var editor: Control

var dock_button: Button
var floating_window: Window


func _ready() -> void:

	var editor_theme: Theme = EditorInterface.get_editor_theme()


	if Engine.is_editor_hint() and not EditorInterface.get_edited_scene_root() == self:
		theme = editor_theme


	var make_floating: Button = get_node("%MakeFloating")
	make_floating.icon = editor_theme.get_icon(&"MakeFloating", &"EditorIcons", )
	make_floating.pressed.connect(_on_make_floating)


	for path: NodePath in [^"%Add", ^"%Load", ^"%GuiTabMenuHl", ^"%Rectangle", ^"%Eraser"]:
		get_node(path).icon = editor_theme.get_icon(str(path).replacen("%", ""), &"EditorIcons", )

	get_node(^"%Draw").icon = editor_theme.get_icon(&"Edit", &"EditorIcons")


	# var draw: Button = get_node(^"%Draw")
	# var rect: Button = get_node(^"%Rectangle")
	# var eraser: Button = get_node(^"%Eraser")


func edit_bitmap(bitmap: BitMap) -> void:
	pass


func _on_make_floating() -> void:
	var plugin: EditorPlugin = Engine.get_singleton(&"eBit")
	
	if not plugin or plugin.editor != self:
		return
		
	if floating_window:
		_on_window_close_requested()
		return

	get_node("%MakeFloating").hide()
	var border_size := Vector2(4, 4) * EditorInterface.get_editor_scale()
	get_parent().remove_child(self)
	
	floating_window = Window.new()

	var panel := Panel.new()
	panel.add_theme_stylebox_override(
		"panel",
		EditorInterface.get_base_control().get_theme_stylebox("PanelForeground", "EditorStyles")
	)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	floating_window.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_child(self)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_right", border_size.x)
	margin.add_theme_constant_override("margin_left", border_size.x)
	margin.add_theme_constant_override("margin_top", border_size.y)
	margin.add_theme_constant_override("margin_bottom", border_size.y)
	panel.add_child(margin)

	floating_window.title = "Rational"
	floating_window.wrap_controls = true
	floating_window.min_size = Vector2i(600, 350)
	floating_window.size = size
	floating_window.position = EditorInterface.get_editor_main_screen().global_position
	floating_window.transient = true
	floating_window.close_requested.connect(_on_window_close_requested)
	
	EditorInterface.set_main_screen_editor("2D")
	EditorInterface.get_base_control().add_child(floating_window)


func _on_window_close_requested() -> void:
	get_parent().remove_child(self)
	
	EditorInterface.set_main_screen_editor("Rational")
	nest_in_bottom_dock.emit(true)
	var plugin: EditorPlugin = Engine.get_singleton(&"eBit")
	floating_window.queue_free()
	floating_window = null
	get_node("%MakeFloating").show()


func close() -> void:
	if floating_window:
		floating_window.queue_free()
	else:
		queue_free()
