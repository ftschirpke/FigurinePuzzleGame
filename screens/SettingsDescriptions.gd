extends VBoxContainer

func _ready() -> void:
    for description_label in get_children():
        description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
