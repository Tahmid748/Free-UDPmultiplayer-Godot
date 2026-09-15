class_name InteractionArea
extends Area2D

enum interaction_types { ONE_SHOT , REUSE }
@export var interaction_type : interaction_types = interaction_types.ONE_SHOT
@export var refresh_time : float = 2.0 #for the time to refresh the interaction if the interaction type is reusable

@export var interaction_key : String = "button_e"
@export var interaction_label : Label
@export var error_message : String = "There was an error!"

@export var hit_interaction : bool = false
@export var hit_object_group : String = "weapon"

var interaction_player : CharacterBody2D #get the player who is inside the interaction zone, if needed.

var has_label := false
var label_tween : Tween

var interacted := false
var can_interact := false
var inside_interact_zone := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_label:
		has_label = true
		interaction_label.z_index = 100 #draw it on top of 
		interaction_label.modulate.a = 0.0


func _on_body_entered(body : Node2D) -> void:
	if !body is Player: return
	if body.is_multiplayer_authority() or body.testing_mode:
		if body.get_node("player_area").target_area != self: return
		enable_area(body)

func _on_body_exited(body : Node2D) -> void:
	if !body is Player: return
	if body.is_multiplayer_authority() or body.testing_mode:
		disable_area()

func disable_area():
	interaction_player = null
	inside_interact_zone = false
	can_interact = false
	display_interaction_label(false)

func enable_area(body : CharacterBody2D):
	interaction_player = body
	inside_interact_zone = true
	
	if !interacted:
		can_interact = true
		display_interaction_label(true)


func _input(event: InputEvent) -> void:
	if !can_interact: return
	if interacted: return
	if hit_interaction: return
	
	if event.is_action_pressed(interaction_key):
		if _validate_interaction():
			interaction()
		else:
			_display_error()
			return


func _display_error():
	if !has_label: return
	if interaction_label.has_meta("interaction_text"): return
	interaction_label.set_meta("interaction_text", interaction_label.text)
	interaction_label.text = error_message
	await get_tree().create_timer(0.5).timeout
	interaction_label.text = interaction_label.get_meta("interaction_text")
	interaction_label.remove_meta("interaction_text")


func display_interaction_label(display : bool) -> void:
	if !has_label: return
	
	if label_tween: label_tween.kill()
	label_tween = create_tween()
	
	var modulate_value : float
	modulate_value = 1.0 if display else 0.0
	
	label_tween.tween_property(interaction_label, "modulate:a", modulate_value , 0.3)

@rpc("any_peer")
func interaction():
	_configure_interaction()
	rpc("_configure_interaction")
	rpc("interaction_execution", interaction_player) #already called it locally while validating interaction so no need to do it anymore

@rpc("any_peer")
func _configure_interaction() -> void:
	interacted = true
	
	display_interaction_label(false)
	
	if interaction_type == interaction_types.REUSE:
		await get_tree().create_timer(refresh_time).timeout
		interacted = false
		if inside_interact_zone:
			can_interact = true #since can_interact will be false if you leave and re-enter the interaction zone during the refresh
			display_interaction_label(true)


func _validate_interaction() -> bool:
	return true if interaction_execution(interaction_player) else false

func take_hit():
	if !hit_interaction: return
	if _validate_interaction():
		interaction()
	else:
		_display_error()
		return


@rpc("any_peer")
func interaction_execution(body) -> bool:
	return false
