class_name InteractionlessArea
extends Area2D

enum interaction_types{ ONE_SHOT , REUSE }
@export var interaction_type : interaction_types = interaction_types.ONE_SHOT
@export var player_required := true

var interacted := false
var interaction_player : CharacterBody2D
var interaction_object

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if player_required:
		if body.is_in_group("player_body"):
			interaction_player = body
			rpc("call_interaction")
	else:
		interaction_object = body
		rpc("call_interaction")

@rpc("any_peer", "call_local")
func call_interaction():
	if interaction_type == interaction_types.ONE_SHOT:
		interacted = true
	
	interaction_execution(interaction_player)
	rpc("interaction_execution" , interaction_player)
	

@rpc("any_peer")
func interaction_execution(player) -> void:
	pass
