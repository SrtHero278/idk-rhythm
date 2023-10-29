class_name KeybindOpt extends Button

@export var option_name:String = "note_left"
@export var default_value:Array[String] = ["A", "Left"]

var prefix:String
var rebinding:bool = false
var queued_binds:Array[String] = []

func _ready():
	prefix = text
	var keybinds = Config.get_opt(option_name, default_value)
	text += keybinds[0] + " & " + keybinds[1]
	pressed.connect(queue_rebind)
	focus_exited.connect(focus_exit)

func queue_rebind():
	queued_binds = []
	rebinding = true
	text = prefix
	
func focus_exit():
	rebinding = false
	var keybinds = Config.get_opt(option_name, default_value)
	text = prefix + keybinds[0] + " & " + keybinds[1]
	
func _unhandled_key_input(event):
	if not event.is_pressed() or not rebinding: return
	var da_key = OS.get_keycode_string(event.keycode)
	queued_binds.append(da_key)
	text += da_key
	if queued_binds.size() == 1:
		text += " & "
	else:
		rebinding = false
		Config.set_opt(option_name, queued_binds)
