tool

extends TCEMixedCluster

################################################################################
#### AUTOLOAD REMARKS ##########################################################
################################################################################
# This script expects the following autoloads:
# "UserInputManager": res://managers/userInputManager/userInputManager.tscn
# "NodeHandling": res://utils/nodeHandling/nodeHandling.gd

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################

const SETTINGS_ELEMENTS_CLUSTER : Array = [
	{
		"heading": "Audio",
		"members": [
			{
				"description": "UI SFX",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ui",
				"keychain": ["volume", "sfx", "ui"],
				"disabled": false,
				"default": true,
				"min": 0.0,
				"max": 100.0,
				"step": 1.0
			},
			{
				"description": "Ambience",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ambience",
				"keychain": ["volume", "sfx", "ambience"],
				"disabled": true,
				"default": false,
				"min": 0.0,
				"max": 100.0,
				"step": 1.0
			},
			{
				"description": "Game SFX",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "game",
				"keychain": ["volume", "sfx", "game"],
				"disabled": false,
				"default": false,
				"min": 0.0,
				"max": 100.0,
				"step": 1.0
			},
			{
				"description": "Music",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "music",
				"keychain": ["volume", "music"],
				"disabled": true,
				"default": false,
				"min": 0.0,
				"max": 100,
				"step": 1.0
			},
			{
				"description": "MASTER",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "master",
				"keychain": ["volume", "master"],
				"disabled": false,
				"default": false,
				"min": 0.0,
				"max": 100.0,
				"step": 1.0
			}
		] # UI SFX, Ambience, Game SFX, Music, Master
	},
	{
		"heading": "Visual",
		"members": [
			{
				"description": "Fullscreen",
				"type": "TCEButtonToggle",
				"tce_event_uuid_suffix": "visual" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "fullscreen",
				"keychain": ["visual", "fullscreen"],
				"disabled": false,
				"default": false
			}
		]
	}
]

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
func set_focus_to_default() -> void:
	if _focusReferences != []:
		_focusReferences[0].grab_focus()

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _initialize(context : String, cluster : Object) -> void:
	self.initialize_ui_cluster_parameters(context, cluster)

	var _tmp_categoryCluster : Array = self._parse_elements_into_categories()
	self._focusReferences = self._process_categories(_tmp_categoryCluster)
	
	self.set_focus_neighbours(self._focusReferences)
	self.set_focus_to_default()

	# print(self._focusReferences)

	# for element in self._focusReferences:
	# 	print(element, "\n\tTop: ", element.focus_neighbour_top,"\n\tBottom: ", element.focus_neighbour_bottom,"\n\tNext: ", element.focus_next, "\n\tPrevious:", element.focus_previous, "\n")

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func set_to_default_values() -> void:
	var _hsliderReferences : Array = []
	NodeHandling.find_all_hslider_nodes(self, _hsliderReferences)

	for _hslider in _hsliderReferences:
		var _grandParent : Object = _hslider.get_parent().get_parent()
		if _grandParent.has_method("set_slider_to_default_value"):
			_grandParent.set_slider_to_default_value()

	# TO-DO: Do the same for TCEButtonToggle, TCEButtonOption

func initialize(context : String) -> void:
	var _tmp_context = context + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "settings"

	self._clusterEntries = self.SETTINGS_ELEMENTS_CLUSTER
	self._initialize(_tmp_context, $CenterContainer/GridContainer)
	self.set_to_default_values()

