@tool
extends EditorScript

func _run() -> void:
	print("\nRunning Editor Script...")
	var scene:= get_scene()
	print(scene)