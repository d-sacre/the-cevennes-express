extends PanelContainer

onready var _buttonCluster : Object = $buttonClusterRoot

func _on_user_input_manager_global_command(tce_event_uuid : String, _value) -> void:
	var _tmp_eventKeychain : Array = ["*", "UserInputManager", "requesting", "global", "execution", "toggle", "menu", "ingame", "root"]

	if UserInputManager.match_tce_event_uuid(tce_event_uuid, _tmp_eventKeychain):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused
		
		# DESCRIPTION: Set the correct size and viewport position
		# REMARK: Is required due to the fact that Godot can not handle the sizes of class inherited
		# objects properly and the calculations during _ready do not show any effect
		_buttonCluster.update_size()

		if self.visible:
			# REMARK: Has to be fine tuned, so that e.g. music would not stop
			audioManager.disable_request_processing()
			_buttonCluster.set_focus_to_default()
			audioManager.enable_request_processing()

func _ready():
	_buttonCluster.initialize(get_tree().get_root().get_node("Main").context)
	_buttonCluster.visible = true
	self.visible = false
	
	UserInputManager.connect("transmit_global_event", self, "_on_user_input_manager_global_command")

	# DESCRIPTION: Set AudioManager/sfxManager pause mode, so that sounds play in the ingame menu
	audioManager.pause_mode = PAUSE_MODE_PROCESS
	sfxManager.pause_mode = PAUSE_MODE_PROCESS
	musicManager.pause_mode = PAUSE_MODE_PROCESS



