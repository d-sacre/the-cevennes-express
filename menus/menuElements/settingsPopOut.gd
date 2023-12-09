extends PanelContainer

signal user_settings_changed(settingKeychain, setterType, settingValue)

var UTILS = load("res://menus/menuElements/dict_utils.gd")
var utils = UTILS.new()

onready var slider_reference : Dictionary = {
	"volume": {
		"sfx": {
			"ui": $VBoxContainer2/audioSubmenu_vboxContainer/uiSFXHBox/volume_uiSFX_slider,
			"ambience": $VBoxContainer2/audioSubmenu_vboxContainer/ambienceSFXHBox/volume_ambienceSFX_slider,
			"game": $VBoxContainer2/audioSubmenu_vboxContainer/gameSFXHBox/volume_gameSFX_slider
		},
		"music": $VBoxContainer2/audioSubmenu_vboxContainer/musicHBox/volume_music_slider,
		"master": $VBoxContainer2/audioSubmenu_vboxContainer/masterHBox/volume_master_slider
	}
}

onready var button_reference : Dictionary = {
	"fullscreen": {"reference": $VBoxContainer2/visualSubmenu_vboxContainer/fullscreen_toggle, "type": "toggle"}
}

func slider_initialize(user_settings) -> void:
	for category in slider_reference:
		var _object = slider_reference[category]
		if _object is Dictionary:
			for subcategory in _object:
				var _subobject = _object[subcategory]

				if _subobject is Dictionary:
					for subsubcategory in _subobject:
						var _subsubobject = _subobject[subsubcategory]
						var slider_keychain = [category, subcategory, subsubcategory]
						_subsubobject.value = utils.get_dict_element_via_keychain(user_settings,slider_keychain)
				else:
					var slider_keychain = [category, subcategory]
					_subobject.value = utils.get_dict_element_via_keychain(user_settings,slider_keychain)
		else:
			var slider_keychain = [category]
			_object.value = utils.get_dict_element_via_keychain(user_settings,slider_keychain)

func button_initialize(user_settings) -> void:
	for category in button_reference:
		var _object = button_reference[category]
		var _button 
		var _button_type = "default"

		if _object is Dictionary:
			if _object.has("reference"):
				_button = _object["reference"]
				_button_type = _object["type"]

				if _button_type == "toggle":
					print(user_settings[category])
					if user_settings[category] == false:
						_button.pressed = false
					elif user_settings[category] == true:
						_button.pressed = true
			else:
				pass
				# to implement if more nested buttons will be added
		

func _on_slider_value_changed_volume_sfx_ui(value) -> void:
	emit_signal("user_settings_changed", ["volume", "sfx", "ui"] ,"slider", value)

func _on_slider_value_changed_volume_sfx_ambience(value) -> void:
	emit_signal("user_settings_changed", ["volume", "sfx", "ambience"] ,"slider", value)
	
func _on_slider_value_changed_volume_sfx_game(value) -> void:
	emit_signal("user_settings_changed", ["volume", "sfx", "game"] ,"slider", value)
	
func _on_slider_value_changed_volume_music(value) -> void:
	emit_signal("user_settings_changed", ["volume", "music"] ,"slider", value)
	
func _on_slider_value_changed_volume_master(value) -> void:
	emit_signal("user_settings_changed", ["volume", "master"] ,"slider", value)

func connect_to_slider_value_changed_signal(sliderRef, _slider_function_id) -> void:
	sliderRef.connect("value_changed", self, "_on_slider_value_changed_" + _slider_function_id)

func connect_to_button_value_changed_signal(buttonRef, _button_function_id, buttonType) -> void:
	if buttonType != "toggle":
		buttonRef.connect("pressed", self, "_on_button_value_changed_" + _button_function_id)
	else:
		buttonRef.connect("toggled", self, "_on_button_value_changed_" + _button_function_id)

func _on_button_value_changed_fullscreen(value) -> void:
	emit_signal("user_settings_changed", ["fullscreen"] ,"toggle", value)

func _ready():
	# connect to all the slider signals
	for category in slider_reference:
		var _object = slider_reference[category]
		if _object is Dictionary:
			for subcategory in _object:
				var slider_function_id_subcategory = "_" + subcategory
				var _subobject = _object[subcategory]
				
				if _subobject is Dictionary:
					for subsubcategory in _subobject:
						var _subsubobject = _subobject[subsubcategory]
						var slider_function_id = category + "_" + subcategory + "_" + subsubcategory
						connect_to_slider_value_changed_signal(_subsubobject, slider_function_id)
				else:
					var slider_function_id = category + "_" + subcategory 
					connect_to_slider_value_changed_signal(_subobject, slider_function_id)
		else:
			var slider_function_id = category
			connect_to_slider_value_changed_signal(_object, slider_function_id)

	# connect to all the button signals
	# FUTURE: Could be implemented in a function
	for category in button_reference:
		var _object = button_reference[category]
		if _object is Dictionary:
			if _object.has("reference"):
				var button_function_id = category
				var buttonType = _object["type"]
				var buttonRef = _object["reference"]
				connect_to_button_value_changed_signal(buttonRef, button_function_id, buttonType)
			else:
				# deeper nesting not implemented yet!
				pass
				# for subcategory in _object:
				# 	var button_function_id_subcategory = "_" + subcategory
				# 	var _subobject = _object[subcategory]
					
				# 	if _subobject is Dictionary:
				# 		for subsubcategory in _subobject:
				# 			var _subsubobject = _subobject[subsubcategory]
				# 			var button_function_id = category + "_" + subcategory + "_" + subsubcategory
				# 			connect_to_button_value_changed_signal(_subsubobject, button_function_id, buttonType)
				# 	else:
				# 		var button_function_id = category + "_" + subcategory 
				# 		connect_to_button_value_changed_signal(_subobject, button_function_id, buttonType)
		else:
			pass
			
