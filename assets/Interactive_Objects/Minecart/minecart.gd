class_name Minecart
extends RigidBody2D

const SPEED = 250.0

@onready var wheel_1: RigidBody2D = $PinJoint2D/wheel
@onready var wheel_2: RigidBody2D = $PinJoint2D2/wheel
@onready var floor_detector: Node2D = $floor_detector

@onready var driver_name: Label = $driver_name
@onready var driving_player_sprite: Sprite2D = $driving_player_sprite
@onready var jumper_name: Label = $jumper_name
@onready var jumping_player_sprite: Sprite2D = $jumping_player_sprite


@export var can_drive := false:
	set(value):
		can_drive = value
		if value:
			change_authority.rpc(multiplayer.get_unique_id())
@export var can_jump := false
@export var jump_velocity : float = 550.0
@export var forward_speed : float = 150.0


var angular_damp_value := 5

var can_push := false

var acceleration := 0.5

var time := 0.0
var impulse_time := 0.0
var easing_duration := 0.6 # total time of the impulse
var applying_impulse := false

var shake_strength = 290

var control_player : CharacterBody2D

var driving_in_use := false
var jumping_in_use := false

@onready var jump_timer: Timer = $jump_timer
var jumping := false

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float
@export var wheel_1_rot : float
@export var wheel_2_rot : float
@export var wheel_1_pos : Vector2
@export var wheel_2_pos : Vector2

var smoothing := 16.0
var start := false

@export var direction : float

@export var testing_mode : bool = false

func _ready() -> void: #introduce a small delay at the start so everything syncs correctly.
	if not is_multiplayer_authority():
		freeze = true
		wheel_1.freeze = true
		wheel_2.freeze = true
		await get_tree().create_timer(0.5).timeout
		start = true
		freeze = false
		wheel_1.freeze = false
		wheel_2.freeze = false
	else:
		start = true


func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
	if is_multiplayer_authority():
		replicated_position = position
		replicated_rotation = rotation
		replicated_linear_velocity = linear_velocity
		replicated_angular_velocity = angular_velocity
		
		wheel_1_rot = wheel_1.rotation
		wheel_2_rot = wheel_2.rotation
		
		wheel_1_pos = wheel_1.position
		wheel_2_pos = wheel_2.position


func _physics_process(delta):
	if not is_multiplayer_authority():
		if !start: return
		position = position.lerp(replicated_position, delta * smoothing)
		rotation = lerp_angle(rotation, replicated_rotation, delta * smoothing)
		
		wheel_1.position = wheel_1.position.lerp(wheel_1_pos, delta * smoothing)
		wheel_2.position = wheel_2.position.lerp(wheel_2_pos, delta * smoothing)
		
		wheel_1.rotation = lerp_angle(wheel_1.rotation, wheel_1_rot, delta * smoothing)
		wheel_2.rotation = lerp_angle(wheel_2.rotation, wheel_2_rot, delta * smoothing)
		
		linear_velocity = replicated_linear_velocity
		angular_velocity = replicated_angular_velocity
	
	if control_player:
		if !control_player.testing_mode:
			if !control_player.is_multiplayer_authority(): return
	if !can_drive: return
	
	if abs(linear_velocity.x) > 100 and not applying_impulse:
		applying_impulse = true
		impulse_time = 0.0

	if applying_impulse:
		impulse_time += delta
		var t := impulse_time / easing_duration
		if t > 1.0:
			applying_impulse = false
			return
		
		var ease_impulse := sin(t * PI)
		var impulse_strength = shake_strength * ease_impulse * delta * 10.0
		
		apply_central_impulse(Vector2.UP * impulse_strength)
		
	
	direction = Input.get_axis("move_left", "move_right")
	var target_velocity := direction * SPEED
	for detector in floor_detector.get_children():
		if detector.is_colliding():
			if not detector.get_collider().is_in_group("rail"):
				wheel_1.angular_velocity = lerp(wheel_1.angular_velocity, target_velocity * 0.01, delta * acceleration)
				wheel_2.angular_velocity = lerp(wheel_2.angular_velocity, target_velocity * 0.01, delta * acceleration)
			else:
				if direction:
					wheel_1.angular_damp = 0
					wheel_2.angular_damp = 0
					wheel_1.angular_velocity = lerp(wheel_1.angular_velocity, target_velocity, delta * acceleration)
					wheel_2.angular_velocity = lerp(wheel_2.angular_velocity, target_velocity, delta * acceleration)
				else:
					wheel_1.angular_damp = 5
					wheel_2.angular_damp = 5
		else:
			wheel_1.rotation = lerp_angle(wheel_1.rotation, 0.0 , delta * 2)
			wheel_2.rotation = lerp_angle(wheel_2.rotation, 0.0 , delta * 2)
			self.rotation = lerp_angle(self.rotation, 0.0 , delta * 2)

func _input(event: InputEvent) -> void:
	
	if testing_mode:
		if event.is_action_pressed("shift"):
			if is_multiplayer_authority():
				print("all actions activated.")
				can_drive = true
				can_jump = true
	
	if control_player:
		if !control_player.testing_mode:
			if !control_player.is_multiplayer_authority(): return
	if !can_jump: return
	for detector in floor_detector.get_children():
		if detector.is_colliding() and !jumping:
			if event.is_action_pressed("jump"):
				jumping = true
				jump_timer.start()
				
				jump_minecart()
				jump_minecart.rpc()

@rpc("any_peer")
func jump_minecart():
	self.linear_velocity = Vector2.ZERO
	self.angular_damp_value = 0
	wheel_1.angular_velocity = 0
	wheel_2.angular_velocity = 0
	wheel_1.linear_velocity = Vector2.ZERO
	wheel_2.linear_velocity = Vector2.ZERO
	
	self.linear_velocity.y = -jump_velocity
	wheel_1.apply_impulse(Vector2(direction, 0) * forward_speed)
	wheel_2.apply_impulse(Vector2(direction, 0) * forward_speed)

@rpc("any_peer", "call_local")
func change_authority(id : int):
	set_multiplayer_authority(id)

@rpc("any_peer") #no call local here cause in use must only be enabled on the other client
func configure_action(value : bool, is_driving : bool = false):
	if is_driving:
		driving_in_use = value
	else:
		jumping_in_use = value

@rpc("any_peer", "call_local")
func prepare_minecart(value : bool, driver : bool = false , body_name : String = "abc", color : Color = Color.WHITE):
	if driver:
		driver_name.text = body_name
		driving_player_sprite.material = driving_player_sprite.material.duplicate()
		driving_player_sprite.material.set_shader_parameter("new_color", color)
		driver_name.visible = value
		driving_player_sprite.visible = value
	else:
		jumper_name.text = body_name
		jumping_player_sprite.material = jumping_player_sprite.material.duplicate()
		jumping_player_sprite.material.set_shader_parameter("new_color", color)
		jumper_name.visible = value
		jumping_player_sprite.visible = value


func _on_jump_timer_timeout() -> void:
	jumping = false
	
