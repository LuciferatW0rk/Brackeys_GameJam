extends RayCast3D


@onready var blood = $"../Blood/GPUParticles3D"
var can_hit = true 
var hit_cooldown = 0.1
func _process(delta):
	
	var hitObj = get_collider()
	if hitObj != null:
		
		var parentObj = hitObj.get_parent()
		if hitObj.is_in_group("enemy"):
			blood.emitting = true
			#print("hit ", hitObj.name)#debug purpose
			hitObj.hit()
		#if parentObj != null :
			#print("Interacted with", parentObj)
		disable_hit()  # Disable further hits for a short duration

# Disable hits for a cooldown period
func disable_hit():
	can_hit = false
	# Create a timer to re-enable hit detection after the cooldown
	await get_tree().create_timer(hit_cooldown).timeout
	can_hit = true
			
