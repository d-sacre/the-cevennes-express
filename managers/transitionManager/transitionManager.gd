extends Node

################################################################################
################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
################################################################################
# The scene this script is attached to is autoloaded as "TransitionManager".   #
################################################################################

################################################################################
################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
################################################################################
var _persistentStorage : Dictionary = {}

################################################################################
################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
################################################################################
onready var animationPlayer = $AnimationPlayer
onready var transitionEffects = $transitionEffects
onready var fadeBlack = $transitionEffects/fadeBlack

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
	# DESCRIPTION: Make sure that transition effects arre visible
	self.transitionEffects.visible = true
	get_tree().paused = true

	# DESCRIPTION: Play animation and wait until it is finished before exiting 
	# the game
	self.animationPlayer.play("fadeToBlack")
	yield(self.animationPlayer, "animation_finished")

	get_tree().quit()

################################################################################
################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
################################################################################
func _ready() -> void:
	# DESCRIPTION: Ensure that even when game is paused the transition will be 
	# processed. Make also sure that the mouse is passed through and the Canvas
	# Layer is by default hidden
	self.pause_mode = Node.PAUSE_MODE_PROCESS 
	self.fadeBlack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.transitionEffects.visible = false
