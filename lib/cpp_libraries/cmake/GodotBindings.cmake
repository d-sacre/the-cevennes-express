
include(FetchContent)

FetchContent_Declare(
    GodotBindings
    GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
    GIT_TAG 3.5
)

# if (NOT EXISTS ${PROJECT_SOURCE_DIR}/deps)
#     make_directory(${PROJECT_SOURCE_DIR}/deps)
# endif()

# set(GodotHeadersPath ${PROJECT_SOURCE_DIR}/deps)

# FetchContent_Populate(GodotBindings
#     SOURCE_DIR ${GodotHeadersPath}
#     GIT_REPOSITORY https://github.com/godotengine/godot-cpp.git
#     GIT_TAG 3.5
# )

FetchContent_Populate(GodotBindings)

FetchContent_GetProperties(GodotBindings
    SOURCE_DIR GodotHeadersPath
    POPULATED GodotPopulated
)

set(GodotBuild $<$<CONFIG:Debug>:debug>$<$<CONFIG:Release>:release>)

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.windows.debug.64.lib
    COMMAND scons platform=windows generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)
add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.windows.release.64.lib
    COMMAND scons platform=windows generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsWindows
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.windows.debug.64.lib
    ${GodotHeadersPath}/bin/libgodot-cpp.windows.release.64.lib
)


add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.linux.debug.64.a
    COMMAND scons platform=linux generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.linux.release.64.a
    COMMAND scons platform=linux generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsLinux
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.linux.debug.64.a
    ${GodotHeadersPath}/bin/libgodot-cpp.linux.release.64.a
)


add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.javascript.debug.wasm.a
    COMMAND scons platform=javascript generate_bindings=yes target=debug
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_command(
    OUTPUT ${GodotHeadersPath}/bin/libgodot-cpp.javascript.release.wasm.a
    COMMAND scons platform=javascript generate_bindings=yes target=release
    WORKING_DIRECTORY ${GodotHeadersPath}
)

add_custom_target(GodotBindingsJavaScript
    DEPENDS
    ${GodotHeadersPath}/bin/libgodot-cpp.javascript.debug.wasm.a
    ${GodotHeadersPath}/bin/libgodot-cpp.javascript.release.wasm.a
)


include_directories(
    ${GodotHeadersPath}/include
    ${GodotHeadersPath}/include/core
    ${GodotHeadersPath}/include/gen
    ${GodotHeadersPath}/godot-headers
)
