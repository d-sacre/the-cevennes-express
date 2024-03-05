extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "userSettingsManager".
# The scene and this script require the following other scenes/scripts to be 
# autoloaded in the following order before this scene can be autoloaded:
# "JsonFio": res://utils/fileHandling/json_fio.gd

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
# user settings
# user:// under Linux/MacOS: ~/.local/share/godot/app_userdata/Name, Windows: %APPDATA%/Name
const USER_SETTINGS_FILEPATH : String = "user://the-cevennes-express_user-settings_honest-jam-6.json"
const FALLBACK_USER_SETTINGS_FILEPATH : String = "res://managers/userSettingsManager/the-cevennes-express_user-settings_honest-jam-6_default.json"

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _userSettings : Dictionary = {}

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _update() -> void:
	self.save_user_settings() # to make sure no settings get lost

	if _userSettings["fullscreen"]:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_user_settings() -> void:
	# checking if user settings file already exists
	var file = File.new()
	print("\t-> Load UserSettingsManager...")
	if not file.file_exists(self.USER_SETTINGS_FILEPATH):
		print("\t\t-> User Settings File @ ", self.USER_SETTINGS_FILEPATH, " does NOT already exist. Copying defaults from ", self.FALLBACK_USER_SETTINGS_FILEPATH, ".")
		var _default_data = JsonFio.load_json(self.FALLBACK_USER_SETTINGS_FILEPATH)
		JsonFio.save_json(self.USER_SETTINGS_FILEPATH, _default_data)
	else:
		print("\t\t-> User Settings File @ ", self.USER_SETTINGS_FILEPATH, " does already exist.")

	file.close()
	
	# loading user settings file
	self._userSettings = JsonFio.load_json(self.USER_SETTINGS_FILEPATH)
	print("\t\t-> Loading User Settings from File @ ", self.USER_SETTINGS_FILEPATH,"...")

	self._update()

	
func save_user_settings() -> void:
	JsonFio.save_json(self.USER_SETTINGS_FILEPATH, self._userSettings)


func update_user_settings(keyChain : Array, setterType, value) -> Dictionary:
	var _audioLevelChange : Dictionary = {}

	# determine the depth in the dictionary to set the value
	if len(keyChain) == 1:
		_userSettings[keyChain[0]] = value
	elif len(keyChain) == 2:
		_userSettings[keyChain[0]][keyChain[1]] = value
	elif len(keyChain) == 3:
		_userSettings[keyChain[0]][keyChain[1]][keyChain[2]] = value
	elif len(keyChain) == 4:
		_userSettings[keyChain[0]][keyChain[1]][keyChain[2]][keyChain[3]] = value

	if keyChain[0] == "volume": # if volume setting changed
		var _tmp_keyChain = []
		for entry in keyChain:
			if entry != "volume":
				_tmp_keyChain.append(entry)
		
		_audioLevelChange = {"keyChain": _tmp_keyChain, "value": value}
	
	self._update()

	return _audioLevelChange

func get_user_settings() -> Dictionary:
	return self._userSettings

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
# Currently not working for main menu, but would be for in-game popup menu
func _on_user_settings_changed(keyChain : Array, setterType, value) -> void:
	var _audioManagerRequest : Dictionary = userSettingsManager.update_user_settings(keyChain, setterType, value)
	
	# DESCRIPTION: If the audio manager request is not empty (that means an audio 
	# volume level has to be changed), pass the result to the AudioManager
	if _audioManagerRequest.has("keyChain"):
		audioManager.set_volume_level(_audioManagerRequest["keyChain"], _audioManagerRequest["value"])
	


