#ifdef _MSC_VER
	#pragma warning(disable : 4201)
	#pragma warning(disable : 4172)
#elif defined(__GNUC__)
	#pragma GCC diagnostic push
	#pragma GCC diagnostic ignored "-Wpedantic"
	#pragma GCC diagnostic ignored "-Wparentheses"
	#if defined(__clang__)
		#pragma GCC diagnostic ignored "-Wreturn-stack-address"
	#else
		#pragma GCC diagnostic ignored "-Wreturn-local-addr"
	#endif
#else
	#error "unsupported compiler"
#endif

#include <Godot.hpp>
#include <Reference.hpp>

#ifdef _MSC_VER
	#pragma warning(default : 4201)
	#pragma warning(default : 4172)
#elif defined(__GNUC__)
	#pragma GCC diagnostic pop
#else
	#error "unsupported compiler"
#endif