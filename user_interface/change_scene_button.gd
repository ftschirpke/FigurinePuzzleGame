extends Button

@export_file("*.tscn") var next_scene_path: String = ""

@onready var scene_tree: SceneTree = get_tree()

func _on_pressed() -> void:
    scene_tree.paused = false
    scene_tree.change_scene_to_file(next_scene_path)
