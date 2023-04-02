extends Button

@onready var scene_tree: SceneTree = get_tree()

func _on_pressed() -> void:
    Settings.save_settings()
    scene_tree.quit()
