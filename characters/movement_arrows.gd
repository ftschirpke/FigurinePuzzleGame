extends Control

@onready var up_arrow: TextureButton = $UpArrow
@onready var left_arrow: TextureButton = $LeftArrow
@onready var right_arrow: TextureButton = $RightArrow
@onready var down_arrow: TextureButton = $DownArrow

func set_visibility(up: bool = false, left: bool = false, right: bool = false, down: bool = false) -> void:
    up_arrow.visible = up
    left_arrow.visible = left
    right_arrow.visible = right
    down_arrow.visible = down
