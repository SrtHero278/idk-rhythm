extends Panel

@onready var tracks = $Tracks
@onready var wait_txt = $WaitingLabel
@onready var container = $Container

var cur_song:String
var song_diffs:Dictionary = {}

func _ready():
	var thread = Thread.new()
	thread.start(load_songs)

func load_songs():
	for folder in DirAccess.open("res://assets/songs").get_directories():
		var meta_path = "res://assets/songs/%s/meta.tres" % folder
		if not ResourceLoader.exists(meta_path): continue
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
			popup.add_radio_check_item(diff)
		
		funny_button.selected = 0
		container.call_deferred("add_child", funny_button)
	wait_txt.queue_free()
	return true;

func select_song(id:int):
	get_tree().paused = false
	Gameplay.chart = Chart.parse_chart(cur_song, song_diffs[cur_song][id - 1])
	Gameplay.song_folder = cur_song
	get_tree().change_scene_to_file("res://scenes/game/Gameplay.tscn")
