class_name Assets extends Object

static var cur_folders:Array[String] = []

static func get_asset_path(path:String):
	for folder in cur_folders:
		if FileAccess.file_exists(folder + "/" + path):
			return folder + "/" + path

	return "res://" + path
	
static func get_text(path:String):
	if not file_exists(path):
		printerr("File \"%s\" does not exist!" % path)
		return ""
		
	return FileAccess.get_file_as_string(get_asset_path(path))
	
static func get_sound(da_path:String):
	if not file_exists(da_path):
		printerr("File \"%s\" does not exist!" % da_path)
		return AudioStream.new()
		
	var path = get_asset_path(da_path)
	if path.begins_with("res://"):
		return load(path)
		
	match path.get_extension():
		"ogg":
			return AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			var stream = AudioStreamMP3.new()
			stream.data = FileAccess.get_file_as_bytes(path)
			return stream
		_:
			printerr("Sound extension \"%s\" is invalid!" % path.get_extension())
			return AudioStream.new()
	
static func file_exists(path:String):
	for folder in cur_folders:
		if FileAccess.file_exists(folder + "/" + path):
			return true

	return FileAccess.file_exists("res://" + path) or FileAccess.file_exists("res://" + path + ".import")
	
static func dir_exists(path:String):
	for folder in cur_folders:
		if DirAccess.dir_exists_absolute(folder + "/" + path):
			return true

	return DirAccess.dir_exists_absolute("res://" + path)
	
static func get_files_at(path:String, all_folders:bool = true):
	var files = []
	
	for folder in cur_folders:
		if DirAccess.dir_exists_absolute(folder + "/" + path):
			files.append_array(DirAccess.get_files_at(folder + "/" + path))
			if not all_folders: return files

	if DirAccess.dir_exists_absolute("res://" + path):
		files.append_array(DirAccess.get_files_at("res://" + path))
	return files
	
static func get_directories_at(path:String, all_folders:bool = true):
	var dirs = []
	
	for folder in cur_folders:
		if DirAccess.dir_exists_absolute(folder + "/" + path):
			dirs.append_array(DirAccess.get_directories_at(folder + "/" + path))
			if not all_folders: return dirs

	if DirAccess.dir_exists_absolute("res://" + path):
		dirs.append_array(DirAccess.get_directories_at("res://" + path))
	return dirs
