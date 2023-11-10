class_name StrumMods extends Resource

var strum_line:StrumLine

var norm_positions:Array[float] = []
var spacing_mult:float = 1.0

## Moves the strums from LDUR to RUDL.
var flip_percent:float = 0.0
## Moves the strums from LDUR to DLRU.
var invert_percent:float = 0.0

var wavy:float = 0.0
var wavy_intensity:float = 1.0

func position_strums(delta:float):
	for i in strum_line.strums.size():
		var strum = strum_line.strums[i]
		strum.modulate.v = lerpf(strum.modulate.v, 1, delta * 7.5)
		
		var invert_i:int = i - ((i % 2) - 0.5) * 2
		strum.position.x = lerpf(norm_positions[i], norm_positions[invert_i], invert_percent)
		strum.position.x -= strum.position.x * 2.0 * flip_percent
		strum.position.x *= spacing_mult

func position_note(note:Note):
	note.position.x = strum_line.strums[note.lane_id].position.x \
					+ wavy * sin((Conductor.cur_pos - note.hit_time) / Conductor.crochet * PI * wavy_intensity) # wavy mod
					
	note.note.rotation = strum_line.strums[note.lane_id].rotation
	
	note.position.y = strum_line.strums[note.lane_id].position.y \
					+ strum_line.speed * 450 * (Conductor.cur_pos - note.hit_time) # basic positioning

func _init(line):
	strum_line = line
	for strum in strum_line.strums:
		norm_positions.append(strum.position.x)
