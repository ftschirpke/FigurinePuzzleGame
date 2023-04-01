extends Control

@onready var viewport: Viewport = get_viewport()
@onready var scene_tree: SceneTree = get_tree()

var paused: bool = false:
    set = _set_paused

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        paused = not paused
        viewport.set_input_as_handled()

func _set_paused(value: bool) -> void:
    paused = value
    scene_tree.paused = value
    self.visible = value

func _on_continue_button_pressed() -> void:
    paused = false
