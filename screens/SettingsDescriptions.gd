extends VBoxContainer

func _ready() -> void:
    for description_label in get_children():
        assert(description_label is Label)
        description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
