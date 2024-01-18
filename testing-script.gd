#!/usr/bin/env -S godot -s
extends SceneTree



func _init():
    print("Loading C++ Backend")
    var cppBridge = load("res://utils/cppBridge.gd").new()
    cppBridge.initialize_cpp_bridge(10,10)
    cppBridge.initialize_grid_in_cpp_backend(0)
    #cppBridge.CreateGame(10, 10, 0)
    print("Hello!")
    cppBridge.free() # to prevent memory leakage; also relevant for game? Or only in testing script
    quit(7) # optional argument for return code
