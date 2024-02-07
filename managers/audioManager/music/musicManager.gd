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
#### PUBLIC MEMBER VARIABLES ###################################################
################################################################################
var permission_to_play : bool = false
var playing_mode : String = "none"
var playlist : Dictionary = {}
var song_requests : Array = []

var predefined_playlists : Dictionary = {}

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _songs : Dictionary = {}

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func request_song(song : String, loop : bool = false) -> void:
	song_requests.append({"title": song, "loop": loop})

func _play_first_song_of_playlist() -> void:
	var _song_to_play = self.playlist["songs"][0] # select the first song from the playlist
	self.playlist["last"] = 0
	get_node(self._songs[_song_to_play]["nodePath"]).play()

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_music_playlist_updated() -> void:
	var _currently_playing_checksum = 0

	# if allowed to play music
	if self.permission_to_play:
		# check whether something is currently playing:
		for _song in self._songs.keys():
			if get_node(self._songs[_song]["nodePath"]).is_playing():
				_currently_playing_checksum += 1

		if _currently_playing_checksum == 0:
			if self.playing_mode == "playlist": # if in playlist mode
				_play_first_song_of_playlist()

func _on_song_finished() -> void:
	# if allowed to play music
	if self.permission_to_play:
		if self.playing_mode == "playlist": # if in playlist mode
			if self.playlist.has("last"): # if already another song has been played from the playlist
				var _potential_next_song_index = self.playlist["last"]+1
				if _potential_next_song_index <= len(self.playlist["songs"])-1: # if the last song was not the last song in the playlist
					var song_to_play = playlist["songs"][_potential_next_song_index] # select the first song from the playlist
					self.playlist["last"] = _potential_next_song_index
					get_node(self._songs[song_to_play]["nodePath"]).play()
				else: # last played song is the last one in the playlist
					if self.playlist["loop"]:
						self._play_first_song_of_playlist()
			else: # no song of the playlist has already be played
				var _song_to_play = self.playlist["songs"][0] # select the first song from the playlist
				self.playlist["last"] = 0
				get_node(self._songs[_song_to_play]["nodePath"]).play()

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready() -> void:
	print("\t-> Load MusicManager...")
	# load all the song information from the json file
	self._songs = JsonFio.load_json("res://managers/audioManager/music/music.json")
	var _song_objects = self._songs.keys()

	for _object in _song_objects:
		var _song_subobject_key_list = self._songs[_object].keys()

		if self._songs[_object].has("fp"): # if the entry is a data entry but a true category
			var _song_object_name = _object # create the subobject name ; old: subobject + "_" +
			var _song_object_node_path = _object # create the node path
			self._songs[_object]["nodePath"] = _song_object_node_path # add the node path to the dictionary entry

			AudioManagerNodeHandling.add_and_configure_AudioStreamPlayer(self, self._songs[_object], "SELF", _song_object_name)

	# connect all finished signals of the songs to common routine
	for _song in self._songs:
		get_node(self._songs[_song]["nodePath"]).connect("finished", self, "_on_song_finished")

	# connect to the signal emitted when the playlist has been updated
	# audioManager.connect("music_playlist_updated", self, "_on_music_playlist_updated")


	

