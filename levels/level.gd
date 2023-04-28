extends Node2D

signal level_solved
signal pause_level

@onready var name_label: Label = $MarginContainer/RightSide/DescriptionBox/NameLabel
@onready var congratulations_label: Label = $MarginContainer/RightSide/DescriptionBox/MarginContainer/CongratulationsLabel
@onready var moves_made_label: Label = $MarginContainer/RightSide/DescriptionBox/MovesMadeContainer/MovesMade
@onready var targets_left_label: Label = $MarginContainer/RightSide/DescriptionBox/TargetsLeftContainer/TargetsLeft
@onready var selected_figurine_sprite: Sprite2D = $MarginContainer/RightSide/DescriptionBox/SelectedFigurineContainer/Control/SelectedFigurine

@onready var wall_tilemap: TileMap = $TileMap
@onready var target_tilemap: TileMap = $TargetTiles

var figurine_scene = preload("res://characters/figurine.tscn")

var board: Board: set = _set_new_board
var figurines: Array[Figurine] = []
var selected_figurine: Figurine = null
var targets: Dictionary = {}

var moves_made: int = 0: set = _set_moves_made

var ignore_input: bool = false: set = _set_ignore_input

var will_hit_target: bool = false
var will_hit_target_at: Vector2 = Vector2.ZERO

var puzzle_name: String: set = _set_puzzle_name

func _set_puzzle_name(new_name: String) -> void:
    puzzle_name = new_name
    name_label.text = puzzle_name

func _on_pause_button_pressed() -> void:
    emit_signal("pause_level")

func determine_atlas_vec(x: int, y: int) -> Vector2:
    if board.get_xy(x, y) == Board.Pos.WALL:
        return Vector2(3, 3)

    var wall_left: bool = y != 0 and board.hwalls[y-1][x]
    var wall_right: bool = y != 17 and board.hwalls[y][x]
    var wall_top: bool = x != 0 and board.vwalls[y][x-1]
    var wall_bottom: bool = x != 17 and board.vwalls[y][x]

    var dot_lt: bool = y != 0 and x != 0 and board.hwalls[y-1][x-1] and board.vwalls[y-1][x-1]
    var dot_rt: bool = y != 0 and x != 17 and board.hwalls[y-1][x+1] and board.vwalls[y-1][x]
    var dot_lb: bool = y != 17 and x != 0 and board.hwalls[y][x-1] and board.vwalls[y+1][x-1]
    var dot_rb: bool = y != 17 and x != 17 and board.hwalls[y][x+1] and board.vwalls[y+1][x]
    
    var atlas_vec: Vector2 = Vector2.ZERO
    if wall_left:
        atlas_vec.y += 1
    if wall_right:
        atlas_vec.y += 2
    if wall_top:
        atlas_vec.x += 1
    if wall_bottom:
        atlas_vec.x += 2

    if atlas_vec.x >= 3 or atlas_vec.y >= 3:
        return atlas_vec
        
    if atlas_vec.x == 0 or atlas_vec.y == 0:
        if atlas_vec.x == 1:
            if dot_rt:
                atlas_vec.x += 1
            if dot_rb:
                atlas_vec.y += 1
            atlas_vec += Vector2(3, 4)
        elif atlas_vec.x == 2:
            if dot_lt:
                atlas_vec.x += 1
            if dot_lb:
                atlas_vec.y += 1
            atlas_vec += Vector2(4, 4)
        elif atlas_vec.y == 1:
            if dot_rb:
                atlas_vec.x += 1
            if dot_lb:
                atlas_vec.y += 1
            atlas_vec += Vector2(4, 5)
        elif atlas_vec.y == 2:
            if dot_rt:
                atlas_vec.x += 1
            if dot_lt:
                atlas_vec.y += 1
            atlas_vec += Vector2(6, 4)
    else:
        if atlas_vec == Vector2.ONE and dot_rb:
            atlas_vec.y += 3
        elif atlas_vec == Vector2(1, 2) and dot_rt:
            atlas_vec.y += 3
        elif atlas_vec == Vector2(2, 1) and dot_lb:
            atlas_vec.y += 3
        elif atlas_vec == Vector2(2, 2) and dot_lt:
            atlas_vec.y += 3
    
    if atlas_vec != Vector2.ZERO:
        return atlas_vec
        
    atlas_vec = Vector2(4, 0)
    if dot_lt:
        atlas_vec.x += 1
    if dot_rt:
        atlas_vec.x += 2
    if dot_lb:
        atlas_vec.y += 1
    if dot_rb:
        atlas_vec.y += 2
    return atlas_vec

func _ready() -> void:    
    congratulations_label.visible = false

func reset() -> void:
    congratulations_label.visible = false

    moves_made = 0
    ignore_input = false

    will_hit_target = false
    will_hit_target_at = Vector2.ZERO

func _set_new_board(new_board: Board) -> void:
    remove_figurines()
    remove_targets()
    board = new_board
    init_tile_map()
    place_figurines()
    place_targets()
    reset()

func init_tile_map() -> void:
    for y in range(18):
        for x in range(18):
            wall_tilemap.set_cell(0, Vector2(x, y), 0, determine_atlas_vec(x, y))

func place_figurines() -> void:
    figurines = []
    var figurine_id: int = 0
    for figurine_pos in board.figurine_starting_positions:
        var new_figurine: Figurine = figurine_scene.instantiate() as Figurine
        add_child(new_figurine)
        figurines.append(new_figurine)
        new_figurine.id = figurine_id
        new_figurine.deselect()
        new_figurine.position = figurine_pos * 60
        new_figurine.figurine_selected.connect(_on_figurine_selected)
        new_figurine.figurine_stops_moving.connect(_on_figurine_stops_moving)
        new_figurine.movement_arrow_pressed.connect(move_input_pressed)
        figurine_id += 1
    selected_figurine = figurines[0]
    selected_figurine.select()
    turn_on_movement_arrows()

func remove_figurines() -> void:
    for figurine in figurines:
        remove_child(figurine)
    figurines = []

func place_targets() -> void:
    targets = board.targets.duplicate()
    for target_pos in targets:
        var target_id: int = targets[target_pos]
        place_target(target_pos, target_id)

func place_target(target_pos: Vector2, target_id: int) -> void:
    @warning_ignore("integer_division")
    var atlas_vec: Vector2 = Vector2(target_id % 4, target_id / 4)
    if target_id == -1:
        atlas_vec = Vector2(3, 1)
    target_tilemap.set_cell(0, target_pos, 1, atlas_vec)

func remove_targets() -> void:
    for target_pos in targets:
        clear_target(target_pos)
    targets = {}

func clear_target(target_pos: Vector2) -> void:
    target_tilemap.erase_cell(0, target_pos)
    
func update_target_amount_label() -> void:
    targets_left_label.text = str(len(targets))

func turn_off_movement_arrows() -> void:
    selected_figurine.movement_arrows.set_visibility()

func turn_on_movement_arrows() -> void:
    if not Settings.show_movement_arrows:
        return
    @warning_ignore("integer_division")
    var pos: Vector2i = selected_figurine.position / 60
    var up: bool = not board.wall_above(pos.x, pos.y) and board.get_vec(pos + Vector2i.UP) != Board.Pos.FIGURINE
    var left: bool = not board.wall_left(pos.x, pos.y) and board.get_vec(pos + Vector2i.LEFT) != Board.Pos.FIGURINE
    var right: bool = not board.wall_right(pos.x, pos.y) and board.get_vec(pos + Vector2i.RIGHT) != Board.Pos.FIGURINE
    var down: bool = not board.wall_below(pos.x, pos.y) and board.get_vec(pos + Vector2i.DOWN) != Board.Pos.FIGURINE
    selected_figurine.movement_arrows.set_visibility(up, left, right, down)

func _on_figurine_selected(figurine_id: int) -> void:
    if ignore_input:
        return
    selected_figurine.deselect()
    selected_figurine = figurines[figurine_id]
    selected_figurine.select()
    turn_on_movement_arrows()
    selected_figurine_sprite.frame = figurine_id

func _on_figurine_stops_moving(_figurine_id: int) -> void:
    if will_hit_target:
        clear_target(will_hit_target_at)
        targets.erase(will_hit_target_at)
        update_target_amount_label()
        if len(targets) == 0:
            finish_puzzle(true)
            return
    ignore_input = false
    
func _set_moves_made(new_value: int) -> void:
    moves_made = new_value
    moves_made_label.text = str(new_value)

func finish_puzzle(solved: bool) -> void:
    if solved:
        congratulations_label.visible = true
        emit_signal("level_solved", moves_made)

func board_pos_to_string(board_pos: Board.Pos) -> String:
    if board_pos == Board.Pos.EMPTY:
        return "EMPTY"
    if board_pos == Board.Pos.FIGURINE:
        return "FIGURINE"
    if board_pos == Board.Pos.WALL:
        return "WALL"
    return "NONE"

func check_target_hit(new_figurine_board_pos: Vector2) -> bool:
    if new_figurine_board_pos in targets:
        var target_id = targets[new_figurine_board_pos]
        return target_id < 0 or selected_figurine.id == target_id
    return false

func _input(event: InputEvent) -> void:
    if ignore_input:
        return
    if event.is_action_pressed("next_figurine"):
        var new_figurine_id: int = (selected_figurine.id + 1) % len(figurines)
        _on_figurine_selected(new_figurine_id)
    elif event.is_action_pressed("previous_figurine"):
        var new_figurine_id: int = (selected_figurine.id - 1) % len(figurines)
        _on_figurine_selected(new_figurine_id)

func move_input_pressed(input_vec: Vector2) -> void:
    var figurine_board_pos: Vector2 = selected_figurine.position / 60
    var new_figurine_board_pos: Vector2 = board.request_move(figurine_board_pos, input_vec)
    if new_figurine_board_pos != figurine_board_pos:
        will_hit_target = check_target_hit(new_figurine_board_pos)
        if not board.move_figurine(figurine_board_pos, new_figurine_board_pos):
            # movement failed for some reason
            will_hit_target = false
            return
        if will_hit_target:
            will_hit_target_at = new_figurine_board_pos
        selected_figurine.move(new_figurine_board_pos * 60)
        ignore_input = true
        moves_made += 1

func _set_ignore_input(value: bool) -> void:
    ignore_input = value
    if ignore_input:
        turn_off_movement_arrows()
    else:
        turn_on_movement_arrows()

func _process(_delta: float) -> void:
    if ignore_input:
        return
    var input_vec: Vector2 = Input.get_vector("mvleft", "mvright", "mvup", "mvdown")
    if abs(input_vec.x + input_vec.y) == 1:
        # diagonal movement not allowed
        move_input_pressed(input_vec)

func update_gameplay_settings() -> void:
    for figurine in figurines:
        figurine.update_speed()

func update_ui_settings() -> void:
    if Settings.show_movement_arrows:
        turn_on_movement_arrows()
    else:
        turn_off_movement_arrows()

func _on_pause_overlay_settings_changed() -> void:
    update_gameplay_settings()
    update_ui_settings()
