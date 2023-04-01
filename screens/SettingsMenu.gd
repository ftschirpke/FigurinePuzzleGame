extends HBoxContainer

@onready var screen_mode_description: Label = $SettingsDescriptions/ScreenModeDescription
@onready var aspect_ratio_description: Label = $SettingsDescriptions/AspectRatioDescription

func _on_screen_mode_mouse_entered() -> void:
    screen_mode_description.visible = true

func _on_screen_mode_mouse_exited() -> void:
    screen_mode_description.visible = false

func _on_aspect_ratio_mouse_entered() -> void:
    aspect_ratio_description.visible = true

func _on_aspect_ratio_mouse_exited() -> void:
    aspect_ratio_description.visible = false
