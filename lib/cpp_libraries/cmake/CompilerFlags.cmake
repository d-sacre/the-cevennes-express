

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CompileFlags /W4 /WX)
elseif (DEFINED EMSCRIPTEN)
    set(CompileFlags "-O3 -sWASM=1 -s SIDE_MODULE=1")
else ()
    set(CompileFlags -Wall -Wextra -Wpedantic -Werror -Wswitch-enum)
endif()