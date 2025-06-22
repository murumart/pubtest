const SAVE_PATH := "user://pubtest/colony/"
const FILENAME := "save"

enum Keys {

}


static func gets(k: Keys, default: Variant = null) -> Variant:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	if not FileAccess.file_exists(SAVE_PATH + FILENAME):
		return default
	var fa := FileAccess.open(SAVE_PATH + FILENAME, FileAccess.READ)
	var dict: Dictionary = fa.get_var()
	return dict.get(k, default)


static func sets(k: Keys, val: Variant) -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
	var fa := FileAccess.open(SAVE_PATH + FILENAME, FileAccess.READ)
	var dict: Dictionary = fa.get_var()
	fa.close()
	dict[k] = val
	fa = FileAccess.open(SAVE_PATH + FILENAME, FileAccess.WRITE)
	fa.store_var(fa)
