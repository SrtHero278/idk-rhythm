extends Slider

@export var label:Control
@export var option_name:String = "scroll"
@export var default_value:float = 2.5

var label_text:String
var has_text:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	has_text = (label != null and "text" in label)
	value = Config.get_opt(option_name, default_value)
	if has_text:
		label_text = label.text
		label.text = label_text.replace("$VALUE", str(value))
	value_changed.connect(slider_change)

func slider_change(new_value):
	Config.set_opt(option_name, new_value)
	if has_text:
		label.text = label_text.replace("$VALUE", str(new_value))
