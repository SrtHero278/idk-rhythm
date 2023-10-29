extends CheckButton

@export var option_name:String = "bool_opt"
@export var default_value:bool = false

func _ready():
	button_pressed = Config.get_opt(option_name, default_value)
	
func _toggled(is_toggled): # YOuRe SHaDOwING A VariaB- shut.
	Config.set_opt(option_name, is_toggled)
