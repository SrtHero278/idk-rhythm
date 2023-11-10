class_name Chart extends Resource

class ChartNote extends Resource:
	var time:float
	var lane:int
	var length:float
	var crochet:float
	var last_change:float
	
	func _init(_time:float, _lane:int, _length:float, _crochet:float, _last:float):
		self.time = _time
		self.lane = _lane
		self.length = _length
		self.crochet = _crochet
		self.last_change = _last

var extra_data:Dictionary = {}

var bpm:float = 120
var bpm_changes:Array[Array] = []

var notes:Array[ChartNote] = []
var speed:float = 2.7

var song_offset:float = 0.0

func _init(_bpm:float):
	self.bpm = _bpm

static func parse_chart(song:String, diff:String):
	var da_chart = null
	
	var file_formats = [
		["res://assets/songs/%s/%s.json" % [song, diff.to_lower()], 	Chart.parse_fnf],
		["res://assets/songs/%s/%s.sm" % [song, song], 					SmParser.parse_sm]
	]
	for path in file_formats:
		if ResourceLoader.exists(path[0]):
			da_chart = path[1].call(path[0], diff)
	
	if da_chart == null:
		da_chart = Chart.new(120) # fallback
					
	return da_chart

static func parse_fnf(path:String, _diff):
	var json = load(path).data.song
	var chart = Chart.new(json.bpm)
	chart.speed = json.speed
	
	if 'songOffset' in json:
		chart.song_offset = json.songOffset
	
	var cur_bpm:float = json.bpm
	var cur_crochet:float = 60 / cur_bpm
	var cur_time:float = 0.0
	var cur_beat:float = 0.0
	var last_time:float = 0.0
	
	for sec in json.notes:
		if "changeBPM" in sec and sec.changeBPM:
			cur_bpm = sec.bpm
			cur_crochet = 60 / sec.bpm
			last_time = cur_time
			chart.bpm_changes.append([cur_bpm, cur_crochet, cur_time, cur_beat])
			
		for note in sec.sectionNotes:
			var dir:int = note[1]
			
			var add_note = true # option was none of the below, we give all of em.
			match (Config.get_opt("fnf_parse", 0)):
				0: add_note = dir < 4 # Camera Target
				1: add_note = (dir < 4) == sec.mustHitSection # Player
				2: add_note = not ((dir < 4) == sec.mustHitSection) # Opponent
			
			if dir < 0 or not add_note: continue
			chart.notes.append(ChartNote.new(note[0] * 0.001, dir % 4, note[2] * 0.001, cur_crochet, last_time))
			
		var sec_beats = sec.lengthInSteps * 0.25 if (not "sectionBeats" in sec) else sec.sectionBeats # PSYCH ENGIN-
		cur_time += cur_crochet * sec_beats
		cur_beat += sec_beats
		
	chart.notes.sort_custom(func(a, b): return a.time < b.time)
	return chart

static func get_tracks(song:String):
	var tracks:Array[AudioStreamPlayer] = []
	
	#we do a little yoinking https://github.com/The-Coders-Den/NovaEngine-Godot-FNF/blob/main/scenes/gameplay/Gameplay.gd#L101-L114
	var audio_path = "res://assets/songs/%s/audio" % song
	var dir = DirAccess.open(audio_path)
	audio_path += "/"
	
	for file in dir.get_files():
		var music:AudioStreamPlayer = AudioStreamPlayer.new()
		for f in ["ogg", "mp3", "wav"]:
			if file.ends_with(f + ".import"):
				music.stream = load(audio_path + file.replace(".import", ""))
				tracks.append(music)
				
	return tracks;

static func get_scripts(song:String):
	var scripts:Array[Node] = []
	
	var script_path = "res://assets/songs/%s/scripts" % song
	if not DirAccess.dir_exists_absolute(script_path):
		return scripts
	var dir = DirAccess.open(script_path)
	script_path += "/"
	
	var found:Array[String] = []
	for file in dir.get_files():
		file = file.replace(".remap", "").replace(".gdc", ".gd")
		var ext = file.get_extension()
		var basename = file.get_basename()

		if ext == "gd" and found.has(basename + ".tscn"):
			continue
		if ext == "tscn" and found.has(basename + ".gd"):
			found[found.find(basename + ".gd")] = file
			continue
		found.append(file)
		
	for file in found:
		var script = load(script_path + file).new() if file.get_extension() == "gd" else load(script_path + file).instantiate()
		scripts.append(script)
		
	return scripts
