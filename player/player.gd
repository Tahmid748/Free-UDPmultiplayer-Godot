class_name Player
extends CharacterBody2D

@export_group("Multiplayer Properties")
@export var player_id : int = 1
@export var camera_limit : Vector4i
@export var testing_mode : bool = false

@export_group("Player Properties")
@export var self_color : Color:
	set(value):
		self_color = value
		_apply_appearance.call_deferred()
	get:
		return self_color
@export var self_name : String:
	set(value):
		self_name = value
		_apply_appearance.call_deferred()
	get:
		return self_name
@export var freeze : bool = false
@export var max_speed : float = 80.0
@export var health : int = 10:
	set(value):
		health = value
		health_updated(value)
	get:
		return health
@export var on_minecart : bool = false:
	set(value):
		on_minecart = value
		freeze = value #set freeze to true if on minecart
		set_collision_layer_value(1, !value)
		set_collision_mask_value(1, !value)
	get:
		return on_minecart
@export var has_weapon : bool = false:
	set(value):
		has_weapon = value
		_configure_weapon() 
	get:
		return has_weapon
var weapon : Area2D

@onready var player_name: Label = $name
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var weapon_location: Marker2D = $weapon_location

enum player_directions { RIGHT , LEFT }
var player_direction : player_directions = player_directions.RIGHT:
	set(direction):
		if direction == player_direction: return
		player_direction = direction
		_update_player_direction()
	get:
		return player_direction

var max_health := 10
var jump_velocity := -300.0
var water_velocity := -50.0
var speed := 80.0

var jumping := false
var in_water := false:
	set(value):
		in_water = value
		water_position_updated(value)
	get:
		return in_water
var swimming := false
var respawn_point : Vector2

signal camera_limit_changed(x,y,z,w)

func _enter_tree() -> void:
	player_id = name.to_int()
	set_multiplayer_authority(player_id)

func _ready() -> void:
	_configure_multiplayer()
	
	respawn_point = global_position
	camera_limit_changed.connect(set_camera_limits)
	
	anim_sprite.material = anim_sprite.material.duplicate()
	_apply_appearance()
	
	if is_multiplayer_authority():
		self_name = MultiplayerManager.self_name
		self_color = MultiplayerManager.self_color

func _configure_multiplayer() -> void:
	if testing_mode: 
		camera.make_current()
		return
	
	if multiplayer.get_unique_id() == player_id:
		camera.make_current()
	else:
		camera.enabled = false
	
	if !multiplayer.is_server():
		self.process_mode = Node.PROCESS_MODE_DISABLED
		$start_timer.start()
		return


func _physics_process(delta: float) -> void:
	
	if Global.stop_input: return
	
	if !testing_mode:
		if !is_multiplayer_authority(): return
	if freeze: return
	
	if !in_water and !swimming:
		speed = 80.0
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			jumping = true
	elif in_water:
		speed = 40.0
		if not is_on_floor():
			velocity.y += 100.0 * delta
		
		if Input.is_action_pressed("jump"):
			velocity.y = water_velocity
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if velocity.x > 0:
		player_direction = player_directions.RIGHT
	elif velocity.x < 0:
		player_direction = player_directions.LEFT
	
	
	_handle_animations(direction)
	_handle_rigid_collisions()
	
	move_and_slide()


func health_updated(value):
	print("health has been updated! Set health to: ", health)
	
	if value <= 0:
		print("The player has died!")
		death()


func death():
	health = max_health
	global_position = respawn_point
	print("the player has respawned!")

func water_position_updated(value) -> void:
	if value:
		swimming = true
	else:
		await get_tree().create_timer(0.15).timeout
		swimming = false

func _configure_weapon() -> void:
	for child in get_children():
		if child.is_in_group("weapon"):
			child.global_position = weapon_location.global_position
			if player_direction == player_directions.LEFT:
				child.scale.x *= -1
			weapon = child

func _apply_appearance() -> void:
	player_name.text = self_name
	anim_sprite.material.set_shader_parameter("new_color", self_color)

func _update_player_direction():
	anim_sprite.flip_h = !anim_sprite.flip_h
	weapon_location.position.x *= -1

func _handle_rigid_collisions():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			if c.get_collider() is Minecart:
				if !c.get_collider().can_push: return
			
			var push_dir = -c.get_normal()
			
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_in_push_dir = max(0.0,velocity_diff_in_push_dir)
			
			var mass_ratio = min(1.0, 80 / c.get_collider().mass)
			push_dir.y = 0
			var push_force = mass_ratio * 5.0
			
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)


func _handle_animations(direction : float):
	#handle jump
	if velocity.y != 0.0:
		if velocity.y < 0:
			anim.play("jump_start")
		elif velocity.y > 120:
			anim.play("jump_end")
		elif velocity.y > 0:
			anim.play("mid_air")
		return
	if jumping and is_on_floor():
		anim.play("jump_end") #force end the jump if jumping is true and you're on floor for some reason
	
	if jumping: return
	
	#handle walk
	if direction:
		anim.play("walk")
	else:
		anim.play("idle")


@rpc("any_peer")
func set_camera_limits(x,y,z,w,disable_camera):
	if disable_camera:
		camera.enabled = false
	camera.limit_left = x
	camera.limit_top = y
	camera.limit_right = z
	camera.limit_bottom = w
	print("changed camera properties!")
	
	await get_tree().process_frame
	
	if multiplayer.is_server():
		rpc("set_camera_limits",x,y,z,w,disable_camera)


func _on_start_timer_timeout() -> void:
	self.process_mode = Node.PROCESS_MODE_INHERIT
	$start_timer.queue_free()
	print("activating self")


func _on_animation_player_current_animation_changed(anim_name: String) -> void:
	if anim_name == "jump_end":
		jumping = false
