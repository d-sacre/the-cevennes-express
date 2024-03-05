tool

extends TCEHSlider

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _ready():
	# DESCRIPTION: Internal Signal Handling
	self._error = self.connect("mouse_entered", self, "_on_mouse_entered")
	self._error = self.connect("focus_entered", self, "_on_focus_entered")
