class_name ScriptNode extends Node

var game:Gameplay

func strum_tween(property:NodePath, value:Variant, duration:float):
	return get_tree().create_tween().tween_property(game.strum_line, property, value, duration)

func set_song_time(new_time:float):
	if new_time == Conductor.cur_pos: return
	
	game.queued_index = game.queued_index if Conductor.cur_pos < new_time else 0
	game.event_index = game.event_index if Conductor.cur_pos < new_time else 0
	
	for note in game.strum_line.notes.get_children():
		note.queue_free()
	for note in game.strum_line.held_notes.get_children():
		note.queue_free()
		
	while Gameplay.chart.notes.size() > game.queued_index:
		var da_note = Gameplay.chart.notes[game.queued_index]
		if da_note.time - new_time > 2.0: break
		if da_note.time > new_time:
			game.strum_line.make_note(Gameplay.chart.notes[game.queued_index])
		game.queued_index += 1
		
	Conductor.cur_pos = new_time
	Conductor.bpm = Gameplay.chart.bpm
	Conductor.crochet = 60 / Gameplay.chart.bpm
	Conductor._process(0.0)
	for track in game.tracks.get_children():
		track.seek(Conductor.cur_pos)
	while game.events.size() > game.event_index and game.events[game.event_index][0] < Conductor.float_beat:
		game.event_index += 1
