extends Node

const max_difficulty_value: int = 6
const min_figurine_count: int = 2
const max_figurine_count: int = 6
const min_target_count: int = 1
const max_target_count: int = 5

const target_difficulties: Array[String] = ["easy", "normal", "hard", "extreme"]

const seed_length: int = 21

class Config:
    var randomness_seed: int = 0
    var difficulty: int = 2: set = _set_difficulty
    var min_figurines: int = min_figurine_count: set = _set_min_figurines
    var max_figurines: int = max_figurine_count: set = _set_max_figurines
    var min_targets: int = min_target_count: set = _set_min_targets
    var max_targets: int = max_target_count: set = _set_max_targets
    
    func _set_difficulty(val: int) -> void:
        if val < 0:
            difficulty = 0
        elif val > max_difficulty_value:
            difficulty = max_difficulty_value
        else:
            difficulty = val

    func _set_min_figurines(val: int) -> void:
        if val < min_figurine_count:
            min_figurines = min_figurine_count
        elif val > max_figurine_count:
            min_figurines = max_figurine_count
        else:
            min_figurines = val
        if min_figurines > max_figurines:
            max_figurines = min_figurines

    func _set_max_figurines(val: int) -> void:
        if val < min_figurine_count:
            max_figurines = min_figurine_count
        elif val > max_figurine_count:
            max_figurines = max_figurine_count
        else:
            max_figurines = val
        if max_figurines < min_figurines:
            min_figurines = max_figurines
    
    func _set_min_targets(val: int) -> void:
        if val < min_target_count:
            min_targets = min_target_count
        elif val > max_target_count:
            min_targets = max_target_count
        else:
            min_targets = val
        if min_targets > max_targets:
            max_targets = min_targets
    
    func _set_max_targets(val: int) -> void:
        if val < min_target_count:
            max_targets = min_target_count
        elif val > max_target_count:
            max_targets = max_target_count
        else:
            max_targets = val
        if max_targets < min_targets:
            min_targets = max_targets

    func _to_string() -> String:
        var config_str: String = "random: %016x, difficulty: %d, figurines: (%d, %d), targets: (%d, %d)"
        return config_str % [randomness_seed, difficulty, min_figurines, max_figurines, min_targets, max_targets]
    
    func to_seed() -> String:
        return "%016x%x%x%x%x%x" % [
            randomness_seed,
            difficulty,
            min_figurines - min_figurine_count,
            max_figurines - min_figurine_count,
            min_targets - min_target_count,
            max_targets - min_target_count
        ]
    
    static func from_seed(config_seed: String) -> Config:
        var new_config: Config = Config.new()
        if not config_seed.is_valid_hex_number():
            return new_config
        new_config.randomness_seed = config_seed.substr(0, 16).hex_to_int()
        new_config.difficulty = config_seed.substr(16, 1).hex_to_int()
        new_config.min_figurines = config_seed.substr(17, 1).hex_to_int() + min_figurine_count
        new_config.max_figurines = config_seed.substr(18, 1).hex_to_int() + min_figurine_count
        new_config.min_targets = config_seed.substr(19, 1).hex_to_int() + min_target_count
        new_config.max_targets = config_seed.substr(20, 1).hex_to_int() + min_target_count
        return new_config
        
    static func random(fixed_difficulty: int = -1) -> Config:
        var new_config: Config = Config.new()
        new_config.randomness_seed = (randi() << 31) + (randi() >> 1)
        if fixed_difficulty < 0:
            new_config.difficulty = randi_range(0, max_difficulty_value)
        else:
            new_config.difficulty = fixed_difficulty
        new_config.min_figurines = randi_range(min_figurine_count, max_figurine_count)
        new_config.max_figurines = randi_range(new_config.min_figurines, max_figurine_count)
        new_config.min_targets = randi_range(min_target_count, max_target_count)
        new_config.max_targets = randi_range(new_config.min_targets, max_target_count)
        return new_config

func generate_fixed(grid: Array, hwalls: Array, vwalls: Array, figurine_starting_positions: Array[Vector2]) -> Board:
    assert(len(grid) == 18)
    for row in grid:
        assert(len(row) == 18)
    assert(len(hwalls) == 17)
    for row in hwalls:
        assert(len(row) == 18)
    assert(len(vwalls) == 18)
    for row in vwalls:
        assert(len(row) == 17)
    
    var board: Board = Board.new()
    board.grid = grid
    board.hwalls = hwalls
    board.vwalls = vwalls
    
    for starting_pos in figurine_starting_positions:
        assert(board.get_vec(starting_pos) == Board.Pos.FIGURINE)
    board.figurine_starting_positions = figurine_starting_positions
    return board

func generate_from_seed(config_seed: String) -> Board:
    return generate_from_config(Config.from_seed(config_seed))

func generate_random() -> Board:
    return generate_from_config(Config.random())

func generate_from_config(config: Config) -> Board:
    seed(config.randomness_seed)

    var board: Board = Board.new()
    var target_amount: int = randi_range(config.min_targets, config.max_targets)
    var figurine_amount: int = randi_range(config.min_figurines, config.min_figurines)

    _generate_random_walls(board)
    
    for i in range(figurine_amount):
        _spawn_random_figurine(board)
    
    var possible_target_positions: Array = _determine_target_positions(board)
    var base_target_difficulty: int = config.difficulty >> 1
    var target_difficulty_alternator: int = config.difficulty % 2 + 1
    
    for i in range(target_amount):
        _spawn_random_target(board, possible_target_positions[base_target_difficulty + i % target_difficulty_alternator])
    
    return board

func _generate_random_walls(board: Board) -> void:
    board.vwalls[1][randi_range(2, 8)] = true
    board.vwalls[1][randi_range(9, 15)] = true
    board.hwalls[randi_range(2, 8)][16] = true
    board.hwalls[randi_range(9, 15)][16] = true
    board.vwalls[16][randi_range(1, 7)] = true
    board.vwalls[16][randi_range(8, 14)] = true
    board.hwalls[randi_range(1, 7)][1] = true
    board.hwalls[randi_range(8, 14)][1] = true
            
    for i in range(8):
        var idx: int = randi_range(0, 47)
        @warning_ignore("integer_division")
        var x: int = idx / 7 + 2
        var y: int = idx % 7 + 2
        if i % 4 >= 2:
            x = 17 - x
        if floori(i / 4.0) == 1:
            y = 17 - y

        var xoff: int = randi_range(0, 1)
        if board.get_xy(x-1, y) == Board.Pos.WALL:
            xoff = 0
        elif board.get_xy(x+1, y) == Board.Pos.WALL:
            xoff = 1
        var yoff: int = randi_range(0, 1)
        if board.get_xy(x, y-1) == Board.Pos.WALL:
            yoff = 0
        elif board.get_xy(x, y+1) == Board.Pos.WALL:
            yoff = 1
        board.hwalls[y - yoff][x] = true
        board.vwalls[y][x - xoff] = true

func _spawn_random_figurine(board: Board) -> void:
    var x: int = randi_range(1, 16)
    var y: int = randi_range(1, 16)
    while board.get_xy(x, y) != Board.Pos.EMPTY:
        x = randi_range(1, 16)
        y = randi_range(1, 16)
    board.figurine_starting_positions.append(Vector2(x, y))
    board.set_xy(x, y, Board.Pos.FIGURINE)

func _determine_target_positions(board: Board) -> Array:
    var possible_target_positions: Array[Array] = []
    for difficulty in target_difficulties:
        possible_target_positions.append([])

    for y in range(1, 17):
        for x in range(1, 17):
            var target_difficulty: int = _get_target_difficulty(board, x, y)
            if target_difficulty >= 0:
                possible_target_positions[target_difficulty].append(Vector2(x, y))
    return possible_target_positions
                    
func _get_target_difficulty(board: Board, x: int, y: int) -> int:
    var vertical_walls: int = int(board.wall_above(x, y)) + int(board.wall_below(x, y))
    var horizontal_walls: int = int(board.wall_left(x, y)) + int(board.wall_right(x, y))
    var on_outer_wall: bool = x == 1 or x == 16 or y == 1 or y == 16

    if horizontal_walls == 2 and vertical_walls == 2:
        return -1
    if vertical_walls == 1 and horizontal_walls == 1:
        if on_outer_wall:
            return 0
        return 1
    if horizontal_walls == 1 or vertical_walls == 1:
        if on_outer_wall:
            return 1
        return 2
    return 3

func _spawn_random_target(board: Board, possible_positions: Array) -> void:
    var amount_of_figurines: int = len(board.figurine_starting_positions)
    var amount_of_possibilities: int = len(possible_positions)
    
    var target_id: int = randi_range(0, amount_of_figurines) - 1
    var target_pos: Vector2 = possible_positions[randi_range(0, amount_of_possibilities - 1)]
    while board.get_vec(target_pos) != Board.Pos.EMPTY:
        target_pos = possible_positions[randi_range(0, amount_of_possibilities - 1)]

    board.targets[target_pos] = target_id
