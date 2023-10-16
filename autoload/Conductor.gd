extends Node

var cur_pos:float = 0
var bpm:float = 120

var cur_beat:int = 0 
var float_beat:float = 0.0
var crochet:float = 0.5

# Formatted in [bpm. crpchet, song_time, beat_time]
var bpm_changes:Array[Array] = []

signal beat_hit(beat:int)

func _process(delta):
	cur_pos += delta
	var old_beat = cur_beat
	var cur_change = [bpm, crochet, 0.0, 0.0]
	
	for change in bpm_changes:
		if change[2] >= cur_pos:
			cur_change = change
			
	bpm = cur_change[0]
	crochet = cur_change[1]
	float_beat = cur_change[3] + (cur_pos - cur_change[2]) / crochet
	cur_beat = floori(float_beat)
	
	if cur_beat > old_beat:
		beat_hit.emit(cur_beat)
