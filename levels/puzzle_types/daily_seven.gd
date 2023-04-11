extends Node2D

@onready var level_manager: LevelManager = $LevelManager

func _ready() -> void:
    var date_string: String = Time.get_date_string_from_system()
    var date_hash: int = date_string.hash()
    level_manager.minimum_amount_of_results_show = 7
    seed(date_hash)
    for difficulty in range(BoardFactory.max_difficulty_value + 1):
        level_manager.level_seeds.append(BoardFactory.Config.random(difficulty).to_seed())
        level_manager.level_names.append("Daily #%d" % (difficulty+1))
    level_manager.start()
