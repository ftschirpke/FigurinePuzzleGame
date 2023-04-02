extends Control

@export var description_label: Label

func _init() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
    description_label.visible = true

func _on_mouse_exited() -> void:
    description_label.visible = false
