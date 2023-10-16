extends Node2D

@onready var notes = $Notes
@onready var held_notes = $HeldNotes
var temp_note = load("res://scripts/objects/Note.tscn").instantiate()

var hit_window:float = 0.15
var speed:float = 2.7

var actions:Array[String] = ["note_left", "note_down", "note_up", "note_right"]

var strums:Array[Sprite2D]

func make_note(note):
	var new_note = temp_note.duplicate()
	new_note.hit_time = note.time
	new_note.lane_id = note.lane
	new_note.crochet = note.crochet
	new_note.last_change = note.last_change - Gameplay.chart.song_offset
	new_note.sustain_length = note.length
	notes.add_child(new_note)
	new_note.position.x = get_child(note.lane).position.x
	new_note.note.rotation = get_child(note.lane).rotation
	new_note.resize_sustain(note.length, speed)

func _ready():
	for child in get_children():
		if child is Sprite2D:
			strums.push_back(child)

func _process(delta):
	for strum in strums:
		strum.modulate.v = lerpf(strum.modulate.v, 1, delta * 7.5)
	
	for note in notes.get_children():
		note = note as Note
		note.position.y = strums[note.lane_id].position.y + speed * 450 * (Conductor.cur_pos - note.hit_time)
		
		if note.hit_time - Conductor.cur_pos < -hit_window:
			note_miss.emit(note)
			note.queue_free()
			
	for note in held_notes.get_children():
		note = note as Note
		note.sustain_length -= delta
		if note.sustain_length <= 0:
			note.queue_free()
		else:
			note.resize_sustain(note.sustain_length, speed)

func _unhandled_key_input(event):
	for i in 4:
		if event.is_action_pressed(actions[i]):
			press(i)
			break
		elif event.is_action_released(actions[i]):
			release(i)
			break
			
func press(index:int):
	var strum = get_child(index)
	strum.modulate.v = 0.25
	
	for note in notes.get_children():
		note = note as Note
		if (note.lane_id != index): continue
		
		if abs(Conductor.cur_pos - note.hit_time) < hit_window:
			strum.modulate.v = 2.0
			note_hit.emit(note)
			if note.sustain_length <= 0:
				note.queue_free()
			else:
				notes.remove_child(note)
				held_notes.add_child(note)
				note.position.y = 0
			break
	
func release(index:int):
	for note in held_notes.get_children():
		note = note as Note
		if (note.lane_id != index): continue
		
		if (note.sustain_length > note.crochet * 0.25):
			note_miss.emit(note)
		note.queue_free()

signal note_hit(note:Note)
signal note_miss(note:Note)
