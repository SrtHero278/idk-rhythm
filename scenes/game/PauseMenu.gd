extends ColorRect

@onready var song_list = $SongList
@onready var option_list = $OptionList

var cur_opt:String = "Select an Option"
var opt_lerp:float = 0.0
const PRESS_SIZE = Vector2(0.9, 0.9)
@onready var options = $Options
@onready var option_label = $OptionLabel

@onready var label = $Label
@onready var resume = $Options/Resume
@onready var icon = $Icon

func _ready():
	if self == get_tree().current_scene:
		options.remove_child(resume)
		resume.queue_free()
		label.text = "  Hello"
	
	var child_count = options.get_child_count()
	var width = 75 * child_count
	for i in child_count:
		options.get_child(i).position.x = 75 * i - width * 0.5
	
	var twn = create_tween().set_parallel()
	twn.tween_property(icon, "rotation", 0, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	twn.tween_property(icon, "position:x", 1000, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _process(delta):
	var mouse_pos = get_local_mouse_position()
	for button in options.get_children():
		var hovered = button.get_global_rect().has_point(mouse_pos)
		var target_y:float = -20.0 if hovered else -37.5
		button.position.y = lerpf(button.position.y, target_y, delta * 4.0)
		button.scale = PRESS_SIZE if hovered and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else Vector2.ONE
		button.modulate.v = 0.8 if hovered and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else 1.0
		
		if hovered and cur_opt != button.name:
			cur_opt = button.name
			option_label.text = cur_opt
			opt_lerp = 1.0

	opt_lerp = lerpf(opt_lerp, 0.0, delta * 8.0)
	option_label.modulate.a = 1.0 - opt_lerp
	option_label.position.y = 450 - opt_lerp * 10.0

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

func _on_assets_pressed():
	add_child(load("res://scenes/pause/AssetSelection.tscn").instantiate())
