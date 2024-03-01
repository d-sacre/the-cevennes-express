FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.14.0
)

FetchContent_MakeAvailable(googletest)

add_library(GTest::GTest INTERFACE IMPORTED)
target_link_libraries(GTest::GTest INTERFACE gtest_main)

set (GTestHeaderPath googletest_SOURCE_DIR)
    
enable_testing()

function (AddTest name)
    if (DEFINED EMSCRIPTEN)
    else ()
        add_executable(${name} ${ARGN})
        
        target_include_directories(${name} PRIVATE
            ${CMAKE_SOURCE_DIR}/include
            ${CMAKE_SOURCE_DIR}/tests
            ${GTestHeaderPath}
        )

        target_compile_options(${name} PUBLIC ${CompileFlags})

        target_link_libraries( ${name}
        PRIVATE
            GTest::GTest
        )

        add_test(NAME ${name} COMMAND ${name})
    endif ()
endfunction()
