extends Button

@onready var scene_tree: SceneTree = get_tree()

func _on_pressed() -> void:
    scene_tree.quit()
