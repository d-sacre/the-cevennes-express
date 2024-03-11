extends Node

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# The scene this script is attached to is autoloaded as "TransitionManager".   #
################################################################################

################################################################################
#### IMPORTANT REMARKS #########################################################
################################################################################
# Scene change with loading screen adapted from 
# https://docs.godotengine.org/en/3.5/tutorials/io/background_loading.html

################################################################################
################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
################################################################################
signal transition_finished

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _persistentStorage : Dictionary = {}

# DESCRIPTION: Variables required for loading screen
var _loader
var _waitFrames
var _timeMax = 100 # msec
var _currentScene 

################################################################################
################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
################################################################################
onready var animationPlayer : AnimationPlayer = $AnimationPlayer

onready var transitionEffects : CanvasLayer = $transitionEffects
onready var fadeBlack : Control = $transitionEffects/fadeBlack

onready var loadingScreen : CanvasLayer = $loadingScreen
onready var progressBar : ProgressBar = $loadingScreen/CenterContainer/VBoxContainer/ProgressBar

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _update_progress() -> void:
	var _progress = float(self._loader.get_stage()) / self._loader.get_stage_count()

	self.progressBar.value = _progress * 100

func _set_new_scene(sceneResource) -> void:
	self._currentScene = sceneResource.instance()
	get_node("/root").add_child(self._currentScene)
	emit_signal("transition_finished")

func _fade_to_black(paused : bool = true) -> void:
	# DESCRIPTION: Make sure that transition effects arre visible
	self.transitionEffects.visible = true
	get_tree().paused = true

	# DESCRIPTION: Play animation and wait until it is finished before emitting signal
	# that transition is finished
	self.animationPlayer.play("fadeToBlack")
	yield(self.animationPlayer, "animation_finished")
	get_tree().paused = paused
	emit_signal("transition_finished")

func _fade_from_black(paused : bool = true) -> void:
	# DESCRIPTION: Make sure that transition effects arre visible
	self.transitionEffects.visible = true
	get_tree().paused = true

	# DESCRIPTION: Play animation and wait until it is finished before emitting signal
	# that transition is finished
	self.animationPlayer.play("fadeFromBlack")
	yield(self.animationPlayer, "animation_finished")
	get_tree().paused = paused
	emit_signal("transition_finished")

func _fade_loading_screen(reverse : bool = false, paused : bool = true) -> void:
	var _method : String = "play"

	if reverse:
		_method = "play_backwards"

	get_tree().paused = true

	self.loadingScreen.visible = true
	self.animationPlayer.call(_method, "fadeLoadingScreen")
	yield(self.animationPlayer, "animation_finished")

	get_tree().paused = paused

	emit_signal("transition_finished")


################################################################################
################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
################################################################################

################################################################################
#### PUBLIC MEMBER FUNCTIONS: SETTER AND GETTER ################################
################################################################################
func set_persistent_storage(dict : Dictionary) -> void:
	self._persistentStorage = dict

func get_persistent_storage() -> Dictionary:
	return self._persistentStorage

################################################################################
#### PUBLIC MEMBER FUNCTIONS: TRANSITIONS ######################################
################################################################################
func exit_to_system() -> void:
	self._fade_to_black()
	yield(self, "transition_finished")

	get_tree().quit()

func goto_scene(path : String): # Game requests to switch to this scene.
	self._loader = ResourceLoader.load_interactive(path)
	if self._loader == null: # Check for errors.
		# show_error()
		return
	self.set_process(true)

	self._currentScene.queue_free() # Get rid of the old scene.

	# Start your "loading..." animation.
	self.progressBar.value = 0

	self._waitFrames = 1

func transition_to_scene(path : String) -> void:
	self.progressBar.value = 0
	self._fade_loading_screen()
	yield(self, "transition_finished")

	self.goto_scene(path)
	yield(self, "transition_finished")
	yield(get_tree().create_timer(2.5), "timeout")
	self._fade_loading_screen(true, false)
	yield(self, "transition_finished")

	self.loadingScreen.visible = false

func transition_to_game() -> void:
	self.transition_to_scene("res://Main.tscn")

func transition_to_main_menu() -> void:
	self.transition_to_scene("res://gui/menus/main/mainMenu.tscn")

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _ready() -> void:
	# DESCRIPTION: Set up loading scene transition
	var root = get_tree().get_root()
	_currentScene = root.get_child(root.get_child_count() -1)

	# DESCRIPTION: Ensure that even when game is paused the transition will be 
	# processed. Make also sure that the mouse is passed through and the Canvas
	# Layer is by default hidden
	self.pause_mode = Node.PAUSE_MODE_PROCESS 
	self.fadeBlack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$loadingScreen/loadingBg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.transitionEffects.visible = false
	self.loadingScreen.visible = false

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _process(_delta) -> void:
	if self._loader == null:
		# no need to process anymore
		self.set_process(false)
		return

	# Wait for frames to let the "loading" animation show up.
	if self._waitFrames > 0:
		self._waitFrames -= 1
		return

	var t = OS.get_ticks_msec()
	# Use "_timeMax" to control for how long we block this thread.
	while OS.get_ticks_msec() < t + self._timeMax:
		# Poll your _loader.
		var _err = _loader.poll()

		if _err == ERR_FILE_EOF: # Finished loading.
			var resource = self._loader.get_resource()
			self._loader = null
			self._set_new_scene(resource)
			break

		elif _err == OK:
			self._update_progress()

		else: # Error during loading.
			# show_error()
			self._loader = null
			break
