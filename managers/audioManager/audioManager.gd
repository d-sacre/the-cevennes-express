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
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var audio_bus_aliases : Dictionary = {
	"master":  "Master",
	"sfx": {
		"ui":  "UI SFX",
		"ambience":  "Ambience SFX",
		"game": "Game SFX"
	},
	"music":  "Music"
}

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func play_sfx(keyChain) -> void:
	sfxManager.play_sound(keyChain)
	
func play_music_by_song_name(song) -> void:
	musicManager.request_song(song)
	
func set_playlist(_playlist, loop = false, start_playback = true) -> void:
	musicManager.playlist = {"songs": _playlist, "loop": loop}
	musicManager.playing_mode = "playlist"
	musicManager.permission_to_play = start_playback
	emit_signal("music_playlist_updated")

func set_predefined_playlist(playlistId, _start_playback = true) -> void:
	var _tmp_playlist_dict = musicManager.predefined_playlists[playlistId]
	var _tmp_playlist = _tmp_playlist_dict["songs"]
	set_playlist(_tmp_playlist, _tmp_playlist_dict["loop"], _start_playback)

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_set_audio_volume(settingKeychain, settingValue) -> void:
	var audio_bus_name = DictionaryParsing.get_dict_element_via_keychain(audio_bus_aliases,settingKeychain)
	var db = linear2db(settingValue/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), db)

	print("Set volume")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	self.connect("music_playlist_updated", musicManager, "_on_music_playlist_updated") # required, since musicManager is loaded as singleton BEFORE audioManager

