##
# Export Variables
# - GodotHeadersPath
#   
# - GodotBuild
#   -> 'debug' or 'release'
#
# - GodotBindingsTarget
#   -> String of the fitting target that builds the Godot bindings
#
# - GodotBindingsExtention
#   -> 'lib' for builds on Windows hosts, 'a' for other hosts
##


include(FetchContent)

FetchContent_Declare(
    GodotBindingsRepo
    GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
    GIT_TAG 3.5
)

FetchContent_Populate(GodotBindingsRepo)

FetchContent_GetProperties(GodotBindingsRepo
    SOURCE_DIR GodotHeadersPath_local
    POPULATED GodotPopulated
)

set(GodotHeadersPath ${GodotHeadersPath_local})
set(GodotBuild $<$<CONFIG:Debug>:debug>$<$<CONFIG:Release>:release>)


if (WIN32)
    set(GodotBindingsTarget GodotBindingsWindows)
elseif (DEFINED EMSCRIPTEN)
    set(GodotBindingsTarget GodotBindingsJavaScript)
elseif (UNIX)
    set(GodotBindingsTarget GodotBindingsLinux)
else()
    set(GodotBindingsTarget UnsupportedOS)
endif ()


if (${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
    set(GodotBindingsExtention "lib")
else ()
    set(GodotBindingsExtention "a")
endif ()

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.windows.debug.64.${GodotBindingsExtention}
    COMMAND scons platform=windows generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)
add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.windows.release.64.${GodotBindingsExtention}
    COMMAND scons platform=windows generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsWindows
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.windows.debug.64.${GodotBindingsExtention}
    ${GodotHeadersPath}/bin/libgodot-cpp.windows.release.64.${GodotBindingsExtention}
)


add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.linux.debug.64.${GodotBindingsExtention}
    COMMAND scons platform=linux generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.linux.release.64.${GodotBindingsExtention}
    COMMAND scons platform=linux generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsLinux
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.linux.debug.64.${GodotBindingsExtention}
    ${GodotHeadersPath}/bin/libgodot-cpp.linux.release.64.${GodotBindingsExtention}
)


add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.javascript.debug.wasm.${GodotBindingsExtention}
    COMMAND scons platform=javascript generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.javascript.release.wasm.${GodotBindingsExtention}
    COMMAND scons platform=javascript generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsJavaScript
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.javascript.debug.wasm.${GodotBindingsExtention}
    ${GodotHeadersPath}/bin/libgodot-cpp.javascript.release.wasm.${GodotBindingsExtention}
)
