extends Control
class_name PauseOverlay

@onready var viewport: Viewport = get_viewport()
@onready var scene_tree: SceneTree = get_tree()

@onready var settings_screen: Control = $SettingsScreen

var pause_allowed: bool = true

var settings_entered: bool = false
signal give_up
signal restart
signal settings_changed

var paused: bool = false:
    set = _set_paused

func _unhandled_input(event: InputEvent) -> void:
    if pause_allowed and event.is_action_pressed("pause"):
        paused = not paused
        viewport.set_input_as_handled()

func _on_level_pause_level():
    if pause_allowed:
        paused = true

func _set_paused(value: bool) -> void:
    paused = value
    scene_tree.paused = value
    self.visible = value

func _on_continue_button_pressed() -> void:
    paused = false

func _on_settings_button_pressed() -> void:
    settings_screen.visible = true
    settings_entered = true

func _on_settings_screen_visibility_changed() -> void:
    if settings_entered and not settings_screen.visible:
        emit_signal("settings_changed")
        settings_entered = false

func _on_restart_button_pressed() -> void:
    emit_signal("restart")
    paused = false

func _on_give_up_button_pressed() -> void:
    emit_signal("give_up")
    paused = false
