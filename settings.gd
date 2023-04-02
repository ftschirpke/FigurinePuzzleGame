extends Node

@onready var settings_file: String = "user://settings.save"

@onready var viewport: Viewport = get_viewport()
@onready var window: Window = get_viewport().get_window()

var file_found: bool = false

# gameplay settings
var figurine_speed: int = 10

# ui settings
var show_movement_arrows: bool = true

# video settings
var screen_mode_id: int = -1: set = _set_screen_mode
var screen_resolution_id: int = -1: set = _set_screen_resolution

var last_windowed_size_id: int = 6

var screen_resolutions: Dictionary = {
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

func _set_screen_resolution(id: int) -> void:
    if id < 0:
        print("Error: screen resolution < 0")
        return
    if id == screen_resolution_id:
        return
    screen_resolution_id = id
    viewport.size = screen_resolutions[id]
    if window.mode == Window.MODE_WINDOWED:
        last_windowed_size_id = id

func _set_screen_mode(id: int) -> void:
    if id < 0:
        print("Error: screen mode < 0")
        return
    if id == screen_mode_id:
        return
    screen_mode_id = id
    
    var borderless: bool = bool(id % 2)
    var fullscreen: bool = id < 2

    if fullscreen:
        if borderless:
            window.mode = Window.MODE_FULLSCREEN
        else:
            window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
    else:
        var was_windowed_before: bool = window.mode == Window.MODE_WINDOWED
        window.mode = Window.MODE_WINDOWED
        window.borderless = borderless
        if not was_windowed_before:
            screen_resolution_id = last_windowed_size_id

func _ready() -> void:
    load_settings()
    if not file_found:
        determine_default_values()

func determine_default_values() -> void:
    var current_resolution: Vector2 = viewport.size

    screen_resolution_id = screen_resolutions.find_key(current_resolution)
    
    if window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
        screen_mode_id = 0
    elif window.mode == Window.MODE_FULLSCREEN:
        screen_mode_id = 1
    elif window.mode == Window.MODE_WINDOWED:
        screen_mode_id = 2 + int(window.borderless)

func load_settings() -> void:
    file_found = FileAccess.file_exists(settings_file)
    if not file_found:
        return
    var file: FileAccess = FileAccess.open(settings_file, FileAccess.READ)
    var data: Dictionary = file.get_var()
    file.close()

    extract_gameplay_settings(data.get("gameplay", {}))
    extract_video_settings(data.get("video", {}))


func save_settings() -> void:
    var data: Dictionary = {
        "gameplay": create_gameplay_settings(),
        "ui": create_ui_settings(),
        "video": create_video_settings(),
    }

    var file: FileAccess = FileAccess.open(settings_file, FileAccess.WRITE)
    file.store_var(data)
    file.close()

func extract_gameplay_settings(gameplay_settings: Dictionary) -> void:
    figurine_speed = gameplay_settings.get("figurine_speed", 10)

func create_gameplay_settings() -> Dictionary:
    return {
        "figurine_speed": figurine_speed,
    }

func extract_ui_settings(ui_settings: Dictionary) -> void:
    show_movement_arrows = ui_settings.get("show_movement_arrows", true)

func create_ui_settings() -> Dictionary:
    return {
        "show_movement_arrows": show_movement_arrows
    }

func extract_video_settings(video_settings: Dictionary) -> void:
    # CAREFUL: order of resolution and mode is important!
    screen_resolution_id = video_settings.get("screen_resolution_id", -1)
    screen_mode_id = video_settings.get("screen_mode_id", -1)

    last_windowed_size_id = video_settings.get("last_windowed_size_id", 6)

func create_video_settings() -> Dictionary:
    return {
        "screen_mode_id": screen_mode_id,
        "screen_resolution_id": screen_resolution_id,
        "last_windowed_size_id": last_windowed_size_id,
    }
    
