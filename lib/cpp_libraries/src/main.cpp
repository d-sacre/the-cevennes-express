#include <iostream>


#ifdef _MSC_VER
    # pragma warning( disable : 4201)
#elif defined(__GNUC__)
    # pragma GCC diagnostic push
    # pragma GCC diagnostic ignored "-Wpedantic"
    # pragma GCC diagnostic ignored "-Wparentheses"
#else
    // #error "unsupported compiler"
#endif

#include <Godot.hpp>
#include <Reference.hpp>

#ifdef _MSC_VER
    # pragma warning( default : 4201)
#elif defined(__GNUC__)
    # pragma GCC diagnostic pop
#else
    // #error "unsupported compiler"
#endif


class Wrapper
    : public godot::Reference
{
    GODOT_CLASS(Wrapper, godot::Reference)
public:
    void _init(){}
    static void _register_methods()
    {
        register_method("test", &Wrapper::test);
    }
    void test([[maybe_unused]] int32_t a)
    {
        std::cout << "test function\n";
        godot::Godot::print("test Error!");
    }
private:
};

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o)
{
    godot::Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o)
{
    godot::Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle)
{
    godot::Godot::nativescript_init(handle);

    godot::register_class<Wrapper>();
}
