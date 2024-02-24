cmake_minimum_required(VERSION 3.18)

project(CevennaExpress_cpp)

include(cmake/GodotBindings.cmake)
include(cmake/GDNativeLibrary.cmake)
include(cmake/ClangToolbox.cmake)


set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


AddGDNativeLibrary(testGDNative src/GodotTestClass.cpp)
