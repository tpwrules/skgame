extends Polygon2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# subdivisions in each dimension
var SUBDIVS = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	# create polygon vertices and UVs
	# and weights for each bone
	var tex = self.get_texture()
	var tex_size = tex.get_height() # which we assume is same as width
	var sub_size = tex_size/SUBDIVS
	assert(tex.get_height() == tex.get_width())

	# get all the bones currently attached
	var bone_paths = []
	var bone_poss = []
	var new_bone_weights = []
	for bone_idx in range(self.get_bone_count()):
		var bp = self.get_bone_path(bone_idx)
		bone_poss.append(
			self.get_node(self.skeleton).get_node(bp).global_position-self.global_position)
		bone_paths.append(bp)
		#var ba = PoolRealArray()
		new_bone_weights.append([])
	self.clear_bones()
	
	var new_points = PoolVector2Array()
	new_points.resize((SUBDIVS+1)*(SUBDIVS+1))
	
	# loop through each vertex
	var v_idx = 0
	for y_idx in range(SUBDIVS+1):
		var y_pos = y_idx*sub_size
		for x_idx in range(SUBDIVS+1):
			var x_pos = x_idx*sub_size
			var v_pos = Vector2(x_pos, y_pos)
			new_points.set(v_idx, v_pos)
			
			# weight vertex based on distance to bone
			for b_idx in range(len(bone_paths)):
				var dist = max(1-(abs(v_pos.distance_to(bone_poss[b_idx])/(tex_size*1.414))), 0)
				#print(dist)
				new_bone_weights[b_idx].append(dist)
			
			v_idx += 1
	
	var polygons = Array()
	for y_idx in range(SUBDIVS):
		for x_idx in range(SUBDIVS):
			polygons.append([
				(y_idx+0)*(SUBDIVS+1)+(x_idx+0),
				(y_idx+0)*(SUBDIVS+1)+(x_idx+1),
				(y_idx+1)*(SUBDIVS+1)+(x_idx+1),
				(y_idx+1)*(SUBDIVS+1)+(x_idx+0),
			])
	
	# configure new vertices and UVs (which are the same)
	self.set_polygon(new_points)
	self.set_uv(new_points)
	self.set_polygons(polygons)
	# configure new bones
	for x in range(len(new_bone_weights[0])):
		new_bone_weights[0][x] = new_bone_weights[0][x] / 10
	for b_idx in range(len(bone_paths)):
		self.add_bone(bone_paths[b_idx], PoolRealArray(new_bone_weights[b_idx]))
	
	#print(new_points)
	#print(polygons)
	for b_idx in range(4, len(new_bone_weights)):
		print(bone_paths[b_idx], new_bone_weights[b_idx])
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
