class_name FileTexture extends ImageTexture

## NOTE: THIS DOES NOT START WITH "res://"
@export var file_path:String:
	get: return file_path
	set(new_path):
		file_path = new_path
		load_from_file(new_path)

static func load(path:String):
	var tex = FileTexture.new()
	tex.load_from_file(path)
	return tex

func load_from_file(path:String):
	if not Assets.file_exists(path):
		printerr("File \"%s\" does not exist!" % path)
		return
		
	var da_path:String = Assets.get_asset_path(path)
	var img:Image = Image.load_from_file(da_path) if da_path.begins_with("user://") else load(da_path)
	set_image(img)
