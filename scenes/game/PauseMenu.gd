extends ColorRect

@onready var song_list = $SongList
@onready var option_list = $OptionList

@onready var label = $Label
@onready var resume = $Resume
@onready var icon = $Icon

func _ready():
	if self == get_tree().current_scene:
		resume.queue_free()
		label.text = "  Hello"
	
	var twn = create_tween().set_parallel()
	twn.tween_property(icon, "rotation", 0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	twn.tween_property(icon, "position:x", 1000, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_resume_pressed():
	var twn = create_tween().set_parallel()
	twn.tween_property(icon, "rotation_degrees", 450, 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	twn.tween_property(icon, "position:x", 1800, 0.75).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).finished.connect(finish_resume)

func finish_resume():
	get_tree().paused = false
	queue_free()



func _on_songs_pressed():
	song_list.visible = true
	option_list.visible = false

func _on_options_pressed():
	song_list.visible = false
	option_list.visible = true
