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
		["assets/songs/%s/%s.json" % [song, diff.to_lower()], 	Chart.parse_fnf],
		["assets/songs/%s/%s.sm" % [song, song], 				SmParser.parse_sm]
	]
	for path in file_formats:
		if Assets.file_exists(path[0]):
			da_chart = path[1].call(path[0], diff)
	
	if da_chart == null:
		da_chart = Chart.new(120) # fallback
					
	return da_chart

static func parse_fnf(path:String, _diff):
	var json = JSON.parse_string(Assets.get_text(path)).song
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
	
	var audio_path = "assets/songs/%s/audio" % song
	var audio_files = Assets.get_files_at(audio_path)
	audio_path += "/"
	
	var exts = ["ogg", "mp3"]
	var added_files = []
	for file in audio_files:
		if file.ends_with(".import"): # to prevent duplicates caused by ".import" files
			file = file.get_basename()
		if added_files.has(file):
			continue
			
		if exts.has(file.get_extension()):
			var music:AudioStreamPlayer = AudioStreamPlayer.new()
			music.stream = Assets.get_sound(audio_path + file)
			tracks.append(music)
			added_files.append(file)
			
	return tracks;

static func get_scripts(song:String):
	var scripts:Array[ScriptNode] = []
	
	var script_path = "assets/songs/%s/scripts" % song
	var script_files = Assets.get_files_at(script_path)
	script_path += "/"
	
	var added_files = []
	for file in script_files:
		if file.ends_with(".remap"): # to prevent duplicates caused by ".remap" files
			file = file.get_basename()
		if added_files.has(file):
			continue
		
		var ext = file.get_extension()
		if ext == "gd" or ext == "gdc":
			var script = GDScript.new()
			script.source_code = Assets.get_text(script_path + file)
			script.reload()
			scripts.append(script.new())
			added_files.append(file)
	
	# commented this out bc this still has the code for loading tscn scripts (idk how to load tscn files locally rn)
	#var found:Array[String] = []
	#for file in dir.get_files():
		#file = file.replace(".remap", "").replace(".gdc", ".gd")
		#var ext = file.get_extension()
		#var basename = file.get_basename()
#
		#if ext == "gd" and found.has(basename + ".tscn"):
			#continue
		#if ext == "tscn" and found.has(basename + ".gd"):
			#found[found.find(basename + ".gd")] = file
			#continue
		#found.append(file)
		#
	#for file in found:
		#var script = load(script_path + file).new() if file.get_extension() == "gd" else load(script_path + file).instantiate()
		#scripts.append(script)
		
	return scripts
