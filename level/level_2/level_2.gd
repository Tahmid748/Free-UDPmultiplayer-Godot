extends Node2D

func _ready() -> void:
	print("level2 ready")
	
	InitiateLevel.player_holder = $player_holder
	InitiateLevel.reference_camera = $reference_camera
	InitiateLevel.prepare_level()


func drain_water():
	var tween = create_tween()
	tween.tween_property($Water,"position:y",602,5)
