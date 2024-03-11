extends TextureProgress

# Source: https://www.bytesnsprites.com/posts/2022/spinner-progress-bar-in-godot/
func create_and_activate_spin_animation() -> void:
	var tween: SceneTreeTween = get_tree().create_tween().set_loops()
	tween.tween_property(self, "radial_initial_angle", 360.0, 1.5).as_relative()

func _ready() -> void:
	self.create_and_activate_spin_animation()
