class_name Board
extends Resource

enum Pos { EMPTY, WALL, FIGURINE }

var grid: Array
var hwalls: Array
var vwalls: Array
var figurine_starting_positions: Array[Vector2]
var targets: Dictionary

var requested_movement_start: Vector2
var requested_movement_end: Vector2
    
func _init() -> void:
    init_grid()
    init_hwalls()
    init_vwalls()

func init_grid() -> void:
    grid.resize(18)
    for y in range(18):
        var row: Array[Pos] = []
        row.resize(18)
        if y == 0 or y == 17:
            for i in range(18):
                row[i] = Pos.WALL
        else:
            row[0] = Pos.WALL
            row[17] = Pos.WALL
            if y == 8 or y == 9:
                row[8] = Pos.WALL
                row[9] = Pos.WALL
        grid[y] = row

func init_hwalls() -> void:
    hwalls.resize(17)
    for y in range(17):
        var row: Array[bool] = []
        row.resize(18)
        for i in range(0, 18):
            row[i] = false
        hwalls[y] = row

func init_vwalls() -> void:
    vwalls.resize(18)
    for y in range(18):
        var row: Array[bool] = []
        row.resize(17)
        for i in range(0, 17):
            row[i] = false
        vwalls[y] = row

func get_xy(x: int, y: int) -> Pos:
    return grid[y][x]

func get_vec(vec: Vector2) -> Pos:
    return grid[vec.y][vec.x]

func set_xy(x: int, y: int, val: Pos) -> void:
    grid[y][x] = val

func set_vec(vec: Vector2, val: Pos) -> void:
    grid[vec.y][vec.x] = val
    
func request_move(figurine_pos: Vector2, direction: Vector2) -> Vector2:
    if get_vec(figurine_pos) == Pos.FIGURINE:
        requested_movement_start = figurine_pos
        
        var is_wall_ahead: Callable
        if direction.normalized() == Vector2.UP:
            is_wall_ahead = func(vec: Vector2) -> bool: return hwalls[vec.y - 1][vec.x]
        elif direction.normalized() == Vector2.DOWN:
            is_wall_ahead = func(vec: Vector2) -> bool: return hwalls[vec.y][vec.x]
        elif direction.normalized() == Vector2.LEFT:
            is_wall_ahead = func(vec: Vector2) -> bool: return vwalls[vec.y][vec.x - 1]
        elif direction.normalized() == Vector2.RIGHT:
            is_wall_ahead = func(vec: Vector2) -> bool: return vwalls[vec.y][vec.x]

        while not is_wall_ahead.call(figurine_pos) and get_vec(figurine_pos + direction) == Pos.EMPTY:
            figurine_pos += direction

        requested_movement_end = figurine_pos
    return figurine_pos

func move_figurine(start: Vector2, end: Vector2) -> bool:
    if start != requested_movement_start or end != requested_movement_end:
        return false
    set_vec(start, Pos.EMPTY)
    set_vec(end, Pos.FIGURINE)
    return true

func wall_above(x: int, y: int) -> bool:
    return get_xy(x, y - 1) == Pos.WALL or hwalls[y - 1][x]

func wall_below(x: int, y: int) -> bool:
    return get_xy(x, y + 1) == Pos.WALL or hwalls[y][x]

func wall_left(x: int, y: int) -> bool:
    return get_xy(x - 1, y) == Pos.WALL or vwalls[y][x - 1]

func wall_right(x: int, y: int) -> bool:
    return get_xy(x + 1, y) == Pos.WALL or vwalls[y][x]
