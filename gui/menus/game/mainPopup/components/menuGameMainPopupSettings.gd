tool

extends TCEMixedCluster

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
				"disabled": false,
				"default": true,
				"default_value": 5,
				"min": 0,
				"max": 100,
				"step": 1
			},
			{
				"description": "Ambience",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ambience",
				"disabled": true,
				"default": false,
				"default_value": 25,
				"min": 0,
				"max": 100,
				"step": 1
			},
			{
				"description": "Game SFX",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "game",
				"disabled": false,
				"default": false,
				"default_value": 50,
				"min": 0,
				"max": 100,
				"step": 1
			},
			{
				"description": "Music",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "music",
				"disabled": true,
				"default": false,
				"default_value": 75,
				"min": 0,
				"max": 100,
				"step": 1
			},
			{
				"description": "MASTER",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "master",
				"disabled": false,
				"default": false,
				"default_value": 100,
				"min": 0,
				"max": 100,
				"step": 1
			}
		] # UI SFX, Ambience, Game SFX, Music, Master
	},
	{
		"heading": "Visual",
		"members": [
			{
				"description": "Visual Test",
				"type": "TCEHSlider",
				"tce_event_uuid_suffix": "audio" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "volume" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "sfx" + UserInputManager.TCE_EVENT_UUID_SEPERATOR + "ui",
				"disabled": false,
				"default": true,
				"default_value": 5,
				"min": 0,
				"max": 100,
				"step": 1
			}
		]
	}
]

const SLIDER_RESOURCE : Resource = preload("res://gui/components/slider/tce_hslider.tscn")

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _lastType : String = ""
var _objectNeighbourReference : Array = []

################################################################################
#### ONREADY MEMBER VARIABLES ##################################################
################################################################################
onready var _clusterContainer : GridContainer = $MarginContainer/CenterContainer/GridContainer
onready var _headingReferences : Array = [$MarginContainer/CenterContainer/GridContainer/settingsTitleLabel]

################################################################################
#### PARENT CLASS PUBLIC MEMBER FUNCTION OVERRIDES #############################
################################################################################
func set_focus_to_default() -> void:
	if _objectNeighbourReference != []:
		_objectNeighbourReference[0].grab_focus()

################################################################################
#### PRIVATE MEMBER FUNCTIONS ##################################################
################################################################################
func _update_cluster_width(value : int) -> void:
	self._cluster.rect_min_size.x = value

func _initialize() -> void:
	self.initialize_ui_cluster_parameters("test", self._clusterContainer)
	print(self._cluster.get_path())

	var _tmp_cluster_of_categories : Array = []
	for _h in self.SETTINGS_ELEMENTS_CLUSTER.size():
		var _category = self.SETTINGS_ELEMENTS_CLUSTER[_h]
		self._lastType = ""
		print(_category["heading"])
		var _tmp_cluster_of_clusters : Array = []
		var _tmp_helper : Dictionary = {}
		if _category.has("members"):
			if len(_category["members"]) != 0:
				for _i in _category["members"].size():
					var _element : Dictionary = _category["members"][_i]
					if _element["type"] != self._lastType:
						if len(_tmp_helper) != 0:
							_tmp_cluster_of_clusters.append(_tmp_helper)
							_tmp_helper = {}
						else:
							self._lastType = _element["type"]
							_tmp_helper = {self._lastType : [{"category": _h, "element": _i}]}
					else:
						if _tmp_helper != {}:
							if _tmp_helper.has(self._lastType):
								_tmp_helper[self._lastType].append({"category": _h, "element": _i})
						else:
							_tmp_helper = {self._lastType : [{"category": _h, "element": _i}]}

					if _i == len(_category["members"])-1:
						if len(_tmp_helper) != 0:
							_tmp_cluster_of_clusters.append(_tmp_helper)
							_tmp_helper = {}

		print(_tmp_cluster_of_clusters)
		_tmp_cluster_of_categories.append(_tmp_cluster_of_clusters)

	# print(_tmp_cluster_of_categories)

	for  _i in range(len(_tmp_cluster_of_categories)):
		var _category = _tmp_cluster_of_categories[_i]

		var _marginContainer : MarginContainer = MarginContainer.new()
		self._clusterContainer.add_child(_marginContainer)
		var _gridContainer : GridContainer = GridContainer.new()
		_marginContainer.add_child(_gridContainer)

		var _title = Label.new()
		_title.text = self.SETTINGS_ELEMENTS_CLUSTER[_i]["heading"]
		_title.align = Label.ALIGN_LEFT
		_title.size_flags_horizontal = SIZE_EXPAND_FILL
		_title.add_font_override("font", preload("res://themes/fonts/lmodern_bold_48px.tres")) # not working
		_gridContainer.add_child(_title)

		self._create_spacer(_gridContainer)

		if _category != []:
			for _element in _category:
				for _key in _element.keys():
					match _key:
						"TCEHSlider":
							var _tmp_sliderData : Array = []

							for _entry in _element[_key]:
								_tmp_sliderData.append(self.SETTINGS_ELEMENTS_CLUSTER[_entry["category"]]["members"][_entry["element"]])

							# print(_tmp_sliderData)
							var _tmp_sliderCluster = TCEHSliderCluster.new()
							_tmp_sliderCluster.disable_container_cleaning()

							_tmp_sliderCluster.initialize_slider_cluster("test", _gridContainer, _tmp_sliderData)
							_tmp_sliderCluster.update_size()

							# REMARK: Currently hardcoded, as all progamatical approaches have failed so far
							# FUTURE: Make it progamatic
							self._update_cluster_width(650)

							self._objectNeighbourReference += _tmp_sliderCluster.get_focus_reference()

		self._create_spacer(_gridContainer)
		self._create_spacer(_gridContainer)

	self.set_focus_neighbours(self._objectNeighbourReference)
	self.set_focus_to_default()

	self.update_size()

	# print(self._objectNeighbourReference)

	# for element in self._objectNeighbourReference:
	# 	print(element, "\n\tTop: ", element.focus_neighbour_top,"\n\tBottom: ", element.focus_neighbour_bottom,"\n\tNext: ", element.focus_next, "\n\tPrevious:", element.focus_previous, "\n")

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	# only for testing purposes
	self._initialize()

	if Engine.editor_hint:
		self._initialize()
