extends Node2D

@onready var congratulations_label: Label = $MarginContainer/VBox/MarginContainer/CongratulationsLabel
@onready var moves_made_label: Label = $MarginContainer/VBox/MovesMadeContainer/MovesMade
@onready var targets_left_label: Label = $MarginContainer/VBox/TargetsLeftContainer/TargetsLeft
@onready var selected_figurine_sprite: Sprite2D = $MarginContainer/VBox/SelectedFigurineContainer/Control/SelectedFigurine

var figurine = preload("res://characters/figurine.tscn")

var grid: Grid = Grid.new()
var figurines: Array
var selected_figurine
var targets: Dictionary

var easy_target_tiles: Array[Vector2]
var normal_target_tiles: Array[Vector2]

var moves_made: int = 0:
    set = _set_moves_made

var ignore_input: bool = false

var will_hit_target: bool = false
var will_hit_target_at: Vector2 = Vector2.ZERO

enum Difficulty { EASY, NORMAL, HARD }

enum GridPos { EMPTY, WALL, figurine }

class Grid:
    var data: Array
    var hwalls: Array
    var vwalls: Array
    var requested_movement_start: Vector2
    var requested_movement_end: Vector2
        
    func _init() -> void:
        init_data()
        init_hwalls()
        init_vwalls()
        
    func init_data() -> void:
        data.resize(18)
        for y in range(18):
            var row: Array[GridPos] = []
            row.resize(18)
            if y == 0 or y == 17:
                for i in range(18):
                    row[i] = GridPos.WALL
            else:
                row[0] = GridPos.WALL
                row[17] = GridPos.WALL
                if y == 8 or y == 9:
                    row[8] = GridPos.WALL
                    row[9] = GridPos.WALL
            data[y] = row

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
            
    func generate_random_walls() -> void:
        vwalls[1][randi_range(2, 8)] = true
        vwalls[1][randi_range(9, 15)] = true
        hwalls[randi_range(2, 8)][16] = true
        hwalls[randi_range(9, 15)][16] = true
        vwalls[16][randi_range(1, 7)] = true
        vwalls[16][randi_range(8, 14)] = true
        hwalls[randi_range(1, 7)][1] = true
        hwalls[randi_range(8, 14)][1] = true
             
        for i in range(8):
            var a: int = randi_range(0, 47)
            var x: int = a / 7 + 2
            var y: int = a % 7 + 2
            if i % 4 >= 2:
                x = 17 - x
            if i / 4 == 1:
                y = 17 - y

            var xoff: int = randi_range(0, 1)
            if getXY(x-1, y) == GridPos.WALL:
                xoff = 0
            elif getXY(x+1, y) == GridPos.WALL:
                xoff = 1
            var yoff: int = randi_range(0, 1)
            if getXY(x, y-1) == GridPos.WALL:
                yoff = 0
            elif getXY(x, y+1) == GridPos.WALL:
                yoff = 1
            hwalls[y - yoff][x] = true
            vwalls[y][x - xoff] = true

    func getXY(x: int, y: int) -> GridPos:
        return data[y][x]

    func getVec(vec: Vector2) -> GridPos:
        return data[vec.y][vec.x]

    func setXY(x: int, y: int, val: GridPos) -> void:
        data[y][x] = val

    func setVec(vec: Vector2, val: GridPos) -> void:
        data[vec.y][vec.x] = val
        
    func requestMove(figurine_pos: Vector2, direction: Vector2) -> Vector2:
        if getVec(figurine_pos) == GridPos.figurine:
            #setVec(figurine_pos, GridPos.EMPTY)
            requested_movement_start = figurine_pos
            
            var is_wall_ahead
            if direction.normalized() == Vector2.UP:
                is_wall_ahead = func(vec: Vector2) -> bool: return hwalls[vec.y - 1][vec.x]
            elif direction.normalized() == Vector2.DOWN:
                is_wall_ahead = func(vec: Vector2) -> bool: return hwalls[vec.y][vec.x]
            elif direction.normalized() == Vector2.LEFT:
                is_wall_ahead = func(vec: Vector2) -> bool: return vwalls[vec.y][vec.x - 1]
            elif direction.normalized() == Vector2.RIGHT:
                is_wall_ahead = func(vec: Vector2) -> bool: return vwalls[vec.y][vec.x]
    
            while not is_wall_ahead.call(figurine_pos) and getVec(figurine_pos + direction) == GridPos.EMPTY:
                figurine_pos += direction

            requested_movement_end = figurine_pos
            #setVec(figurine_pos, GridPos.figurine)
        return figurine_pos

    func movefigurine(start: Vector2, end: Vector2) -> bool:
        if start != requested_movement_start or end != requested_movement_end:
            return false
        setVec(start, GridPos.EMPTY)
        setVec(end, GridPos.figurine)
        return true

    func wallAbove(x: int, y: int) -> bool:
        return getXY(x, y - 1) == GridPos.WALL or hwalls[y - 1][x]

    func wallBelow(x: int, y: int) -> bool:
        return getXY(x, y + 1) == GridPos.WALL or hwalls[y][x]

    func wallLeft(x: int, y: int) -> bool:
        return getXY(x - 1, y) == GridPos.WALL or vwalls[y][x - 1]

    func wallRight(x: int, y: int) -> bool:
        return getXY(x + 1, y) == GridPos.WALL or vwalls[y][x]

func determine_atlas_vec(x: int, y: int) -> Vector2:    
    if grid.getXY(x, y) == GridPos.WALL:
        return Vector2(3, 3)

    var wall_left: bool = y != 0 and grid.hwalls[y-1][x]
    var wall_right: bool = y != 17 and grid.hwalls[y][x]
    var wall_top: bool = x != 0 and grid.vwalls[y][x-1]
    var wall_bottom: bool = x != 17 and grid.vwalls[y][x]

    var dot_lt: bool = y != 0 and x != 0 and grid.hwalls[y-1][x-1] and grid.vwalls[y-1][x-1]
    var dot_rt: bool = y != 0 and x != 17 and grid.hwalls[y-1][x+1] and grid.vwalls[y-1][x]
    var dot_lb: bool = y != 17 and x != 0 and grid.hwalls[y][x-1] and grid.vwalls[y+1][x-1]
    var dot_rb: bool = y != 17 and x != 17 and grid.hwalls[y][x+1] and grid.vwalls[y+1][x]
    
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

func init_tile_map() -> void:
    for y in range(18):
        for x in range(18):
            $TileMap.set_cell(0, Vector2(x, y), 0, determine_atlas_vec(x, y))
    
    for y in range(1, 17):
        for x in range(1, 17):
            check_targetability(x, y)

func check_targetability(x: int, y: int) -> void:
    var vertical_walls: int = int(grid.wallAbove(x, y)) + int(grid.wallBelow(x, y))
    var horizontal_walls: int = int(grid.wallLeft(x, y)) + int(grid.wallRight(x, y))
    
    if vertical_walls != 1 and horizontal_walls == 1:
        normal_target_tiles.append(Vector2(x, y))
    elif vertical_walls == 1 and horizontal_walls != 1:
        normal_target_tiles.append(Vector2(x, y))
    elif vertical_walls == 1 and horizontal_walls == 1:
        easy_target_tiles.append(Vector2(x, y))

func _ready() -> void:
    # seed(1234)
    congratulations_label.visible = false
    grid.generate_random_walls()
    init_tile_map()
    spawn_figurines()
    var target_amount: int = randi_range(1, 5)
    for i in range(target_amount):
        spawn_target(Difficulty.NORMAL)
    update_target_amount()

func spawn_figurines() -> void:
    var amount: int = randi_range(2, 6)
    for i in range(amount):
        var x: int = randi_range(1, 16)
        var y: int = randi_range(1, 16)
        while grid.getXY(x, y) != GridPos.EMPTY:
            x = randi_range(1, 16)
            y = randi_range(1, 16)
        var new_figurine = figurine.instantiate()
        add_child(new_figurine)
        figurines.append(new_figurine)
        new_figurine.id = i
        new_figurine.deselect()
        new_figurine.position = Vector2(x,y) * 60
        new_figurine.figurine_selected.connect(_on_figurine_selected)
        new_figurine.figurine_stops_moving.connect(_on_figurine_stops_moving)
        grid.setXY(x, y, GridPos.figurine)
    selected_figurine = figurines[0]
    selected_figurine.select()

func get_random_target_pos(difficulty: Difficulty) -> Vector2:
    if difficulty == Difficulty.EASY:
        return easy_target_tiles[randi_range(0, len(easy_target_tiles) - 1)]
    if difficulty == Difficulty.NORMAL:
        return normal_target_tiles[randi_range(0, len(normal_target_tiles) - 1)]
    if difficulty == Difficulty.HARD:
        # not implemented yet
        # treat as normal for now
        return normal_target_tiles[randi_range(0, len(normal_target_tiles) - 1)]
    return Vector2(-1, -1)
    

func spawn_target(difficulty: Difficulty) -> void:
    var amount_of_figurines: int = len(figurines)
    var target_id: int = randi_range(0, amount_of_figurines) - 1

    var target_pos: Vector2 = get_random_target_pos(difficulty)
    while grid.getVec(target_pos) != GridPos.EMPTY:
        target_pos = get_random_target_pos(difficulty)

    set_target(target_pos, target_id)
    targets[target_pos] = target_id

func set_target(target_pos: Vector2, target_id: int) -> void:
    var atlas_vec: Vector2 = Vector2(target_id % 4, target_id / 4)
    if target_id == -1:
        atlas_vec = Vector2(3, 1)
    $TargetTiles.set_cell(0, target_pos, 1, atlas_vec)

func clear_target(target_pos: Vector2) -> void:
    $TargetTiles.erase_cell(0, target_pos)
    
func update_target_amount() -> void:
    targets_left_label.text = str(len(targets))

func _on_figurine_selected(figurine_id: int) -> void:
    if ignore_input:
        return
    selected_figurine.deselect()
    selected_figurine = figurines[figurine_id]
    selected_figurine.select()
    selected_figurine_sprite.frame = figurine_id

func _on_figurine_stops_moving(figurine_id: int) -> void:
    if will_hit_target:
        clear_target(will_hit_target_at)
        targets.erase(will_hit_target_at)
        update_target_amount()
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

func grid_pos_to_string(grid_pos: GridPos) -> String:
    if grid_pos == GridPos.EMPTY:
        return "EMPTY"
    if grid_pos == GridPos.figurine:
        return "figurine"
    if grid_pos == GridPos.WALL:
        return "WALL"
    return "NONE"

func check_target_hit(new_figurine_grid_pos: Vector2) -> bool:
    if new_figurine_grid_pos in targets:
        var target_id = targets[new_figurine_grid_pos]
        return target_id < 0 or selected_figurine.id == target_id
    return false

func _input(event: InputEvent) -> void:
    if ignore_input:
        return
    if event.is_action_pressed("switch_figurine"):
        var new_figurine_id: int = (selected_figurine.id + 1) % len(figurines)
        _on_figurine_selected(new_figurine_id)

func _process(delta: float) -> void:
    if ignore_input:
        return
    var input_vec: Vector2 = Input.get_vector("mvleft", "mvright", "mvup", "mvdown")
    if abs(input_vec.x + input_vec.y) != 1:
        # diagonal movement not allowed
        return
    var figurine_grid_pos: Vector2 = selected_figurine.position / 60
    var new_figurine_grid_pos: Vector2 = grid.requestMove(figurine_grid_pos, input_vec)
    if new_figurine_grid_pos != figurine_grid_pos:
        will_hit_target = check_target_hit(new_figurine_grid_pos)
        if not grid.movefigurine(figurine_grid_pos, new_figurine_grid_pos):
            # movement failed for some reason
            will_hit_target = false
            return
        if will_hit_target:
            will_hit_target_at = new_figurine_grid_pos
        selected_figurine.move(new_figurine_grid_pos * 60)
        ignore_input = true
        moves_made += 1
        
    
