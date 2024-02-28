
find_program(ClangFormatExecutable clang-format-14 clang-format)
find_program(ClangTidyExecutable clang-tidy-14 clang-tidy)

file(GLOB CheckingSources CONFIGURE_DEPENDS "src/*.cpp")
file(GLOB CheckingSourcesTests CONFIGURE_DEPENDS "tests/*.cpp")
file(GLOB CheckingHeaders CONFIGURE_DEPENDS "include/*.hpp" "tests/*.hpp")

if (${ClangFormatExecutable} STREQUAL "ClangFormatExecutable-NOTFOUND")
    add_custom_target(
        ClangFormat
    )
    message("clang-format not found!")
elseif (CMAKE_CROSSCOMPILING)
    add_custom_target(
        ClangFormat
    )
    message("no clang-format; cross-compiling!")
else()
    add_custom_target(
        ClangFormat
        DEPENDS ${GodotBindings}
        COMMAND ${ClangFormatExecutable} --style=file -i ${CheckingSources} ${CheckingSourcesTests} ${CheckingHeaders} --verbose
    )
    message("clang-format found!")
endif()

if (${ClangTidyExecutable} STREQUAL "ClangTidyExecutable-NOTFOUND")
    add_custom_target(
        ClangTidy
    )
    message("clang-tidy not found!")
elseif (CMAKE_CROSSCOMPILING)
    add_custom_target(
        ClangTidy
    )
    message("no clang-tidy; cross-compiling!")
else()
    add_custom_target(
        ClangTidy
        DEPENDS ${GodotBindings}
        COMMAND ${ClangTidyExecutable} --format-style=file -p ${CMAKE_BINARY_DIR} ${CheckingSources}
        # COMMAND ${ClangTidyExecutable} --fix --format-style=file -p ${CMAKE_BINARY_DIR} ${CheckingSources}
    )
    message("clang-tidy found!")
endif()
