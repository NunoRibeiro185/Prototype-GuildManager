extends TileMap

var moisture = FastNoiseLite.new() #X
var temperature = FastNoiseLite.new() #Y
var altitude = FastNoiseLite.new() #Oceans and Mountains

@export var moisture_frequency: float = 0.01
@export var temperature_frequency: float = 0.05
@export var altitude_frequency: float = 0.005

@onready var camera = $"../Camera2D"

var width = 128
var height = 128

var loaded_chunks = []

func _ready():
	moisture.noise_type = FastNoiseLite.TYPE_CELLULAR
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	
	moisture.frequency = moisture_frequency
	temperature.frequency = temperature_frequency
	altitude.frequency = altitude_frequency
	
func _process(delta):
	var camera_tile_pos = local_to_map(camera.position)
	generate_chunk(camera_tile_pos)
	unload_distant_chunks(camera_tile_pos)
	
func generate_chunk(pos):
	for x in range(width):
		for y in range(height):
			var x_pos = pos.x - (width/2) + x
			var y_pos = pos.y - (width/2) + y
			var moist = moisture.get_noise_2d(x_pos, y_pos) * 10
			var temp = temperature.get_noise_2d(x_pos, y_pos) * 10
			var alt = altitude.get_noise_2d(x_pos, y_pos) * 10
			
			if alt < 0: 
				set_cell(0, Vector2i(x_pos, y_pos), 0, Vector2(3,calc_altitude(alt)))
			else:
				set_cell(0, Vector2i(x_pos, y_pos), 0, Vector2(to_atlas(moist),to_atlas(temp)))
			
			if Vector2i(pos.x, pos.y) not in loaded_chunks:
				loaded_chunks.append(Vector2i(pos.x, pos.y))
			

func unload_distant_chunks(camera_position):
	var unload_dist = width * 3 + 1
	
	for chunk in loaded_chunks:
		var dist_to_camera = dist(chunk, camera_position)
		
		if dist_to_camera > unload_dist:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)
			
func clear_chunk(pos):
	for x in range(width):
		for y in range(height):
			var x_pos = pos.x - (width/2) + x
			var y_pos = pos.y - (width/2) + y
			set_cell(0, Vector2i(x_pos, y_pos), -1, Vector2(-1,-1))
	
func dist(point1, point2):
	var diff = point1 - point2
	return sqrt(diff.x ** 2 + diff.y ** 2)

func to_atlas(value):
	return round(3 * (value + 10)/20)

func calc_altitude(value):
	return round((3 * (value + 20))/20)
