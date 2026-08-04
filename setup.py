import os

files = {
    'scripts/characters/Player.gd': '''extends CharacterBody2D
class_name Player

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0

var gravity: float = ProjectSettings.get_setting(\"physics/2d/default_gravity\")
var is_active: bool = true

func _physics_process(delta: float) -> void:
\tif not is_on_floor():
\t\tvelocity.y += gravity * delta

\tif not is_active:
\t\tvelocity.x = move_toward(velocity.x, 0, speed)
\t\tmove_and_slide()
\t\treturn

\tif (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)) and is_on_floor():
\t\tvelocity.y = jump_velocity

\tvar direction := 0.0
\tif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
\t\tdirection += 1.0
\tif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
\t\tdirection -= 1.0

\tif direction:
\t\tvelocity.x = direction * speed
\telse:
\t\tvelocity.x = move_toward(velocity.x, 0, speed)

\tmove_and_slide()

func _draw() -> void:
\tvar rect := Rect2(-16, -32, 32, 64)
\tdraw_rect(rect, Color.DODGER_BLUE if is_active else Color.SLATE_GRAY)
\t
func _process(_delta: float) -> void:
\tqueue_redraw()
''',

    'scripts/characters/Drone.gd': '''extends CharacterBody2D
class_name Drone

@export var speed: float = 400.0
var is_active: bool = false

func _physics_process(_delta: float) -> void:
\tif not is_active:
\t\tvelocity = Vector2.ZERO
\t\tmove_and_slide()
\t\treturn

\tvar dir_x := 0.0
\tvar dir_y := 0.0
\t
\tif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir_x += 1.0
\tif Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): dir_x -= 1.0
\tif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): dir_y += 1.0
\tif Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): dir_y -= 1.0

\tvar direction := Vector2(dir_x, dir_y).normalized()
\tvelocity = direction * speed
\tmove_and_slide()

func _draw() -> void:
\tdraw_circle(Vector2.ZERO, 12, Color.GOLD if is_active else Color.DIM_GRAY)

func _process(_delta: float) -> void:
\tqueue_redraw()
''',

    'scripts/core/GameManager.gd': '''extends Node
class_name GameManager

@export var player: Player
@export var drone: Drone

var _last_tab_pressed: bool = false

func _ready() -> void:
\tif player and drone:
\t\tplayer.is_active = true
\t\tdrone.is_active = false

func _process(_delta: float) -> void:
\tvar tab_pressed := Input.is_key_pressed(KEY_TAB)
\tif tab_pressed and not _last_tab_pressed:
\t\t_toggle_active_character()
\t_last_tab_pressed = tab_pressed

\tif Input.is_key_pressed(KEY_ESCAPE):
\t\tget_tree().quit()

func _toggle_active_character() -> void:
\tif not player or not drone:
\t\treturn
\t
\tplayer.is_active = not player.is_active
\tdrone.is_active = not drone.is_active
''',

    'scenes/levels/prototype.tscn': '''[gd_scene load_steps=10 format=3 uid=\"uid://d0m5e4x0h2j3\"]

[ext_resource type=\"Script\" path=\"res://scripts/characters/Player.gd\" id=\"1_play\"]
[ext_resource type=\"Script\" path=\"res://scripts/characters/Drone.gd\" id=\"2_dron\"]
[ext_resource type=\"Script\" path=\"res://scripts/core/GameManager.gd\" id=\"3_gm\"]
[ext_resource type=\"Script\" path=\"res://scripts/utils/ShadowColliderGenerator.gd\" id=\"4_scg\"]

[sub_resource type=\"RectangleShape2D\" id=\"RectangleShape2D_player\"]
size = Vector2(32, 64)

[sub_resource type=\"CircleShape2D\" id=\"CircleShape2D_drone\"]
radius = 12.0

[sub_resource type=\"RectangleShape2D\" id=\"RectangleShape2D_floor\"]
size = Vector2(2000, 50)

[sub_resource type=\"Gradient\" id=\"Gradient_light\"]
offsets = PackedFloat32Array(0, 0.7)
colors = PackedColorArray(1, 1, 1, 1, 0, 0, 0, 1)

[sub_resource type=\"GradientTexture2D\" id=\"GradientTexture2D_light\"]
gradient = SubResource(\"Gradient_light\")
fill = 1
fill_from = Vector2(0.5, 0.5)
fill_to = Vector2(0.8, 0.8)
width = 1024
height = 1024

[sub_resource type=\"OccluderPolygon2D\" id=\"OccluderPolygon2D_box\"]
polygon = PackedVector2Array(-50, -50, 50, -50, 50, 50, -50, 50)

[node name=\"Prototype\" type=\"Node2D\"]

[node name=\"ColorRect\" type=\"ColorRect\" parent=\".\"]
offset_left = -2000.0
offset_top = -2000.0
offset_right = 2000.0
offset_bottom = 2000.0
color = Color(0.12, 0.12, 0.15, 1)

[node name=\"GameManager\" type=\"Node\" parent=\".\" node_paths=PackedStringArray(\"player\", \"drone\")]
script = ExtResource(\"3_gm\")
player = NodePath(\"../Player\")
drone = NodePath(\"../Drone\")

[node name=\"Floor\" type=\"StaticBody2D\" parent=\".\"]
position = Vector2(500, 600)

[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"Floor\"]
shape = SubResource(\"RectangleShape2D_floor\")

[node name=\"Polygon2D\" type=\"Polygon2D\" parent=\"Floor\"]
color = Color(0.2, 0.3, 0.2, 1)
polygon = PackedVector2Array(-1000, -25, 1000, -25, 1000, 25, -1000, 25)

[node name=\"Obstacle\" type=\"Node2D\" parent=\".\"]
position = Vector2(500, 450)

[node name=\"StaticBody2D\" type=\"StaticBody2D\" parent=\"Obstacle\"]

[node name=\"CollisionPolygon2D\" type=\"CollisionPolygon2D\" parent=\"Obstacle/StaticBody2D\"]
polygon = PackedVector2Array(-50, -50, 50, -50, 50, 50, -50, 50)

[node name=\"Polygon2D\" type=\"Polygon2D\" parent=\"Obstacle\"]
color = Color(0.4, 0.2, 0.2, 1)
polygon = PackedVector2Array(-50, -50, 50, -50, 50, 50, -50, 50)

[node name=\"LightOccluder2D\" type=\"LightOccluder2D\" parent=\"Obstacle\"]
occluder = SubResource(\"OccluderPolygon2D_box\")

[node name=\"Player\" type=\"CharacterBody2D\" parent=\".\"]
position = Vector2(200, 500)
script = ExtResource(\"1_play\")

[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"Player\"]
shape = SubResource(\"RectangleShape2D_player\")

[node name=\"Camera2D\" type=\"Camera2D\" parent=\"Player\"]
zoom = Vector2(1.2, 1.2)
position_smoothing_enabled = true

[node name=\"Drone\" type=\"CharacterBody2D\" parent=\".\"]
position = Vector2(300, 200)
script = ExtResource(\"2_dron\")

[node name=\"CollisionShape2D\" type=\"CollisionShape2D\" parent=\"Drone\"]
shape = SubResource(\"CircleShape2D_drone\")

[node name=\"PointLight2D\" type=\"PointLight2D\" parent=\"Drone\"]
color = Color(0.9, 0.85, 0.6, 1)
energy = 1.5
shadow_enabled = true
shadow_color = Color(0, 0, 0, 1)
texture = SubResource(\"GradientTexture2D_light\")

[node name=\"ShadowColliderGenerator\" type=\"Node2D\" parent=\".\" node_paths=PackedStringArray(\"light_source\", \"occluders_parent\")]
script = ExtResource(\"4_scg\")
light_source = NodePath(\"../Drone/PointLight2D\")
occluders_parent = NodePath(\"../Obstacle\")
shadow_length = 2000.0

[node name=\"UI\" type=\"CanvasLayer\" parent=\".\"]

[node name=\"Label\" type=\"Label\" parent=\"UI\"]
offset_left = 20.0
offset_top = 20.0
offset_right = 300.0
offset_bottom = 60.0
text = \"A/D - Move | W/Space - Jump
TAB - Switch Character | ESC - Quit\"
''',

    'project.godot': '''; Engine configuration file.

config_version=5

[application]
config/name=\"UmbraForge\"
run/main_scene=\"res://scenes/levels/prototype.tscn\"
config/features=PackedStringArray(\"4.2\", \"Forward Plus\")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720

[rendering]
environment/defaults/default_clear_color=Color(0.1, 0.1, 0.1, 1)
'''
}

for path, content in files.items():
    full_path = os.path.join(r\"C:\Users\vidha\OneDrive\Documents\GODOT\UmbraForge\", path.replace(\"/\", \"\\\\\"))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, \"w\", encoding=\"utf-8\") as f:
        f.write(content)

print(\"Files generated successfully!\")
