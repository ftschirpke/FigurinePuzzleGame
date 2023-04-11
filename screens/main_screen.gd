extends Control

@onready var settings_screen: Control = $SettingsScreen

func _ready() -> void:
    if not Settings.file_found:
        Settings.set_default_values()

func _on_settings_button_pressed() -> void:
    settings_screen.visible = true
