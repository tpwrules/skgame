extends CollisionShape2D


onready var gfx_obj = $"../../graphics"
onready var trail_wheel_obj = $"../../trailing_wheel"

# distance between us and the player's graphics
onready var rel_pos = self.global_position - gfx_obj.global_position
# distance between us and the other wheel
onready var wheel_dist = (self.global_position-trail_wheel_obj.global_position).length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	gfx_obj.global_position = self.global_position - rel_pos
	var prev_pos = trail_wheel_obj.global_position
	var other_dir = self.global_position.direction_to(prev_pos)
	# put the other wheel at the same angle relative to us as before,
	# but at the fixed wheel distance
	prev_pos = (other_dir*wheel_dist)+self.global_position
	trail_wheel_obj.global_position = prev_pos
	
	# rotate the graphics to follow the wheel positions
	gfx_obj.rotation = (self.global_position-prev_pos).angle()
	
