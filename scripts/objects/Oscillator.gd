extends Node2D
class_name Oscillator

@export var amplitude: Vector2 = Vector2(200, 0)
@export var speed: float = 2.0
@export var offset: float = 0.0

var _start_pos: Vector2
var _time: float = 0.0

func _ready() -> void:
	_start_pos = position

func _process(delta: float) -> void:
	_time += delta
	position = _start_pos + amplitude * sin(_time * speed + offset)
