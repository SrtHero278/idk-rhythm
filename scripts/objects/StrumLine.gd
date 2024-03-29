class_name StrumLine extends Node2D

@onready var notes = $Notes
@onready var held_notes = $HeldNotes
var temp_note = load("res://scripts/objects/Note.tscn").instantiate()

var hit_window:float = 0.15
var speed:float = 2.7:
	get: return speed
	set(new_speed):
		if speed == new_speed: return
		
		for note in notes.get_children():
			if note.sustain_length > 0.0:
				note.resize_sustain(note.sustain_length, new_speed, 0)
		speed = new_speed

var actions:Array[String] = ["note_left", "note_down", "note_up", "note_right"]

var strums:Array[Sprite2D]
var glows:Array[Sprite2D]
var mods:StrumMods

func make_note(note):
	var new_note = temp_note.duplicate()
	new_note.hit_time = note.time
	new_note.lane_id = note.lane
	new_note.crochet = note.crochet
	new_note.last_change = note.last_change - Gameplay.chart.song_offset
	new_note.sustain_length = note.length
	notes.add_child(new_note)
	new_note.resize_sustain(note.length, speed, 0)

func _ready():
	for child in get_children():
		if child is Sprite2D:
			strums.push_back(child)
			glows.push_back(child.get_child(0))
	mods = StrumMods.new(self)

func _process(delta):
	mods.position_strums(delta)
	
	for note in notes.get_children():
		note = note as Note
		mods.position_note(note)
		
		if note.hit_time - Conductor.cur_pos < -hit_window:
			note_miss.emit(note)
			note.queue_free()
			
	var sin_mult = sin(fmod(Conductor.float_beat, 1.0) * PI) * 0.35 + 0.35
	for note in held_notes.get_children():
		note = note as Note
		
		note.note.modulate.a = sin_mult
		note.transform = strums[note.lane_id].transform
		
		note.sustain_length -= delta
		if note.sustain_length <= 0:
			note.queue_free()
			glows[note.lane_id].modulate = note.modulate
		else:
			note.resize_sustain(note.sustain_length, speed, strums[note.lane_id].rotation)

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
				glows[note.lane_id].modulate = note.modulate
			else:
				notes.remove_child(note)
				held_notes.add_child(note)
				note.note.rotation = 0
				note.sustain_length += note.hit_time - Conductor.cur_pos
				note.resize_sustain(note.sustain_length, speed, 0)
			break
	
func release(index:int):
	for note in held_notes.get_children():
		note = note as Note
		if (note.lane_id != index): continue
		
		if (note.sustain_length > note.crochet * 0.25):
			note_miss.emit(note)
		note.queue_free()

func zoom_from_center(amount:float):
	var unscaled_y = 290.0 * signf(speed)
	var unscaled_x = unscaled_y * -sin(rotation)
	unscaled_y *= cos(rotation)
		
	position.x += unscaled_x * -scale.y + unscaled_x * amount
	position.y += unscaled_y * -scale.y + unscaled_y * amount
	scale.x = amount
	scale.y = amount
	
func rotate_from_center(degrees:float):
	var scaled_y = 290.0 * signf(speed) * scale.y
	degrees = deg_to_rad(degrees)
	
	position.x += scaled_y * sin(rotation) + scaled_y * -sin(degrees)
	position.y += scaled_y * -cos(rotation) + scaled_y * cos(degrees)
	rotation = degrees

signal note_hit(note:Note)
signal note_miss(note:Note)

signal pre_strum_process(strum:Node2D, index:int)
signal post_strum_process(strum:Node2D, index:int)

signal pre_note_process(note:Note)
signal post_note_process(note:Note)
