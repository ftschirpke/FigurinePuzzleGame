extends Sprite2D

@onready var speed: int = Settings.figurine_speed * 60
@onready var movement_arrows: Control = $MovementArrows

@export var id: int

var selected: bool = false
var moving: bool = false
var target: Vector2 = Vector2.ZERO

signal figurine_selected(figurine_id: int)
signal figurine_stops_moving(figurine_id: int)
signal movement_arrow_pressed(direction: Vector2)

func _ready() -> void:
    deselect()

func update_speed() -> void:
    speed = Settings.figurine_speed * 60

func select() -> void:
    selected = true
    frame = id + 8

func deselect() -> void:
    selected = false
    frame = id
    movement_arrows.set_visibility()

func move(to: Vector2) -> void:
    moving = true
    target = to
 
func _physics_process(delta: float) -> void:
    if moving:
        var velocity: Vector2 = position.direction_to(target) * speed
        if position.distance_to(target) > speed * delta:
            position += velocity * delta
        else:
            position = target
            moving = false
            emit_signal("figurine_stops_moving", id)

func _on_select_figurine_button_pressed() -> void:
    if not selected:
        emit_signal("figurine_selected", id)

func _on_up_arrow_pressed() -> void:
    emit_signal("movement_arrow_pressed", Vector2.UP)

func _on_left_arrow_pressed() -> void:
    emit_signal("movement_arrow_pressed", Vector2.LEFT)

func _on_right_arrow_pressed() -> void:
    emit_signal("movement_arrow_pressed", Vector2.RIGHT)

func _on_down_arrow_pressed() -> void:
    emit_signal("movement_arrow_pressed", Vector2.DOWN)
