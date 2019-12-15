extends Node

# total number of indexed riffs
var NUM_RIFFS = 5

# list of stream players for each riff
var riff_players = []

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	rng.seed += 69 # different stream from others
	# get the players for all the riffs
	for riff_num in range(1, NUM_RIFFS+1):
		var player = self.get_node("r"+str(riff_num))
		riff_players.append(player)

func play_riff():
	var riff_player = riff_players[rng.randi_range(0, NUM_RIFFS-1)]
	riff_player.play()
