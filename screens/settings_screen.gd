extends Control

func _on_back_button_pressed() -> void:
    Settings.save_settings()
    visible = false

func _on_exiting_program() -> void:
    Settings.save_settings()
