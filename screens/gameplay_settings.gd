extends GridContainer

@onready var move_speed_value_label: Label = $FigurineSpeedValue/FigurineSpeedValueLabel
@onready var move_speed_slider: HSlider = $FigurineSpeedValue/FigurineSpeedSlider

func _ready() -> void:
    move_speed_slider.value = Settings.figurine_speed
    move_speed_value_label.text = str(Settings.figurine_speed)

func _on_figurine_move_speed_slider_value_changed(value: float) -> void:
    Settings.figurine_speed = value
    move_speed_value_label.text = str(value)
