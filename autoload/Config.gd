extends Node

var options:ConfigFile

func _ready():
	options = ConfigFile.new()
	if FileAccess.file_exists("user://idkOptions.cfg"):
		options.load("user://idkOptions.cfg")
	Overlay.cur_vol = get_opt("volume", 0.5)

func get_opt(opt:StringName, default:Variant):
	return options.get_value("Options", opt, default)
	
func set_opt(opt:StringName, val:Variant):
	options.set_value("Options", opt, val)

func save():
	options.save("user://idkOptions.cfg")
