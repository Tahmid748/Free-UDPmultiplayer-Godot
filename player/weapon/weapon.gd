class_name Weapon
extends Area2D

@export var swing_key : String = "LMB"

@export var rotate_back : float = -40.0
@export var rotate_front : float = 40.0
@export var rotation_speed : float = 0.2

@onready var damage_timer: Timer = $damage_timer

var player_sprite : bool = false:
	set(value):
		if player_sprite == value: return
		player_sprite = value
		_configure_self()
	get:
		return player_sprite

var rotation_tween : Tween
var collision_shape : CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	for child in get_children():
		if child is CollisionShape2D:
			collision_shape = child
			child.disabled = true

func _process(delta: float) -> void:
	if get_parent() is CharacterBody2D:
		player_sprite = get_parent().find_child("AnimatedSprite2D").flip_h

func _input(event: InputEvent) -> void:
	if !get_parent().is_multiplayer_authority(): return
	
	if event.is_action_pressed(swing_key):
		swing_weapon()
		rpc("swing_weapon")
		damage_timer.wait_time = rotation_speed * 2
		damage_timer.start()

@rpc("any_peer")
func swing_weapon():
	if rotation_tween: rotation_tween.kill()
	rotation_tween = create_tween()
	
	collision_shape.disabled = true
	
	rotation_tween.tween_property(self,"rotation",deg_to_rad(rotate_back),rotation_speed)
	rotation_tween.tween_property(self,"rotation",deg_to_rad(rotate_front),rotation_speed)
	rotation_tween.tween_property(self,"rotation",0.0,rotation_speed)


func _on_body_entered(body : Node2D):
	pass

func _on_area_entered(area : Area2D):
	pass

func _configure_self():
	var weapon_marker = get_parent().find_child("weapon_location")
	
	self.global_position = weapon_marker.global_position
	self.scale.x = sign(weapon_marker.position.x)


func _on_damage_timer_timeout() -> void:
	collision_shape.disabled = false
	await get_tree().create_timer(0.2).timeout
	collision_shape.disabled = true
