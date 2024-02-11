function (AddGDNativeLibrary name)

    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        add_library(${name} SHARED ${ARGN})
        add_dependencies(${name} GodotBindingsWindows)

        target_compile_options(${name} PUBLIC /W4 /WX)

        set_target_properties(${name} PROPERTIES PREFIX "")
        set_target_properties(${name} PROPERTIES OUTPUT_NAME "${name}_${GodotBuild}")
        set_target_properties(${name} PROPERTIES SUFFIX ".dll")

        target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.windows.${GodotBuild}.64.lib)

    elseif (DEFINED EMSCRIPTEN)
        add_executable(${name} ${ARGN})
        add_dependencies(${name} GodotBindingsJavaScript)

        set_target_properties(${name} PROPERTIES PREFIX "")
        set_target_properties(${name} PROPERTIES OUTPUT_NAME "${name}_${GodotBuild}")
        set_target_properties(${name} PROPERTIES SUFFIX ".wasm")

        set_target_properties(${name} PROPERTIES COMPILE_FLAGS "-O3 -s SIDE_MODULE=1")
	    set_target_properties(${name} PROPERTIES LINK_FLAGS    "-O3 -s WASM=1 -s SIDE_MODULE=1 -s STANDALONE_WASM --no-entry")

        target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.javascript.${GodotBuild}.wasm.a)

    else ()
        add_library(${name} SHARED ${ARGN})
        
        target_compile_options(${name} PUBLIC -fPIC -O3 -Wall -Wextra -Wpedantic -Werror)
        
        set_target_properties(${name} PROPERTIES PREFIX "")
        set_target_properties(${name} PROPERTIES OUTPUT_NAME "${name}_${GodotBuild}")
        
        if (WIN32)
            add_dependencies(${name} GodotBindingsWindows)
            set_target_properties(${name} PROPERTIES SUFFIX ".dll")
            target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.windows.${GodotBuild}.64.lib)
        else ()
            add_dependencies(${name} GodotBindingsLinux)
            set_target_properties(${name} PROPERTIES SUFFIX ".so")
            target_link_libraries(${name} PRIVATE ${GodotHeadersPath}/bin/libgodot-cpp.linux.${GodotBuild}.64.a)
        endif()

    endif ()

endfunction()