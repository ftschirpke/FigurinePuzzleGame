extends GridContainer

@onready var show_arrows_button: CheckButton = $ShowMovementArrowsCheckButton

func _ready() -> void:
    set_show_arrows_text(Settings.show_movement_arrows)
    show_arrows_button.button_pressed = Settings.show_movement_arrows

func set_show_arrows_text(show_arrows: bool) -> void:
    show_arrows_button.text = "Yes " if show_arrows else "No "

func _on_show_movement_arrows_check_button_toggled(button_pressed: bool) -> void:
    Settings.show_movement_arrows = button_pressed
    set_show_arrows_text(button_pressed)
