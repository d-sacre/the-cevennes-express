function (AddGDNativeLibrary name)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        add_library(${name} SHARED ${ARGN})
        # add_dependencies(${name} GodotBindingsWindows)
        add_dependencies(${name} ClangFormat ClangTidy)

        target_compile_options(${name} PUBLIC /W4 /WX)

        set_target_properties(${name} PROPERTIES SUFFIX ".dll")

        target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.windows.${GodotBuild}.64.lib)

    elseif (DEFINED EMSCRIPTEN)
        add_executable(${name} ${ARGN})
        # add_dependencies(${name} GodotBindingsJavaScript)

        set_target_properties(${name} PROPERTIES SUFFIX ".wasm")

        set_target_properties(${name} PROPERTIES COMPILE_FLAGS "-O3 -s SIDE_MODULE=1")
	    set_target_properties(${name} PROPERTIES LINK_FLAGS    "-O3 -s WASM=1 -s SIDE_MODULE=1 -s STANDALONE_WASM --no-entry")

        target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.javascript.${GodotBuild}.wasm.a)
        
    else ()
        add_library(${name} SHARED ${ARGN})
        
        add_dependencies(${name} ClangFormat)
        
        target_compile_options(${name} PUBLIC -Wall -Wextra -Wpedantic -Werror)
        
        if (WIN32)
            # add_dependencies(${name} GodotBindingsWindows)
            set_target_properties(${name} PROPERTIES SUFFIX ".dll")
            target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.windows.${GodotBuild}.64.${GodotBindingsExtention})
        else ()
            # add_dependencies(${name} GodotBindingsLinux)
            set_target_properties(${name} PROPERTIES SUFFIX ".so")
            target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.linux.${GodotBuild}.64.${GodotBindingsExtention})
        endif()
        
    endif ()
    add_dependencies(${name} ${GodotBindingsTarget})

    set_target_properties(${name} PROPERTIES PREFIX "")
    set_target_properties(${name} PROPERTIES OUTPUT_NAME "${name}_${GodotBuild}")
    
    target_include_directories(${name} PRIVATE
        ${PROJECT_SOURCE_DIR}/include
        ${GodotHeadersPath}/include
        ${GodotHeadersPath}/include/core
        ${GodotHeadersPath}/include/gen
        ${GodotHeadersPath}/godot-headers
    )

    add_custom_target(${name}_clang-tidy
        DEPENDS ${name} ClangTidy
    )

endfunction()