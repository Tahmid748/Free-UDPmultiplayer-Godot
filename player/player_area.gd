extends Area2D

var overlapping_areas : Array[Area2D] = []
var target_area : Area2D

func check_overlapping() -> Area2D:
	overlapping_areas.clear()
	
	for a in get_overlapping_areas():
		if a is InteractionArea:
			overlapping_areas.append(a)
	if overlapping_areas.size() == 0:
		return null
	if overlapping_areas.size() == 1:
		return overlapping_areas[0] #return the only area if there are only 1 areas 
	
	var cloest_area : Area2D = null
	var cloest_distance : float = INF
	
	for area in overlapping_areas:
		if area.interacted:
			continue
		
		var distance = area.global_position.distance_to(self.global_position)
		if distance < cloest_distance:
			cloest_distance = distance
			cloest_area = area
	
	return cloest_area


func _on_area_entered(area: Area2D) -> void:
	if area is InteractionArea:
		configure_area()

func _on_area_exited(area: Area2D) -> void:
	if area is InteractionArea:
		configure_area()


func configure_area():
	if !get_parent().testing_mode:
		if !is_multiplayer_authority(): return
	
	if target_area: #disable the area if it already exists
		target_area.disable_area()
	target_area = check_overlapping()
	if !target_area: return
	
	target_area.enable_area(get_parent())
	
	for overlap in overlapping_areas:
		if overlap != target_area:
			overlap.disable_area()
