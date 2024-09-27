@tool
extends PanelContainer

@onready var make_floating: Button = %MakeFloatingButton

func _ready() -> void:
	var editor_theme : Theme = EditorInterface.get_editor_theme()
	make_floating.icon = editor_theme.get_icon(&"MakeFloating",&"EditorIcons",)
	var margin: MarginContainer = MarginContainer.new()
	margin.theme_type_variation = &"MarginContainer4px"


	# add_theme_constant_override("margin_left", 4)
	# add_theme_constant_override("margin_right", 4)
	# add_theme_constant_override("margin_up", 4)
	# add_theme_constant_override("margin_down", 4)
	