extends Panel

@onready var tracks = $Tracks
@onready var wait_txt = $WaitingLabel
@onready var container = $Container/VBoxContainer

var cur_song:String
var song_diffs:Dictionary = {}
var stepmania_list:Dictionary = {}

@onready var folders:PackedStringArray = DirAccess.open("res://assets/songs").get_directories()

func _ready():
	for i in folders.size():
		load_song(i)
	#WorkerThreadPool.add_group_task(load_song, folders.size()) this was causing some issues. not a big priority bc the loading is already fast.
	wait_txt.queue_free()

func load_song(index:int):
	var folder:String = folders[index]
	var meta_path = "res://assets/songs/%s/meta.tres" % folder
	if not ResourceLoader.exists(meta_path): return
	var meta:SongMeta = load(meta_path)
	song_diffs[folder] = meta.difficulties

	var funny_button = OptionButton.new()
	funny_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	funny_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	funny_button.item_selected.connect(select_song)
	
	var popup = funny_button.get_popup()
	
	popup.visibility_changed.connect(func():
		cur_song = folder
		
		for track in tracks.get_children():
			track.queue_free()
			
		if popup.visible:
			for track in Chart.get_tracks(folder):
				tracks.add_child(track)
				track.volume_db = linear_to_db(0.25)
				track.play()
	)
	
	popup.add_radio_check_item(meta.display_name)
	popup.set_item_disabled(0, true)
	popup.set_item_as_separator(0, true)
	
	for diff in meta.difficulties:
		add_diff(popup, folder, diff)
	
	funny_button.selected = 0
	container.call_deferred("add_child", funny_button)

func add_diff(popup:PopupMenu, song:String, diff:String):
	if diff == "<STEPMANIA>":
		stepmania_list[song] = SmParser.parse_sm("res://assets/songs/%s/%s.sm" % [song, song], "<ALL>")
		
		var new_popup = PopupMenu.new()
		for key in stepmania_list[song].keys():
			var data = stepmania_list[song][key].extra_data
			new_popup.add_radio_check_item("%s - %s (%s)" % [data["SM_Steps"], data["SM_DiffType"], data["SM_DiffRating"]])
		new_popup.name = "stepmania"
		popup.add_child(new_popup)
		new_popup.id_pressed.connect(select_sm)
		
		popup.add_submenu_item("Stepmania Diffs", "stepmania")
	else:
		popup.add_radio_check_item(diff)

func select_sm(id:int):
	get_tree().paused = false
	Gameplay.chart = stepmania_list[cur_song][stepmania_list[cur_song].keys()[id]]
	Gameplay.song_folder = cur_song
	get_tree().change_scene_to_file("res://scenes/game/Gameplay.tscn")

func select_song(id:int):
	get_tree().paused = false
	Gameplay.chart = Chart.parse_chart(cur_song, song_diffs[cur_song][id - 1])
	Gameplay.song_folder = cur_song
	get_tree().change_scene_to_file("res://scenes/game/Gameplay.tscn")
