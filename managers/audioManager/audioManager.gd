extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "audioManager".
# The scene and this script require the following other scenes/scripts to be 
# autoloaded in the following order before this scene can be autoloaded:
# "JsonFio": res://utils/fileHandling/json_fio.gd
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# "AudioManagerNodeHandling": res://managers/audioManager/utils/audioManager_node-handling.gd
# "sfxManager": res://managers/audioManager/sfx/sfxManager.tscn
# "musicManager": res://managers/audioManager/music/musicManager.tscn

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal music_playlist_updated

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _audio_bus_aliases : Dictionary = {
	"master":  "Master",
	"sfx": {
		"ui":  "UI SFX",
		"ambience":  "Ambience SFX",
		"game": "Game SFX"
	},
	"music":  "Music"
}

var _playing_allowed : bool = true

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func initialize_volume_levels(_userSettings : Dictionary) -> void:
	var userSettingsVolume = _userSettings["volume"]
	
	var _volumesToInitialize : Array = []
	var _keys = userSettingsVolume.keys()

	for _key in _keys:
		var _element = userSettingsVolume[_key]
		var _tmp_array_entry : Dictionary = {"keychain": [], "value": 0}
		
		_tmp_array_entry["keychain"].append(_key)

		if _element is Dictionary:
			var _subkeys = _element.keys()
			var _subkeyIndex = 0

			for _subkey in _subkeys:
				var _subelement = _element[_subkey]

				if _subelement is Dictionary:
					pass
				else:
					var _tmp_tmp_array_entry = _tmp_array_entry.duplicate(true)
					_tmp_tmp_array_entry["keychain"].append(_subkey)
					_tmp_tmp_array_entry["value"] = _subelement
					_volumesToInitialize.append(_tmp_tmp_array_entry)
		else:
			_tmp_array_entry["value"] = _element
			_volumesToInitialize.append(_tmp_array_entry)

	# print("Master Volume before: ", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

	for _element in _volumesToInitialize:
		self.set_volume_level(_element["keychain"], _element["value"])

	# print("Master Volume after: ", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func set_volume_level(settingKeychain : Array, settingValue : float) -> void:
	var _audio_bus_name = DictionaryParsing.get_dict_element_via_keychain(self._audio_bus_aliases,settingKeychain)
	var _db = linear2db(settingValue/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(_audio_bus_name), _db)

func enable_request_processing() -> void:
	self._playing_allowed = true

func disable_request_processing() -> void:
	self._playing_allowed = false

func play_sfx(keyChain : Array) -> void:
	if self._playing_allowed:
		sfxManager.play_sound(keyChain)
	
func play_music_by_song_name(song : String) -> void:
	if self._playing_allowed:
		musicManager.request_song(song)
	
func set_playlist(_playlist : Dictionary, loop : bool = false, start_playback : bool = true) -> void:
	if self._playing_allowed:
		musicManager.playlist = {"songs": _playlist, "loop": loop}
		musicManager.playing_mode = "playlist"
		musicManager.permission_to_play = start_playback
		emit_signal("music_playlist_updated")

func set_predefined_playlist(playlistId : String, _start_playback : bool = true) -> void:
	var _tmp_playlist_dict = musicManager.predefined_playlists[playlistId]
	var _tmp_playlist = _tmp_playlist_dict["songs"]
	self.set_playlist(_tmp_playlist, _tmp_playlist_dict["loop"], _start_playback)

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	print("\t-> Load AudioManager...")
	self.connect("music_playlist_updated", musicManager, "_on_music_playlist_updated") # required, since musicManager is loaded as singleton BEFORE audioManager

