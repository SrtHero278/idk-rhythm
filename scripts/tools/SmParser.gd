class_name SmParser extends Object

static var charts:Dictionary = {}
static var cur_chart:Chart = null
static var bpm_changes:Array[Array] = []

static var queued_holds:Array[Chart.ChartNote] = [null, null, null, null]
static var queued_note_lines:Array[String] = []
static var note_line_count:int = -1
static var cur_type = "<NONE>"

static var cur_bpm = 120
static var quant_offset:float = 0.0
static var cur_time:float = 0.0
static var last_beat:float = 0.0
static var change_index:int = 0
static var first_change:Array = [120.0, 0.5, 0.0, 0.0]
static var last_change:Array = [120.0, 0.5, 0.0, 0.0]

static func parse_sm(path:String, diff:String):
	charts = {}
	bpm_changes = []
	first_change = [120.0, 0.5, 0.0, 0.0]
	last_change = [120.0, 0.5, 0.0, 0.0]
	cur_time = 0.0
	last_beat = 0.0
	quant_offset = 0.0
	note_line_count = -1
	
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()

	for line in text.split("\n", false):
		parse_line(line)

	return charts if (diff == "<ALL>") else charts[diff];

static func parse_line(line:String):
	match cur_type:
		"<NONE>":
			if line.begins_with("#"):
				cur_type = line.substr(1, line.find(":") - 1)
				parse_line(line)
		"OFFSET":
			quant_offset = float(line.substr(line.find(":"), line.find(";") - 1))
			cur_type = "<NONE>"
		"BPMS":
			for bep in line.split(",", false):
				var da_beat = float(bep.substr(0, bep.find("=") - 1))
				var da_bpm = float(bep.substr(bep.find("=") + 1))
				if bpm_changes.size() > 0:
					cur_time += (60 / da_bpm) * (da_beat - last_beat)
				bpm_changes.append([da_bpm, 60 / da_bpm, cur_time, da_beat])
				last_beat = da_beat
			
			if line.ends_with(";"):
				first_change = bpm_changes.pop_front()
				cur_bpm = first_change[0]
				cur_type = "<NONE>"
		"NOTES":
			if cur_chart == null:
				last_change = first_change
				change_index = 0
				cur_time = 0.0
				cur_chart = Chart.new(cur_bpm)
				cur_chart.song_offset = quant_offset
				cur_chart.bpm_changes = bpm_changes
			
			match note_line_count:
				1:
					cur_chart.extra_data["SM_Steps"] = line.substr(0, line.length() - 1).dedent()
				2:
					cur_chart.extra_data["SM_DiffType"] = line.substr(0, line.length() - 1).dedent()
				3:
					cur_chart.extra_data["SM_DiffRating"] = line.substr(0, line.length() - 1).dedent()
				4:
					note_line_count = -1
					cur_type = "NOTE_QUEUE"
			note_line_count += 1
		"NOTE_QUEUE":
			if line[0] == "," or line[0] == ";":
				var beat_inc:float = 4.0 / note_line_count;
				for i in note_line_count:
					for l in 4:
						match(queued_note_lines[i][l]):
							"1":
								cur_chart.notes.append(Chart.ChartNote.new(cur_time + quant_offset, l, 0.0, last_change[1], last_change[2]))
							"2":
								queued_holds[l] = Chart.ChartNote.new(cur_time + quant_offset, l, 0.0, last_change[1], last_change[2])
								cur_chart.notes.append(queued_holds[l])
							"3":
								if queued_holds[l] != null:
									queued_holds[l].length = (cur_time - queued_holds[l].time)
									queued_holds[l] = null
								
					cur_time += last_change[1] * beat_inc
					for b in range(change_index, bpm_changes.size()):
						if bpm_changes[b][2] >= cur_time:
							last_change = bpm_changes[b]
				queued_note_lines = []
				note_line_count = 0
				if line[0] == ";":
					charts[cur_chart.extra_data["SM_DiffType"]] = cur_chart
					cur_chart = null
					note_line_count = -1
					cur_type = "<NONE>"
			else:
				queued_note_lines.append(line)
				note_line_count += 1
		_:
			cur_type = "<NONE>"
