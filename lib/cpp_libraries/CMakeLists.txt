cmake_minimum_required(VERSION 3.14)

project(CevennaExpress_cpp)

include(cmake/GodotBindings.cmake)
include(cmake/GDNativeLibrary.cmake)


set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

set(CMAKE_CXX_STANDARD 17)


AddGDNativeLibrary(testGDNative src/main.cpp)
