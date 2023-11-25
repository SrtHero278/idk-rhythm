extends ColorRect

@onready var container = $Panel/Container/VBoxContainer
@onready var templete_check = $Panel/Container/VBoxContainer/TempleteCheck

func _ready():
	if not DirAccess.dir_exists_absolute("user://extra_assets"):
		DirAccess.make_dir_recursive_absolute("user://extra_assets/Personal/assets/songs")
		var desc = FileAccess.open("user://extra_assets/Personal/desc.txt", FileAccess.WRITE)
		desc.store_string("A extra folder for little thingies\nyou want in your copy of idk rhythm.")
		desc.close()
		
	for folder in DirAccess.get_directories_at("user://extra_assets"):
		var check:CheckBox = templete_check.duplicate()
		check.text = folder
		check.button_pressed = Assets.cur_folders.has("user://extra_assets/" + folder)
		if FileAccess.file_exists("user://extra_assets/" + folder + "/desc.txt"):
			check.tooltip_text = FileAccess.get_file_as_string("user://extra_assets/" + folder + "/desc.txt")
		container.add_child(check)
		
	templete_check.queue_free()


func _on_confirm_pressed():
	var check_list = container.get_children()
	for check in check_list:
		if check.button_pressed != Assets.cur_folders.has("user://extra_assets/" + check.text):
			Assets.cur_folders = []
			for box in check_list:
				if box.button_pressed:
					Assets.cur_folders.append("user://extra_assets/" + box.text)
			get_tree().change_scene_to_file("res://scenes/game/PauseMenu.tscn")
			return
	queue_free()

func _on_folder_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://extra_assets"))
