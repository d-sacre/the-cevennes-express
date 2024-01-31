extends Control

################################################################################
#### CUSTOM SIGNAL DEFINITIONS #################################################
################################################################################
signal gui_mouse_context(context, status)

onready var actionItemList : Object = $PanelContainer/CenterContainer/actionItemList

################################################################################
#### SIGNAL HANDLING ###########################################################
################################################################################
func _on_mouse_entered():
	emit_signal("gui_mouse_context", "actionSelector", "entered")
	print("entered")

func _on_mouse_exited():
	emit_signal("gui_mouse_context", "actionSelector", "exited")

################################################################################
#### GODOT RUNTIME FUNCTION OVERRIDES ##########################################
################################################################################
func _ready():
	# REMARK: only until all functions are implemented
    # set all not implemented to disabled
    for i in range(1,5):
        actionItemList.set_item_selectable (i, false)

    actionItemList.select(0,true)

    actionItemList.connect("mouse_entered", self, "_on_mouse_entered")
    actionItemList.connect("mouse_exited", self, "_on_mouse_exited")
