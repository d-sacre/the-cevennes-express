tool

extends TCEClusterSettings

# extends TCEClusterMixed

# ################################################################################
# #### AUTOLOAD REMARKS ##########################################################
# ################################################################################
# # This script expects the following autoloads:
# # "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# # "NodeHandling": res://utils/nodeHandling/nodeHandling.gd

# ################################################################################
# #### CONSTANT DEFINITIONS ######################################################
# ################################################################################

# const SETTINGS_ELEMENTS_CLUSTER : Array = [
# 	{
# 		"heading": "Audio",
# 		"members": [
# 			{
# 				"description": "UI SFX",
# 				"type": "TCEHSlider",
# 				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ui",
# 				"keychain": ["volume", "sfx", "ui"],
# 				"disabled": false,
# 				"default": true,
# 				"min": 0.0,
# 				"max": 100.0,
# 				"step": 1.0
# 			},
# 			{
# 				"description": "Ambience",
# 				"type": "TCEHSlider",
# 				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ambience",
# 				"keychain": ["volume", "sfx", "ambience"],
# 				"disabled": true,
# 				"default": false,
# 				"min": 0.0,
# 				"max": 100.0,
# 				"step": 1.0
# 			},
# 			{
# 				"description": "Game SFX",
# 				"type": "TCEHSlider",
# 				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "game",
# 				"keychain": ["volume", "sfx", "game"],
# 				"disabled": false,
# 				"default": false,
# 				"min": 0.0,
# 				"max": 100.0,
# 				"step": 1.0
# 			},
# 			{
# 				"description": "Music",
# 				"type": "TCEHSlider",
# 				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "music",
# 				"keychain": ["volume", "music"],
# 				"disabled": true,
# 				"default": false,
# 				"min": 0.0,
# 				"max": 100,
# 				"step": 1.0
# 			},
# 			{
# 				"description": "MASTER",
# 				"type": "TCEHSlider",
# 				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "master",
# 				"keychain": ["volume", "master"],
# 				"disabled": false,
# 				"default": false,
# 				"min": 0.0,
# 				"max": 100.0,
# 				"step": 1.0
# 			}
# 		] # UI SFX, Ambience, Game SFX, Music, Master
# 	},
# 	{
# 		"heading": "Visual",
# 		"members": [
# 			{
# 				"description": "Fullscreen",
# 				"type": "TCEButtonToggle",
# 				"tce_event_uuid_suffix": "visual" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "fullscreen",
# 				"keychain": ["visual", "fullscreen"],
# 				"disabled": false,
# 				"default": false
# 			}
# 		]
# 	}
# ]

# var _clusterHeight : int = 0

# ################################################################################
# #### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
# ################################################################################
# func set_focus_to_default() -> void:
# 	if _focusReferences != []:
# 		self._defaultObject = _focusReferences[0]

# 	.set_focus_to_default()

# ################################################################################
# #### PUBLIC MEMBER FUNCTIONS ###################################################
# ################################################################################
# func set_to_default_values() -> void:
# 	for _type in ["TCEHSlider", "TCEButtonToggle"]:
# 		self._set_all_nodes_of_type_to_default(_type)

# func get_cluster_height() -> int:
# 	return self._clusterHeight

# func initialize(context : String) -> void:
# 	var _tmp_context = context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "settings"

# 	self._clusterEntries = self.SETTINGS_ELEMENTS_CLUSTER
# 	self._initialize(_tmp_context, $CenterContainer/GridContainer)
# 	self.set_to_default_values()
# 	self.update_size()

# 	var _elements : Array = self._cluster.get_children()

# 	for _child in _elements:
# 		self._clusterHeight += _child.rect_size.y

	 

