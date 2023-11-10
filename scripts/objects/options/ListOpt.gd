class_name ListOpt extends OptionButton

@export var option_name:String = "fnf_parse"
@export var default_value:int = 0

func _ready():
	select(Config.get_opt(option_name, default_value))
	item_selected.connect(select_item)
	
func select_item(id:int):
	Config.set_opt(option_name, id)
