#include "GodotTestClass.hpp"

void GodotTestClass::_init() {}

// NOLINTNEXTLINE(readability-convert-member-functions-to-static)
void GodotTestClass::Print(const godot::String& str)
{
	std::cout << str.utf8().get_data() << "\n";
}

// NOLINTNEXTLINE(readability-convert-member-functions-to-static)
void GodotTestClass::PrintGodot(const godot::String& str)
{
	godot::Godot::print(str);
}

// NOLINTNEXTLINE(readability-convert-member-functions-to-static)
int32_t GodotTestClass::Double(int32_t toDouble)
{
	return toDouble * 2;
}

// NOLINTNEXTLINE(readability-convert-member-functions-to-static)
float GodotTestClass::Add(float first, float second)
{
	return first + second;
}

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options * options)
{
	godot::Godot::gdnative_init(options);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options * options)
{
	godot::Godot::gdnative_terminate(options);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void * handle)
{
	godot::Godot::nativescript_init(handle);

	godot::register_class<GodotTestClass>();
}
