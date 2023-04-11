extends Button

@onready var scene_tree: SceneTree = get_tree()

func _on_pressed() -> void:
    scene_tree.paused = false
    var level_manager_scene: PackedScene = load("res://levels/level_manager.tscn")
    var level_manager: LevelManager = level_manager_scene.instantiate()
    level_manager.start_daily()
    scene_tree.get_root().add_child(level_manager)
    scene_tree.get_root().remove_child(get_node("/root/MainScreen"))

