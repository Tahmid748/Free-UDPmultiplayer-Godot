extends Node2D

@onready var boulder: RigidBody2D = $boulder
var self_path : String = "res://level/level_3/level_3.tscn"

func _ready() -> void:
	print("level 3 ready")
	
	InitiateLevel.player_holder = $player_holder
	InitiateLevel.reference_camera = $reference_camera
	InitiateLevel.prepare_level()
