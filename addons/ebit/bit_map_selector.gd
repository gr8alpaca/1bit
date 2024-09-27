@tool
class_name BitMapEditor extends Control


var bitmap_size: Vector2 

func _draw() -> void:
	draw_rect(Rect2(0,0, size.x, size.y), Color.MAGENTA, false, -1.0)