class_name StrumMods extends Resource

var _prop_list:Array[String] = []

var _strum_line:StrumLine

var _norm_positions:Array[float] = []
var spacing_mult:float = 1.0

## Moves the strums from LDUR to RUDL.
var flip_percent:float = 0.0
## Moves the strums from LDUR to DLRU.
var invert_percent:float = 0.0

var wavy:float = 0.0
var wavy_intensity:float = 1.0

var strum_scale:Vector2 = Vector2(0.7, 0.7)
var rotation_offset:float = 0.0
var _base_rotations:Array[float] = [0, -90, 90, 180]

enum BounceType {TILT, VERTICALS, HORIZONTALS, LEFT_SIDE, RIGHT_SIDE, ALTERNATING, INVERT_ALTERNATING}
var bounce_type:BounceType = BounceType.TILT
var bounce_pixels:float = 0.0
var bounce_absolute:bool = false
var _bounce_mult:Array[Array] = [[-1.5, -0.5, 0.5, 1.5], [0, -1, 1, 0], [-1, 0, 0, 1], [-1, 1, 0, 0], [0, 0, -1, 1], [0, -1, 0, 1], [-1, 0, 1, 0]]

var _backup:Dictionary = {}

func position_strums(delta:float):
	for i in _strum_line.strums.size():
		var strum = _strum_line.strums[i]
		make_backup()
		_strum_line.pre_strum_process.emit(strum, i)
		strum.modulate.v = lerpf(strum.modulate.v, 1, delta * 7.5)
		
		var invert_i:int = i - ((i % 2) * 2) - 1
		strum.position.x = lerpf(_norm_positions[i], _norm_positions[invert_i], invert_percent)
		strum.position.x -= strum.position.x * 2.0 * flip_percent
		strum.position.x *= spacing_mult
		strum.position.y = bounce_pixels * _bounce_mult[bounce_type][i]
		strum.scale = strum_scale
		strum.rotation_degrees = _base_rotations[i] + rotation_offset
		
		var glow = _strum_line.glows[i]
		glow.modulate.a = move_toward(glow.modulate.a, 0.0, delta * 3.5)
		glow.scale.x = 1.35 - 0.35 * glow.modulate.a
		glow.scale.y = glow.scale.x
		
		_strum_line.post_strum_process.emit(strum, i)
		recover()

func position_note(note:Note):
	make_backup()
	_strum_line.pre_note_process.emit(note)
	note.position.x = _strum_line.strums[note.lane_id].position.x \
					+ wavy * sin((Conductor.cur_pos - note.hit_time) / Conductor.crochet * PI * wavy_intensity) # wavy mod
					
	note.scale = _strum_line.strums[note.lane_id].scale
	note.note.rotation = _strum_line.strums[note.lane_id].rotation
	
	note.position.y = _strum_line.strums[note.lane_id].position.y \
					+ _strum_line.speed * 450 * (Conductor.cur_pos - note.hit_time) # basic positioning
	_strum_line.post_note_process.emit(note)
	recover()

func make_backup():
	for prop in _prop_list:
		_backup[prop] = get(prop)

func recover():
	for prop in _prop_list:
		set(prop, _backup[prop])

func _init(line):
	for prop in get_script().get_script_property_list():
		if not prop["name"].begins_with("_"):
			_prop_list.append(prop["name"])
	
	_strum_line = line
	for strum in _strum_line.strums:
		_norm_positions.append(strum.position.x)
