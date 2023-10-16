class_name Gameplay extends Node2D

@onready var strum_line = $StrumLine
@onready var tracks = $Tracks
@onready var hit_info = $HitInfo
@onready var score_info = $AnchorWorkaround/ScoreInfo
@onready var anchor_workaround = $AnchorWorkaround

@export var ms_gradient:Gradient = Gradient.new()

static var song_folder:String = "mismatch"
static var chart:Chart
var combo:int = 0

var score:int = 0
var misses:int = 0

var ms_sum:float = 0
var ms_calc:float = 0
var passed_notes:int = 0

func _ready():
	Conductor.bpm = chart.bpm
	Conductor.crochet = 60 / chart.bpm

	Conductor.cur_pos = -Conductor.crochet
	await get_tree().create_timer(Conductor.crochet).timeout

	strum_line.speed = chart.speed
	for track in Chart.get_tracks(song_folder):
		tracks.add_child(track)
		track.play()
		
	Conductor.beat_hit.connect(beat_hit)

func beat_hit(_beat):
	if abs(tracks.get_child(0).get_playback_position() - Conductor.cur_pos) >= 0.02:
		for track in tracks.get_children():
			track.seek(Conductor.cur_pos)

func _process(delta):
	var beat_progress = 1 - fmod(Conductor.float_beat, 1.0)
	anchor_workaround.scale.x = 1 + (beat_progress * beat_progress * 0.1)
	anchor_workaround.scale.y = anchor_workaround.scale.x
	
	hit_info.rotation = lerpf(hit_info.rotation, 0, delta * 7)
	hit_info.modulate.a -= delta * 3
	
	for note in chart.notes:
		if note.time > Conductor.cur_pos + 2: break
		
		strum_line.make_note(note)
		chart.notes.erase(note)
		
	if Input.is_action_just_pressed("ui_text_submit"):
		get_tree().paused = true
		add_child(load("res://scenes/game/PauseMenu.tscn").instantiate())

func _note_hit(note):
	combo += 1
	
	var ms = roundf((Conductor.cur_pos - note.hit_time) * 100000) * 0.01
	ms_sum += ms
	ms_calc += abs(ms)
	if ms < 0:
		hit_info.text = "< %s ms\nCombo: %s" % [ms, combo]
		hit_info.rotation_degrees = -10
	else:
		hit_info.text = "%s ms >\nCombo: %s" % [ms, combo]
		hit_info.rotation_degrees = 10
	
	ms *= 0.001
	var score_mult = 1 - abs(ms / strum_line.hit_window)
	score += 350 * score_mult + floori(5 * (combo / 20))
	update_score()
	
	hit_info.modulate = ms_gradient.sample(score_mult)
	hit_info.modulate.a = 1.5

func _note_miss(_note):
	combo = 0
	score -= 10
	misses += 1
	ms_calc += strum_line.hit_window * 1000
	hit_info.text = "oops..."
	hit_info.rotation_degrees = 10 if hit_info.rotation < 0 else -10
	hit_info.modulate = Color(1, 0.15, 0.15, 1.5)
	update_score()

func update_score():
	passed_notes += 1
	var av_ms = roundf(ms_sum / passed_notes * 100) * 0.01
	var acc_ms = ms_calc / passed_notes
	var acc = 100 - abs(roundf(acc_ms / (strum_line.hit_window * 1000) * 10000) * 0.01)
	score_info.text = "Score: %s\nMisses: %s\nAccuracy: %s%s\nAverage MS: %s" % [score, misses, acc, "%", av_ms]
