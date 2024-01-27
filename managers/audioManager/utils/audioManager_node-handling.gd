extends Node

func add_and_configure_AudioStreamPlayer(context, dict, parent, name):
	var _parent_ref
	
	if parent == "SELF":
		_parent_ref = context
	else:
		_parent_ref = context.get_node(parent)
	
	if _parent_ref.has_node(name): # if AudioStreamPlayer has already been created previously
		# do nothing 
		pass
	else: # if AudioStreamPlayer does not exist
		# source: https://ask.godotengine.org/15486/create-nodes-in-the-editor-from-script
		var _audioplayerCreator = AudioStreamPlayer.new()
		_audioplayerCreator.name = name # set the node name
		_parent_ref.add_child(_audioplayerCreator) # add it to the parent

		var _tmp_root_ref
		if parent == "SELF":
			_tmp_root_ref = context.get_parent()
		else:
			_tmp_root_ref = context.get_parent().get_parent()

		_audioplayerCreator.set_owner(_tmp_root_ref.get_tree().get_edited_scene_root()) # make sure that it also displays in the editor

	# set or update the settings of the audio player
	var _audioplayer = _parent_ref.get_node(name)
	var _stream = load(dict["fp"])
	_audioplayer.set_stream(_stream)
	_audioplayer.volume_db = dict["volume_db"]
	_audioplayer.set_bus(dict["bus"])

func add_category_node(context, parent, name):
	var _parent_ref 
	if parent == "SELF":
		_parent_ref = context
	else:
		_parent_ref = context.get_node(parent)
		
	var _tmp_node = Node.new()
	_tmp_node.name = name
	_parent_ref.add_child(_tmp_node)
	var _tmp_root_ref = context#.get_parent()#.get_parent()
	# print("tmp_root: ", _tmp_root_ref)
	_tmp_node.set_owner(_tmp_root_ref.get_tree().get_edited_scene_root())
