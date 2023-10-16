extends CanvasLayer

@onready var label:Label = $Label
@onready var vol_sheet = $VolLabel/VolSheet
@onready var vol_label:Label = $VolLabel
@onready var vol_panel = $VolLabel/VolPanel

var cur_vol:float = 1;

func _ready():
	label.text = " " + str(Engine.get_frames_per_second()) + " FPS "
	label.size = Vector2.ZERO
	
func _physics_process(_delta):
	label.text = " " + str(Engine.get_frames_per_second()) + " FPS "
	label.size = Vector2.ZERO

func _unhandled_key_input(event):
	if not event.is_pressed(): return
	
	var actions = ["vol_up", "vol_down", "vol_mute"]
	for i in 3:
		if event.is_action(actions[i]):
			match i:
				0: cur_vol = min(cur_vol + 0.1, 1);
				1: cur_vol = max(cur_vol - 0.1, 0);
				2: cur_vol = 1 - ceilf(cur_vol);
			AudioServer.set_bus_volume_db(0, linear_to_db(cur_vol))
			vol_label.text = "      " + str(roundf(cur_vol * 100)) + "% "
			vol_label.size = Vector2.ZERO
			vol_sheet.frame = ceil(cur_vol)
