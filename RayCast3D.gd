extends RayCast3D


func _process(delta):
	
	var hitObj = get_collider()
	if hitObj != null:
		#print("Collided with: ", hitObj.name, " of type: ", hitObj.get_class())

		var parentObj = hitObj.get_parent()

		if parentObj != null and parentObj.has_method("interact") && Input.is_action_just_pressed("interact"):
			#print("Has interact method on parent")
			parentObj.interact()
