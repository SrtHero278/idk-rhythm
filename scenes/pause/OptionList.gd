extends Panel

@onready var scroll_check = $Container/VBoxContainer/ScrollCheck
@onready var scroll_speed = $Container/VBoxContainer/ScrollSpeed
@onready var v_box_container = $Container/VBoxContainer

func _ready():
	scroll_speed.value = Config.get_opt("scroll", 2.5)
	scroll_check.text = "Force Scroll Speed (%0.02f)" % [scroll_speed.value]

func _exit_tree():
	for child in v_box_container.get_children():
		if child is KeybindOpt:
			for cur_bind in InputMap.action_get_events(child.option_name):
				InputMap.action_erase_event(child.option_name, cur_bind)
			
			var keys = Config.get_opt(child.option_name, child.default_value)
			for key in keys:
				var event = InputEventKey.new()
				event.keycode = OS.find_keycode_from_string(key.to_lower())
				InputMap.action_add_event(child.option_name, event)
			
	Config.save()

func _scroll_changed(value):
	Config.set_opt("scroll", value)
	scroll_check.text = "Force Scroll Speed (%0.02f)" % [value]
