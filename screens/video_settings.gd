extends GridContainer

@onready var viewport: Viewport = get_viewport()
@onready var window: Window = get_viewport().get_window()

@onready var aspect_ratio_button: OptionButton = $AspectRatioButton
@onready var screen_mode_button: OptionButton = $ScreenModeButton

var aspect_ratios: Dictionary = {
     0: Vector2(1024,  768),
     1: Vector2(1280,  720),
     2: Vector2(1280,  800),
     3: Vector2(1360,  768),
     4: Vector2(1366,  768),
     5: Vector2(1440,  900),
     6: Vector2(1600,  900),
     7: Vector2(1680, 1050),
     8: Vector2(1920, 1080),
     9: Vector2(1920, 1200),
    10: Vector2(2560, 1080),
    11: Vector2(2560, 1440),
    12: Vector2(2560, 1600),
    13: Vector2(3440, 1440),
    14: Vector2(3840, 2160),
}

var screen_size_id: int
var last_windowed_size_id: int = 6

func _ready() -> void:
    var screen_size: Vector2 = DisplayServer.screen_get_size()
    
    var current_ratio: Vector2 = viewport.size

    var ratio: Vector2
    for id in aspect_ratios:
        ratio = aspect_ratios.get(id)
        aspect_ratio_button.add_item(str(ratio.x) + "x" + str(ratio.y), id)
        if ratio == current_ratio:
            aspect_ratio_button.select(id)
        if ratio == screen_size:
            screen_size_id = id
    
    var screen_mode_id: int
    
    if window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
        screen_mode_id = 0
    elif window.mode == Window.MODE_FULLSCREEN:
        screen_mode_id = 1
    elif window.mode == Window.MODE_WINDOWED:
        var borderless: bool = window.borderless
        screen_mode_id = 2 + int(borderless)
    screen_mode_button.select(screen_mode_id)
    _on_screen_mode_button_item_selected(screen_mode_id)

func _on_aspect_ratio_button_item_selected(index: int) -> void:
    viewport.size = aspect_ratios[index]

func _on_screen_mode_button_item_selected(index: int) -> void:
    var borderless: bool = bool(index % 2)
    var fullscreen: bool = index < 2

    if fullscreen:
        if window.mode == Window.MODE_WINDOWED:
            last_windowed_size_id = aspect_ratio_button.selected
        aspect_ratio_button.select(screen_size_id)
        aspect_ratio_button.disabled = true
        if borderless:
            window.mode = Window.MODE_FULLSCREEN
        else:
            window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
    else:
        aspect_ratio_button.disabled = false
        var was_windowed_before: bool = window.mode == Window.MODE_WINDOWED
        window.mode = Window.MODE_WINDOWED
        window.borderless = borderless
        if not was_windowed_before:
            aspect_ratio_button.select(last_windowed_size_id)
            viewport.size = aspect_ratios[last_windowed_size_id]

func _on_screen_mode_mouse_entered() -> void:
    pass # Replace with function body.


func _on_screen_mode_mouse_exited() -> void:
    pass # Replace with function body.


