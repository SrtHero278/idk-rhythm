extends ScriptNode

var og_speed:float = 2.5
var passed_beat:float = 0.0

func _ready():
	og_speed = game.strum_line.speed
	game.get_node("Panel").queue_free()

	game.events = [
		[1.5, strum_tween, ["position:x", 320, Conductor.crochet * 0.25]],
		[16.75, woah, ["invert_percent", 0.0]],
		[17.5, woah, ["flip_percent", 1.0]],
		[37.5, scroll_drop],
		[48.75, quick_move, [-145, og_speed * 0.5]],
		[49.5, quick_move, [-145 * 0.75, og_speed * -0.5]],
		[53.5, scroll_drop],
		[61.5, center_strum],
		[64.75, rotate_strum],
		[65.5, rotate_strum],
		[66.25, rotate_strum]
	]

func woah(mod:String, val:float):
	game.strum_line.scale = Vector2(1.2, 1.2)
	game.strum_line.speed = og_speed * 1.25
	strum_tween("speed", og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	strum_tween("scale", Vector2.ONE, Conductor.crochet * 0.45)
	strum_tween("mods:" + mod, val, Conductor.crochet * 0.45)

func scroll_drop():
	game.strum_line.mods.wavy = 30
	strum_tween("position:y", 220, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	strum_tween("speed", og_speed * -0.25, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func quick_move(pos:float, speed:float):
	strum_tween("position:y", pos, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	strum_tween("speed", speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func center_strum():
	game.strum_line.mods.wavy = 30
	strum_tween("position:y", 0, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	strum_tween("speed", og_speed * 0.5, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func rotate_strum():
	strum_tween("rotation_degrees", game.strum_line.rotation_degrees + 90.0, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

#func _process(_delta):
#	if passed_beat < 1.5 && Conductor.float_beat >= 1.5:
#		passed_beat = 1.5
#		strum_tween("position:x", 320, Conductor.crochet * 0.25)
#	if passed_beat < 16.75 && Conductor.float_beat >= 16.75:
#		passed_beat = 16.75
#		game.strum_line.scale = Vector2(1.2, 1.2)
#		game.strum_line.speed = og_speed * 1.25
#		strum_tween("speed", og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("scale", Vector2.ONE, Conductor.crochet * 0.45)
#		strum_tween("mods:invert_percent", 0.0, Conductor.crochet * 0.45)
#	if passed_beat < 17.5 && Conductor.float_beat >= 17.5:
#		passed_beat = 17.5
#		game.strum_line.scale = Vector2(1.2, 1.2)
#		game.strum_line.speed = og_speed * 1.25
#		strum_tween("speed", og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("scale", Vector2.ONE, Conductor.crochet * 0.45)
#		strum_tween("mods:flip_percent", 1.0, Conductor.crochet * 0.45)
#	if passed_beat < 37.5 && Conductor.float_beat >= 37.5:
#		passed_beat = 37.5
#		game.strum_line.mods.wavy = 30
#		strum_tween("position:y", 220, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("speed", og_speed * -0.25, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 48.75 && Conductor.float_beat >= 48.75:
#		passed_beat = 48.75
#		game.strum_line.mods.wavy = 30
#		strum_tween("position:y", -145, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("speed", og_speed * 0.5, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 49.5 && Conductor.float_beat >= 49.5:
#		passed_beat = 49.5
#		strum_tween("position:y", -145 * 0.75, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("speed", -og_speed * 0.5, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 53.5 && Conductor.float_beat >= 53.5:
#		passed_beat = 53.5
#		game.strum_line.mods.wavy = 30
#		strum_tween("position:y", 220, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("speed", og_speed * -0.25, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 61.5 && Conductor.float_beat >= 61.5:
#		passed_beat = 61.5
#		game.strum_line.mods.wavy = 30
#		strum_tween("position:y", 0, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#		strum_tween("speed", og_speed * 0.5, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 64.75 && Conductor.float_beat >= 64.75:
#		passed_beat = 64.75
#		strum_tween("rotation_degrees", 180, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 65.5 && Conductor.float_beat >= 65.5:
#		passed_beat = 65.5
#		strum_tween("rotation_degrees", 270, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
#	if passed_beat < 66.25 && Conductor.float_beat >= 66.25:
#		passed_beat = 66.25
#		strum_tween("rotation_degrees", 360, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func beat_hit(beat):
	match beat:
		0:
			strum_tween("position:x", -320, Conductor.crochet * 0.25)
		3:
			strum_tween("position:x", 0, Conductor.crochet * 0.25)
		4, 12, 20:
			game.strum_line.mods.wavy = 0
			game.strum_line.mods.spacing_mult = 2.0
			strum_tween("speed", og_speed, Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("mods:spacing_mult", 1.0, Conductor.crochet * 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		5, 21:
			game.strum_line.mods.wavy = 30
			strum_tween("speed", og_speed * 0.5, Conductor.crochet * 6.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		13:
			game.strum_line.mods.wavy = 30
			strum_tween("speed", og_speed * 0.5, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		16:
			game.strum_line.scale = Vector2(1.2, 1.2)
			game.strum_line.speed = og_speed * 1.25
			strum_tween("speed", og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("scale", Vector2.ONE, Conductor.crochet * 0.45)
			strum_tween("mods:invert_percent", 1.0, Conductor.crochet * 0.45)
		18:
			game.strum_line.scale = Vector2(1.2, 1.2)
			game.strum_line.speed = og_speed * 1.25
			strum_tween("speed", og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("scale", Vector2.ONE, Conductor.crochet * 0.45)
			strum_tween("mods:flip_percent", 0.0, Conductor.crochet * 0.45)
		28:
			get_tree().create_tween().tween_property(game, "scale", Vector2(2.0, 2.0), Conductor.crochet * 5.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("speed", og_speed, Conductor.crochet * 5.5)
		36:
			game.strum_line.mods.wavy = 0
			game.strum_line.mods.spacing_mult = 2.0
			get_tree().create_tween().tween_property(game, "scale", Vector2.ONE, Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("position", Vector2(-320, -290), Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("speed", -og_speed, Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("mods:spacing_mult", 1.0, Conductor.crochet * 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		44, 60:
			game.strum_line.mods.wavy = 0
			game.strum_line.mods.spacing_mult = 2.0
			strum_tween("position", Vector2(0, 290), Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("speed", og_speed, Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("mods:spacing_mult", 1.0, Conductor.crochet * 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		45:
			game.strum_line.mods.wavy = 30
			strum_tween("position:y", 0, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("speed", og_speed * 0.5, Conductor.crochet * 3.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		48:
			game.strum_line.mods.wavy = 0
			strum_tween("position:y", -145 * 0.5, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		50:
			strum_tween("position:y", -290, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("speed", -og_speed, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		52:
			game.strum_line.mods.spacing_mult = 2.0
			strum_tween("position:x", 320, Conductor.crochet * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			strum_tween("mods:spacing_mult", 1.0, Conductor.crochet * 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		64:
			game.strum_line.mods.wavy = 0
			strum_tween("rotation_degrees", 90, Conductor.crochet * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		67:
			get_tree().create_tween().tween_property(game, "rotation_degrees", -720, Conductor.crochet).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
