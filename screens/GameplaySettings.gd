extends GridContainer

@onready var move_speed_value_label: Label = $FigurineMoveSpeedValueLabel

func _on_figurine_move_speed_slider_value_changed(value: float) -> void:
    move_speed_value_label.text = str(value)
