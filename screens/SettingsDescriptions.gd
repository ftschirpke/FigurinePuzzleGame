extends VBoxContainer

func _ready() -> void:
    for description_label in get_children():
        var label: Label = description_label as Label
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
