extends ScriptNode

func song_start():
	game.strum_line.speed *= -1
	game.strum_line.position.y *= -1
	set_song_time(11.0)

func beat_hit(beat:int):
	if beat > 30:
		game.strum_line.mods.rotation_offset += 30
		game.strum_line.mods.strum_scale *= 1.5
		strum_tween("mods:strum_scale", Vector2(0.7, 0.7), Conductor.crochet * 0.5)
		get_tree().create_tween().tween_method(game.strum_line.rotate_from_center, 15 - 30 * (beat % 2), 0.0, Conductor.crochet * 0.5)
		# might make a helper for ^^^
