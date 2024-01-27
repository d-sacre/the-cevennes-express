tool
extends Node

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# The scene this script is attached to is autoloaded as "musicManager".
# The scene and this script require the following other scenes/scripts to be 
# autoloaded in the following order before this scene can be autoloaded:
# "JsonFio": res://utils/fileHandling/json_fio.gd
# "DictionaryParsing": res://utils/dataHandling/dictionaryParsing.gd
# "AudioManagerNodeHandling": res://managers/audioManager/utils/audioManager_node-handling.gd
# "musicManager": res://managers/audioManager/music/musicManager.tscn

################################################################################
#### VARIABLE DEFINITIONS ######################################################
################################################################################
var permission_to_play : bool = false
var playing_mode : String = "none"
var playlist : Dictionary = {}
var song_requests : Array = []


var songs : Dictionary = {}

var predefined_playlists : Dictionary = {}

################################################################################
#### FUNCTION DEFINITIONS ######################################################
################################################################################
func request_song(song, loop = false) -> void:
	song_requests.append({"title": song, "loop": loop})

func _play_first_song_of_playlist() -> void:
	var song_to_play = playlist["songs"][0] # select the first song from the playlist
	playlist["last"] = 0
	get_node(songs[song_to_play]["nodePath"]).play()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_music_playlist_updated() -> void:
	var currently_playing_checksum = 0

	# if allowed to play music
	if permission_to_play:
		# check whether something is currently playing:
		for song in songs.keys():
			if get_node(songs[song]["nodePath"]).is_playing():
				currently_playing_checksum += 1

		if currently_playing_checksum == 0:
			if playing_mode == "playlist": # if in playlist mode
				_play_first_song_of_playlist()

func _on_song_finished() -> void:
	# if allowed to play music
	if permission_to_play:
		if playing_mode == "playlist": # if in playlist mode
			if playlist.has("last"): # if already another song has been played from the playlist
				var _potential_next_song_index = playlist["last"]+1
				if _potential_next_song_index <= len(playlist["songs"])-1: # if the last song was not the last song in the playlist
					var song_to_play = playlist["songs"][_potential_next_song_index] # select the first song from the playlist
					playlist["last"] = _potential_next_song_index
					get_node(songs[song_to_play]["nodePath"]).play()
				else: # last played song is the last one in the playlist
					if playlist["loop"]:
						_play_first_song_of_playlist()
			else: # no song of the playlist has already be played
				var song_to_play = playlist["songs"][0] # select the first song from the playlist
				playlist["last"] = 0
				get_node(songs[song_to_play]["nodePath"]).play()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	print("\t-> Initialize MusicManager...")
	# load all the song information from the json file
	songs = JsonFio.load_json("res://managers/audioManager/music/music.json")
	var song_objects = songs.keys()

	for object in song_objects:
		var song_subobject_key_list = songs[object].keys()

		if songs[object].has("fp"): # if the entry is a data entry but a true category
			var song_object_name = object # create the subobject name ; old: subobject + "_" +
			var song_object_node_path = object # create the node path
			songs[object]["nodePath"] = song_object_node_path # add the node path to the dictionary entry

			self.nodeutils.add_and_configure_AudioStreamPlayer(self,songs[object], "SELF", song_object_name)

	# connect all finished signals of the songs to common routine
	for song in songs:
		get_node(songs[song]["nodePath"]).connect("finished", self, "_on_song_finished")

	# connect to the signal emitted when the playlist has been updated
	# audioManager.connect("music_playlist_updated", self, "_on_music_playlist_updated")


	

