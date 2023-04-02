extends GridContainer

@onready var screen_resolution_button: OptionButton = $ScreenResolutionButton
@onready var screen_mode_button: OptionButton = $ScreenModeButton

var screen_size: Vector2
var screen_size_id: int
var last_windowed_size_id: int = 6

func _ready() -> void:    
    screen_size = DisplayServer.screen_get_size()
 
    var resolution: Vector2
    for id in Settings.screen_resolutions:
        resolution = Settings.screen_resolutions.get(id)
        screen_resolution_button.add_item(str(resolution.x) + "x" + str(resolution.y), id)
        if resolution == screen_size:
            screen_size_id = id

    screen_resolution_button.select(Settings.screen_resolution_id)
    _on_screen_resolution_button_item_selected(Settings.screen_resolution_id)
    
    screen_mode_button.select(Settings.screen_mode_id)
    _on_screen_mode_button_item_selected(Settings.screen_mode_id)

func _on_screen_resolution_button_item_selected(index: int) -> void:
    Settings.screen_resolution_id = index

func _on_screen_mode_button_item_selected(index: int) -> void:
    var was_windowed_before: bool = get_viewport().get_window().mode == Window.MODE_WINDOWED
    var fullscreen: bool = index < 2
    
    Settings.screen_mode_id = index

    if fullscreen:
        if was_windowed_before:
            last_windowed_size_id = screen_resolution_button.selected
        screen_resolution_button.select(screen_size_id)
        screen_resolution_button.disabled = true
    else:
        screen_resolution_button.disabled = false
        if not was_windowed_before:
            screen_resolution_button.select(last_windowed_size_id)

