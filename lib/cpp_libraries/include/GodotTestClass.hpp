#include "GodotIncludes.hpp"

#include <iostream>

class GodotTestClass : public godot::Reference
{
	// NOLINTBEGIN
	GODOT_CLASS(GodotTestClass, godot::Reference)
	// NOLINTEND

  public:
	void _init();

	// NOLINTNEXTLINE(readability-identifier-naming)
	static void _register_methods()
	{
		godot::register_method("Print", &GodotTestClass::Print);
		godot::register_method("PrintGodot", &GodotTestClass::PrintGodot);
		godot::register_method("Double", &GodotTestClass::Double);
		godot::register_method("Add", &GodotTestClass::Add);
	}

	void	Print(godot::String str);
	void	PrintGodot(godot::String str);
	int32_t Double(int32_t toDouble);
	float	Add(float first, float second);
};
