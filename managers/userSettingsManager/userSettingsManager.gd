extends Node

const FIO = preload("res://managers/userSettingsManager/utils/userSettingsManager_json_fio_handling.gd")
var fio = FIO.new()

# user settings
# user:// under Linux/MacOS: ~/.local/share/godot/app_userdata/Name, Windows: %APPDATA%/Name
const USER_SETTINGS_FILEPATH : String = "user://the-cevennes-express_user-settings_honest-jam-6.json"
const FALLBACK_USER_SETTINGS_FILEPATH : String = "res://managers/userSettingsManager/the-cevennes-express_user-settings_honest-jam-6_default.json"

var userSettings : Dictionary = {}

func _update():
	self.save_user_settings() # to make sure no settings get lost

	if userSettings["fullscreen"]:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)

func initialize_user_settings() -> void:
	# checking if user settings file already exists
	var file = File.new()
	
	if not file.file_exists(self.USER_SETTINGS_FILEPATH):
		print("User settings file @ ", self.USER_SETTINGS_FILEPATH, " does NOT already exist. Copying defaults from ", self.FALLBACK_USER_SETTINGS_FILEPATH, ".")
		var _default_data = fio.load_json(self.FALLBACK_USER_SETTINGS_FILEPATH)
		fio.save_json(self.USER_SETTINGS_FILEPATH, _default_data)
	else:
		print("User settings file @ ", self.USER_SETTINGS_FILEPATH, " does already exist.")

	file.close()
	
	# loading user settings file
	self.userSettings = fio.load_json(self.USER_SETTINGS_FILEPATH)

	self._update()

	
	
func save_user_settings() -> void:
	fio.save_json(self.USER_SETTINGS_FILEPATH, self.userSettings)


func update_user_settings(settingKeychain, setterType, settingValue) -> Dictionary:
	var _returnSignal : Dictionary = {}

	# determine the depth in the dictionary to set the value
	if len(settingKeychain) == 1:
		userSettings[settingKeychain[0]] = settingValue
	elif len(settingKeychain) == 2:
		userSettings[settingKeychain[0]][settingKeychain[1]] = settingValue
	elif len(settingKeychain) == 3:
		userSettings[settingKeychain[0]][settingKeychain[1]][settingKeychain[2]] = settingValue
	elif len(settingKeychain) == 4:
		userSettings[settingKeychain[0]][settingKeychain[1]][settingKeychain[2]][settingKeychain[3]] = settingValue

	if settingKeychain[0] == "volume": # if volume setting changed
		var _tmp_settingKeychain = []
		for entry in settingKeychain:
			if entry != "volume":
				_tmp_settingKeychain.append(entry)
		
		_returnSignal = {"keyChain": _tmp_settingKeychain, "value": settingValue}
	
	print(_returnSignal)
	
	self._update()

	return _returnSignal

func get_user_settings() -> Dictionary:
	return self.userSettings
