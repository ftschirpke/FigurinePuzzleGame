extends Node2D
class_name LevelManager

@onready var current_level = $Level1
@onready var finished_screen: Control = $UserInterface/FinishedScreen
@onready var results_table: ResultsTable = $UserInterface/FinishedScreen/MarginContainer/HBoxContainer/VBoxContainer/ResultsTable
@onready var congratulations_label: Label = $UserInterface/FinishedScreen/MarginContainer/HBoxContainer/VBoxContainer/CongratulationsLabel
@onready var congratulations_timer: Timer = $CongratulationsTimer
@onready var pause_overlay: PauseOverlay = $UserInterface/PauseOverlay

const congratulations_text: String = "%s, you solved %s puzzles correctly%s"

var level = preload("res://levels/level.tscn")

var current_seed_id: int: set = _set_current_seed_id
var is_last_level: bool = false

var level_seeds: Array[String]
var level_names: Array[String]
var moves_needed_for_levels: Array[int]

var minimum_amount_of_results_show: int = -1

func start() -> void:
    assert(len(level_seeds) > 0)
    assert(len(level_seeds) <= 8)
    current_seed_id = 0

    if len(level_seeds) == 1:
        is_last_level = true

func _set_current_seed_id(new_seed_id: int) -> void:
    current_seed_id = new_seed_id
    if current_seed_id == len(level_seeds) - 1:
        is_last_level = true
    current_level.board = BoardFactory.generate_from_seed(level_seeds[current_seed_id])
    current_level.puzzle_name = level_names[current_seed_id]

func restart() -> void:
    moves_needed_for_levels = []
    results_table.reset()
    current_seed_id = 0
    finished_screen.visible = false

func finish() -> void:
    var levels_solved: int = len(moves_needed_for_levels)
    var levels_amount: int = len(level_seeds)
    
    var start_str: String = "Congratulations" if levels_solved > 0 else "Sorry"
    var amount_str: String
    if levels_solved < levels_amount:
        amount_str = "%d out of %d" % [levels_solved, levels_amount]
    else:
        amount_str = "all %d" % levels_amount
    var end_str: String = "!" if levels_solved > 0 else "."
    congratulations_label.text = congratulations_text % [start_str, amount_str, end_str]
    
    var results_shown: int = 0
    var results_to_show: int = min(minimum_amount_of_results_show, levels_amount)
    while results_shown < levels_solved:
        results_table.add_pair(level_seeds[results_shown], moves_needed_for_levels[results_shown])
        results_shown += 1
    while results_shown < results_to_show:
        results_table.add_pair(level_seeds[results_shown], -1)
        results_shown += 1
    finished_screen.visible = true

func _on_pause_overlay_restart() -> void:
    restart()

func _on_current_level_solved(moves_needed: int) -> void:
    moves_needed_for_levels.append(moves_needed)
    congratulations_timer.start(1)

func _on_congratulations_timer_timeout() -> void:
    congratulations_timer.stop()
    if is_last_level:
        finish()
    else:
        current_seed_id += 1

func _on_pause_overlay_give_up() -> void:
    finish()

func _on_finished_screen_visibility_changed() -> void:
    pause_overlay.pause_allowed = not finished_screen.visible
