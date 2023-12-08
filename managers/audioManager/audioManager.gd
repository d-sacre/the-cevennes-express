extends Node

signal music_playlist_updated

var DICTUTILS = load("res://managers/audioManager/utils/audioManager_dict_utils.gd")
var dictutils = DICTUTILS.new()

var audio_bus_aliases : Dictionary = {
	"master":  "Master",
	"sfx": {
		"ui":  "UI SFX",
		"ambience":  "Ambience SFX",
		"game": "Game SFX"
	},
	"music":  "Music"
}

onready var musicManager : Node = $musicManager
onready var sfxManager : Node = $sfxManager

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

func _on_set_audio_volume(settingKeychain, settingValue) -> void:
	var audio_bus_name = dictutils.get_dict_element_via_keychain(audio_bus_aliases,settingKeychain)
	var db = linear2db(settingValue/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), db)

func _ready():
	var _root = get_node("../")
	_root.connect("set_audio_volume", self, "_on_set_audio_volume")

