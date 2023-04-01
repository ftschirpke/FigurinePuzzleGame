extends Sprite2D

@export var id: int
@export var speed: int = 600

var selected: bool = false
var moving: bool = false
var target: Vector2 = Vector2.ZERO

signal robot_selected(robot_id: int)
signal robot_stops_moving(robot_id: int)

func _ready() -> void:
    deselect()

func select() -> void:
    selected = true
    frame = id + 8

func deselect() -> void:
    selected = false
    frame = id

func move(to: Vector2) -> void:
    moving = true
    target = to
 
func _physics_process(delta: float) -> void:
    if moving:
        var velocity: Vector2 = position.direction_to(target) * speed
        if position.distance_to(target) > 10:
            position += velocity * delta
        else:
            position = target
            moving = false
            emit_signal("robot_stops_moving", id)

func _on_select_robot_button_pressed() -> void:
    if not selected:
        emit_signal("robot_selected", id)
