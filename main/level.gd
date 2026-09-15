extends Node

func new_level(scene_path):
	var scene = load(scene_path)
	
	print("getting the level...")
	print(self.get_children())
	
	for c in self.get_children():
		self.remove_child(c)
		c.call_deferred("queue_free")
	
	var new_scene = scene.instantiate()
	call_deferred("add_child", new_scene)
