tool
extends TCEButton

# Called when the node enters the scene tree for the first time.
func _ready():
	# DESCRIPTION: Internal Signal Handling
	self._error = self.connect("mouse_entered", self, "_on_mouse_entered")
	self._error = self.connect("focus_entered", self, "_on_focus_entered")
	self._error = self.connect("focus_exited", self, "_on_focus_exited")
	self._error = self.connect("pressed", self, "_on_button_pressed")




