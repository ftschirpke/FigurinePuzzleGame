extends GridContainer
class_name ResultsTable

var added: Array[Node] = []
var amount_of_rows: int = 0

func reset() -> void:
    amount_of_rows = 0
    for added_node in added:
        remove_child(added_node)

func add_pair(puzzle_seed: String, val: int) -> void:
    var val_str = str(val) if val >= 0 else "-"
    amount_of_rows += 1
    add_label(str(amount_of_rows))
    add_seperator()
    add_seed_button(puzzle_seed)
    add_seperator()
    add_label(val_str)

func add_seperator() -> void:
    var sep: ColorRect = ColorRect.new()
    add_child(sep)
    added.append(sep)

func add_label(text: String) -> Label:
    var new_label: Label = Label.new()
    new_label.text = text
    new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    add_child(new_label)
    added.append(new_label)
    return new_label

func add_seed_button(puzzle_seed: String) -> Button:
    var copy_seed_to_clipboard: Callable = func() -> void: DisplayServer.clipboard_set(puzzle_seed)
    var new_button: Button = Button.new()
    new_button.tooltip_text = "copy seed to clipboard"
    new_button.text = puzzle_seed
    new_button.pressed.connect(copy_seed_to_clipboard)
    add_child(new_button)
    added.append(new_button)
    return new_button
